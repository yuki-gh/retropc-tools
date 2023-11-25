
# FIXME
# float/double
# jumpaddress
# N98 REM

# flake8 list.py|grep -v W191
# pylint list.py|grep -v W0311|grep -v C0103

from enum import Enum
# import io
# import os
import sys
# import typing


class Mode(Enum):
	"""Nxx-BASIC"""
	N_N80_N80SR = 1
	N60_N66 = 2
	N88 = 3
	N66SR = 4
	N98 = 5


mode: Mode = Mode.N_N80_N80SR
# mode = Mode.N60_N66
# mode = Mode.N88
# mode = Mode.N66SR
# mode = Mode.N98

reserved_words_n66: list[str] = [
	"END",
	"FOR",
	"NEXT",
	"DATA",
	"INPUT",
	"DIM",
	"READ",
	"LET",
	"GOTO",
	"RUN",
	"IF",
	"RESTORE",
	"GOSUB",
	"RETURN",
	"REM",
	"STOP",
	"OUT",
	"ON",
	"LPRINT",
	"DEF",
	"POKE",
	"PRINT",
	"CONT",
	"LIST",
	"LLIST",
	"CLEAR",
	"COLOR",
	"PSET",
	"PRESET",
	"LINE",
	"PAINT",
	"SCREEN",
	"CLS",
	"LOCATE",
	"CONSOLE",
	"CLOAD",
	"CSAVE",
	"EXEC",
	"SOUND",
	"PLAY",
	"KEY",
	"LCOPY",
	"NEW",
	"RENUM",
	"CIRCLE",
	"GET",
	"PUT",
	"BLOAD",
	"BSAVE",
	"FIELD",
	"LFILES",
	"LOAD",
	"MERGE",
	"NAME",
	"SAVE",
	"FILES",
	"LSET",
	"RSET",
	"OPEN",
	"CLOSE",
	"DSKO$",
	"KILL",
	"TALK",
	"MON",
	"KANJI",
	"DELETE",
	"TAB(",
	"TO",
	"FN",
	"SPC(",
	"INKEY$",
	"THEN",
	"NOT",
	"STEP",
	"+",
	"-",
	"*",
	"/",
	"^",
	"AND",
	"OR",
	">",
	"=",
	"<",
	"SGN",
	"INT",
	"ABS",
	"USR",
	"FRE",
	"INP",
	"LPOS",
	"POS",
	"SQR",
	"RND",
	"LOG",
	"EXP",
	"COS",
	"SIN",
	"TAN",
	"PEEK",
	"LEN",
	"HEX$",
	"STR$",
	"VAL",
	"ASC",
	"CHR$",
	"LEFT$",
	"RIGHT$",
	"MID$",
	"POINT",
	"CSRLIN",
	"STICK",
	"STRIG",
	"TIME",
	"PAD",
	"DSKI$",
	"LOF",
	"LOC",
	"EOF",
	"DSKF",
	"CVS",
	"MKS$"
]

