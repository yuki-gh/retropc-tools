# 6809 disassembler
# usage: $0 binfile org offset-to-start-in-hex

# TODO:

# utility funcs

def to_hex8(num)
  format('$%02X', num)
end

def to_hex16(num)
  format('$%04X', num)
end

def fetch8s(mem, ptr)
  disp = mem[ptr].ord
  disp -= 0x100 if disp >= 0x80
  disp
end

def fetch16(mem, ptr)
  mem[ptr].ord * 256 + mem[ptr + 1].ord
end

def fetch16s(mem, ptr)
  disp = mem[ptr].ord * 256 + mem[ptr + 1].ord
  disp -= 0x10000 if disp >= 0x8000
  disp
end

# addressing modes

def imm8(mem, ptr)
  '#' + to_hex8(mem[ptr].ord)
end

def imm16(mem, ptr)
  '#' + to_hex16(fetch16(mem, ptr))
end

def direct(mem, ptr)
  '<' + to_hex8(mem[ptr].ord)
end

def extended(mem, ptr)
  '>' + to_hex16(fetch16(mem, ptr))
end

# indexed addressing mode

def indexed(mem, ptr)
  basereg = %w[X Y U S]

  pb = mem[ptr].ord
  ptr += 1
  reg = basereg[(pb >> 5) & 3]
  operand = ''
  n = 1
  if (pb & 0x80).zero?
    # FIXME: non-indirect, 5-bit signed const
    disp = pb & 0x1f
    disp -= 0x20 if disp >= 0x10
    operand = "#{disp},#{reg}"
  else
    case pb & 0x0f
    when 0
      operand = ",#{reg}+"
    when 1
      operand = ",#{reg}++"
    when 2
      operand = ",-#{reg}"
    when 3
      operand = ",--#{reg}"
    when 4
      operand = ",#{reg}"
    when 5
      operand = "B,#{reg}"
    when 6
      operand = "A,#{reg}"
    when 8
      disp = fetch8s(mem, ptr)
      n = 2
      operand = "#{disp},#{reg}"
    when 9
      disp = fetch16s(mem, ptr)
      n = 3
      operand = "#{disp},#{reg}"
    when 11
      operand = "D,#{reg}"
    when 12
      disp = fetch8s(mem, ptr)
      n = 2
      operand = "#{disp},PCR"
    when 13
      disp = fetch16s(mem, ptr)
      n = 3
      # FIXME: signed
      operand = "#{disp},PCR"
    when 15
      disp = fetch16(mem, ptr)
      n = 3
      operand = to_hex16(disp)
    end
    operand = '[' + operand + ']' if (pb & 0x10).positive?
  end
  [operand, n]
end

def pass; end

# core

