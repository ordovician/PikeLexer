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
	l.start = l.pos # Dont' want to include ~ in the name
    accept_char_run(l) do ch
        isalpha(ch) || ch == ' '
    end
    s = lexeme(l)
    emit_token(l, SECTION, s)
    ignore_whitespace(l)

	if startswith(uppercase(s), "A")
		return lex_inside_data_section
	else
		return lex_inside_header_section
	end
end

function lex_mnemonic(l::Lexer)
	ch = next_char(l)
	if !isalpha(ch)
		return error(l, "Mnemonic must start with A-Z")
	end
	l.pos = search(l.input, '.', l.pos)
	if isspace(peek_char(l))
		emit_token(l, MNEMONIC)
        return lex_header_value
	else
		emit_token(l, MNEMONIC)
        return lex_unit
	end
end

function lex_unit(l::Lexer)
	ch = next_char(l)
	if !isalpha(ch)
		return error(l, "Unit must start with A-Z")
	end	
	invalid_char(c) = !isalnum(c) && c != '/'
	l.pos = find_token_end(invalid_char, l)
	emit_token(l, UNIT)
    return lex_header_value		
end

function lex_header_value(l :: Lexer)
	ignore_whitespace(l)
	ch = peek_char(l)
	if isdigit(ch)
		put!(l.tokens, scan_number(l))
        return lex_description
	else
		put!(l.tokens, scan_string(l))
        return lex_description
	end
end

function lex_description(l::Lexer)
	ignore_whitespace(l)
	accept_char(l, ":")
	l.start = l.pos # Dont' want to include : in the description
	l.pos = search(l.input, "\n", l.pos)
	emit_token(l, DESCRIPTION)
    lex_inside_header_section
end

function lex_inside_header_section(l::Lexer)
	ignore_whitespace(l)
	ch = peek_char(l)

	if ch == EOFChar
	    emit_token(l, EOF)
        return lex_end
	end	

	if ch == '~'
		return lex_section
	else
		return lex_mnemonic
	end
end

function lex_inside_data_section(l :: Lexer)
	ignore_whitespace(l)
	ch = peek_char(l)

	if ch == EOFChar
		return emit_token(l, EOF)
	end	

	if isdigit(ch)
		put!(l.tokens, scan_number(l)) 
        return lex_inside_data_section
	else
		put!(l.tokens, scan_string(l))
        return lex_inside_data_section
	end
end

function lex_comment(l::Lexer)
    accept_char(l, '#')
    accept_char_run(ch->ch != '\n', l)
    emit_token(l, COMMENT)
    return las_lex  
end

function lex_las(l::Lexer)
    while true
        ch = peek_char(l)

    	if ch == EOFChar
    		emit_token(l, EOF)
            return lex_end	
        elseif isspace(ch)
            next_char(l)
            continue 
    	elseif ch == '#'
            return lex_comment
        else	
            return lex_section
        end
    end
end
