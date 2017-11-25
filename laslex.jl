# Example of LAS 2.0 file

# ~VERSION INFORMATION
#  VERS.                          2.0 :   CWLS LOG ASCII STANDARD -VERSION 2.0
#  WRAP.                          NO  :   ONE LINE PER DEPTH STEP
# ~WELL INFORMATION
# #MNEM.UNIT              DATA                       DESCRIPTION
# #----- -----            ----------               -------------------------
# STRT    .M              1670.0000                :START DEPTH
# STOP    .M              1660.0000                :STOP DEPTH
# STEP    .M              -0.1250                  :STEP
# NULL    .               -999.25                  :NULL VALUE

function find_token_end(predicate::Function, l::Lexer)
	l.pos + findfirst(predicate, l.input[l.pos:end]) - 1
end

function lex_section(l::Lexer)
	accept_char(l, "~")
	ignore(l) # Dont' want to include ~ in the name
    accept_char_run(l) do ch
        isalpha(ch) || ch == ' '
    end
    emit_token(l, SECTION)
    ignore_whitespace(l)
    return lex_las
end

function lex_mnemonic(l::Lexer)
	ch = next_char(l)
	if !isalpha(ch)
		return error(l, "Mnemonic must start with A-Z")
	end
	pos = search(l.input, '.', l.pos)
	if pos == 0
		return error(l, "Mnemonic must be terminated with a '.''")
	else
		l.pos = pos
		emit_token(l, MNEMONIC, strip(lexeme(l)))
		next_char(l)
		if isspace(peek_char(l))
			return lex_header_value
		else
			backup_char(l)
			return lex_unit
		end
	end
end

function lex_unit(l::Lexer)
	accept_char(l, ".")
	ignore(l)
	ch = next_char(l)
	if !isalpha(ch)
		return error(l, "Unit must start with A-Z")
	end
	invalid_char(c) = !isalnum(c) && c != '/'
	l.pos = find_token_end(invalid_char, l)
	emit_token(l, UNIT)
    return lex_header_value
end

function lex_header_value(l::Lexer)
	ignore_whitespace(l)
	pos = search(l.input, ':', l.pos)
	if pos == 0
		error(l, "The parameter line is missing a colon, so we can't determine the parameter value")
	else
		l.pos = pos
		s = strip(lexeme(l))
		if !isempty(s)
			emit_token(l, DATA, s)
		end
		lex_description
	end
end

function lex_description(l::Lexer)
	ignore_whitespace(l)
	accept_char(l, ":")
	ignore(l)     # Dont' want to include : in the description
	pos = search(l.input, '\n', l.pos)
	if pos == 0
		error(l, "Parameter description should be terminated by a newline")
	else
		l.pos = pos
		emit_token(l, DESCRIPTION, strip(lexeme(l)))
		lex_las
	end
end

function lex_comment(l::Lexer)
    accept_char(l, '#')
    accept_char_run(ch->ch != '\n', l)
    emit_token(l, COMMENT, strip(lexeme(l)))
    return lex_las
end

function lex_endline(l::Lexer)
	for i in 1:10
		ch = next_char(l)
		if isspace(ch) && ch != '\n'
			ignore(l)
		elseif ch == EOFChar
			emit_token(l, EOF)
			return lex_end
		elseif ch == '\n'
			emit_token(l, ENDL)
			return lex_las
		else
			backup_char(l)
			return lex_las
		end
	end
end

function lex_las(l::Lexer)
    while true
        ignore_whitespace(l)
        ch = peek_char(l)
    	if ch == EOFChar
    		emit_token(l, EOF)
            return lex_end
    	elseif ch == '#'
            return lex_comment
        elseif ch == '~'
            return lex_section
        elseif ch == '"'
			if scan_string(l)
				emit_token(l, STRING)
				return lex_endline
            else
				error(l, "Invalid quoted string")
			end
        elseif isalpha(ch)
            return lex_mnemonic
        elseif isdigit(ch)
			scan_number(l)
			emit_token(l, NUMBER)
			return lex_endline
        end
    end
end
