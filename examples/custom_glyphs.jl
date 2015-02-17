using Bokeh
using Compat
autoopen(true)

function pallette(y)
    # this method simply maps a continuously varying vector to these 11 colours
    colours = ["#000000", "#190000", "#320000", "#4b0000", "#640000", "#7d0000", "#960000", 
               "#af0000", "#c80000", "#e10000", "#ff0000"]
    low = minimum(y)
    high= maximum(y)
    y_ints = Int64[floor(9.99*(x-low)/(high-low)) + 1 for x in y]
    [colours[i] for i in y_ints]
end

omega = 0:0.1:2pi
# x and y simply describe a circle of radius 1
x1 = cos(omega)
y1 = sin(omega)

# size is just another varying vector used to plot something pretty
size1 = map(x -> 0.1 - 0.05*cos(4x), omega)

data1 = Dict{Symbol, Vector}({:x => x1, :y => y1, :size => size1, :colours => pallette(size1)})

x2 = x1*0.8
y2 = y1*0.8
size2 = map(x -> 0.1 + 0.05*cos(4x), omega)

data2 = Dict{Symbol, Vector}({:x => x2, :y => y2, :size => size2, :colours => pallette(size2)})

fields = @compat Dict{Symbol, Symbol}(:fillcolor=>:colours, :size=>:size)
varying_glyph = Glyph(:Circle, linewidth=1, linecolor="transparent", fields=fields)
# note that varying_glyph is independent of the actual data so it can be reused
plot([BokehDataSet(data1, varying_glyph), BokehDataSet(data2, varying_glyph)], title="Custom Glyphs")