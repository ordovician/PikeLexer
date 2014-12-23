# Lexer inspired Rob Pike's talk


type Lexer
	name  :: String # Just used for error
	input :: String # string being scanned
	start :: Int64  # start position of this item (lexeme)
	pos   :: Int64  # current position in the input
	ppos  :: Int64  # position of previous character in case of backup
	# channel of scanned tokens. Don't need this as we just call produce()?
end

# A state is a function which uses the lexer to decide what the next state will be.
# The next state being another function returning a state function.
# So each function will be either looking for numbers, strings, identifiers etc. When
# e.g. a number is found it might return another function looking for something else.
function state(lexer)
	return function(lexer)
		return state
	end
end

# Marker for indicating there is no more input
function end_state(l :: Lexer)
	return end_state
end

function start_state(l :: Lexer)
	while true
		if beginswith(l.input[l.pos:end], '{')
			# if l.pos > l.start
			# 	l.emit(TextToken)
			# end
			return left_curly_state
		end
		if next(l) == EOF break end
	end
	# Correctly reach EOF
	if l.pos > l.start
		emit(l, TextToken)
	end
	emit(l, EOFToken)
	end_state
end

function left_curly_state(l :: Lexer)
	l.pos += 1 # length of {
	emit(l, LeftCurlyToken)
	return inside_dict_state	# Inside { } braces defining a dictionary
end

function error_state(l :: Lexer, error_msg :: String)
	produce(Token(ErrorToken, error_msg))
	return end_state
end

# Get next character
function next(l :: Lexer)
	l.ppos = pos
	if l.pos >= endof(l.input)
		return EOF
	end
	ch, l.pos = next(l.input, l.pos)
	return ch
end

function peek(l :: Lexer)
	ch = next(l)
	backup(l)
	ch
end


function inside_dict_state(l :: Lexer)
	while true
		if beginswith(l.input[l.pos:end], '}')
			return right_curly_state
		end 
		ch = next(l)
		if ch == EOF
			error_state(l, "unclosed dictionary")
		else if ch in " \t\n"
			ignore(l)
		end
		
	end
end

# run lexes the input by executing state functions until we reach the end_state which
# is just a marker for no more input to look for.
function run(l :: Lexer)
	state = start_state
	while state != end_state
		state = state(l)
	end
end

function emit(l :: Lexer, t :: TokenType)
	produce(Token(t, l.input[l.start:l.pos]))
	l.start = l.pos + 1
end

function lex(name :: String, input :: String)
	l = Lexer(name, input)
	l, @task l.run()
end