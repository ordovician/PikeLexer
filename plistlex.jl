# Token types
const IDENT 	= :Identifier		# Idnetifier
const LPAREN = symbol('(')
const RPAREN = symbol(')')
const LBRACE = symbol('{')
const RBRACE = symbol('}')
const COMMA = symbol(',')
const EQUAL = symbol('=')
const SEMICOLON = symbol(';')

function lex_plist(input :: String)
	l = Lexer(input)
	function start_state(l :: Lexer)
		produce(lex_plist(l))
		return start_state
	end
	@task run(l, start_state)
end

function lex_indentifier(l :: Lexer)
	ch = next_char(l)
	if !isalpha(ch)
		return error(l, "Indentifier must start with alphabetical character")
	end
	i = findfirst(l.input[l.pos:end]) do ch
		!isalnum(ch)
	end
	if i == 0
		_, l.pos = next(l.input, endof(l.input))
	else
		l.pos += i - 1
	end
	emit_token(l, IDENT)	
end

function lex_plist(l :: Lexer)
	ignore_whitespace(l)
	ch = peek_char(l)

	if ch == EOFChar
		emit_token(l, EOF)			
	elseif ch in "{}(),=;"
		next_char(l)
		emit_token(l, symbol(ch))
	elseif isdigit(ch) || ch in "-+"
		lex_number(l)
	elseif ch == '"'
		lex_string(l)
	elseif isalpha(ch)
		lex_indentifier(l)	
	elseif isblank(ch)
		lex_whitespace(l)
	end
end