# 0x81-0xfe
reserved_words_n80_1: list[str] = [
	"END",
	"FOR",
	"NEXT",
	"DATA",
	"INPUT",
	"DIM",
	"READ",
	"LET",
	"GOTO",
	"RUN",
	"IF",
	"RESTORE",
	"GOSUB",
	"RETURN",
	"REM",
	"STOP",
	"PRINT",
	"CLEAR",
	"LIST",
	"NEW",
	"ON",
	"WAIT",
	"DEF",
	"POKE",
	"CONT",
	"CSAVE",
	"CLOAD",
	"OUT",
	"LPRINT",
	"LLIST",
	"CONSOLE",
	"WIDTH",
	"ELSE",
	"TRON",
	"TROFF",
	"SWAP",
	"ERASE",
	"ERROR",
	"RESUME",
	"DELETE",
	"AUTO",
	"RENUM",
	"DEFSTR",
	"DEFINT",
	"DEFSNG",
	"DEFDBL",
	"LINE",
	"PRESET",
	"PSET",
	"BEEP",
	"FORMAT",
	"KEY",
	"COLOR",
	"TERM",
	"MON",
	"CMD",
	"MOTOR",
	"POLL",
	"RBYTE",
	"WBYTE",
	"ISET",
	"IRESET",
	"TALK",
	"MAT",
	"LISTEN",
	"DSKO$",
	"REMOVE",
	"MOUNT",
	"OPEN",
	"FIELD",
	"GET",
	"PUT",
	"SET",
	"CLOSE",
	"LOAD",
	"MERGE",
	"FILES",
	"NAME",
	"KILL",
	"LSET",
	"RSET",
	"SAVE",
	"LFILES",
	"INIT",
	"LOCATE",
	"",
	"TO",
	"THEN",
	"TAB(",
	"STEP",
	"USR",
	"FN",
	"SPC(",
	"NOT",
	"ERL",
	"ERR",
	"STRING$",
	"USING",
	"INSTR",
	"'",
	"VARPTR",
	"CSRLIN",
	"ATTR$",
	"DSKI$",
	"INKEY$",
	"TIME$",
	"DATE$",
	"",
	"SRQ",
	"STATUS",
	"POINT",
	">",
	"=",
	"<",
	"+",
	"-",
	"*",
	"/",
	"^",
	"AND",
	"OR",
	"XOR",
	"EQV",
	"IMP",
	"MOD",
	"\\"
]

# 0xff81-0xffad
reserved_words_n80_2: list[str] = [
	"LEFT$",
	"RIGHT$",
	"MID$",
	"SGN",
	"INT",
	"ABS",
	"SQR",
	"RND",
	"SIN",
	"LOG",
	"EXP",
	"COS",
	"TAN",
	"ATN",
	"FRE",
	"INP",
	"POS",
	"LEN",
	"STR$",
	"VAL",
	"ASC",
	"CHR$",
	"PEEK",
	"SPACE$",
	"OCT$",
	"HEX$",
	"LPOS",
	"PORT",
	"DEC",
	"BCD$",
	"CINT",
	"CSNG",
	"CDBL",
	"FIX",
	"CVI",
	"CVS",
	"CVD",
	"DSKF",
	"EOF",
	"LOC",
	"LOF",
	"FPOS",
	"MKI$",
	"MKS$",
	"MKD$"
#	"IEEE"		# 0xffec
]

# 81-fe
reserved_words_n88_1: list[str] = [
	"END",
	"FOR",
	"NEXT",
	"DATA",
	"INPUT",
	"DIM",
	"READ",
	"LET",
	"GOTO",
	"RUN",
	"IF",
	"RESTORE",
	"GOSUB",
	"RETURN",
	"REM",
	"STOP",
	"PRINT",
	"CLEAR",
	"LIST",
	"NEW",
	"ON",
	"WAIT",
	"DEF",
	"POKE",
	"CONT",
	"OUT",
	"LPRINT",
	"LLIST",
	"CONSOLE",
	"WIDTH",
	"ELSE",
	"TRON",
	"TROFF",
	"SWAP",
	"ERASE",
	"EDIT",		# N66SR:MENU
	"ERROR",
	"RESUME",
	"DELETE",
	"AUTO",
	"RENUM",
	"DEFSTR",
	"DEFINT",
	"DEFSNG",
	"DEFDBL",
	"LINE",
	"WHILE",
	"WEND",
	"CALL",		# N66SR:EXEC
	"LFO",		# N66SR
	"PLAY",		# N66SR
	"BGM",		# N66SR
	"WRITE",	# N66SR:SOUND
	"COMMON",
	"CHAIN",
	"OPTION",	# N66SR:CLOAD
	"RANDOMIZE",	# N66SR:CSAVE
	"DSKO$",
	"OPEN",
	"FIELD",
	"GET",
	"PUT",
	"SET",
	"CLOSE",
	"LOAD",
	"MERGE",
	"FILES",
	"NAME",
	"KILL",
	"LSET",
	"RSET",
	"SAVE",
	"LFILES",
	"MON",
	"COLOR",
	"CIRCLE",
	"COPY",		# N66SR:LCOPY
	"CLS",
	"PSET",
	"PRESET",
	"PAINT",
	"TERM",
	"SCREEN",
	"BLOAD",
	"BSAVE",
	"LOCATE",
	"BEEP",
	"ROLL",
	"HELP",		# N66SR:PALET
	"TALK",		# N66SR
	"KANJI",
	"TO",
	"THEN",
	"TAB(",
	"STEP",
	"USR",
	"FN",
	"SPC(",
	"NOT",
	"ERL",
	"ERR",
	"STRING$",
	"USING",
	"INSTR",
	"'",
	"VARPTR",
	"ATTR$",
	"DSKI$",
	"SRQ",
	"OFF",
	"INKEY$",
	">",
	"=",
	"<",
	"+",
	"-",
	"*",
	"/",
	"^",
	"AND",
	"OR",
	"XOR",
	"EQV",
	"IMP",
	"MOD",
	"\\"
]

