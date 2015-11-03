using Mustache

# TODO: currently auto and log aren't implemented properly
_axis_type(s::Symbol) = s == :auto ? (:BasicTicker, :BasicTickFormatter) :
                        s == :linear ? (:BasicTicker, :BasicTickFormatter) :
                        s == :log ? (:BasicTicker, :BasicTickFormatter) :
                        s == :datetime ? (:DatetimeTicker, :DatetimeTickFormatter) :
                        error("Unknown axis type")

function _genmodels(p::Plot)
    bkplot = Bokehjs.Plot()
    doc = Bokehjs.uuid4()  # The document id
    obs = Dict{AbstractString, BkAny}[]  # vector of PlotObject in Dict form

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

    obs, bkplot
end

"""
```julia
_obdict(ob::Bokehjs.PlotObject, doc::Bokehjs.UUID)
```

Returns a Dict with three key-value pairs:

1. `attributes::Dict`: all fields of the type are put into a `Dict` where
the fieldname is the key and the value is the value
2. `doc::UUID`: the UUID for the document
3. `type`: If not a special Bokeh.js type name (e.g. the name of a glyph
like Circle) then the `DataType` of the `ob`. Otherwise a `Symbol` containing
the special Bokeh.js name.
"""
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

function _render_jscss(buildin::Bool, minified::Bool=true, widgets::Bool=true)
    dir = joinpath(dirname(@__FILE__), "..", "deps", "bokehjs")
    min_suffix = minified ?  ".min" : ""
    base_names = widgets ? ["bokeh", "bokeh-widgets"] : ["bokeh"]
    csspath = [joinpath(dir, string(nm, min_suffix, ".css")) for nm in base_names]
    jspath = [joinpath(dir, string(nm, min_suffix, ".js")) for nm in base_names]

    if buildin
        css = join(map(x-> string("<style>", open(readall, x, "r"), "</style>"),
                       csspath),
                   '\n')
        js = join(map(x-> string("<script type=\"text/javascript\">",
                                 open(readall, x, "r"), "</script>"),
                      jspath),
                  '\n')
    else
        css = join(map(x-> "<link rel=\"stylesheet\" href=\"$x\" type=\"text/css\" />\n",
                       csspath),
                   '\n')
        js = join(map(x-> "<script type=\"text/javascript\" src=\"$x\"></script>\n",
                      jspath),
                  '\n')
    end
    return string(css, "\n", js)
end

function _rendertemplate(modelsjson::AbstractString, model_obj::Bokehjs.PlotObject,
                         isijulia::Bool)
    base = isijulia ? _gettemplate("ijulia.html") :
                      _gettemplate("standalone.html")

    main = _gettemplate("main.html")
    body = _gettemplate("body.html")

    # render the javascript and css
    minified = !DEBUG
    builtin = isijulia || INCLUDE_JS
    jscss = _render_jscss(builtin, !DEBUG)

    if DEBUG
        open(replace(PLOTFILE, ".html", "") * ".json", "w") do f
            print(f, modelsjson)
        end
    end

    context = Dict{AbstractString, AbstractString}(
        "model_id" => string(model_obj.uuid),
        "all_models" => modelsjson,
        "div_id" => string(Bokehjs.uuid4()),
        "modeltype" => Bokehjs.modeltype(model_obj)
    )

    main = render(main, context)
    body = render(body, context)

    maincontext = Dict{AbstractString, AbstractString}(
        "jscss" => jscss,
        "main" => main,
        "body" => body,
    )

    render(base, maincontext)
end

function renderplot(p::Plot, isijulia::Bool=false)
    models, bkplot = _genmodels(p)
    modelsjson = json(models, DEBUG ? 2 : 0)
    _rendertemplate(modelsjson, bkplot, isijulia)
end

renderplot() = renderplot(CURPLOT)

function genplot(p::Plot, filename::NullString=nothing)
    filename = filename == nothing ? p.filename : filename
    @show html = renderplot(p)
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
