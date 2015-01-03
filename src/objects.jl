module GlyphBase
    function Circle(;linewidth=1, linecolor="blue", fillcolor="blue", linealpha=1.0, fillalpha=0.5, size=4)
        Bokehjs.Glyph(glyphtype="Circle", linewidth=linewidth, linecolor=linecolor, 
            fillcolor=fillcolor, linealpha=linealpha, fillalpha=fillalpha, size=size)
    end

    function Line(;linewidth=1, linecolor="blue", linealpha=1.0, dash=nothing)
        Bokehjs.Glyph(glyphtype="Line", linewidth=linewidth, linecolor=linecolor, linealpha=linealpha, dash=dash)
    end
end

typealias NullRange Union(Range, Nothing)

type DataColumn
    columns::Array{String, 1}
    data::Dict{String, RealVect}
    glyph::Glyph
    legend::NullString
    xrange::NullRange
    yrange::NullRange
end

function DataColumn(xdata::RealVect, ydata::RealVect, glyph::Glyph, legend::NullString=nothing)
	data = ["x" => xdata, "y" => ydata]
	DataColumn(["x", "y"], data, glyph, legend, nothing, nothing)
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

# heavily borrowed from Winston, thanks Winston!

const chartokens = [
    '-' => {:dash => nothing},
    ':' => {:dash => [1, 4]},
    ';' => {:dash => [1, 4, 2]},
    # '+' => {:glyphtype => "plus"},
    'o' => {:glyphtype => "circle"},
    # '*' => {:glyphtype => "asterisk"},
    # '.' => {:glyphtype => "dot"},
    # 'x' => {:glyphtype => "cross"},
    # 's' => {:glyphtype => "square"},
    # 'd' => {:glyphtype => "diamond"},
    # '^' => {:glyphtype => "triangle"},
    # 'v' => {:glyphtype => "down-triangle"},
    # '>' => {:glyphtype => "right-triangle"},
    # '<' => {:glyphtype => "left-triangle"},
    'y' => {:linecolor => "yellow"},
    'm' => {:linecolor => "magenta"},
    'c' => {:linecolor => "cyan"},
    'r' => {:linecolor => "red"},
    'g' => {:linecolor => "green"},
    'b' => {:linecolor => "blue"},
    'w' => {:linecolor => "white"},
    'k' => {:linecolor => "black"},
]

function Base.convert(::Type{Array{Glyph, 1}}, styles::String)
    map(style -> convert(Glyph, style), split(styles, '|'))
end

function Base.convert(::Type{Glyph}, style::String)
    styd = Dict{Symbol, Any}([:glyphtype => "Line", :linecolor => "blue", :linewidth => 1, :linealpha => 1.0])

    for (k,v) in [ "--" => [4, 4], "-." => [1, 4, 2], ".-" => [1, 4, 2] ]
        splitstyle = split(style, k)
        if length(splitstyle) > 1
            styd[:dash] = v
            style = join(splitstyle)
        end
    end

    for char in style
        if haskey(chartokens, char)
            for (k,v) in chartokens[char]
                styd[k] = v
            end
        else
            warn("unrecognized char '$char'")
        end
    end

    filledglyphs = ["Circle"]
    if in(styd[:glyphtype], filledglyphs)
        styd[:fillcolor] = styd[:linecolor]
        styd[:fillalpha] = DEFAULT_FILL_ALPHA
    end
    sizeglyphs = ["Circle"]
    if in(styd[:glyphtype], sizeglyphs)
        !haskey(styd, :size) && (styd[:size] = DEFAULT_SIZE)
    end
    # @show styd
    Glyph(;styd...)
end