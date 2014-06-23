include("browser.jl")
include("generate.jl")

typealias URange Union(Union(Range, UnitRange))

function show(plot::Plot)
    openhtml(plot.filename)
end

function plot(columns::Array{DataColumn, 1};
              title::String=TITLE, width::Int=WIDTH, height::Int=HEIGHT,
              filename::String=FILENAME, autoopen::Bool=AUTOOPEN)
    plt = Plot(columns, filename, title, width, height)
    if autoopen
        models, plotcon = genmodels(plt)
        rendertemplate(models, plotcon, plt.filename)
        show(plt)
    end
    return plt
end

function plot(x::Real1d, y::Real1d;glyph=DEFAULT_LINE, kwargs...)
    dcs = DataColumn[DataColumn(x, y, glyph)]
	plot(dcs; kwargs...)
end

function plot(x::Real1d, y::Real1d, style; kwargs...)
    g = convert(Glyph, style)
    plot(x, y; glyph=g, kwargs...)
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