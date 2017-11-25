using LasLexer
using Base.Test

l = lex_las(readstring("test/example-min-header2.las"))

@test next_token(l) == Token(SECTION, "V")

# VERS. 2.0   :   CWLS log ASCII Standard -VERSION 2.0
@test next_token(l) == Token(MNEMONIC, "VERS")
@test next_token(l) == Token(DATA, "2.0")
@test next_token(l) == Token(DESCRIPTION, "CWLS log ASCII Standard -VERSION 2.0")

# WRAP.  NO    :   One line per depth step
@test next_token(l) == Token(MNEMONIC, "WRAP")
@test next_token(l) == Token(DATA, "NO")
@test next_token(l) == Token(DESCRIPTION, "One line per depth step")

@test next_token(l) == Token(SECTION, "W")

# STRT.M  635.0000        :START DEPTH
@test next_token(l) == Token(MNEMONIC, "STRT")
@test next_token(l) == Token(UNIT, "M")
@test next_token(l) == Token(DATA, "635.0000")
@test next_token(l) == Token(DESCRIPTION, "START DEPTH")


@test next_token(l) == Token(MNEMONIC, "STOP")
@test next_token(l) == Token(UNIT, "M")
@test next_token(l) == Token(DATA, "400.0000")
@test next_token(l) == Token(DESCRIPTION, "STOP DEPTH")


