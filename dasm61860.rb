#! /usr/bin/env ruby

module Type
  IMP = 0
  IMM = 1
  ABS = 2
  RELP = 3
  RELM = 4
  SPE = 5
  UND = 6
end

OPCODES1 = [
  # 0x0*
  [Type::IMM, 'LII'],
  [Type::IMM, 'LIJ'],
  [Type::IMM, 'LIA'],
  [Type::IMM, 'LIB'],
  [Type::IMP, 'IX'],
  [Type::IMP, 'DX'],
  [Type::IMP, 'IY'],
  [Type::IMP, 'DY'],
  [Type::IMP, 'MVW'],
  [Type::IMP, 'EXW'],
  [Type::IMP, 'MVB'],
  [Type::IMP, 'EXB'],
  [Type::IMP, 'ADN'],
  [Type::IMP, 'SBN'],
  [Type::IMP, 'ADW'],
  [Type::IMP, 'SBW'],

  # 0x1*
  [Type::ABS, 'LIDP'],
  [Type::IMM, 'LIDL'],
  [Type::IMM, 'LIP'],
  [Type::IMM, 'LIQ'],
  [Type::IMP, 'ADB'],
  [Type::IMP, 'SBB'],
  [Type::UND, ''],
  [Type::UND, ''],
  [Type::IMP, 'MVWD'],
  [Type::IMP, 'EXWD'],
  [Type::IMP, 'MVBD'],
  [Type::IMP, 'EXBD'],
  [Type::IMP, 'SRW'],
  [Type::IMP, 'SLW'],
  [Type::IMP, 'FILM'],
  [Type::IMP, 'FILD'],

  # 0x2*
  [Type::IMP, 'LDP'],
  [Type::IMP, 'LDQ'],
  [Type::IMP, 'LDR'],
  [Type::IMP, '(CLRA)'],
  [Type::IMP, 'IXL'],
  [Type::IMP, 'DXL'],
  [Type::IMP, 'IYS'],
  [Type::IMP, 'DYS'],
  [Type::RELP, 'JRNZP'],
  [Type::RELM, 'JRNZM'],
  [Type::RELP, 'JRNCP'],
  [Type::RELM, 'JRNCM'],
  [Type::RELP, 'JRP'],
  [Type::RELM, 'JRM'],
  [Type::UND, ''],
  [Type::RELM, 'LOOP'],

  # 0x3*
  [Type::IMP, 'STP'],
  [Type::IMP, 'STQ'],
  [Type::IMP, 'STR'],
  [Type::UND, ''],
  [Type::IMP, 'PUSH'],
  [Type::IMP, 'DATA'],
  [Type::UND, ''],
  [Type::IMP, 'RTN'],
  [Type::RELP, 'JRZP'],
  [Type::RELM, 'JRZM'],
  [Type::RELP, 'JRCP'],
  [Type::RELM, 'JRCM'],
  [Type::UND, ''],
  [Type::UND, ''],
  [Type::UND, ''],
  [Type::UND, ''],

  # 0x4*
  [Type::IMP, 'INCI'],
  [Type::IMP, 'DECI'],
  [Type::IMP, 'INCA'],
  [Type::IMP, 'DECA'],
  [Type::IMP, 'ADM'],
  [Type::IMP, 'SBM'],
  [Type::IMP, 'ANMA'],
  [Type::IMP, 'ORMA'],
  [Type::IMP, 'INCK'],
  [Type::IMP, 'DECK'],
  [Type::IMP, 'INCM'],
  [Type::IMP, 'DECM'],
  [Type::IMP, 'INA'],
  [Type::IMP, 'NOPW'],
  [Type::IMM, 'WAIT'],
  [Type::IMP, 'CUP'],

  # 0x5*
  [Type::IMP, 'INCP'],
  [Type::IMP, 'DECP'],
  [Type::IMP, 'STD'],
  [Type::IMP, 'MVDM'],
  [Type::IMP, 'READM'],
  [Type::IMP, 'MVMD'],
  [Type::IMP, 'READ'],
  [Type::IMP, 'LDD'],
  [Type::IMP, 'SWAP'],
  [Type::IMP, 'LDM'],
  [Type::IMP, 'SL'],
  [Type::IMP, 'POP'],
  [Type::UND, ''],
  [Type::IMP, 'OUTA'],
  [Type::UND, ''],
  [Type::IMP, 'OUTF'],

  # 0x6*
  [Type::IMM, 'ANIM'],
  [Type::IMM, 'ORIM'],
  [Type::IMM, 'TSIM'],
  [Type::IMM, 'CPIM'],
  [Type::IMM, 'ANIA'],
  [Type::IMM, 'ORIA'],
  [Type::IMM, 'TSIA'],
  [Type::IMM, 'CPIA'],
  [Type::UND, ''],
  [Type::SPE, 'CASE2'],
  [Type::UND, ''],
  [Type::IMM, 'TEST'],
  [Type::UND, ''],
  [Type::UND, ''],
  [Type::UND, ''],
  [Type::IMP, 'CDN'],

  # 0x7*
  [Type::IMM, 'ADIM'],
  [Type::IMM, 'SBIM'],
  [Type::UND, ''],
  [Type::UND, ''],
  [Type::IMM, 'ADIA'],
  [Type::IMM, 'SBIA'],
  [Type::UND, ''],
  [Type::UND, ''],
  [Type::ABS, 'CALL'],
  [Type::ABS, 'JP'],
  [Type::SPE, 'CASE1'],
  [Type::UND, ''],
  [Type::ABS, 'JPNZ'],
  [Type::ABS, 'JPNC'],
  [Type::ABS, 'JPZ'],
  [Type::ABS, 'JPC']
].freeze

