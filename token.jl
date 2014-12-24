import Base.show

# Token types
const NUMBER 	= 1
const STRING 	= 2
const IDENT 	= 3		# Idnetifier
const UNKNOWN 	= 10
const EOF 		= 11
const WHITESPACE = int(' ')
const LPAREN = int('(')
const RPAREN = int(')')
const LBRACE = int('{')
const RBRACE = int('}')
const COMMA = int(',')
const EQUAL = int('=')
const SEMICOLON = int(';')

typealias TokenType Int64

type Token
    tokentype::TokenType
    lexeme::String
end

function Token(tokentype::TokenType) 
    lexeme = ""
    if !haskey(token_names, tokentype)
       lexeme = string(char(tokentype)) 
    end
    Token(tokentype, lexeme)
end

function show(io::IO, token::Token)  # avoids recursion into prev and next
    token_str = if haskey(token_names, token.tokentype)
        token_names[token.tokentype]
    else
        string(char(token.tokentype))        
    end
    
    lex_str = if token.lexeme != "" && token.lexeme != string(char(token.tokentype)) 
        "($(token.lexeme))" 
    else 
        "" 
    end
    print(io, "$token_str $lex_str")
end

==(t1::Token, t2::Token) = t1.tokentype == t2.tokentype && t1.lexeme == t2.lexeme

# mapping from token type to a string representation
const token_names = [NUMBER => "Number", STRING => "String", UNKNOWN => "Unknown", EOF => "EOF"] 