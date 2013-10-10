# Normal form of the inequality is x + y + c < 0
class Inequation
  constructor: (@x, @y, @c) ->

  toString: -> "#{@x}x + #{@y}y + #{@c} < 0"

# A non-normalised inequality is made up of multiple terms
class Term
  constructor: (coefficient, @variable) ->
    @coefficient = parseFloat coefficient

  toString: ->
    c = "#{@coefficient}"
    if @variable == 'c'
      c
    else
      "#{c}#{@variable}"

class Inequality
  constructor: (@sign) ->

  toString: -> @sign

# Tokens have type and value
class Token
  constructor: (@type, @value) ->
    if @type == "COEFFICIENT" and @value == "-"
      @value = "-1"

  toString: -> "[#{@type} '#{@value}']"

# Lexers can be applied in a set of states, with a regexp to match tokens,
# and a token type to output
class Lexer
  constructor: (@states, @regexp, @token) ->

lexers = [
  # Operators follow coefficients and variables. This is highest priority
  # so that x-5y is parsed as [x, -, 5, y], not [x, -5, y].
  new Lexer ["COEFFICIENT", "VARIABLE"], /^[+-]/, "OPERATOR"

  # Inequalities also follow coefficients or variables
  new Lexer ["COEFFICIENT", "VARIABLE"], /^[<>]/, "INEQUALITY"

  # Coefficients can only appear at the start of the expression or after an
  # operator or inequality. The value is either a number or "-", which means
  # -1.
  new Lexer [undefined, "INEQUALITY", "OPERATOR"], /^(-?[0-9]+(\.[0-9]+)?)|(-)/, "COEFFICIENT"

  # Variables follow everything except other variables. Only x and y are
  # allowed, since this is a two-variable inequality.
  new Lexer [undefined, "INEQUALITY", "COEFFICIENT", "OPERATOR"], /^[xyXY]/, "VARIABLE"
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

# Replace all subtract operators with adds, normalising the coefficeints
convert_operators = (tokens, normalised=[]) ->
  if tokens.length == 0
    return normalised

  if tokens[0].type == "OPERATOR" and tokens[0].value == "-"
    if tokens.length == 1
      throw "Unexpected end of expression at operator: #{tokens}"
    operator = new Token "OPERATOR", "+"
    if tokens[1].type == "COEFFICIENT"
      value = parseFloat(tokens[1].value) * -1
      coefficient = new Token "COEFFICIENT", "#{value}"
      return convert_operators tokens.slice(2), normalised.concat(operator, coefficient)
    else
      coefficient = new Token "COEFFICIENT", "-1"
      return convert_operators tokens.slice(1), normalised.concat(operator, coefficient)

  return convert_operators tokens.slice(1), normalised.concat(tokens[0])

# Parse the lexed tokens into a set of terms
parse = (tokens, terms=[]) ->
  if tokens.length == 0
    return terms

  switch tokens[0].type
    when "VARIABLE"
      term = new Term 1, tokens[0].value
      return parse tokens.slice(1), terms.concat(term)
    when "INEQUALITY"
      term = new Inequality tokens[0].value
      return parse tokens.slice(1), terms.concat(term)
    when "COEFFICIENT"
      if tokens.length > 1 && tokens[1].type == "VARIABLE"
        term = new Term tokens[0].value, tokens[1].value
        return parse tokens.slice(2), terms.concat(term)
      else
        term = new Term tokens[0].value, "c"
        return parse tokens.slice(1), terms.concat(term)
    when "OPERATOR"
      return parse tokens.slice(1), terms
    else
      throw "Unexpected token found: #{tokens[0]}"

# Validate and convert the inequality to less than, if necessary
convert_inequality = (terms) ->
  inequalities = terms.filter (t) -> t.constructor == Inequality

  if inequalities.length == 0
    throw "No inequalities in expression: #{terms}"

  if inequalities.length > 1
    throw "Too many inequalities in expression: #{terms}"

  inequality = inequalities[0]
  index = terms.indexOf inequality

  if index == terms.length - 1
    throw "Inequality at the end of expression: #{terms}"

  invert = (term) -> new Term term.coefficient * -1, term.variable

  zero = new Term 0, "c"

  left = terms.slice(0, index)
  right = terms.slice(index + 1)

  if inequality.sign == "<"
    return left.concat(right.map(invert), inequality, zero)
  else
    inequality = new Inequality "<"
    return left.map(invert).concat(right, inequality, zero)

normalise_inequation = (terms, i=new Inequation 0, 0, 0) ->
  if terms.length == 0
    throw "Unexpected end of expression"

  if terms[0].constructor == Inequality
    return i

  term = terms[0]
  inequation = switch term.variable
    when "x" then new Inequation i.x + term.coefficient, i.y, i.c
    when "y" then new Inequation i.x, i.y + term.coefficient, i.c
    when "c" then new Inequation i.x, i.y, i.c + term.coefficient
    else throw "Unexpected term '#{term}'"

  return normalise_inequation terms.slice(1), inequation

# These inputs should all be parseable. Not a maximally reduced set,
# but I think this covers everything
good = ["2x + 0.5y < 350", "-3x+2y-50<0","-x-3y-1>0", "2<x+y", "2x+-5y+5-x+6>0"]

console.log "Good inputs:\n"
for i in good
  console.log i

  tokens = lex i
  console.log tokens.join(" ")

  converted = convert_operators tokens
  console.log converted.join(" ")

  parsed = parse converted
  console.log parsed.join(" ")

  converted = convert_inequality parsed
  console.log converted.join(" ")

  normalised = normalise_inequation converted
  console.log normalised.toString()

  console.log ""

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
