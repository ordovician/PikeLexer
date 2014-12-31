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


# Token types
const MNEMONIC = :Mnemonic		# name of keywords under sections in LAS terminology
const UNIT		= :Unit			# unit like meter or feet
const SECTION 	= :Section		# section name (a heading for mnemonics)
const DESCRIPTION = :Description # description of the purpose of mnemonic
const COMMENT	= :Comment		# comment like this

# Delimeters between data values
const COLON = symbol(':')

function find_token_end(predicate :: Function, l :: Lexer)
	l.pos + findfirst(predicate, l.input[l.pos:end]) - 1
end

function lex_section(l :: Lexer)
	accept_char(l, "~")
	l.start = l.pos # Dont' want to include ~ in the name
	l.pos = search(l.input, " \t\n", l.pos)
	t = Token(SECTION, lexeme(l))
	l.pos = search(l.input, '\n', prevind(l.pos))
	l.start = l.pos
	if beginswith(uppercase(t.lexeme), "A")
		return t, lex_inside_data_section
	else
		return t, lex_inside_header_section
	end
end

function lex_mnemonic(l :: Lexer)
	ch = next_char(l)
	if !isalpha(ch)
		return error(l, "Mnemonic must start with A-Z")
	end
	l.pos = search(l.input, '.', l.pos)
	if isblank(peek_char(l))
		emit_token(l, MNEMONIC), lex_header_value
	else
		emit_token(l, MNEMONIC), lex_unit
	end
end

function lex_unit(l :: Lexer)
	ch = next_char(l)
	if !isalpha(ch)
		return error(l, "Unit must start with A-Z")
	end	
	invalid_char(c) = !isalnum(c) && c != '/'
	l.pos = find_token_end(invalid_char, l)
	emit_token(l, UNIT), lex_header_value		
end

function lex_header_value(l :: Lexer)
	ignore_whitespace(l)
	ch = peek_char(l)
	if isdigit(ch)
		scan_number(l), lex_description
	else
		scan_string(l), lex_description
	end
end

function lex_description(l :: Lexer)
	ignore_whitespace(l)
	accept_char(l, ":")
	l.start = l.pos # Dont' want to include : in the description
	l.pos = search(l.input, "\n", l.pos)
	emit_token(l, DESCRIPTION), lex_inside_header_section
end

function lex_inside_header_section(l :: Lexer)
	ignore_whitespace(l)
	ch = peek_char(l)

	if ch == EOFChar
		return emit_token(l, EOF)
	end	

	if ch == '~'
		return lex_section(l)
	else
		return lex_mnemonic(l)
	end
end

function lex_inside_data_section(l :: Lexer)
	ignore_whitespace(l)
	ch = peek_char(l)

	if ch == EOFChar
		return emit_token(l, EOF)
	end	

	if isdigit(ch)
		scan_number(l), lex_inside_data_section
	else
		scan_string(l), lex_inside_data_section
	end
end

function lex_las(l :: Lexer)
	ignore_whitespace(l)
	ch = peek_char(l)

	if ch == EOFChar
		return emit_token(l, EOF)
	elseif ch == '#'
	end	

	return lex_section(l)
end

# run lexes the input by executing state functions until we reach the end_state which
# is just a marker for no more input to look for.
function run(l :: Lexer)
	state = lex_las
	while state != lex_end
		token, state = state(l)
		produce(token)
	end
	return Token(EOF, "")
end