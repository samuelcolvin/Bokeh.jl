include("browser.jl")
include("generate.jl")

typealias URange Union(Union(Range, UnitRange))

function plot(x::Real1d, y::Real1d;
              title::String="Bokeh Plot", width::Int=WIDTH, height::Int=HEIGHT,
              filename::String=FILENAME, autoopen::Bool=AUTOOPEN)
    glyph = Glyph("line", linewidth=1, linecolor="blue")
    dcs = DataColumn[DataColumn(x, y, glyph)]
	models, plotcon = genmodels(dcs, title, width, height)
	rendertemplate(models, plotcon, filename)
	autoopen && openhtml(filename)
end

function plot(y::Real1d, args...; kwargs...)
	x = 1:length(y)
    plot(x, y, args...; kwargs...)
end

function plot(f::Function, start::Real=-10, stop::Real=10, args...;
			  counteval::Int=COUNTEVAL, kwargs...)
	x = linspace(start, stop, counteval)
	y = map(f, x)
    plot(x, y, args...; kwargs...)
end

function plot(f::Function, rng::URange, args...;kwargs...)
	stop = isdefined(rng, :stop) ? rng.stop : rng.len
    plot(f, rng.start, stop, args...; kwargs...)
end

const chartokens = [
    '-' => {:linekind => "solid"},
    ':' => {:linekind => "dotted"},
    ';' => {:linekind => "dotdashed"},
    '+' => {:symbolkind => "plus"},
    'o' => {:symbolkind => "circle"},
    '*' => {:symbolkind => "asterisk"},
    '.' => {:symbolkind => "dot"},
    'x' => {:symbolkind => "cross"},
    's' => {:symbolkind => "square"},
    'd' => {:symbolkind => "diamond"},
    '^' => {:symbolkind => "triangle"},
    'v' => {:symbolkind => "down-triangle"},
    '>' => {:symbolkind => "right-triangle"},
    '<' => {:symbolkind => "left-triangle"},
    'y' => {:color => "yellow"},
    'm' => {:color => "magenta"},
    'c' => {:color => "cyan"},
    'r' => {:color => "red"},
    'g' => {:color => "green"},
    'b' => {:color => "blue"},
    'w' => {:color => "white"},
    'k' => {:color => "black"},
]

function parse_spec(spec::String)
    try
        return { :color => Color.color(spec) }
    end

    style = Dict()

    for (k,v) in [ "--" => "dashed", "-." => "dotdashed" ]
        splitspec = split(spec, k)
        if length(splitspec) > 1
            style[:linekind] = v
            spec = join(splitspec)
        end
    end

    for char in spec
        if haskey(chartokens, char)
            for (k,v) in chartokens[char]
                style[k] = v
            end
        else
            warn("unrecognized style '$char'")
        end
    end

    style
end