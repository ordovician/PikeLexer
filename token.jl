import Base: ==

export Token

"""
A string of code is turned into an array of Tokens by the lexer. Each
symbol or word in code is represented as a Token.
"""
struct Token
    kind::TokenType
    lexeme::String
end
   
function Token(kind::TokenType)
    ch = Char(kind)
    if ch in "{}(),=;"
        Token(kind, string(ch))
    else
       Token(kind, "") 
    end
end

==(t1::Token, t2::Token) = t1.kind == t2.kind && t1.lexeme == t2.lexeme
