typealias URange Union(Union(Range, UnitRange))

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

function plot(x::RealMat, y::RealMat, styles::String=DEFAULT_GLYPHS_STR; glyphs::Vector{Glyph}=DEFAULT_GLYPHS, kwargs...)
    size(x) != size(y) && error("size of x and y are not equal: x: $(size(x)), y: $(size(y))")
    glyphs = glyphs == DEFAULT_GLYPHS ? convert(Vector{Glyph}, styles) : glyphs
    cols = size(x,2)
    glyphs = repmat(glyphs, int(ceil(cols / length(glyphs))))
    dcs = DataColumn[DataColumn(x[:,i], y[:,i], glyphs[i]) for i in 1:cols]
    plot(dcs; kwargs...)
end

function plot(columns::Array{DataColumn, 1};
              title::String=TITLE, width::Int=WIDTH, height::Int=HEIGHT,
              filename::String=FILENAME, autoopen::Bool=AUTOOPEN)
    if CURPLOT == nothing
        plt = Plot(columns, filename, title, width, height)
        HOLD && (global CURPLOT = plt)
    else
        append!(CURPLOT.datacolumns, columns)
        filename != FILENAME && (CURPLOT.filename = filename)
        title != TITLE && (CURPLOT.title = title)
        width != WIDTH && (CURPLOT.width = width)
        height != HEIGHT && (CURPLOT.height = height)
        plt = CURPLOT
    end
    !isinteractive() && autoopen && display(plt)
    return plt
end