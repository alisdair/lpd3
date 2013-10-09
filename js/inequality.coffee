# These inputs should all be parseable. Not a maximally reduced set,
# but I think this covers everything
good = ["2x + 0.5y < 350", "-3x+2y-50<0","-x-3y-1>0", "2<x+y", "2x+-5y+5+6>0"]

# These should be invalid.
bad  = ["< 5", "horse", "x + y + z < 0", "x = 0"]

# Normal form of the inequality is x + y + c < 0
class Inequality
  constructor: (@x, @y, @c) ->

  toString: -> "#{@x}x + #{@y}y + #{@c} < 0"

# Given a string and a RegExp.exec result, return the unmatched remainder
# of the string
consume = (input, result) -> input.slice(result.index + result[0].length)

# Tokens have type and value
class Token
  constructor: (@type, @value) ->

  toString: -> "[#{@type} '#{@value}']"

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

  # Operators must follow coefficients or variables
  if state == "COEFFICIENT" or state == "VARIABLE"
    result = /^[<>+-]/.exec input
    if result
      token = new Token "OPERATOR", result[0]
      return lex consume(input, result), tokens.concat(token)

  # Coefficients can exist at the start of an expression, or after an operator
  if not state or state == "OPERATOR"
    result = /^(-?[0-9]+(\.[0-9]+)?)|(-)/.exec input
    if result
      token = new Token "COEFFICIENT", result[0]
      return lex consume(input, result), tokens.concat(token)

  # Variables can come at any point except after a variable
  if state != "VARIABLE"
    result = /^[xyXY]/.exec input
    if result
      token = new Token "VARIABLE", result[0]
      return lex consume(input, result), tokens.concat(token)

  throw "Parse error at '#{input}' (tokens: #{tokens}, last token: #{previous})"

console.log "Good inputs:\n"
for i in good
  console.log i
  console.log lex(i).join(" -> ")

console.log "\nBad inputs:\n"
for i in bad
  try
    tokens = lex(i)
    console.log "Should not have been able to lex '#{i}'"
    console.log "Result: ", tokens
  catch e
    console.log e