# ff81-ffad
reserved_words_n88_2a: list[str] = [
	"LEFT$",
	"RIGHT$",
	"MID$",
	"SGN",
	"INT",
	"ABS",
	"SQR",
	"RND",
	"SIN",
	"LOG",
	"EXP",
	"COS",
	"TAN",
	"ATN",
	"FRE",
	"INP",
	"POS",
	"LEN",
	"STR$",
	"VAL",
	"ASC",
	"CHR$",
	"PEEK",
	"SPACE$",
	"OCT$",
	"HEX$",
	"LPOS",
	"CINT",
	"CSNG",
	"CDBL",
	"FIX",
	"CVI",
	"CVS",
	"CVD",
	"EOF",
	"LOC",
	"LOF",
	"FPOS",
	"MKI$",
	"MKS$",
	"MKD$",
	"AKCNV$",		# n66SR STICK
	"KACNV$",		# n66SR strig
	"KLEN",		# n66sr pad
	"KPOS"		# n66sr grp$
]

# ffd0-ffe5

reserved_words_n88_2b: list[str] = [
	"DSKF",
	"VIEW",
	"WINDOW",
	"POINT",
	"CSRLIN",
	"MAP",
	"SEARCH",
	"MOTOR",
	"PEN",
	"DATE$",
	"COM",
	"KEY",
	"TIME$",		# n66SR:time
	"WBYTE",
	"RBYTE",
	"POLL",
	"ISET",
	"IEEE",
	"IRESET",
	"STATUS",
	"CMD",
	"KPLOAD"
]

# 0x80-0xfe

