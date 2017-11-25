module LasLexer

export  lex_las,
        NUMBER, STRING, IDENT,
        UNKNOWN, ERROR, EOF,
        MNEMONIC, UNIT, DATA, SECTION, DESCRIPTION, COMMENT, ENDL,
        lex_mnemonic, lex_unit

@enum(TokenType,
      NUMBER, STRING, IDENT,      # Generic
      UNKNOWN, ERROR, EOF,        # Control
      # LAS
      MNEMONIC,                   # name of keywords under sections in LAS terminology
      UNIT,                       # unit like meter or feet
      DATA,                       # string of number following unit, not containing colon
      SECTION,                    # section name (a heading for mnemonics)
      DESCRIPTION,                # description of the purpose of mnemonic
      COMMENT,                    # comment like this
      ENDL)                       # end of line. Useful to keek track of which data belongs to a row

include("token.jl")
include("lexer.jl")
include("laslex.jl")

function lex_las(input::String)
    lex(input, lex_las)
end

end

# using LasLexer
# l, tokens = lex_las(readstring("test/example-min-header2.las"))
# take!(tokens)
