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
    # use 0:(length - 1) so the x values are the sames as the indices of y
    x = 0:(size(y, 1) - 1)
    x = ndims(y) > 1 ? repmat(x, 1, size(y, 2)) : x
    plot(x, y, args...; kwargs...)
end

# need to work with arrays of arrays as well as mats:
# function plot{T}(y::Array{Array{T,1}, 1}; kwargs...)
#     len = maximum(map(length, y))
#     y2 = zeros(len, length(y))
#     for (i, ar) in enumerate(y)
#         y2[:, 1:length(ar)] = ar
#     end
#     plot(y2; kwargs...)
# end

function plot(x::RealVect, y::RealVect, args...; kwargs...)
    # is there a more efficient way of forcing a matrix ?
    # this seems ugly but is apparently pretty quick even for big mats
    plot(reshape(x, length(x), 1), reshape(y, length(y), 1), args...; kwargs...)
end

function plot(x::RealMat, y::RealMat, styles::String=DEFAULT_GLYPHS_STR; 
              glyphs::Vector{Glyph}=DEFAULT_GLYPHS, legends::Union(Nothing, Vector)=nothing, kwargs...)
    size(x) != size(y) && error("size of x and y are not equal: x: $(size(x)), y: $(size(y))")
    glyphs = glyphs == DEFAULT_GLYPHS ? convert(Vector{Glyph}, styles) : glyphs
    cols = size(x,2)
    glyphs = repmat(glyphs, int(ceil(cols / length(glyphs))))
    legends = legends == nothing ? [nothing for _ in 1:cols] : legends
    dcs = DataColumn[DataColumn(x[:,i], y[:,i], glyphs[i], legends[i]) for i in 1:cols]
    plot(dcs; kwargs...)
end

# TODO: this "root" plot method is effectively figure, could be changed for clarity?

# there a good if boring reason that we have to use nothing for width, height etc. rather than 
# set the default to WIDTH, HEIGHT etc.: its because we wouldn't be able to specify a new width 
# or height on an extending plot if the new value happened to be the same as WIDTH or HEIGHT
function plot(columns::Array{DataColumn, 1}; extend::Union(Nothing, Plot)=nothing,
              title::NullString=nothing, width::NullInt=nothing, height::NullInt=nothing,
              x_axis_type=nothing, y_axis_type=nothing, legendsgo::NullSymbol=nothing,
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