reserved_words_n98_1: list[str] = [
	"AUTO",
	"BSAVE",
	"BLOAD",
	"BEEP",
	"CONSOLE",
	"COPY",
	"CLOSE",
	"CONT",
	"CLEAR",
	"CALL",
	"COMMON",
	"CHAIN",
	"COM",
	"CIRCLE",
	"COLOR",
	"CLS",
	"DELETE",
	"DATA",
	"DIM",
	"DEFSTR",
	"DEFINT",
	"DEFSNG",
	"DEFDBL",
	"DSKO$",
	"DEF",
	"ELSE",
	"END",
	"ERASE",
	"EDIT",
	"ERROR",
	"FOR",
	"FIELD",
	"FILES",
	"FN",
	"DRAW",
	"GOTO",
	"GOSUB",
	"GET",
	"HELP",
	"INPUT",
	"IF",
	"KEY",
	"KILL",
	"KANJI",
	"LOCATE",
	"LPRINT",
	"LLIST",
	"LET",
	"LINE",
	"LOAD",
	"LSET",
	"LFILES",
	"MOTOR",
	"MERGE",
	"MON",		# DOS:CHILD
	"NEXT",
	"NAME",
	"NEW",
	"NOT",
	"OPEN",
	"OUT",
	"ON",
	"OPTION",
	"OFF",
	"PRINT",
	"PUT",
	"POKE",
	"PSET",
	"PRESET",
	"PAINT",
	"RETURN",
	"READ",
	"RUN",
	"RESTORE",
	"",		# 0xca
	"RESUME",
	"RSET",
	"RENUM",
	"RANDOMIZE",
	"ROLL",
	"SCREEN",
	"STOP",
	"SWAP",
	"SAVE",
	"SPC",
	"STEP",
	"THEN",
	"TRON",
	"TROFF",
	"TAB",
	"TO",
	"TERM",		# DOS:SYSTEM
	"USING",
	"USR",
	"WIDTH",
	"WAIT",
	"WHILE",
	"WEND",
	"WRITE",
	"LIST",
	"SEG",
	"SET",
	"KINPUT",
	"SRQ",
	"CMD",
	"IRESET",
	"ISET",
	"POLL",
	"RBYTE",
	"WBYTE",
	"KPLOAD",
	"\0",		# DOS:CHDIR/MKDIR/RMDIR
	">",
	"=",
	"<",
	"+",
	"-",
	"*",
	"/",
	"^",
	"AND",
	"OR",
	"XOR",
	"EQV",
	"IMP",
	"MOD",
	"\\",
]

# 0xff80-ff86

reserved_words_n98_2a: list[str] = [
	"DATE$",
	"MID$",
	"POINT",
	"PEN",		# DOS:MOUSE
	"TIME$",
	"VIEW",
	"WINDOW",
]

# 0xff90-ffcf

reserved_words_n98_2b: list[str] = [
	"ABS",
	"ATN",
	"ASC",
	"ATTR$",
	"CSRLIN",
	"CINT",
	"CSNG",
	"CDBL",
	"CVI",
	"CUS",
	"CVD",
	"COS",
	"CHR$",
	"DSKF",
	"ERL",
	"ERR",
	"EXP",
	"EOF",
	"FIX",
	"FPOS",		# DOS:SEGPTR
	"HEX$",
	"INSTR",
	"INT",
	"INP",
	"INKEY$",
	"LPOS",
	"LOG",
	"LOC",
	"LEN",
	"LEFT$",
	"LOF",
	"MKI$",
	"MKS$",
	"MKD$",
	"MAP",
	"OCT$",
	"POS",
	"PEEK",
	"RIGHT$",
	"RND",
	"SEARCH",
	"SGN",
	"SQR",
	"SIN",
	"STR$",
	"STRING$",
	"SPACE$",
	"TAN",
	"VAL",
	"DSKI$",
	"FRE",
	"VARPTR",
	"INPUT$",
	"JIS$",
	"KNJ$",
	"KTYPE",
	"KLEN",
	"KMID$",
	"KEXT$",
	"KINSTR",
	"AKCNV$",
	"KACNV$",
	"IEEE",
	"STATUS",
]


def conv(c: int) -> str:
	"""convert a character code into appropriate character"""
	if c < 0x7f:
		return chr(c)
	if 0x80 <= c < 0xa0:
		if mode in (Mode.N60_N66, Mode.N66SR):
			return "♠♥♣♦○●をぁぃぅぇぉゃゅょっ あいうえおかきくけこさしすせそ"[c - 0x80]
		return "▁▂▃▄▅▆▇█▏▎▍▌▋▊▉┼┴┬┤├▔─│▕┌┐└┘╭╮╰╯"[c - 0x80]
	if 0xa0 < c < 0xe0:
		return chr(0xff60 + c - 0xa0)
	if mode in (Mode.N60_N66, Mode.N66SR):
		if 0xe0 <= c <= 0xfd:
			return "たちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわん"[c - 0x80]
	else:
		if 0xe0 <= c <= 0xf7:
			return "═╞╪╡◢◣◥◤♠♥♦♣●○╱╲╳円年月日時分秒"[c - 0xe0]
	return "?"


