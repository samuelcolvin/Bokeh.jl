include("browser.jl")
include("generate.jl")

typealias URange Union(Union(Range, UnitRange))

function show(plot::Plot)
    openhtml(plot.filename)
end

function plot(f::Function, args...;kwargs...)
    plot([f], args...; kwargs...)
end

function plot(fs::Vector{Function}, rng::URange, args...;kwargs...)
    stop = isdefined(rng, :stop) ? rng.stop : rng.len
    plot(fs, rng.start, stop, args...; kwargs...)
end

function plot(fs::Vector{Function}, start::Real=-10, stop::Real=10, args...;
              counteval::Int=COUNTEVAL, kwargs...)
    x = linspace(start, stop, counteval)
    y = Array(Float64, counteval, length(fs))
    for (i, f) in enumerate(fs)
        y[:, i] = map(f, x)
    end
    x = repmat(x, 1, length(fs))
    plot(x, y, args...; kwargs...)
end

function plot(x::RealVect, y::RealMat, args...; kwargs...)
    x = repmat(x, 1, size(y, 2))
    plot(x, y, args...; kwargs...)
end

function plot(y::RealMatVect, args...; kwargs...)
    x = 1:size(y, 1)
    x = ndims(y) > 1 ? repmat(x, 1, size(y, 2)) : x
    plot(x, y, args...; kwargs...)
end

function plot(x::RealVect, y::RealVect, args...; kwargs...)
    # is there a more efficient way of forcing a matrix ?
    # this seems ugly but is apparently pretty quick even for big mats
    plot(reshape(x, length(x), 1), reshape(y, length(y), 1), args...; kwargs...)
end
function plot(x::RealMat, y::RealMat, style::String=DEFAULT_LINE_STR; glyph=DEFAULT_LINE, kwargs...)
    size(x) != size(y) && error("size of x and y are not equal: x: $(size(x)), y: $(size(y))")
    glyph = glyph == DEFAULT_LINE ? convert(Glyph, style) : glyph
    dcs = DataColumn[DataColumn(x[:,i], y[:,i], glyph) for i in 1:size(x,2)]
    plot(dcs; kwargs...)
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