def decode(mem, org, ptr)
  ppreg = ['CC', 'A', 'B', 'DP', 'X', 'Y', 'S/U', 'PC']
  tereg = ['D', 'X', 'Y', 'U', 'S', 'PC', '?', '?', 'A', 'B', 'CC', 'DP', '?', '?', '?', '?']

  # $0x, $4x - $7x
  op1 = [
    'NEG',	# x0
    '???',
    '???',
    'COM',	# x3
    'LSR',	# x4
    '???',
    'ROR',	# x6
    'ASR',	# x7
    'ASL',	# x8
    # "LSL",	# x8
    'ROL',	# x9
    'DEC',	# xA
    '???',
    'INC',	# xC
    'TST',	# xD
    'JMP',	# xE
    'CLR'	# xF
  ]

  # $8x - $Bx
  op2a = [
    'SUBA',
    'CMPA',
    'SBCA',
    'SUBD',	# CMPD/U
    'ANDA',
    'BITA',
    'LDA',
    'STA',	# no imm

    'EORA',
    'ADCA',
    'ORA',
    'ADDA',
    'CMPX',	# CMPY/S
    'JSR',	# imm is BSR($8D)
    'LDX',	# LDY
    'STX'	# STY; no imm
  ]

  op2a_2 = [
    '???', '???', '???', 'CMPD',
    '???', '???', '???', '???',
    '???', '???', '???', '???',
    'CMPY', '???', 'LDY', 'STY'
  ]

  op2a_3 = [
    '???', '???', '???', 'CMPU',
    '???', '???', '???', '???',
    '???', '???', '???', '???',
    'CMPS', '???', '???', '???'
  ]

  # $Cx - $Fx
  op2b = [
    'SUBB',
    'CMPB',
    'SBCB',
    'ADDD',
    'ANDB',
    'BITB',
    'LDB',
    'STB',	# no imm

    'EORB',
    'ADCB',
    'ORB',
    'ADDB',
    'LDD',
    'STD',	# no imm
    'LDU',	# LDS
    'STU'	# STS; no imm
  ]

  op2b_2 = [
    '', '', '', '',
    '', '', '', '',
    '', '', '', '',
    '', '', 'LDS', 'STS'
  ]

  op2b_3 = [
    '', '', '', '',
    '', '', '', '',
    '', '', '', '',
    '', '', '', ''
  ]

  # $1x
  op1x = [
    '???',
    '???',
    'NOP',
    'SYNC',
    '???',
    '???',
    'LBRA',		# e
    'LBSR',		# e

    '???',
    'DAA',
    'ORCC',		# imm
    '???',
    'ANDCC',	# imm
    'SEX',
    'EXG',	# postbyte
    'TFR'	# postbyte
  ]

  # $3x
  op3x = [
    'LEAX',	# indexed
    'LEAY',
    'LEAS',
    'LEAU',

    'PSHS',		# postbyte
    'PULS',
    'PSHU',
    'PULU',

    '???',
    'RTS',
    'ABX',
    'RTI',

    'CWAI',		# imm
    'MUL',
    '???',
    'SWI'	# SWI2/3
  ]

  # other branches: LBRA($16), BSR($8D), LBSR($17)
  br = [
    'BRA',
    'BRN',
    'BHI',
    'BLS',

    'BCC',	# "BHS"
    'BCS',	# "BLO"
    'BNE',
    'BEQ',

    'BVC',
    'BVS',
    'BPL',
    'BMI',

    'BGE',
    'BLT',
    'BGT',
    'BLE'
  ]

  orig_ptr = ptr
  op = mem[ptr].ord
  ptr += 1
  insn = '???'
  operand = ''
  prefix = 0

  if [0x10, 0x11].include?(op)
    prefix = op
    op = mem[ptr].ord
    ptr += 1
  end

  case op
  when 0x8d
    # BSR
    insn = 'BSR'
    disp = fetch8s(mem, ptr)
    ptr += 1
    operand = to_hex16(org + ptr + disp)
  else
    high = op >> 4
    low = op & 15
    case high
    when 1
      insn = op1x[low]
      case low
      when 6, 7
        # LBRA, LBSR
        e = fetch16(mem, ptr)
        ptr += 2
        operand = to_hex16(org + ptr + e)
      when 10, 12
        # ANDCC, ORCC imm
        operand = imm8(mem, ptr)
        ptr += 1
      when 14, 15
        # EXG,TFR
        pb = mem[ptr].ord
        ptr += 1
        src = tereg[pb / 16]
        dst = tereg[pb & 15]
        operand = "#{src},#{dst}"
      end
    when 2
      insn = br[low]	# e
      if prefix == 0x10
        insn = 'L' + insn
        e = fetch16s(mem, ptr)
        ptr += 2
      else
        e = fetch8s(mem, ptr)
        ptr += 1
      end
      operand = to_hex16(org + ptr + e)
    when 3
      insn = op3x[low]
      case low
      when 0..3
        # LEA
        result = indexed(mem, ptr)
        operand = result[0]
        ptr += result[1]
      when 4..7
        # PSH/PUL
        pb = mem[ptr].ord
        ptr += 1
        regs = []
        8.times do |i|
          if pb & (1 << i) != 0
            if i != 6
              regs.push(ppreg[i])
            elsif low < 6
              regs.push('U')
            else
              regs.push('S')
            end
          end
        end
        operand = regs.join(',')
      when 12
        # CWAI imm
        operand = imm8(mem, ptr)
        ptr += 1
      when 15
        case prefix
        when 0x10
          insn << '2'
        when 0x11
          insn << '3'
        end
      end
    else
      if high < 8
        insn = op1[low]
        case high
        when 0
          # direct
          operand = direct(mem, ptr)
          ptr += 1
        when 4
          insn << 'A'
        when 5
          insn << 'B'
        when 6
          # indexed
          result = indexed(mem, ptr)
          operand = result[0]
          ptr += result[1]
        when 7
          # extended
          operand = extended(mem, ptr)
          ptr += 2
        end
      else
        insn = case prefix
               when 0x10
                 high < 12 ? op2a_2[low] : op2b_2[low]
               when 0x11
                 high < 12 ? op2a_3[low] : op2b_3[low]
               else
                 high < 12 ? op2a[low] : op2b[low]
               end

        case high & 3
        when 0
          # imm
          case low
          when 3, 12, 14
            operand = imm16(mem, ptr)
            ptr += 2
          else
            operand = imm8(mem, ptr)
            ptr += 1
          end
        when 1
          # direct
          operand = direct(mem, ptr)
          ptr += 1
        when 2
          # indexed
          result = indexed(mem, ptr)
          operand = result[0]
          n = result[1]
          ptr += n
        when 3
          # extended
          operand = extended(mem, ptr)
          ptr += 2
        end
      end
    end
  end

  print(format('%04X: ', org + orig_ptr))
  nb = ptr - orig_ptr
  (0...nb).each do |j|
    print(format('%02X ', mem[orig_ptr + j].ord))
  end
  print('   ' * (4 - nb))
  if operand == ''
    puts(insn)
  else
    print("#{insn}\t#{operand}\n")
  end
  ptr
end

def main
  mem = File.binread(ARGV[0])
  org = ARGV[1].to_i(16)
  ptr = ARGV[2].to_i(16)

  while ptr < mem.size
    begin
      ptr = decode(mem, org, ptr)
    rescue NoMethodError
      exit
    end
  end
end

main if __FILE__ == $PROGRAM_NAME
