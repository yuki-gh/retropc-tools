#! /usr/bin/env ruby

# TODO:
#	output to file
#	non-address 16-bit imm
#	specify sections: code, raw data, address table
#	address inference
#	tablize

require 'colorize'

MAIN_2BYTES = [
  # 8-bit imm load
  0x06, 0x0e,
  0x16, 0x1e,
  0x26, 0x2e,
  0x36, 0x3e,

  # rel jump
  0x10, 0x18,
  0x20, 0x28,
  0x30, 0x38,

  # 8-bit arith/log
  0xc6, 0xce,
  0xd6, 0xde,
  0xe6, 0xee,
  0xf6, 0xfe,

  # misc
  0xcb, 0xd3, 0xdb
].freeze

# relocated
MAIN_3BYTES = [
  # 16-bit imm
  0x01, 0x11, 0x21, 0x31,

  # extended
  0x22, 0x2a,
  0x32, 0x3a,

  # jump/call/ret
  0xc3, 0xcd,
  0xc2, 0xc4, 0xca, 0xcc,
  0xd2, 0xd4, 0xda, 0xdc,
  0xe2, 0xe4, 0xea, 0xec,
  0xf2, 0xf4, 0xfa, 0xfc
].freeze

# validity check only
INDEX_2BYTES = [
  # 16-bit arith
  0x09, 0x19, 0x29, 0x39,
  0x23, 0x2b,

  # ixh, ixl arith
  0x24, 0x25, 0x2c, 0x2d,

  # ixh, ixl ld
  0x44, 0x45, 0x4c, 0x4d,
  0x54, 0x55, 0x5c, 0x5d,
  0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x67,
  0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6f,
  0x7c, 0x7d,

  # ixh, ixl arith/log
  0x84, 0x85, 0x8c, 0x8d,
  0x94, 0x95, 0x9c, 0x9d,
  0xa4, 0xa5, 0xac, 0xad,
  0xb4, 0xb5, 0xbc, 0xbd,

  # misc
  0xe1, 0xe5,
  0xe3, 0xe9, 0xf9
].freeze

INDEX_3BYTES = [
  # ixh,n
  0x26, 0x2e,

  # (ix+d)
  0x34, 0x35,

  # ld (ix+d)
  0x46, 0x4e,
  0x56, 0x5e,
  0x66, 0x6e,
  0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77, 0x7e,

  # arith/log (ix+d)
  0x86, 0x8e,
  0x96, 0x9e,
  0xa6, 0xae,
  0xb6, 0xbe
].freeze

# relocated
INDEX_4BYTES = [
  # 16-bit imm
  0x21,

  # extended
  0x22, 0x2a
].freeze

# validity check only
SUB_2BYTES = [
  # indirect in/out
  0x40, 0x41, 0x48, 0x49,
  0x50, 0x51, 0x58, 0x59,
  0x60, 0x61, 0x68, 0x69,
  0x78, 0x79,

  # 16-bit arith
  0x42, 0x4a,
  0x52, 0x5a,
  0x62, 0x6a,
  0x72, 0x7a,

  # misc
  0x44, 0x45, 0x46, 0x47, 0x4d, 0x4f,
  0x56, 0x57, 0x5e, 0x5f,
  0x67,             0x6f,

  # block
  0xa0, 0xa1, 0xa2, 0xa3, 0xa8, 0xa9, 0xaa, 0xab,
  0xb0, 0xb1, 0xb2, 0xb3, 0xb8, 0xb9, 0xba, 0xbb
].freeze

# relocated
SUB_4BYTES = [
  # 16-bit ld
  0x43, 0x4b,
  0x53, 0x5b,
  0x63, 0x6b,	# undefined insn
  0x73, 0x7b
].freeze

