type Lexer
	name 	:: String # Just used for error
	input	:: String # string being scanned
	start	:: Int64  # start position of this item (lexeme)
	pos		:: Int64  # current position in the input
	prevpos :: Int64  # position of previous character in case of backup
	task	:: Task
	function Lexer(input :: String)
		l = new("", input, start(input), start(input), -1)
		l.task = @task run(l)
		return l
	end
end

const EOFChar = -1

# Get next character
function nextchar(l :: Lexer)
	if l.pos > endof(l.input)
		return EOFChar
	end
	l.prevpos = l.pos	
	ch, l.pos = next(l.input, l.pos)
	return ch
end

function backupchar(l :: Lexer)
	l.pos = l.prevpos
end

function peekchar(l :: Lexer)
	ch = nextchar(l)
	backupchar(l)
	ch
end

function emit_token(l :: Lexer, t :: TokenType)
	produce(Token(t, l.input[l.start:l.pos]))
	l.start = l.pos + 1
end

function nexttoken(l :: Lexer)
	consume(l.task)
end


####### Lexer States ################################################

# Marker for indicating there is no more input
function end_state(l :: Lexer)
	return end_state
end


# run lexes the input by executing state functions until we reach the end_state which
# is just a marker for no more input to look for.
function run(l :: Lexer)
	state = start_state
	while state != end_state
		state = state(l)
	end
end

