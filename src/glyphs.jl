module Glyphs
    typealias NullString Union(String, Nothing)
    typealias NullFloat Union(Float64, Nothing)
    typealias NullInt Union(Int, Nothing)

    type Glyph
        gtype::String
        linewidth::NullInt
        linecolor::NullString
        fillcolor::NullString
        linealpha::NullFloat
        fillalpha::NullFloat
        size::NullInt
        dash::Union(Nothing, Array{Int, 1})
    end

    function Base.show(io::IO, g::Glyph)
        names = Glyph.names
        features = String[]
        for name in Glyph.names
            showname = name == :gtype ? :type : name
            g.(name) != nothing && push!(features, "$showname: $(g.(name))")
        end
        print(io, "<Glyph ", join(features, ", "), ">")
    end

    function Glyph(;glyphtype=nothing,
    	            linewidth=nothing, 
                    linecolor=nothing, 
                    fillcolor=nothing, 
                    linealpha=nothing, 
                    fillalpha=nothing, 
                    size=nothing, 
                    dash=nothing)
        glyphtype == nothing && error("glyphtype is required in Glyph definitions")
    	Glyph(glyphtype, linewidth, linecolor, fillcolor, linealpha, fillalpha, size, dash)
    end

    function Circle(;linewidth=1, linecolor="blue", fillcolor="blue", linealpha=1, fillalpha=0.5, size=4)
        Glyph(glyphtype="circle", linewidth=linewidth, linecolor=linecolor, 
            fillcolor=fillcolor, linealpha=linealpha, fillalpha=fillalpha, size=size)
    end

    function Line(;linewidth=1, linecolor="blue", linealpha=1.0, dash=nothing)
        Glyph(glyphtype="line", linewidth=linewidth, linecolor=linecolor, linealpha=linealpha, dash=dash)
    end
end

typealias Glyph Glyphs.Glyph

typealias NullRange Union(Range, Nothing)

type DataColumn
    columns::Array{String, 1}
    data::Dict{String, RealVect}
    glyph::Glyph
    xrange::NullRange
    yrange::NullRange
end

function DataColumn(xdata::RealVect, ydata::RealVect, glyph::Glyph)
	data = ["x" => xdata, "y" => ydata]
	DataColumn(["x", "y"], data, glyph, nothing, nothing)
end

type Plot
    datacolumns::Array{DataColumn, 1}
    filename::String
    title::String
    width::Int
    height::Int
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
    styd = Dict{Symbol, Any}([:glyphtype => "line"])

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

    filledglyphs = ["circle"]
    if in(styd[:glyphtype], filledglyphs)
        styd[:fillcolor] = styd[:linecolor]
        styd[:fillalpha] = DEFAULT_FILL_ALPHA
    end
    sizeglyphs = ["circle"]
    if in(styd[:glyphtype], sizeglyphs)
        !haskey(styd, :size) && (styd[:size] = DEFAULT_SIZE)
    end
    # @show styd
    Glyph(;styd...)
end