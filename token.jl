import Base.show

typealias TokenType Symbol

type Token
    tokentype::TokenType
    lexeme::String
end

function Token(tokentype::TokenType) 
    Token(tokentype, string(tokentype))
end

function show(io::IO, t::Token)  # avoids recursion into prev and next
    print(io, "$(t.tokentype) \"$(t.lexeme)\"")
end

==(t1::Token, t2::Token) = t1.tokentype == t2.tokentype && t1.lexeme == t2.lexeme
