using LasLexer
using Base.Test

l, tokens = lex_las(readstring("test/example-min-header2.las"))

@test take!(tokens) == Token(SECTION, "V")
@test take!(tokens) == Token(MNEMONIC, "VERS")



