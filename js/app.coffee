$ ->
  coefficients = [
    # x, y, c
    [1, 1, -210],
    [2, 1, -280],
    [-1, 0, 0],
    [0, -1, 0]
  ]

  margin =
    top: 20
    right: 10
    bottom: 20
    left: 10

  width = 480 - margin.left - margin.right
  height = 480 - margin.top - margin.bottom

  vis = d3.select("#program")
    .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(#{margin.left}, #{margin.top})")

  xs = _.map(coefficients, (d) -> -d[2] / d[0])
  ys = _.map(coefficients, (d) -> -d[2] / d[1])
  x = d3.scale.linear().range([0, width]).domain([_.min(xs), _.max(xs)])
  y = d3.scale.linear().range([height, 0]).domain([_.min(ys), _.max(ys)])

  vis.selectAll(".inequality")
    .data(coefficients)
    .enter().append("svg:line")
      .attr("class", "inequality")
      .attr("x1", x(0))
      .attr("y1", (d) -> if d[1] == 0 then y(_.max(ys)) else y(-d[2] / d[1]))
      .attr("x2", (d) -> if d[0] == 0 then x(_.max(xs)) else x(-d[2] / d[0]))
      .attr("y2", y(0))
