using Mustache

# TODO: currently auto and log aren't implemented properly
_axis_type(s::Symbol) = s == :auto ? (:BasicTicker, :BasicTickFormatter) :
                        s == :linear ? (:BasicTicker, :BasicTickFormatter) :
                        s == :log ? (:BasicTicker, :BasicTickFormatter) :
                        s == :datetime ? (:DatetimeTicker, :DatetimeTickFormatter) :
                        error("Unknown axis type")

function _genmodels(p::Plot)
    bkplot = Bokehjs.Plot()
    doc = Bokehjs.uuid4()
    obs = Dict{AbstractString, BkAny}[]

    cdss = Bokehjs.ColumnDataSource[]
    renderers = Bokehjs.PlotObject[]
    legends = Tuple[]
    for datacolumn in p.datacolumns
        cds = Bokehjs.ColumnDataSource(datacolumn.data)
        push!(cdss, cds)
        pushdict!(obs, cds, doc)

        glyph = datacolumn.glyph
        pushdict!(obs, glyph, doc)

        glyphrenderer = Bokehjs.GlyphRenderer(cds, glyph, nothing, glyph)
        push!(renderers, glyphrenderer)
        pushdict!(obs, glyphrenderer, doc)

        if datacolumn.legend != nothing
            push!(legends, (datacolumn.legend, glyphrenderer))
        end
    end

    cdss, renderers, legends

    if length(legends) > 0
        legend = Bokehjs.Legend(bkplot, legends, p.legendsgo)
        push!(renderers, legend)
        pushdict!(obs, legend, doc)
    end

    dr1x = Bokehjs.DataRange1d(cdss, AbstractString["x"])
    dr1y = Bokehjs.DataRange1d(cdss, AbstractString["y"])
    pushdict!(obs, dr1x, doc)
    pushdict!(obs, dr1y, doc)

    axes = Dict{Symbol, Vector}(:above => [],
                                :below => Bokehjs.LinearAxis[],
                                :left => Bokehjs.LinearAxis[],
                                :right => []
                               )

    for (i, loc, sym) in [(0, :below, :x), (1, :left, :y)]
        @eval begin
            tick_type, tickform_type = _axis_type(getfield($p, symbol($"$(sym)_axis_type")))

            tick = Bokehjs.Ticker(tick_type)
            tickform = Bokehjs.TickFormatter(tickform_type)
            axis = Bokehjs.LinearAxis($i, tickform, tick, $bkplot)
            grid = Bokehjs.Grid($i, $bkplot, tick)

            for obj in (tick, axis, tickform, grid)
                pushdict!($obs, obj, $doc)
            end

            push!($renderers, axis)
            push!($renderers, grid)
            $axes[symbol($"$loc")] = [axis]
        end
    end

    tools = Bokehjs.PlotObject[]
    if in(:pan, p.tools)
        pantool = Bokehjs.Metatool("PanTool", bkplot,
                                   AbstractString["width", "height"])
        pushdict!(obs, pantool, doc)
        push!(tools, pantool)
    end
    if in(:wheelzoom, p.tools)
        wheelzoomtool = Bokehjs.Metatool("WheelZoomTool", bkplot,
                                         AbstractString["width", "height"])
        pushdict!(obs, wheelzoomtool, doc)
        push!(tools, wheelzoomtool)
    end
    if in(:boxzoom, p.tools)
        boxzoomtool = Bokehjs.Metatool("BoxZoomTool", bkplot)
        pushdict!(obs, boxzoomtool, doc)
        push!(tools, boxzoomtool)
    end
    if in(:resize, p.tools)
        resizetool = Bokehjs.Metatool("ResizeTool", bkplot)
        pushdict!(obs, resizetool, doc)
        push!(tools, resizetool)
    end
    if in(:reset, p.tools)
        resettool = Bokehjs.Metatool("ResetTool", bkplot)
        pushdict!(obs, resettool, doc)
        push!(tools, resettool)
    end

    bkplot = Bokehjs.Plot(bkplot, dr1x, dr1y, renderers, axes, tools, p.title,
                          p.height, p.width)
    pushdict!(obs, bkplot, doc)

    plotcontext = Bokehjs.PlotContext(bkplot)
    pushdict!(obs, plotcontext, doc)

    indent = DEBUG ? 2 : 0
    json(obs, indent), plotcontext
