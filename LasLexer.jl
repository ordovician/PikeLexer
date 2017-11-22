module LasLexer

export  lex_las,
        NUMBER, STRING, IDENT,                                                 
        UNKNOWN, ERROR, EOF,
        MNEMONIC, UNIT, SECTION, DESCRIPTION, COMMENT,
        lex_mnemonic, lex_unit                                         

@enum(TokenType,
      NUMBER, STRING, IDENT,      # Generic
      UNKNOWN, ERROR, EOF,        # Control
      # LAS                                                             
      MNEMONIC,                   # name of keywords under sections in LAS terminology
      UNIT,                       # unit like meter or feet
      SECTION,                    # section name (a heading for mnemonics)
      DESCRIPTION,                # description of the purpose of mnemonic
      COMMENT)                    # comment like this

include("token.jl")
include("lexer.jl")
include("laslex.jl")

function lex_las(input::String)
    lex(input, lex_las)
end

end

