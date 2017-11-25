# Pike Lexer

Rob Pike, well known in Unix circles and one of the creators of the Go programming language, had a talk about how to implement a Lexer utilizing a unique feature in Go, channels. The [talk](https://www.youtube.com/watch?v=HxaD_trXwRE) was at the Sydney Google Technology User Group.

The gist of the idea is to use represent state transitions, as changing current function used for lexing and utilizing channels as a way of emitting tokens.

Rob Pike's lexer is implemented in Go, and you can see a [version of it](https://golang.org/src/text/template/parse/lex.go) in the Go standard library, where it is used to parse HTML template files.

This version is implemented in the Julia programming language instead. My original attempt in Julia v0.5 relied on coroutines and a `producer()`, `consumer()` interface which has been depricated.

Interestingly Julia v0.6 replaced this interface with channels, which makes it possible to write the Julia code in the same manner as the Go code is written. This made porting a bit more straight forward. Although this is not a straight port but an inspiration.

Instead of lexing HTML template files, and I am attempting to lex the old Apple/NeXT PList format as well as LAS files used to store well data (from logging tools in oil wells).

## Overview
The main function is `run()` which runs a function associated with a particular lexing state. This function will return the function object corresponding to the next lexer state.

    function run(l::Lexer, start::Function)
        state = start
        while state != lex_end
            state = state(l)
        end
        close(l.tokens)
    end
    
Unlike the Go version, there is no `nil` or `null` in Julia, so we have to find alternatives. My solution is to use an empty function `lex_end()` as a sort of marker or sentinel for the end.

    function lex_end(l::Lexer)
    	return lex_end
    end
    
Because functions just return the next state, and not tokens, we have to have a different place to return tokens. We are utilizing Julia Channels for this. This is how a token is emitted, utilizing a token channel.

    function emit_token(l::Lexer, t::TokenType, s::AbstractString)
    	token = Token(t, s)
        put!(l.tokens, token)
        l.start = l.pos
    end
    
You can see here how the channels are defined and created by the lexer:

    mutable struct Lexer
    	input	:: String # string being scanned
    	start	:: Int    # start position of this item (lexeme)
    	pos		:: Int    # current position in the input
        tokens  :: Channel{Token}
    	function Lexer(input::String)
    		l = new(input, start(input), start(input), Channel{Token}(32))
    		return l
    	end
    end
    
## How To Use the Lexer
With the two examples `PlistLexer.jl` and `LasLexer.jl` I am showing how to reuse the lexer for lexing two completely different file formats.

If you look at either one you see the way you use them is that you define a module with:

    include("token.jl")
    include("lexer.jl")
    
Above these lines you place a definition of your token types. The `token.jl` expects a token type to be defined.

Below you place lexing functions specific to the formats you are lexing.

## Why is this not a Package?
I indend to build packages of this foundation but this repo serves mainly as a way for people to learn about the lexer. I'll keep more complicating elements out such as counting line number and position.