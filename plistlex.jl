
function lex_plist(input :: String)
	l = Lexer(input)
	function start_state(l :: Lexer)
		produce(lex_plist(l))
		return start_state
	end
	@task run(l, start_state)
end

function lex_whitespace(l :: Lexer)
	while peek_char(l) in " \t\n"
		next_char(l)
	end
	emit_token(l, WHITESPACE)
end

function lex_number(l :: Lexer)
	# leading sign is optional, but we'll accept it
	accept_char(l, "-+")
	
	# Could be a hex number, assume it is not first
	digits = "0123456789"
	if accept_char(l, "0") && accept("xX")
		digits *= "abcdefABCDEF"
	end
	accept_char_run(l, digits)
	if accept_char(l, ".")
		accept_char_run(l, digits)
	end
	if accept_char(l, "eE")
		accept(l, "-+")
		accept_char_run(l, "0123456789")
	end
	emit_token(l, NUMBER)
end

function lex_string(l :: Lexer)
	accept_char(l, "\"")
	while true
		ch = next_char(l)
		if ch == '"'
			backup_char(l)
			if current_char(l) != '\\'
				break
			end
			accept_char("\"")
		elseif ch == EOFChar
			return error(l, "EOF when reading string literal")
		end
	end
	accept_char(l, "\"")
	tok = Token(STRING, strip(lexeme(l), '"'))
	l.start = l.pos
	return tok	
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
		l.pos = next(l.input, endof(l.input))
		emit_token(l, IDENT)
		return lex_end
	else
		l.pos += i - 1
		emit_token(l, IDENT)
	end
end

function lex_plist(l :: Lexer)
	ch = peek_char(l)

	if ch == EOFChar
		emit_token(l, EOF)			
	elseif ch in "{}(),=;"
		next_char(l)
		emit_token(l, int(ch))
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