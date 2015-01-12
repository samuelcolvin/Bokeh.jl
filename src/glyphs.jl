using Compat

# Glyph has to be a Bokehjs type as it's defined directly in Bokeh's JSON, but these methods are
# more porcelain than plumbing, so are defined here. 
function Bokehjs.Glyph(glyphtype::Symbol,
               linecolor::NullString, 
               linewidth::NullInt, 
               linealpha::NullFloat, 
               fillcolor::NullString,
               fillalpha::NullFloat,
               size::NullInt,
               dash::Union(Nothing, Vector{Int64}),
               fields::Union(Nothing, Dict{Symbol, Symbol}))
    props = @Compat.compat Dict(
        :linecolor => linecolor == nothing ? omit : @Compat.compat(Dict{Symbol, BkAny}(:value => linecolor)),
        :linewidth => linewidth == nothing ? omit : @Compat.compat(Dict{Symbol, BkAny}(:units => :data, :value =>linewidth)),
        :linealpha => linealpha == nothing ? omit : @Compat.compat(Dict{Symbol, BkAny}(:units => :data, :value =>linealpha)),
        :fillalpha => fillalpha == nothing ? omit : @Compat.compat(Dict{Symbol, BkAny}(:units => :data, :value =>fillalpha)),
        :size => size == nothing ? omit : @Compat.compat(Dict{Symbol, BkAny}(:units => :screen, :value =>size)),
        :fillcolor => fillcolor == nothing ? omit : @Compat.compat(Dict{Symbol, BkAny}(:value =>fillcolor)),
    )
    if fields != nothing
        for (field, val) in fields
            !haskey(props, field) && error("unknown field $(field) passed to Glyph")
            props[field] = @Compat.compat Dict{Symbol, BkAny}(:field => val, :units => :data)
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
          @Compat.compat(Dict(:units =>:data, :field => :x)), 
          @Compat.compat(Dict(:units =>:data, :field => :y)))
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
    Glyph(glyphtype, linecolor, linewidth, linealpha, fillcolor, fillalpha, size, dash, fields)
end

function Bokehjs.Glyph(glyphtype::Symbol; kwargs...)
    Glyph(glyphtype=glyphtype; kwargs...)
end

function Base.show(io::IO, g::Bokehjs.Glyph)
    names = Glyph.names
    features = String[]
    for name in Glyph.names
        showname = name == :_type_name ? :type : name
        g.(name) != nothing && push!(features, "$showname: $(g.(name))")
    end
    print(io, "Glyph(", join(features, ", "), ")")
end

type BokehDataSet
    data::Dict{Symbol, Vector}
    glyph::Glyph
    legend::NullString
    BokehDataSet(data::Dict{Symbol, Vector}, glyph::Glyph, legend::NullString=nothing) = new(data, glyph, legend)
end

function BokehDataSet(xdata::RealVect, ydata::RealVect, args...)
    data = @compat Dict{Symbol, Vector}(:x => xdata, :y => ydata)
    BokehDataSet(data, args...)
end

type Plot
    datacolumns::Array{BokehDataSet, 1}
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
    '.'=>@Compat.compat(Dict(:glyphtype=>:Circle, :size=>2)),
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
        if !haskey(styd, :size)
            styd[:size] = DEFAULT_SIZE
        end
    end
    emptyglyphs = [:CircleX, :CircleCross, :SquareX, :SquareCross]
    if in(styd[:glyphtype], emptyglyphs)
        styd[:fillcolor] = "transparent"
        styd[:size] = DEFAULT_SIZE
    end
    Glyph(;styd...)
end