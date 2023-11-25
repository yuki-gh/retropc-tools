# FIXME
# IX, IY, (IX+d), (IY+d)

$zilog = true
# $zilog = false

def to_hex8(num)
  format('%02XH', num)
end

def to_hex16(num)
  format('%04XH', num)
end

def fetch16(mem, ptr)
  mem[ptr].ord + mem[ptr + 1].ord * 256
end

def reladr(ptr, e)
  e -= 256 if e >= 128
  ptr + e
end

def pass; end

def decode(mem, ptr)
  if $zilog
    reg8 = ['B', 'C', 'D', 'E', 'H', 'L', '(HL)', 'A']
    reg16 = %w[BC DE HL SP]
    regp = %w[BC DE HL AF]
    op8 = ["ADD\tA,", "ADC\tA,", "SUB\t", "SBC\tA,", "AND\t", "XOR\t", "OR\t", "CP\t"]
    insn_07_3f = %w[RLCA RRCA RLA RRA DAA CPL SCF CCF]
  else
    reg8 = %w[B C D E H L M A]
    reg16 = %w[B D H SP]
    regp = %w[B D H PSW]
    op8 = %w[ADD ADC SUB SBB ANA XRA ORA CMP]
    imm8 = %w[ADI ACI SUI SBI ANI XRI ORI CPI]
    insn_07_3f = %w[RLC RRC RAL RAR DAA CMA STC CMC]
  end
  cc = %w[NZ Z NC C PO PE P M]

  # cb
  rot_shift = %w[RLC RRC RL RR SLA SRA SLL SRL]
  # ed
  blk_xfer = [
    %w[LDI CPI INI OUTI],
    %w[LDD CPD IND OUTD],
    %w[LDIR CPIR INIR OTIR],
    %w[LDDR CPDR INDR OTDR]
  ]

  # FIXME: error in ruby-lint
  opcodes_nooper = if $zilog
                     {
                       0x00 => 'NOP',
                       0x02 => "LD\t(BC),A",
                       0x08 => "EX\tAF,AF'",
                       0x0a => "LD\tA,(BC)",
                       0x12 => "LD\t(DE),A",
                       0x1a => "LD\tA,(DE)",
                       0x76 => 'HALT',
                       0xc9 => 'RET',
                       0xd9 => 'EXX',
                       0xe3 => "EX\t(SP),HL",
                       0xe9 => "JP\t(HL)",
                       0xeb => "EX\tDE,HL",
                       0xf3 => 'DI',
                       0xf9 => "LD\tSP,HL",
                       0xfb => 'EI'
                     }
                   else
                     {
                       0x00 => 'NOP',
                       0x02 => "STAX\tB",
                       0x08 => "EX\tAF,AF'",
                       0x0a => "LDAX\tB",
                       0x12 => "STAX\tD",
                       0x1a => "LDAX\tD",
                       0x76 => 'HLT',
                       0xc9 => 'RET',
                       0xd9 => 'EXX',
                       0xe3 => 'XTHL',
                       0xe9 => 'PCHL',
                       0xeb => 'XCHG',
                       0xf3 => 'DI',
                       0xf9 => 'SPHL',
                       0xfb => 'EI'
                     }
                   end

  # FIXME: error in ruby-lint
  opcodes_n = if $zilog
                {
                  # FIXME
                  0xd3 => "OUT\t(%s),A",
                  0xdb => "IN\tA,(%s)"
                }
              else
                {
                  # n
                  0xd3 => 'OUT',
                  0xdb => 'IN'
                }
              end

  opcodes_e = {
    # e
    0x10 => 'DJNZ',
    0x18 => 'JR'
  }

  # FIXME: error in ruby-lint
  opcodes_nn = if $zilog
                 {
                   # FIXME
                   0x22 => "LD\t(%s),HL",
                   0x2a => "LD\tHL,(%s)",
                   0x32 => "LD\t(%s),A",
                   0x3a => "LD\tA,(%s)",
                   0xc3 => "JP\t%s",
                   0xcd => "CALL\t%s"
                 }
               else
                 {
                   # nn
                   0x22 => 'SHLD',
                   0x2a => 'LHLD',
                   0x32 => 'STA',
                   0x3a => 'LDA',
                   0xc3 => 'JMP',
                   0xcd => 'CALL'
                 }
               end

  opcodes_ed = {
    # ed
    0x44 => 'NEG',
    0x45 => 'RETN',
    0x4d => 'RETI',
    0x67 => 'RRD',
    0x6f => 'RLD',
    0x46 => "IM\t0",
    0x56 => "IM\t1",
    0x5e => "IM\t2",
    0x47 => "LD\tI,A",
    0x4f => "LD\tR,A",
    0x57 => "LD\tA,I",
    0x5f => "LD\tA,R"
  }

  op = mem[ptr].ord
  orig_ptr = ptr
  ptr += 1
  insn = '???'

  case op
  when 0xdd
    insn = '(IX prefix)'
    flag_dd = true
  when 0xfd
    insn = '(IY prefix)'
    flag_fd = true
  when 0xcb
    op = mem[ptr].ord
    ptr += 1
    op1 = op >> 6
    op2 = op >> 3 & 7
    op3 = op & 7
    case op1
    when 0
      # rotate/shift
      insn = "#{rot_shift[op2]}\t#{reg8[op3]}"
    when 1
      insn = "BIT\t#{op2},#{reg8[op3]}"
    when 2
      insn = "RES\t#{op2},#{reg8[op3]}"
    when 3
      insn = "SET\t#{op2},#{reg8[op3]}"
    end
    if (flag_dd || flag_fd) && op3 == 6
      # FIXME: (IX+d)
      ptr += 1
      flag_fd = false
      flag_dd = false
    end
  when 0xed
    op = mem[ptr].ord
    ptr += 1
    if opcodes_ed.key?(op)
      insn = (opcodes_ed[op])
    else
      op1 = op >> 6
      op2 = op >> 3 & 7
      op3 = op & 7
      case op1
      when 1
        case op3
        when 0
          # IN
          insn = "IN\t#{reg8[op2]},(C)" if op2 != 6
        when 1
          # OUT
          insn = "OUT\t(C),#{reg8[op2]}" if op2 != 6
        when 2
          # SBC/ADC
          insn = if (op2 & 1).positive?
                   "ADC\tHL,#{reg16[op2 / 2]}"
                 else
                   "SBC\tHL,#{reg16[op2 / 2]}"
                 end
        when 3
          # SxxD/LxxD
          nn = fetch16(mem, ptr)
          ptr += 2
          insn = if (op2 & 1).positive?
                   "LD\t#{reg16[op2 / 2]},(#{to_hex16(nn)})"
                 else
                   "LD\t(#{to_hex16(nn)}),#{reg16[op2 / 2]}"
                 end
        end
      when 2
        # FIXME
        insn = (blk_xfer[op2 - 4][op3]) if op2 >= 4 && op3 < 4
      else
        pass
      end
    end
  else
    if opcodes_nooper.key?(op)
      insn = (opcodes_nooper[op])
    elsif opcodes_n.key?(op)
      n = mem[ptr].ord
      ptr += 1
      insn = if $zilog
               opcodes_n[op] % to_hex8(n)
             else
               "#{opcodes_n[op]}\t#{to_hex8(n)}"
             end
    elsif opcodes_e.key?(op)
      e = mem[ptr].ord
      ptr += 1
      adr = reladr(ptr, e)
      insn = "#{opcodes_e[op]}\t#{to_hex16(adr)}"
    elsif opcodes_nn.key?(op)
      nn = fetch16(mem, ptr)
      ptr += 2
      insn = if $zilog
               opcodes_nn[op] % to_hex16(nn)
             else
               "#{opcodes_nn[op]}\t#{to_hex16(nn)}"
             end
    else
      op1 = op >> 6
      op2 = op >> 3 & 7
      op3 = op & 7
      case op1
      when 0
        # various
        case op3
        when 0
          # NOP, JR etc.
          e = mem[ptr].ord
          ptr += 1
          adr = reladr(ptr, e)
          insn = "JR\t#{cc[op2 - 4]},#{to_hex16(adr)}"
        when 1
          if (op2 & 1).positive?
            # DAD
            insn = if $zilog
                     "ADD\tHL,#{reg16[op2 / 2]}"
                   else
                     "DAD\t#{reg16[op2 / 2]}"
                   end
          else
            # LXI
            nn = fetch16(mem, ptr)
            ptr += 2
            insn = if $zilog
                     "LD\t#{reg16[op2 / 2]},#{to_hex16(nn)}"
                   else
                     "LXI\t#{reg16[op2 / 2]},#{to_hex16(nn)}"
                   end
          end
        when 2
          # STAX, LDAX
          pass
        when 3
          # INX, DCX
          insn = if (op2 & 1).positive?
                   if $zilog
                     "DEC\t#{reg16[op2 / 2]}"
                   else
                     "DCX\t#{reg16[op2 / 2]}"
                   end
                 elsif $zilog
                   "INC\t#{reg16[op2 / 2]}"
                 else
                   "INX\t#{reg16[op2 / 2]}"
                 end
        when 4
          # INR
          insn = if $zilog
                   "INC\t#{reg8[op2]}"
                 else
                   "INR\t#{reg8[op2]}"
                 end
          if (flag_dd || flag_fd) && op2 == 6
            # FIXME: (IX+d)
            ptr += 1
            flag_fd = false
            flag_dd = false
          end
        when 5
          # DCR
          insn = if $zilog
                   "DEC\t#{reg8[op2]}"
                 else
                   "DCR\t#{reg8[op2]}"
                 end
          if (flag_dd || flag_fd) && op2 == 6
            # FIXME: (IX+d)
            ptr += 1
            flag_fd = false
            flag_dd = false
          end
        when 6
          # MVI
          n = mem[ptr].ord
          ptr += 1
          insn = if $zilog
                   "LD\t#{reg8[op2]},#{to_hex8(n)}"
                 else
                   "MVI\t#{reg8[op2]},#{to_hex8(n)}"
                 end
          if (flag_dd || flag_fd) && op2 == 6
            # FIXME: (IX+d)
            ptr += 1
            flag_fd = false
            flag_dd = false
          end
        when 7
          # various
          insn = (insn_07_3f[op2])
        end
      when 1
        # MOV
        insn = if $zilog
                 "LD\t#{reg8[op2]},#{reg8[op3]}"
               else
                 "MOV\t#{reg8[op2]},#{reg8[op3]}"
               end
        if (flag_dd || flag_fd) && (op2 == 6 || op3 == 6)
          # FIXME: (IX+d)
          ptr += 1
          flag_fd = false
          flag_dd = false
        end
      when 2
        # 8-bit arithmetic/logical
        insn = if $zilog
                 op8[op2] + reg8[op3]
               else
                 "#{op8[op2]}\t#{reg8[op3]}"
               end
        if (flag_dd || flag_fd) && op3 == 6
          # FIXME: (IX+d)
          ptr += 1
          flag_fd = false
          flag_dd = false
        end
      when 3
        # various
        case op3
        when 0
          # Rcc
          insn = if $zilog
                   "RET\t#{cc[op2]}"
                 else
                   "R#{cc[op2]}"
                 end
        when 1
          # POP, RET etc.
          insn = "POP\t#{regp[op2 / 2]}"
        when 2
          # Jcc
          nn = fetch16(mem, ptr)
          ptr += 2
          insn = if $zilog
                   "JP\t#{cc[op2]},#{to_hex16(nn)}"
                 else
                   "J#{cc[op2]}\t#{to_hex16(nn)}"
                 end
        when 3
          # JMP, CB, IN, OUT etc.
          pass
        when 4
          # Ccc
          nn = fetch16(mem, ptr)
          ptr += 2
          insn = if $zilog
                   "CALL\t#{cc[op2]},#{to_hex16(nn)}"
                 else
                   "C#{cc[op2]}\t#{to_hex16(nn)}"
                 end
        when 5
          # PUSH etc.
          insn = "PUSH\t#{regp[op2 / 2]}"
        when 6
          # ADI etc.
          n = mem[ptr].ord
          ptr += 1
          insn = if $zilog
                   op8[op2] + to_hex8(n)
                 else
                   "#{imm8[op2]}\t#{to_hex8(n)}"
                 end
        when 7
          # RST
          insn = if $zilog
                   "RST\t#{to_hex8(op2 * 8)}"
                 else
                   "RST\t#{op2}"
                 end
        end
      end
    end
  end
  print(format('%04X: ', orig_ptr))
  nb = ptr - orig_ptr
  (0...nb).each do |i|
    print(format('%02X ', mem[orig_ptr + i].ord))
  end
  print('   ' * (4 - nb))
  puts(insn)
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

main if __FILE__ == $0
