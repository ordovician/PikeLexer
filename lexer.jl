import Base.error

# Common Token types for all lexers
const NUMBER 	= :Number
const STRING 	= :String
const EOF 		= :EOF
const UNKNOWN 	= :Unknown
const ERROR		= :Error

type Lexer
	name 	:: String # Just used for error
	input	:: String # string being scanned
	start	:: Int64  # start position of this item (lexeme)
	pos		:: Int64  # current position in the input
	function Lexer(input :: String)
		l = new("", input, start(input), start(input))
		return l
	end
end

const EOFChar = char(-1)

# Get next character
function next_char(l :: Lexer)
	if l.pos > endof(l.input)
		return EOFChar
	end
	ch, l.pos = next(l.input, l.pos)
	return ch
end

function backup_char(l :: Lexer)
	l.pos = prevind(l.input, l.pos)
	return l.input[l.pos]
end

function peek_char(l :: Lexer)
	if l.pos > endof(l.input)
		return EOFChar
	end
	return l.input[l.pos]
end

function current_char(l :: Lexer)
	if l.pos <= 1
		error("Can't ask for current char before first char has been fetched")
	end
	return l.input[prevind(l.input, l.pos)]
end

# Check if next character is one of among the valid ones
function accept_char(l :: Lexer, valid :: String)
	if next_char(l) in valid
		return true
	end
	backup_char(l)
	return false
end

# Accept a run of characters contained withing array of valid chars
function accept_char_run(l :: Lexer, valid :: String)
	while next_char(l) in valid end
	backup_char(l)
end

function lexeme(l)
	endind = prevind(l.input, l.pos)
	l.input[l.start:endind]	
end

token(l :: Lexer, t :: TokenType) = Token(t, lexeme(l))

function emit_token(l :: Lexer, t :: TokenType)
	tok = token(l, t)
	l.start = l.pos		
	return tok
end

# Skip the current token. E.g. because it is whitespace
function ignore_lexeme(l :: Lexer)
	l.start = l.pos
end

function error(l :: Lexer, error_msg :: String)
	return Token(ERROR, error_msg), lex_end
end

####### Lexer States ################################################

# Marker for indicating there is no more input
function lex_end(l :: Lexer)
	return lex_end
end

# Lex functions common to most lexers
function ignore_whitespace(l :: Lexer)
	while peek_char(l) in " \t\n"
		next_char(l)
	end
	l.start = l.pos
end

function scan_number(l :: Lexer)
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

function scan_string(l :: Lexer)
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