OPCODES2 = [
  # 0xc*
  [Type::IMP, 'INCJ'],
  [Type::IMP, 'DECJ'],
  [Type::IMP, 'INCB'],
  [Type::IMP, 'DECB'],
  [Type::IMP, 'ADCM'],
  [Type::IMP, 'SBCM'],
  [Type::IMP, '(TSMA)'],
  [Type::IMP, 'CPMA'],
  [Type::IMP, 'INCL'],
  [Type::IMP, 'DECL'],
  [Type::IMP, 'INCN'],
  [Type::IMP, 'DECN'],
  [Type::IMP, 'INB'],
  [Type::UND, ''],
  [Type::IMP, 'NOPT'],
  [Type::UND, ''],

  # 0xd*
  [Type::IMP, 'SC'],
  [Type::IMP, 'RC'],
  [Type::IMP, 'SR'],
  [Type::IMM, '(WAIT)'],
  [Type::IMM, 'ANID'],
  [Type::IMM, 'ORID'],
  [Type::IMM, 'TSID'],
  [Type::UND, ''],
  [Type::IMP, 'LEAVE'],
  [Type::UND, ''],
  [Type::IMP, 'EXAB'],
  [Type::IMP, 'EXAM'],
  [Type::UND, ''],
  [Type::IMP, 'OUTB'],
  [Type::UND, ''],
  [Type::IMP, 'OUTC']
].freeze

$cases = 0

def pass; end

def decode(mem, ptr)
  orig_ptr = ptr
  op = mem[ptr].ord
  ptr += 1
  opcode = ''
  operand = ''

  if (op & 0xc0) == 0x80
    # LP
    opcode = 'LP'
    operand = format('0x%02x', op & 0x3f)

  elsif (op & 0xe0) == 0xe0
    # CAL
    opcode = 'CAL'
    operand = format('0x%04x', ((op & 0x1f) << 8) + mem[ptr].ord)
    ptr += 1

  elsif op == 0x7a
    # CASE1
    opcode = 'CASE1'
    $cases = mem[ptr].ord
    ptr += 1
    ret = (mem[ptr].ord << 8) + mem[ptr + 1].ord
    ptr += 2
    operand = format('%d, 0x%04x', $cases, ret)

  elsif op == 0x69
    # CASE2
    opcode = 'CASE2'
    (0...$cases).each do
      operand += format('0x%02x: ', mem[ptr].ord)
      ptr += 1
      operand += format('0x%04x, ', (mem[ptr].ord << 8) + mem[ptr + 1].ord)
      ptr += 2
    end
    operand += format('default: 0x%04x', (mem[ptr].ord << 8) + mem[ptr + 1].ord)
    ptr += 2

  else
    if (op & 0x80).zero?
      opcode = OPCODES1[op][1]
      type = OPCODES1[op][0]
    else
      opcode = OPCODES2[op - 0xc0][1]
      type = OPCODES2[op - 0xc0][0]
    end

    case type
    when Type::IMM
      operand = format('0x%02x', mem[ptr].ord)
      ptr += 1

    when Type::ABS
      operand = format('0x%04x', (mem[ptr].ord << 8) + mem[ptr + 1].ord)
      ptr += 2

    when Type::RELP
      operand = format('0x%04x', ptr + mem[ptr].ord)
      ptr += 1

    when Type::RELM
      operand = format('0x%04x', ptr - mem[ptr].ord)
      ptr += 1

    when Type::IMP
      pass

    when Type::UND
      opcode = '???'
    end
  end

  print(format('%04x: ', orig_ptr))

  nb = ptr - orig_ptr
  (0...nb).each do |i|
    print(format('%02X ', mem[orig_ptr + i].ord))
  end
  # FIXME: CASE2
  print('   ' * (4 - nb)) if (4 - nb).positive?

  if operand == ''
    puts(opcode)
  else
    print("#{opcode}\t#{operand}\n")
  end
  ptr
end

def main
  mem = File.binread(ARGV[0])
  ptr = ARGV[1].to_i(16)

  while ptr < mem.size
    begin
      ptr = decode(mem, ptr)
    rescue NoMethodError
      exit
    end
  end
end

main if __FILE__ == $PROGRAM_NAME
