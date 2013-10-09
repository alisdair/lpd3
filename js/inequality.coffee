# These inputs should all be parseable. Not a maximally reduced set,
# but I think this covers everything
good = ["2x + 0.5y < 350", "-3x+2y-50<0","-x-3y-1>0", "2<x+y", "2x+-5y+5+6>0"]

# These should be invalid.
bad  = ["< 5", "horse", "x + y + z < 0", "x = 0"]

# Normal form of the inequality is x + y + c < 0
inequality = (x, y, c) -> {x: x, y: y, c: c}

lex = (input) ->
  tokens = []
  while input.length > 0
    # Extract previous token type (if any)
    token = tokens.slice(-1)[0]
    state = token[0] if token?

    # Ignore whitespace
    result = /^\s+/.exec input
    if result
      input = input.slice(result.index + result[0].length)
      continue

    # Operators must follow coefficients or variables
    if state == "COEFFICIENT" or state == "VARIABLE"
      result = /^[<>+-]/.exec input
      if result
        input = input.slice(result.index + result[0].length)
        tokens.push ["OPERATOR", result[0]]
        continue

    # Coefficients can exist at the start of an expression, or after an operator
    if not state or state == "OPERATOR"
      result = /^(-?[0-9]+(\.[0-9]+)?)|(-)/.exec input
      if result
        input = input.slice(result.index + result[0].length)
        tokens.push ["COEFFICIENT", result[0]]
        continue

    # Variables can come at any point except after a variable
    if state != "VARIABLE"
      result = /^[xyXY]/.exec input
      if result
        input = input.slice(result.index + result[0].length)
        tokens.push ["VARIABLE", result[0]]
        continue

    throw "Parse error at '#{input}' (tokens: #{tokens}, state: #{state})"

  tokens

for i in good
  console.log i, lex(i)

for i in bad
  try
    tokens = lex(i)
    console.log "Should not have been able to lex '#{i}'"
    console.log "Result: ", tokens
  catch e
    console.log e
