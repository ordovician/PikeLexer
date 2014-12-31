using PListLexer
using Base.Test

l = Lexer(open(readall, "test/example.plist"))

@test lex_plist(l) == Token(LBRACE)
@test lex_plist(l) == Token(IDENT, "Dogs")
@test lex_plist(l) == Token(EQUAL)
@test lex_plist(l) == Token(LPAREN)
@test lex_plist(l) == Token(LBRACE)
@test lex_plist(l) == Token(IDENT, "Name")
@test lex_plist(l) == Token(EQUAL)
@test lex_plist(l) == Token(STRING, "Scooby Doo")
@test lex_plist(l) == Token(SEMICOLON)
@test lex_plist(l) == Token(IDENT, "Age")
@test lex_plist(l) == Token(EQUAL)
@test lex_plist(l) == Token(NUMBER, "43")
@test lex_plist(l) == Token(SEMICOLON)
@test lex_plist(l) == Token(IDENT, "Colors")
@test lex_plist(l) == Token(EQUAL)
@test lex_plist(l) == Token(LPAREN)
@test lex_plist(l) == Token(IDENT, "Brown")
@test lex_plist(l) == Token(COMMA)
@test lex_plist(l) == Token(IDENT, "Black")
@test lex_plist(l) == Token(RPAREN)
@test lex_plist(l) == Token(SEMICOLON)
@test lex_plist(l) == Token(RBRACE)
@test lex_plist(l) == Token(RPAREN)
@test lex_plist(l) == Token(SEMICOLON)
@test lex_plist(l) == Token(RBRACE)


