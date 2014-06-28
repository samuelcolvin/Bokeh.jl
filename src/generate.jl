using Mustache

function Bokehjs.Glyph(glyph::Glyph,
					   coldata::Bokehjs.ColumnDataSource, 
					   xrange::Bokehjs.NullBkRange=nothing, 
					   yrange::Bokehjs.NullBkRange=nothing)
	glyphspec = Dict{String, BkAny}([
		"type" => glyph.gtype,
		"y" => ["units" => "data", "field" => "y"],
		"x" => ["units" => "data", "field" => "x"],
		])
	glyph.linewidth != nothing && (glyphspec["line_width"] = ["units" => "data", "value" => glyph.linewidth])

	glyph.linecolor != nothing && (glyphspec["line_color"] = ["value" => glyph.linecolor])
	glyph.fillcolor != nothing && (glyphspec["fill_color"] = ["value" => glyph.fillcolor])

	glyph.linealpha != nothing && (glyphspec["line_alpha"] = ["value" => glyph.linealpha])
	glyph.fillalpha != nothing && (glyphspec["fill_alpha"] = ["value" => glyph.fillalpha])

	glyph.size != nothing && (glyphspec["size"] = ["units" => "screen", "value" => glyph.size])

	glyph.dash != nothing && (glyphspec["line_dash"] = glyph.dash)
	
	Bokehjs.Glyph(coldata, xrange, yrange, glyphspec)
end

function _genmodels(plot::Plot)
	bkplot = Bokehjs.Plot()
	doc = Bokehjs.uuid4()
	obs = Dict{String, BkAny}[]

	cdss = Bokehjs.ColumnDataSource[]
	bkglyphs = Bokehjs.PlotObject[]
	for datacolumn in plot.datacolumns
		cds = Bokehjs.ColumnDataSource(datacolumn.columns, datacolumn.data)
		pushdict!(obs, cds, doc)
		bg = Bokehjs.Glyph(datacolumn.glyph, cds)
		push!(cdss, cds)
		push!(bkglyphs, bg)
		pushdict!(obs, bg, doc)
	end
	dr1x = Bokehjs.DataRange1d(cdss, String["x"])
	dr1y = Bokehjs.DataRange1d(cdss, String["y"])
	pushdict!(obs, dr1x, doc)
	pushdict!(obs, dr1y, doc)

	ticker0 = Bokehjs.BasicTicker()
	ticker1 = Bokehjs.BasicTicker()
	pushdict!(obs, ticker0, doc)
	pushdict!(obs, ticker1, doc)

	tickform0 = Bokehjs.BasicTickFormatter()
	tickform1 = Bokehjs.BasicTickFormatter()
	pushdict!(obs, tickform0, doc)
	pushdict!(obs, tickform1, doc)

	axis0 = Bokehjs.LinearAxis(0, tickform0, ticker0, bkplot)
	axis1 = Bokehjs.LinearAxis(1, tickform1, ticker1, bkplot)
	pushdict!(obs, axis0, doc)
	pushdict!(obs, axis1, doc)
	grid0 = Bokehjs.Grid(0, bkplot, axis0)
	grid1 = Bokehjs.Grid(1, bkplot, axis1)
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

	renderers = Bokehjs.PlotObject[
		axis0,
		axis1,
		grid0,
		grid1
	]
	append!(renderers, bkglyphs)
	
	bkplot = Bokehjs.Plot(bkplot,
				dr1x,
				dr1y,
				renderers,
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
	d = Dict{String, BkAny}()
	d["id"] = ob.uuid
	extra_attrs = typeof(ob).names
	d["type"] = in(:_type_name, extra_attrs) ? ob._type_name : typeof(ob)
	attrs = Dict{String, Any}()
	attrs["id"] = d["id"]
	attrs["doc"] = doc
	special = [:_type_name]
	for name in extra_attrs[2:end]
		in(name, special) && continue
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
	jspath = joinpath(dir, "js", minified ? "bokeh.min.js" : "bokeh.js")
	csspath = joinpath(dir, "css", minified ? "bokeh.min.css" : "bokeh.css")
	(jspath, csspath)
end

function _render_jscss(jspath::String, csspath::String, buildin::Bool)
	if !buildin
		return "<link rel=\"stylesheet\" href=\"$csspath\" type=\"text/css\" />\n"*
				"<script type=\"text/javascript\" src=\"$jspath\"></script>\n"
	else
		css = outfile_content = open(readall, csspath, "r")
		js = outfile_content = open(readall, jspath, "r")
		return "<style>\n$css\n</style><script type=\"text/javascript\">\n$js\n</script>\n"
	end
end

function _rendertemplate(models::String, plotcon::Bokehjs.PlotContext, isijulia::Bool)
	base = isijulia ? _gettemplate("ijulia.html") : _gettemplate("standalone.html")
	main = _gettemplate("main.html")
	body = _gettemplate("body.html")
	jspath, csspath = _bokehjs_paths(!DEBUG)
	jscss = _render_jscss(jspath, csspath, isijulia)
	if DEBUG
		open(replace(PLOTFILE, ".html", "") * ".json", "w") do f
			print(f, models)
		end
	end
	context = Dict{String, String}([
		"model_id" => string(plotcon.uuid),
		"all_models" => models,
		"div_id" => string(Bokehjs.uuid4())
	])
	main = render(main, context)
	body = render(body, context)
	maincontext = Dict{String, String}([
		"jscss" => jscss,
		"main" => main,
		"body" => body,
	])
	result = render(base, maincontext)
end

function renderplot(plot::Plot, isijulia::Bool)
    modelsjson, plotcontext = _genmodels(plot)
    _rendertemplate(modelsjson, plotcontext, isijulia)
end



