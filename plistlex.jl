function lex_plist(input :: String)
	Lexer(input, lex_start)
end

function lex_whitespace(l :: Lexer)
	while peek_char(l) in " \t\n"
		next_char(l)
	end
	emit_token(l, WHITESPACE)
	return lex_start
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
	l.start = l.pos
	while true
		ch = next_char(l)
		if ch == '"'
			backup_char(l)
			if l.input[l.pos] != '\\'
				break
			end
			accept_char("\"")
		elseif ch == EOFChar
			return error(l, "EOF when reading string literal")
		end
	end
	emit_token(l, STRING)
	accept_char(l, "\"")	
end

function lex_start(l :: Lexer)
	while peek_char(l) != EOFChar
		ch = next_char(l)
		if ch in "{}(),=;"
			emit_token(l, int(ch))
		elseif isdigit(ch) || ch in "-+"
			backup_char(l)
			return lex_number
		elseif ch == '"'
			backup_char(l)
			return lex_string
		elseif isalpha(ch)
			l.pos += findfirst(c -> !isalnum(c), l.input[l.pos:end]) - 2
			emit_token(l, IDENT)						
		end
	end
	emit(l, EOF)
	return lex_end
end