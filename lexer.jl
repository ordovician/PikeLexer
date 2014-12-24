import Base.error

type Lexer
	name 	:: String # Just used for error
	input	:: String # string being scanned
	start	:: Int64  # start position of this item (lexeme)
	pos		:: Int64  # current position in the input
	task	:: Task
	function Lexer(input :: String, lex_start :: Function)
		l = new("", input, start(input), start(input))
		l.task = @task run(l, lex_start)
		return l
	end
end

const EOFChar = -1

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
	ch = next_char(l)
	backup_char(l)
	ch
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

function emit_token(l :: Lexer, t :: TokenType)
	produce(Token(t, l.input[l.start:l.pos]))
	l.start = l.pos
end

# Skip the current token. E.g. because it is whitespace
function ignore_token(l :: Lexer)
	l.start = l.pos
end

function next_token(l :: Lexer)
	consume(l.task)
end


function error(l :: Lexer, error_msg :: String)
	produce(Token(ErrorToken, error_msg))
	return lex_end
end

####### Lexer States ################################################

# Marker for indicating there is no more input
function lex_end(l :: Lexer)
	return lex_end
end


# run lexes the input by executing state functions until we reach the end_state which
# is just a marker for no more input to look for.
function run(l :: Lexer, lex_start :: Function)
	state = lex_start
	while state != lex_end
		state = state(l)
	end
end

