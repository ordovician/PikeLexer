module PikeLexer

export	Token, TokenType, Lexer,
		NUMBER, STRING, UNKNOWN, EOF, DOT, COLON
		lexeme, token, emit_token, ignore_lexeme,
		
		lex_mnemonic, lex_number, lex_string, lex_unit

include("token.jl")
include("lexer.jl")
include("laslex.jl")

end