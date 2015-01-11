using Compat

module GlyphBase
    function Circle(;linewidth=1, linecolor="blue", fillcolor="blue", linealpha=1.0, fillalpha=0.5, size=4)
        Bokehjs.Glyph(glyphtype=:Circle, linewidth=linewidth, linecolor=linecolor, 
            fillcolor=fillcolor, linealpha=linealpha, fillalpha=fillalpha, size=size)
    end

    function Line(;linewidth=1, linecolor="blue", linealpha=1.0, dash=nothing)
        Bokehjs.Glyph(glyphtype=:Line, linewidth=linewidth, linecolor=linecolor, linealpha=linealpha, dash=dash)
    end
end

typealias NullRange Union(Range, Nothing)

type DataColumn
    data::Dict{String, RealVect}
    glyph::Glyph
    legend::NullString
    xrange::NullRange
    yrange::NullRange
end

function DataColumn(xdata::RealVect, ydata::RealVect, args...)
    data = @compat Dict{String, RealVect}("x" => xdata, "y" => ydata)
    DataColumn(data, args...)
end

function DataColumn(data::Dict{String, RealVect}, 
                    glyph::Glyph, 
                    legend::NullString=nothing)
    DataColumn(data, glyph, legend, nothing, nothing)
end

type Plot
    datacolumns::Array{DataColumn, 1}
    tools::Vector{Symbol}
    filename::String
    title::String
    width::Int
    height::Int
    x_axis_type::NullSymbol
    y_axis_type::NullSymbol
    legendsgo::NullSymbol
end

# both the string and the reversed string will be tried, eg. "ox" is equivilent to "xo"
STRINGTOKENS = @compat Dict(
    "--"=>@Compat.compat(Dict(:dash=>[4, 4])),
    "-."=>@Compat.compat(Dict(:dash=>[1, 4, 2])),
    "ox"=>@Compat.compat(Dict(:glyphtype=>:CircleX)),
    "o+"=>@Compat.compat(Dict(:glyphtype=>:CircleCross)),
    "sx"=>@Compat.compat(Dict(:glyphtype=>:SquareX)),
    "s+"=>@Compat.compat(Dict(:glyphtype=>:SquareCross)),
)

for (k, v) in Dict(STRINGTOKENS)
    STRINGTOKENS[reverse(k)] = v
end

# heavily borrowed from Winston, thanks Winston!
const CHARTOKENS = @compat Dict(
    '-'=>@Compat.compat(Dict(:dash=>nothing)),
    ':'=>@Compat.compat(Dict(:dash=>[1, 4])),
    ';'=>@Compat.compat(Dict(:dash=>[1, 4, 2])),
    '+'=>@Compat.compat(Dict(:glyphtype=>:Cross)),
    'o'=>@Compat.compat(Dict(:glyphtype=>:Circle)),
    '*'=>@Compat.compat(Dict(:glyphtype=>:Asterisk)),
    # '.'=>@Compat.compat(Dict(:glyphtype=>"dot")),
    'x'=>@Compat.compat(Dict(:glyphtype=>:X)),
    's'=>@Compat.compat(Dict(:glyphtype=>:Square)),
    'd'=>@Compat.compat(Dict(:glyphtype=>:Diamond)),
    '^'=>@Compat.compat(Dict(:glyphtype=>:Triangle)),
    'v'=>@Compat.compat(Dict(:glyphtype=>:InvertedTriangle)),
    'y'=>@Compat.compat(Dict(:linecolor=>"yellow")),
    'm'=>@Compat.compat(Dict(:linecolor=>"magenta")),
    'c'=>@Compat.compat(Dict(:linecolor=>"cyan")),
    'r'=>@Compat.compat(Dict(:linecolor=>"red")),
    'g'=>@Compat.compat(Dict(:linecolor=>"green")),
    'b'=>@Compat.compat(Dict(:linecolor=>"blue")),
    'w'=>@Compat.compat(Dict(:linecolor=>"white")),
    'k'=>@Compat.compat(Dict(:linecolor=>"black")),
)

Base.convert(::Type{Array{Glyph, 1}}, glyph::Glyph) = [glyph]

function Base.convert(::Type{Array{Glyph, 1}}, styles::String)
    map(style -> convert(Glyph, style), split(styles, '|'))
end

function Base.convert(::Type{Glyph}, style::String)
    styd = @compat Dict(:glyphtype=>:Line, :linecolor=>"blue", :linewidth=>1, :linealpha=>1.0)
    for key in keys(STRINGTOKENS)
        splitstyle = split(style, key)
        if length(splitstyle) > 1
            for (k, v) in STRINGTOKENS[key]
                styd[k] = v
            end
            style = join(splitstyle)
        end
    end

    for char in style
        if haskey(CHARTOKENS, char)
            for (k, v) in CHARTOKENS[char]
                styd[k] = v
            end
        else
            warn("unrecognized char '$char'")
        end
    end

    filledglyphs = [:Circle, :Square, :Diamond, :Triangle, :InvertedTriangle]
    if in(styd[:glyphtype], filledglyphs)
        styd[:fillcolor] = styd[:linecolor]
        styd[:fillalpha] = DEFAULT_FILL_ALPHA
        # this seems to be the best way of making plots look right, better ideas?
        styd[:linealpha] = DEFAULT_FILL_ALPHA
        styd[:size] = DEFAULT_SIZE
    end
    emptyglyphs = [:CircleX, :CircleCross, :SquareX, :SquareCross]
    if in(styd[:glyphtype], emptyglyphs)
        styd[:fillcolor] = "transparent"
        styd[:size] = DEFAULT_SIZE
    end
    Glyph(;styd...)
end