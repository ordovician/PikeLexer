# Lexer inspired Rob Pike's talk

include("token.jl")
include("lexer.jl")

# A state is a function which uses the lexer to decide what the next state will be.
# The next state being another function returning a state function.
# So each function will be either looking for numbers, strings, identifiers etc. When
# e.g. a number is found it might return another function looking for something else.
function state(lexer)
	return function(lexer)
		return state
	end
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

