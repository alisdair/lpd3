# Normal form of the inequality is x + y + c < 0
class Inequality
  constructor: (@x, @y, @c) ->

  toString: -> "#{@x}x + #{@y}y + #{@c} < 0"

# Tokens have type and value
class Token
  constructor: (@type, @value) ->

  toString: -> "[#{@type} '#{@value}']"

# Lexers can be applied in a set of states, with a regexp to match tokens,
# and a token type to output
class Lexer
  constructor: (@states, @regexp, @token) ->

lexers = [
  # Operators follow coefficients and variables. This is highest priority
  # so that x-5y is parsed as [x, -, 5, y], not [x, -5, y].
  new Lexer ["COEFFICIENT", "VARIABLE"], /^[<>+-]/, "OPERATOR"

  # Coefficients can only appear at the start of the expression or after an
  # operator. The value is either a number or "-", which means -1.
  new Lexer [undefined, "OPERATOR"], /^(-?[0-9]+(\.[0-9]+)?)|(-)/, "COEFFICIENT"

  # Variables follow everything except other variables. Only x and y are
  # allowed, since this is a two-variable inequality.
  new Lexer [undefined, "COEFFICIENT", "OPERATOR"], /^[xyXY]/, "VARIABLE"
]

# Given a string and a RegExp.exec result, return the unmatched remainder
# of the string
consume = (input, result) -> input.slice(result.index + result[0].length)

# Lex the input string into an array of tokens
lex = (input, tokens=[]) ->
  if input.length == 0
    return tokens

  # Extract previous token type (if any)
  previous = tokens.slice(-1)[0]
  state = previous.type if previous?

  # Ignore whitespace
  result = /^\s+/.exec input
  if result
    return lex consume(input, result), tokens

  # Lex tokens!
  for lexer in lexers
    continue unless state in lexer.states
    result = lexer.regexp.exec input
    if result
      token = new Token lexer.token, result[0]
      return lex consume(input, result), tokens.concat(token)

  throw "Parse error at '#{input}' (tokens: #{tokens}, last token: #{previous})"

# These inputs should all be parseable. Not a maximally reduced set,
# but I think this covers everything
good = ["2x + 0.5y < 350", "-3x+2y-50<0","-x-3y-1>0", "2<x+y", "2x+-5y+5+6>0"]

console.log "Good inputs:\n"
for i in good
  console.log i
  console.log lex(i).join(" -> ")

# These should be invalid.
bad  = ["< 5", "horse", "x + y + z < 0", "x = 0"]

console.log "\nBad inputs:\n"
for i in bad
  try
    tokens = lex(i)
    console.log "Should not have been able to lex '#{i}'"
    console.log "Result: ", tokens
  catch e
    console.log e