MAIN_TABLE = [
  1, 3, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,	# 0x
  2, 3, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 2, 1, 	# 1x
  2, 3, 3, 1, 1, 1, 2, 1, 2, 1, 3, 1, 1, 1, 2, 1, 	# 2x
  2, 3, 3, 1, 1, 1, 2, 1, 2, 1, 3, 1, 1, 1, 2, 1, 	# 3x

  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 	# 4x
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 	# 5x
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 	# 6x
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 	# 7x

  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 	# 8x
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 	# 9x
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 	# Ax
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 	# Bx

  1, 1, 3, 3, 3, 1, 2, 1, 1, 1, 3, 2, 3, 3, 2, 1, 	# Cx
  1, 1, 3, 2, 3, 1, 2, 1, 1, 1, 3, 2, 3, 1, 2, 1, 	# Dx
  1, 1, 3, 1, 3, 1, 2, 1, 1, 1, 3, 1, 3, 1, 2, 1, 	# Ex
  1, 1, 3, 1, 3, 1, 2, 1, 1, 1, 3, 1, 3, 1, 2, 1	# Fx
].freeze

SUB_TABLE = [
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	# 0x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 	# 1x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 	# 2x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 	# 3x

  2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 0, 2, 0, 2, 	# 4x
  2, 2, 2, 4, 0, 0, 2, 2, 2, 2, 2, 4, 0, 0, 2, 2, 	# 5x
  2, 2, 2, 4, 0, 0, 0, 2, 2, 2, 2, 4, 0, 0, 0, 2, 	# 6x
  0, 0, 2, 4, 0, 0, 0, 0, 2, 2, 2, 4, 0, 0, 0, 0, 	# 7x

  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 	# 8x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 	# 9x
  2, 2, 2, 2, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 	# Ax
  2, 2, 2, 2, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 	# Bx

  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 	# Cx
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 	# Dx
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 	# Ex
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	# Fx
].freeze

INDEX_TABLE = [
  0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0,	# 0x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 	# 1x
  0, 4, 4, 2, 2, 2, 3, 0, 0, 2, 4, 2, 2, 2, 3, 0, 	# 2x
  0, 0, 0, 0, 3, 3, 4, 0, 0, 2, 0, 0, 0, 0, 0, 0, 	# 3x

  0, 0, 0, 0, 2, 2, 3, 0, 0, 0, 0, 0, 2, 2, 3, 0, 	# 4x
  0, 0, 0, 0, 2, 2, 3, 0, 0, 0, 0, 0, 2, 2, 3, 0, 	# 5x
  2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 2, 	# 6x
  3, 3, 3, 3, 3, 3, 0, 3, 0, 0, 0, 0, 2, 2, 3, 0, 	# 7x

  0, 0, 0, 0, 2, 2, 3, 0, 0, 0, 0, 0, 2, 2, 3, 0, 	# 8x
  0, 0, 0, 0, 2, 2, 3, 0, 0, 0, 0, 0, 2, 2, 3, 0, 	# 9x
  0, 0, 0, 0, 2, 2, 3, 0, 0, 0, 0, 0, 2, 2, 3, 0, 	# Ax
  0, 0, 0, 0, 2, 2, 3, 0, 0, 0, 0, 0, 2, 2, 3, 0, 	# Bx

  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 	# Cx
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 	# Dx
  0, 2, 0, 2, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 	# Ex
  0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0	# Fx
].freeze

def fetch_addr(mem, ptr)
  lo = mem[ptr].ord
  hi = mem[ptr + 1].ord
  (hi << 8) + lo
end

def print_addr(adr, iscolor)
  if iscolor
    printf('%02X %02X'.red, adr & 255, adr >> 8)
  else
    printf('%02X %02X', adr & 255, adr >> 8)
  end
end

