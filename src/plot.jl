if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

typealias URange Union(Union(Range, UnitRange))

typealias DTArray Union(AbstractMatrix{DateTime}, AbstractMatrix{Date}, AbstractVector{DateTime}, AbstractVector{Date})

typealias GlyphTypes Union(String, Glyph, Vector{Glyph})

const epoch = DateTime(1970, 1, 1)

unixtime(d::DateTime) = int(d - epoch)

unixtime(d::Date) = int(convert(DateTime, d) - epoch)

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

function plot(x::DTArray, args...; kwargs...)
    plot(map(unixtime, x), args...; x_axis_type=:datetime, kwargs...)
end

function plot(x::RealArray, y::DTArray, args...; kwargs...)
    plot(x, map(unixtime, y), args...; y_axis_type=:datetime, kwargs...)
end

# function getindex_safe(v::Vector{Vector}, i::Int64, j::Int64)
#     (j < 1 || i < 1 || i > length(v)) && return NaN
#     vv = v[i]
#     (j > length(vv)) && return NaN
#     vv[j]
# end

# tomatrix(v::Vector{Vector}) = Float64[getindex_safe(v, i, j) for j=1:maximum(map(length, v)), i=1:length(v)]

function getglyphs(styles::GlyphTypes, count::Int64)
    glyphs = convert(Vector{Glyph}, styles)
    repmat(glyphs, int(ceil(count / length(glyphs))))
end

function plot(y::Vector{Vector}, styles::GlyphTypes=DEFAULT_GLYPHS_STR; kwargs...)
    x = [[1:length(yv)] for yv in y]
    plot(x, y, styles; kwargs...)
end

function plot(x::RealArray, y::Vector{Vector}, args...; kwargs...)
    x = [x[1:length(yv)] for yv in y]
    plot(x, y, args...; kwargs...)
end

function plot{T <: AbstractVector}(x::Vector{T}, y::Vector{Vector}, styles::GlyphTypes=DEFAULT_GLYPHS_STR; kwargs...)
    hold_val = HOLD
    # restart CURPLOT if old was false
    !hold_val && global CURPLOT = nothing
    hold(true)
    lx = length(x)
    lx != length(y) && error("length of x and y are not equal: x: $(length(x)), y: $(length(y))")
    glyphs = getglyphs(styles, lx)
    plt = nothing
    for i in 1:lx
        plt = plot(x[i], y[i], glyphs[i]; kwargs...)
    end
    hold(hold_val)
    # set CURPLOT which may have been cleared by hold(false)
    !hold_val && global CURPLOT = plt
    return plt
end

function plot(y::RealArray, styles::GlyphTypes=DEFAULT_GLYPHS_STR; kwargs...)
    x = 1:size(y, 1)
    x = ndims(y) > 1 ? repmat(x, 1, size(y, 2)) : x
    plot(x, y, styles; kwargs...)
end

function plot(x::RealVect, y::RealMat, args...; kwargs...)
    x = repmat(x, 1, size(y, 2))
    plot(x, y, args...; kwargs...)
end

function plot(x::RealVect, y::RealVect, args...; kwargs...)
    # is there a more efficient way of forcing a matrix ?
    # this seems ugly but is apparently pretty quick even for big mats
    plot(reshape(x, length(x), 1), reshape(y, length(y), 1), args...; kwargs...)
end

function plot(x::RealMat, y::RealMat, styles::GlyphTypes=DEFAULT_GLYPHS_STR; 
              legends::Union(Nothing, Vector)=nothing, kwargs...)
    size(x) != size(y) && error("size of x and y are not equal: x: $(size(x)), y: $(size(y))")
    cols = size(x, 2)
    glyphs = getglyphs(styles, cols)
    legends = legends == nothing ? [nothing for _ in 1:cols] : legends
    dcs = DataColumn[DataColumn(x[:,i], y[:,i], glyphs[i], legends[i]) for i in 1:cols]
    plot(dcs; kwargs...)
end

# there a good if boring reason why we have to use nothing for width, height etc. rather than 
# set the default to WIDTH, HEIGHT etc.: its because we wouldn't be able to specify a new width 
# or height on an extending plot if the new value happened to be the same as WIDTH or HEIGHT
function plot(columns::Array{DataColumn, 1}; extend::Union(Nothing, Plot)=nothing,
              title::NullString=nothing, width::NullInt=nothing, height::NullInt=nothing,
              x_axis_type::NullSymbol=nothing, y_axis_type::NullSymbol=nothing, legendsgo::NullSymbol=nothing,
              plotfile::NullString=nothing, tools::Union(Nothing, Array{Symbol, 1})=nothing, 
              autoopen::Bool=AUTOOPEN)
    extend == nothing && !HOLD && (global CURPLOT = nothing)
    if extend == nothing && CURPLOT == nothing
        plt = Plot(columns, 
                   tools == nothing ? TOOLS : tools, 
                   plotfile == nothing ? PLOTFILE : plotfile, 
                   title == nothing ? TITLE : title, 
                   width == nothing ? WIDTH : width, 
                   height == nothing ? HEIGHT : height,
                   x_axis_type == nothing ? X_AXIS_TYPE : x_axis_type,
                   y_axis_type == nothing ? Y_AXIS_TYPE : y_axis_type,
                   legendsgo)
        extend == nothing && (global CURPLOT = plt)
    else
        function add2plot!(p::Plot)
            append!(p.datacolumns, columns)
            tools != nothing && (p.tools = tools)
            plotfile != nothing && (p.filename = plotfile)
            title != nothing && (p.title = title)
            width != nothing && (p.width = width)
            height != nothing && (p.height = height)
        end
        if extend == nothing
            add2plot!(CURPLOT)
            plt = CURPLOT
        else
            add2plot!(extend)
            plt = extend
        end
    end
    !isinteractive() && autoopen && showplot(plt)
    return plt
end