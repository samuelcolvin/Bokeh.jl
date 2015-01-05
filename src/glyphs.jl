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

# heavily borrowed from Winston, thanks Winston!
const chartokens = @compat Dict(
    '-'=>@Compat.compat(Dict(:dash=>nothing)),
    ':'=>@Compat.compat(Dict(:dash=>[1, 4])),
    ';'=>@Compat.compat(Dict(:dash=>[1, 4, 2])),
    # '+'=>@Compat.compat(Dict(:glyphtype=>"plus")),
    'o'=>@Compat.compat(Dict(:glyphtype=>:Circle)),
    # '*'=>@Compat.compat(Dict(:glyphtype=>"asterisk")),
    # '.'=>@Compat.compat(Dict(:glyphtype=>"dot")),
    # 'x'=>@Compat.compat(Dict(:glyphtype=>"cross")),
    's'=>@Compat.compat(Dict(:glyphtype=>:Square)),
    # 'd'=>@Compat.compat(Dict(:glyphtype=>"diamond")),
    # '^'=>@Compat.compat(Dict(:glyphtype=>"triangle")),
    # 'v'=>@Compat.compat(Dict(:glyphtype=>"down-triangle")),
    # '>'=>@Compat.compat(Dict(:glyphtype=>"right-triangle")),
    # '<'=>@Compat.compat(Dict(:glyphtype=>"left-triangle")),
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

    for (k,v) in @compat Dict("--"=>[4, 4], "-."=>[1, 4, 2], ".-"=>[1, 4, 2])
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

    filledglyphs = [:Circle, :Square]
    if in(styd[:glyphtype], filledglyphs)
        styd[:fillcolor] = styd[:linecolor]
        styd[:fillalpha] = DEFAULT_FILL_ALPHA
    end
    Glyph(;styd...)
end