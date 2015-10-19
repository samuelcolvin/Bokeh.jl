# Glyph has to be a Bokehjs type as it's defined directly in Bokeh's JSON, but these methods are
# more porcelain than plumbing, so are defined here.
function Bokehjs.Glyph(glyphtype::Symbol,
                       linecolor::NullString,
                       linewidth::NullInt,
                       linealpha::NullFloat,
                       fillcolor::NullString,
                       fillalpha::NullFloat,
                       size::NullInt,
                       dash::Union{Void, Vector{Int64}},
                       fields::Union{Void, Dict{Symbol, Symbol}})
    props = Dict(
        :linecolor => linecolor == nothing ? omit : Dict{Symbol, BkAny}(:value => linecolor),
        :linewidth => linewidth == nothing ? omit : Dict{Symbol, BkAny}(:units => :data, :value =>linewidth),
        :linealpha => linealpha == nothing ? omit : Dict{Symbol, BkAny}(:units => :data, :value =>linealpha),
        :fillalpha => fillalpha == nothing ? omit : Dict{Symbol, BkAny}(:units => :data, :value =>fillalpha),
        :size => size == nothing ? omit : Dict{Symbol, BkAny}(:units => :screen, :value =>size),
        :fillcolor => fillcolor == nothing ? omit : Dict{Symbol, BkAny}(:value =>fillcolor),
    )
    if fields != nothing
        for (field, val) in fields
            if !haskey(props, field)
                error("unknown field $(field) passed to Glyph")
            end
            props[field] = Dict{Symbol,BkAny}(:field => val, :units => :data)
        end
    end
    Glyph(Bokehjs.uuid4(),
          glyphtype,
          props[:linecolor],
          props[:linewidth],
          props[:linealpha],
          props[:fillcolor],
          props[:fillalpha],
          props[:size],
          dash == nothing ? omit : dash,
          Dict(:units =>:data, :field => :x),
          Dict(:units =>:data, :field => :y))
end

function Bokehjs.Glyph(;glyphtype=nothing,
                        linecolor=nothing,
                        linewidth=nothing,
                        linealpha=nothing,
                        fillcolor=nothing,
                        fillalpha=nothing,
                        size=nothing,
                        dash=nothing,
                        fields=nothing)
    glyphtype = glyphtype == nothing ? :Line : glyphtype
    Glyph(glyphtype, linecolor, linewidth, linealpha, fillcolor, fillalpha,
          size, dash, fields)
end

function Bokehjs.Glyph(glyphtype::Symbol; kwargs...)
    Glyph(glyphtype=glyphtype; kwargs...)
end

function Base.show(io::IO, g::Bokehjs.Glyph)
    names = Glyph.names
    features = AbstractString[]
    for field in fieldnames(Glyph)
        showname = field == :_type_name ? :type : field
        g.(field) != nothing && push!(features, "$showname: $(g.(field))")
    end
    print(io, "Glyph(", join(features, ", "), ")")
end

type BokehDataSet
    data::Dict{Symbol, Vector}
    glyph::Glyph
    legend::NullString

    function BokehDataSet(data::Dict{Symbol, Vector}, glyph::Glyph,
                          legend::NullString=nothing)
        new(data, glyph, legend)
    end
end

function BokehDataSet(xdata::RealVect, ydata::RealVect, args...)
    data = Dict{Symbol, Vector}(:x => xdata, :y => ydata)
    BokehDataSet(data, args...)
end

type Plot
    datacolumns::Vector{BokehDataSet}
    tools::Vector{Symbol}
    filename::AbstractString
    title::AbstractString
    width::Int
    height::Int
    x_axis_type::NullSymbol
    y_axis_type::NullSymbol
    legendsgo::NullSymbol
end

# both the string and the reversed string will be tried, eg. "ox" is equivilent
# to "xo"
const STRINGTOKENS = let
    temp = Dict{ASCIIString,Dict{Symbol,Any}}(
            "--" => Dict(:dash      => [4, 4]),
            "-." => Dict(:dash      => [1, 4, 2]),
            "ox" => Dict(:glyphtype => :CircleX),
            "o+" => Dict(:glyphtype => :CircleCross),
            "sx" => Dict(:glyphtype => :SquareX),
            "s+" => Dict(:glyphtype => :SquareCross),
        )

    for (k, v) in Dict(temp)
        temp[reverse(k)] = v
    end
    temp
end

# heavily borrowed from Winston, thanks Winston!
const CHARTOKENS = Dict(
    '-'=> Dict(:dash=>nothing),
    ':'=> Dict(:dash=>[1, 4]),
    ';'=> Dict(:dash=>[1, 4, 2]),
    '+'=> Dict(:glyphtype=>:Cross),
    'o'=> Dict(:glyphtype=>:Circle),
    '*'=> Dict(:glyphtype=>:Asterisk),
    '.'=> Dict(:glyphtype=>:Circle, :size=>2),
    'x'=> Dict(:glyphtype=>:X),
    's'=> Dict(:glyphtype=>:Square),
    'd'=> Dict(:glyphtype=>:Diamond),
    '^'=> Dict(:glyphtype=>:Triangle),
    'v'=> Dict(:glyphtype=>:InvertedTriangle),
    'y'=> Dict(:linecolor=>"yellow"),
    'm'=> Dict(:linecolor=>"magenta"),
    'c'=> Dict(:linecolor=>"cyan"),
    'r'=> Dict(:linecolor=>"red"),
    'g'=> Dict(:linecolor=>"green"),
    'b'=> Dict(:linecolor=>"blue"),
    'w'=> Dict(:linecolor=>"white"),
    'k'=> Dict(:linecolor=>"black"),
)

Base.convert(::Type{Array{Glyph, 1}}, glyph::Glyph) = [glyph]

function Base.convert(::Type{Array{Glyph, 1}}, styles::AbstractString)
    map(style -> convert(Glyph, style), split(styles, '|'))
end

function Base.convert(::Type{Glyph}, style::AbstractString)
    # start wil default style
    styd = Dict(:glyphtype=>:Line, :linecolor=>"blue", :linewidth=>1,
                :linealpha=>1.0)

    # loop over all string tokens
    for key in keys(STRINGTOKENS)
        splitstyle = split(style, key)

        # if we found a match, apply it
        if length(splitstyle) > 1
            for (k, v) in STRINGTOKENS[key]
                styd[k] = v
            end

            # then remove it from `style` to start next loop
            style = join(splitstyle)
        end
    end

    # if we still have any char tokens left, process them
    for char in style
        if haskey(CHARTOKENS, char)
            for (k, v) in CHARTOKENS[char]
                styd[k] = v
            end
        else
            warn("unrecognized char '$char'")
        end
    end

    # set sane defaults for glyphs that are supposed to be filled or empty
    filledglyphs = [:Circle, :Square, :Diamond, :Triangle, :InvertedTriangle]
    if in(styd[:glyphtype], filledglyphs)
        styd[:fillcolor] = styd[:linecolor]
        styd[:fillalpha] = DEFAULT_FILL_ALPHA
        styd[:linealpha] = DEFAULT_FILL_ALPHA
        if !haskey(styd, :size)
            styd[:size] = DEFAULT_SIZE
        end
    end

    emptyglyphs = [:CircleX, :CircleCross, :SquareX, :SquareCross]
    if in(styd[:glyphtype], emptyglyphs)
        styd[:fillcolor] = "transparent"
        styd[:size] = DEFAULT_SIZE
    end

     # set sane defaults for glyphs that are supposed to be filled or empty
    Glyph(;styd...)
end
