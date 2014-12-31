module PListLexer

export	Token, TokenType, Lexer,
		NUMBER, STRING, IDENT, UNKNOWN, EOF, LPAREN, RPAREN, LBRACE, RBRACE, COMMA, EQUAL, SEMICOLON,
		lexeme, token, emit_token, ignore_lexeme,
		
		lex_plist, lex_whitespace, scan_number, scan_string, lex_identifier

include("token.jl")
include("lexer.jl")
include("plistlex.jl")

end