def main() -> None:
	"""main"""
	with open(sys.argv[1], 'rb') as f:
		# sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8_sig')
		mem: bytes = f.read()
		ptr: int = 16

		lp: int = mem[ptr] + mem[ptr+1] * 256
		ptr += 2
		while lp > 0:
			lin: int = mem[ptr] + mem[ptr+1] * 256
			ptr += 2
			print(f'{lin} ', end="")

			incomment: bool = False
			instr: bool = False
			c: int = mem[ptr]
			ptr += 1
			while c > 0:
				if incomment:
					print(conv(c), end="")
				elif instr:
					print(conv(c), end="")
					if c == 0x22:
						instr = False
				elif c == 0x22:
					print(conv(c), end="")
					instr = True
	
				elif c == 0xb:
					# &O
					val: int = mem[ptr] + mem[ptr+1] * 256
					print(f'&O{val:o}', end="")
					ptr += 2
				elif c == 0xc:
					# &H
					val = mem[ptr] + mem[ptr+1] * 256
					print(f'&H{val:X}', end="")
					ptr += 2
				elif c == 0xd:
					# FIXME jump address
					ptr += 2
				elif c == 0xe:
					# jump lineno
					print(mem[ptr] + mem[ptr+1] * 256, end="")
					ptr += 2
				elif c == 0xf:
					# int const 10-255
					print(mem[ptr], end="")
					ptr += 1
				elif 0x11 <= c <= 0x1a:
					# int const 0-9
					print(c - 0x11, end="")
				elif c == 0x1c:
					# int const
					print(mem[ptr] + mem[ptr+1] * 256, end="")
					ptr += 2
				elif c == 0x1d:
					# FIXME float const
					ptr += 4
				elif c == 0x1f:
					# FIXME double const
					ptr += 8
				elif mode == Mode.N_N80_N80SR and 0x81 <= c <= 0xfe:
					# reserved words
					print(reserved_words_n80_1[c-0x81], end="")
					if c == 0x8f:
						incomment = True
				elif mode == Mode.N60_N66 and 0x80 <= c <= 0xf9:
					# reserved words
					print(reserved_words_n66[c-0x80], end="")
					if c == 0x8e:
						incomment = True
				elif mode in (Mode.N88, Mode.N66SR) and 0x80 <= c <= 0xf9:
					# reserved words
					print(reserved_words_n88_1[c-0x81], end="")
					if c == 0x8f:
						incomment = True
				elif mode == Mode.N98 and 0x80 <= c <= 0xfe:
					# reserved words
					print(reserved_words_n98_1[c-0x80], end="")
					if c == 0x00:
						incomment = True
				elif c == 0xff:
					# reserved words
					c = mem[ptr]
					ptr += 1
					if mode == Mode.N_N80_N80SR and 0x81 <= c <= 0xad:
						print(reserved_words_n80_2[c-0x81], end="")
					if mode in (Mode.N66SR, Mode.N88):
						if 0x81 <= c <= 0xad:
							print(reserved_words_n88_2a[c-0x81], end="")
						elif 0xd0 <= c <= 0xe5:
							print(reserved_words_n88_2b[c-0xd0], end="")
					if mode == Mode.N98:
						if 0x80 <= c <= 0x86:
							print(reserved_words_n98_2a[c-0x80], end="")
						elif 0x90 <= c <= 0xcf:
							print(reserved_words_n98_2b[c-0x90], end="")
				elif c == 0x3a:
					if mem[ptr] == 0x8f:
						print("'", end="")
						ptr += 2
					elif mem[ptr] == 0xa1:
						print("ELSE", end="")
						ptr += 1
					else:
						print(":", end="")
				elif (0x20 <= c <= 0x7e) or c == 0x09:
					print(conv(c), end="")
				else:
					print("===unknown byte:", c)
				c = mem[ptr]
				ptr += 1
			print()
			lp = mem[ptr] + mem[ptr+1] * 256
			ptr += 2


if __name__ == '__main__':
	main()
