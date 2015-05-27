using Bokeh
using Compat
hold(true)
Bokeh.debug(true)

plotfile("glyphs_custom.html")

x = linspace(0, 2pi, 10)
y = 1 + 0.5sin(x)
# you can get a list of markers from https://github.com/bokeh/bokeh/blob/master/bokeh/models/markers.py
glyph_with_everything = Glyph(:DiamondCross, 
							  linecolor="red", 
							  linewidth=2, 
							  linealpha=0.7,
							  dash=[4,1],
							  fillcolor="#88f",
							  fillalpha=0.5,
							  size=50)
plot([y y*-1], [Glyph(:Asterisk), glyph_with_everything])
palette = ["#000000", "#190000", "#320000", "#4b0000", "#640000", "#7d0000", "#960000", "#af0000", "#c80000", "#e10000", "#ff0000"]
low = minimum(y)
high= maximum(y)
y_ints = Int64[floor(9.99*(x-low)/(high-low)) + 1 for x in y]  # round to nearest value in range 1:11
y_colours = [palette[i] for i in y_ints]

data = @compat Dict{Symbol, Vector}(:x => collect(x), :y => y, :y_colours => y_colours, :y_sizes => y)
fields = @compat Dict{Symbol, Symbol}(:fillcolor=>:y_colours, :size=>:y_sizes)
varying_glyph = Glyph(:Circle, size=30, linewidth=3, fields=fields)
plot([BokehDataSet(data, varying_glyph)])
showplot()