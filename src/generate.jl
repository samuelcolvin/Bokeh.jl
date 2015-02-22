using Mustache
using Compat

function _genmodels(plot::Plot)
    bkplot = Bokehjs.Plot()
    doc = Bokehjs.uuid4()
    obs = Dict{String, BkAny}[]

    cdss = Bokehjs.ColumnDataSource[]
    renderers = Bokehjs.PlotObject[]
    legends = Tuple[]
    for datacolumn in plot.datacolumns
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

    if length(legends) > 0
        legend = Bokehjs.Legend(bkplot, legends, plot.legendsgo)
        push!(renderers, legend)
        pushdict!(obs, legend, doc)
    end

    dr1x = Bokehjs.DataRange1d(cdss, String["x"])
    dr1y = Bokehjs.DataRange1d(cdss, String["y"])
    pushdict!(obs, dr1x, doc)
    pushdict!(obs, dr1y, doc)

    # TODO: currently auto and log aren't implemented properly
    axis_types = @compat Dict{Symbol, Tuple}(
    :auto =>     (:BasicTicker, :BasicTickFormatter),
    :linear =>   (:BasicTicker, :BasicTickFormatter),
    :log =>      (:BasicTicker, :BasicTickFormatter),
    :datetime => (:DatetimeTicker, :DatetimeTickFormatter),
    )
    xticker_type, xtickform_type = axis_types[plot.x_axis_type]
    yticker_type, ytickform_type = axis_types[plot.y_axis_type]

    ticker0 = Bokehjs.Ticker(xticker_type)
    ticker1 = Bokehjs.Ticker(yticker_type)
    pushdict!(obs, ticker0, doc)
    pushdict!(obs, ticker1, doc)

    tickform0 = Bokehjs.TickFormatter(xtickform_type)
    tickform1 = Bokehjs.TickFormatter(ytickform_type)
    pushdict!(obs, tickform0, doc)
    pushdict!(obs, tickform1, doc)

    axis0 = Bokehjs.LinearAxis(0, tickform0, ticker0, bkplot)
    axis1 = Bokehjs.LinearAxis(1, tickform1, ticker1, bkplot)
    pushdict!(obs, axis0, doc)
    pushdict!(obs, axis1, doc)
    grid0 = Bokehjs.Grid(0, bkplot, ticker0)
    grid1 = Bokehjs.Grid(1, bkplot, ticker1)
    pushdict!(obs, grid0, doc)
    pushdict!(obs, grid1, doc)

    tools = Bokehjs.PlotObject[]
    if in(:pan, plot.tools)
        pantool = Bokehjs.Metatool("PanTool", bkplot, String["width", "height"])
        pushdict!(obs, pantool, doc)
        push!(tools, pantool)
    end
    if in(:wheelzoom, plot.tools)
        wheelzoomtool = Bokehjs.Metatool("WheelZoomTool", bkplot, String["width", "height"])
        pushdict!(obs, wheelzoomtool, doc)
        push!(tools, wheelzoomtool)
    end
    if in(:boxzoom, plot.tools)
        boxzoomtool = Bokehjs.Metatool("BoxZoomTool", bkplot)
        pushdict!(obs, boxzoomtool, doc)
        push!(tools, boxzoomtool)
    end
    if in(:resize, plot.tools)
        resizetool = Bokehjs.Metatool("ResizeTool", bkplot)
        pushdict!(obs, resizetool, doc)
        push!(tools, resizetool)
    end
    if in(:reset, plot.tools)
        resettool = Bokehjs.Metatool("ResetTool", bkplot)
        pushdict!(obs, resettool, doc)
        push!(tools, resettool)
    end

    push!(renderers, axis0)
    push!(renderers, axis1)
    push!(renderers, grid0)
    push!(renderers, grid1)

    axes = @compat Dict{Symbol, Vector}(
        :above => [],
        :below => [axis0],
        :left => [axis1],
        :right => []
    )

    bkplot = Bokehjs.Plot(bkplot,
                dr1x,
                dr1y,
                renderers,
                axes,
                tools,
                plot.title,
                plot.height,
                plot.width)
    pushdict!(obs, bkplot, doc)

    plotcontext = Bokehjs.PlotContext(bkplot)
    pushdict!(obs, plotcontext, doc)

    indent = DEBUG ? 2 : 0
    method_exists(json, (Dict, Int)) ? (json(obs, indent), plotcontext): 
                                       (json(obs), plotcontext)
end

function _obdict(ob::Bokehjs.PlotObject, doc::Bokehjs.UUID)
    d = @compat Dict{String, BkAny}()
    d["id"] = ob.uuid
    extra_attrs = typeof(ob).names
    d["type"] = in(:_type_name, extra_attrs) ? ob._type_name : typeof(ob)
    attrs = @compat Dict{String, Any}()
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

pushdict!(obs::Any, ob::Bokehjs.PlotObject, doc::Bokehjs.UUID) = push!(obs, _obdict(ob, doc))

_get_resources_dir() = Pkg.dir("Bokeh", "templates")

function _gettemplate(template::String, path::Union(String, Nothing)=nothing)
    path = path == nothing ? _get_resources_dir() : path
    fname = joinpath(path, template)
    open(readall, fname, "r")
end

function _bokehjs_paths(minified::Bool=true)
    dir = Pkg.dir("Bokeh", "deps", "bokehjs")
    jspath = joinpath(dir, minified ? "bokeh.min.js" : "bokeh.js")
    csspath = joinpath(dir, minified ? "bokeh.min.css" : "bokeh.css")
    (jspath, csspath)
end

function _render_jscss(jspath::String, csspath::String, buildin::Bool)
    if buildin
        css = open(readall, csspath, "r")
        js = open(readall, jspath, "r")
        return "<style>\n$css\n</style>\n<script type=\"text/javascript\">\n$js\n</script>\n"
    else
        return "<link rel=\"stylesheet\" href=\"$csspath\" type=\"text/css\" />\n"*
               "<script type=\"text/javascript\" src=\"$jspath\"></script>\n"
    end
end

function _rendertemplate(models::String, plotcon::Bokehjs.PlotContext, isijulia::Bool)
    base = isijulia ? _gettemplate("ijulia.html") : _gettemplate("standalone.html")
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
    context = @compat Dict{String, String}(
        "model_id" => string(plotcon.uuid),
        "all_models" => models,
        "div_id" => string(Bokehjs.uuid4())
    )
    main = render(main, context)
    body = render(body, context)
    maincontext = @compat Dict{String, String}(
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
genplot(filename::String) = genplot(CURPLOT, filename)

