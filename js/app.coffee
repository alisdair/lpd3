inequality = (x, y, c) ->
  x: x
  y: y
  c: c
  enabled: true

# FIXME: possibly the worst function I have ever written
polynomial = (inequality) ->
  if inequality.x != 0 and inequality.y != 0
    x = "#{inequality.x}x"
    y = "#{Math.abs(inequality.y)}y"
    if inequality.x == 1
      x = "x"
    if inequality.y == 1
      y = "y"
    if inequality.y > 0
      sign = "+"
    else
      sign = "-"
    "#{x} #{sign} #{y} < #{inequality.c * -1}"
  else if inequality.x == 0
    y = "#{Math.abs(inequality.y)}y"
    if Math.abs(inequality.y) == 1
      y = "y"
    if inequality.y < 0
      sign = ">"
      c = inequality.c
    else
      sign = "<"
      c = inequality.c * -1
    "#{y} #{sign} #{c}"
  else if inequality.y == 0
    x = "#{Math.abs(inequality.x)}x"
    if Math.abs(inequality.x) == 1
      x = "x"
    if inequality.x < 0
      sign = ">"
      c = inequality.c
    else
      sign = "<"
      c = inequality.c * -1
    "#{x} #{sign} #{c}"
  else
    "idk"

program = [
    inequality 1, 1, -210
    inequality 2, 1, -280
    inequality -1, 0, 0
    inequality 0, -1, 0
  ]

$ ->
  margin =
    top: 20
    right: 10
    bottom: 20
    left: 10

  width = 480 - margin.left - margin.right
  height = 480 - margin.top - margin.bottom

  vis = d3.select("#diagram")
    .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(#{margin.left}, #{margin.top})")

  xs = _.map(program, (d) -> -d.c / d.x)
  ys = _.map(program, (d) -> -d.c / d.y)
  x = d3.scale.linear().range([0, width]).domain([_.min(xs), _.max(xs)])
  y = d3.scale.linear().range([height, 0]).domain([_.min(ys), _.max(ys)])

  do update = (data=program) ->
    lines = vis.selectAll(".inequality")
      .data(data)
    lines.enter().append("svg:line")
    lines.attr("class", (d, i) -> "inequality inequality_#{i}")
        .attr("x1", x(0))
        .attr("y1", (d) -> if d.y == 0 then y(_.max(ys)) else y(-d.c / d.y))
        .attr("x2", (d) -> if d.x == 0 then x(_.max(xs)) else x(-d.c / d.x))
        .attr("y2", y(0))
        .classed("hidden", (d) -> not d.enabled)

  _.each program, (inequality, i) ->
    selector = "inequality_#{i}"
    input = "<input type='checkbox' id='#{selector}_checkbox' data-index='#{i}' #{if inequality.enabled then "checked" else ""}>"
    label = polynomial(inequality)
    $("#program").append("<label>#{input} #{label}")

  $("#program input").on "change", (e) ->
    index = parseInt $(this).data("index")
    program[index].enabled = $(this).is(":checked")
    update program