def decode(src_mem, src_base, dst_base, ptr)
  printf('%04X: ', dst_base + ptr)

  op = src_mem[ptr].ord
  ptr += 1
  printf('%02X ', op)

  case op
  when 0xdd, 0xfd
    op = src_mem[ptr].ord
    ptr += 1
    printf('%02X ', op)
    if op == 0xcb
      # DD/FD CB d op
      printf('%02X ', src_mem[ptr].ord)
      ptr += 1
      printf('%02X ', src_mem[ptr].ord)
      ptr += 1
    elsif op == 0x36	# LD (IX+d),n
      printf('%02X ', src_mem[ptr].ord)
      ptr += 1
      printf('%02X ', src_mem[ptr].ord)
      ptr += 1
    elsif INDEX_TABLE[op] == 3 # INDEX_3BYTES.include?(op)
      # DD/FD op d
      printf('%02X ', src_mem[ptr].ord)
      ptr += 1
    elsif INDEX_TABLE[op] == 4 # INDEX_4BYTES.include?(op)
      # DD/FD op nn
      adr = fetch_addr(src_mem, ptr)
      ptr += 2
      if src_base <= adr && adr < src_base + src_mem.size
        adr = adr - src_base + dst_base
        print_addr(adr, true)
      else
        print_addr(adr, false)
      end
    elsif INDEX_TABLE[op] == 2 # INDEX_2BYTES.include?(op)
      # DD/FD op
    else
      print('???')
    end
  when 0xcb
    # CB op
    printf('%02X ', src_mem[ptr].ord)
    ptr += 1
  when 0xed
    op = src_mem[ptr].ord
    ptr += 1
    printf('%02X ', op)
    if SUB_TABLE[op] == 4 # SUB_4BYTES.include?(op)
      # ED op nn
      adr = fetch_addr(src_mem, ptr)
      ptr += 2
      if src_base <= adr && adr < src_base + src_mem.size
        adr = adr - src_base + dst_base
        print_addr(adr, true)
      else
        print_addr(adr, false)
      end
    elsif SUB_TABLE[op] == 2 # SUB_2BYTES.include?(op)
      # ED op
    else
      print('???')
    end
  else
    if MAIN_TABLE[op] == 2 # MAIN_2BYTES.include?(op)
      # op n/e
      printf('%02X ', src_mem[ptr].ord)
      ptr += 1
    elsif MAIN_TABLE[op] == 3 # MAIN_3BYTES.include?(op)
      # op nn
      adr = fetch_addr(src_mem, ptr)
      ptr += 2
      if src_base <= adr && adr < src_base + src_mem.size
        adr = adr - src_base + dst_base
        print_addr(adr, true)
      else
        print_addr(adr, false)
      end
    end
  end
  puts
  ptr
end

def tablize_sub(table, opcodes, bytes)
  opcodes.each  do |op|
    table[op] = bytes
  end
end

def show_table(table)
  16.times do |y|
    print("\t")
    16.times do |x|
      print(table[y * 16 + x], ',')
      print(' ') if (x & 3) == 3
    end
    printf("\t# %Xx\n", y)
    puts if (y & 3) == 3
  end
end

def tablize
  table_main = Array.new(256, 1)
  tablize_sub(table_main, MAIN_2BYTES, 2)
  tablize_sub(table_main, MAIN_3BYTES, 3)
  #	show_table(table_main)

  table_sub = Array.new(256, 0)
  tablize_sub(table_sub, SUB_2BYTES, 2)
  tablize_sub(table_sub, SUB_4BYTES, 4)
  #	show_table(table_sub)

  table_index = Array.new(256, 0)
  tablize_sub(table_index, INDEX_2BYTES, 2)
  tablize_sub(table_index, INDEX_3BYTES, 3)
  tablize_sub(table_index, INDEX_4BYTES, 4)
  table_index[0x36] = 4
  show_table(table_index)
end

def main
  src_mem = File.binread(ARGV[0])
  src_base = ARGV[1].to_i(16)
  dst_base = ARGV[2].to_i(16)
  ptr = 0

  while ptr < src_mem.size
    begin
      ptr = decode(src_mem, src_base, dst_base, ptr)
    rescue NoMethodError
      exit
    end
  end
end

main if __FILE__ == $PROGRAM_NAME