end

function _obdict(ob::Bokehjs.PlotObject, doc::Bokehjs.UUID)
    d = Dict{AbstractString, BkAny}()
    d["id"] = ob.uuid
    extra_attrs = fieldnames(ob)
    d["type"] = in(:_type_name, extra_attrs) ? ob._type_name : typeof(ob)

    attrs = Dict{AbstractString, Any}()
    attrs["id"] = d["id"]
    attrs["doc"] = doc

    special = [:_type_name]

    for name in extra_attrs[2:end]
        in(name, special) && continue
        ob.(name) == Bokehjs.omit && continue
        key = string(name)
        # key = begingswith(key, "_") ? key[2:end] : key
        attrs[key] = ob.(name)
    end

    d["attributes"] = attrs

    return d
end

pushdict!(obs::Any, ob::Bokehjs.PlotObject, doc::Bokehjs.UUID) =
    push!(obs, _obdict(ob, doc))

_get_resources_dir() = Pkg.dir("Bokeh", "templates")

function _gettemplate(template::AbstractString,
                      path::Union{AbstractString, Void}=nothing)
    path = path == nothing ? _get_resources_dir() : path
    fname = joinpath(path, template)
    open(readall, fname, "r")
end

function _bokehjs_paths(minified::Bool=true)
    dir = joinpath(dirname(@__FILE__), "..", "deps", "bokehjs")
    jspath = joinpath(dir, minified ? "bokeh.min.js" : "bokeh.js")
    csspath = joinpath(dir, minified ? "bokeh.min.css" : "bokeh.css")
    (jspath, csspath)
end

function _render_jscss(jspath::AbstractString, csspath::AbstractString,
                       buildin::Bool)
    if buildin
        css = open(readall, csspath, "r")
        js = open(readall, jspath, "r")
        return "<style>\n$css\n</style>\n<script type=\"text/javascript\">\n$js\n</script>\n"
    else
        return "<link rel=\"stylesheet\" href=\"$csspath\" type=\"text/css\" />\n"*
               "<script type=\"text/javascript\" src=\"$jspath\"></script>\n"
    end
end

function _rendertemplate(models::AbstractString, plotcon::Bokehjs.PlotContext,
                         isijulia::Bool)
    base = isijulia ? _gettemplate("ijulia.html") :
                      _gettemplate("standalone.html")

    main = _gettemplate("main.html")
    body = _gettemplate("body.html")

    jspath, csspath = _bokehjs_paths(!DEBUG)
    builtin = isijulia || INCLUDE_JS
    jscss = _render_jscss(jspath, csspath, builtin)

    if DEBUG
        open(replace(PLOTFILE, ".html", "") * ".json", "w") do f
            print(f, models)
        end
    end

    context = Dict{AbstractString, AbstractString}(
        "model_id" => string(plotcon.uuid),
        "all_models" => models,
        "div_id" => string(Bokehjs.uuid4())
    )

    main = render(main, context)
    body = render(body, context)

    maincontext = Dict{AbstractString, AbstractString}(
        "jscss" => jscss,
        "main" => main,
        "body" => body,
    )

    result = render(base, maincontext)
end

function renderplot(plot::Plot, isijulia::Bool=false)
    modelsjson, plotcontext = _genmodels(plot)
    _rendertemplate(modelsjson, plotcontext, isijulia)
end

renderplot() = renderplot(CURPLOT)

function genplot(p::Plot, filename::NullString=nothing)
    filename = filename == nothing ? p.filename : filename
    html = renderplot(p)
    if ispath(filename) && FILE_WARNINGS
        if WARN_FILE != filename
            println("$(filename) already exists, overwriting")
            global WARN_FILE = filename
        end
    end
    open(filename, "w") do f
        print(f, html)
    end
end

genplot() = genplot(CURPLOT)
genplot(filename::AbstractString) = genplot(CURPLOT, filename)
