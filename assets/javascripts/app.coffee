#= require jquery-2.0.3
#= require d3.v3
#= require lodash
#= require inequality

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
    new Inequation 1, 1, -210
    new Inequation 2, 1, -280
    new Inequation -1, 0, 0
    new Inequation 0, -1, 0
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

  do update = (data=program) ->
    xs = _.map(program, (d) -> -d.c / d.x)
    ys = _.map(program, (d) -> -d.c / d.y)
    x = d3.scale.linear().range([0, width]).domain([_.min(xs), _.max(xs)])
    y = d3.scale.linear().range([height, 0]).domain([_.min(ys), _.max(ys)])

    lines = vis.selectAll(".inequality")
      .data(data)
    lines.enter().append("svg:line")
    lines.attr("class", (d, i) -> "inequality inequality_#{i}")
        .attr("x1", x(_.min(xs)))
        .attr("y1", (d) -> if d.y == 0 then y(_.max(ys)) else y(-d.c / d.y))
        .attr("x2", (d) -> if d.x == 0 then x(_.max(xs)) else x(-d.c / d.x))
        .attr("y2", y(_.min(ys)))
        .classed("hidden", (d) -> not d.enabled)
    areas = vis.selectAll(".region")
      .data(data)
    areas.enter().append("svg:path")
    areas.attr("class", (d, i) -> "region region_#{i}")
      .classed("hidden", (d) -> not d.enabled)
      .attr("d", (d) ->
        x1 = x(_.min(xs))
        y1 = if d.y == 0 then y(_.max(ys)) else y(-d.c / d.y)
        x2 = if d.x == 0 then x(_.max(xs)) else x(-d.c / d.x)
        y2 = y(_.min(ys))
        if d.x > 0
          x3 = x(_.min(xs))
        else
          x3 = x(_.max(xs))
        if d.y > 0
          y3 = y(_.min(ys))
        else
          y3 = y(_.max(ys))
        "M #{x1} #{y1} L #{x2} #{y2} L #{x3} #{y3} Z"
      )

  _.each program, (inequality, i) ->
    selector = "inequality_#{i}"
    input = "<input type='checkbox' id='#{selector}_checkbox' data-index='#{i}' #{if inequality.enabled then "checked" else ""}>"
    label = polynomial(inequality)
    $("#program").append("<label>#{input} #{label}")

  $("#program input").on "change", (e) ->
    index = parseInt $(this).data("index")
    program[index].enabled = $(this).is(":checked")
    update program
