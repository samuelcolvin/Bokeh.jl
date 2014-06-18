module Bokeh
	include("objects.jl")
	using JSON
	using Mustache

	function obdict(ob::PlotObject, doc::UUID)
		d = Dict{String, VALUE_TYPES}()
		d["id"] = string(ob.uuid)
		extra_attrs = typeof(ob).names
		d["type"] = in(:_type_name, extra_attrs) ? ob._type_name : typeof(ob)
		attrs = Dict{String, Any}()
		attrs["id"] = d["id"]
		attrs["doc"] = string(doc)
		special = [:_type_name]
		for name in extra_attrs[2:end]
			in(name, special) && continue
			key = string(name)
			# key = begingswith(key, "_") ? key[2:end] : key
			attrs[key] = ob.(name)
		end
		d["attributes"] = attrs
		d
	end

	function genmodels(indent::Int=0)
		pid= uuid4()

		plotcontext = PlotContext(pid)
		doc = uuid4()

		ticker0 = BasicTicker()

		tickform0 = BasicTickFormatter()

		axis0 = LinearAxis(0, tickform0, ticker0, pid)

		grid0 = Grid(0, pid, axis0)

		ticker1 = BasicTicker()

		tickform1 = BasicTickFormatter()

		axis1 = LinearAxis(1, tickform1, ticker1, pid)

		grid1 = Grid(1, pid, axis1)

		column_names = String["x", "y"]
		data = Dict{String, Array{Number, 1}}()
		data["x"] = [0, 1, 2, 3, 4, 5]
		data["y"] = data["x"].^2
		column = ColumnDataSource(column_names, data)

		dr1y = DataRange1d(column.uuid, String["y"])

		dr1x = DataRange1d(column.uuid, String["x"])

		glyph = Glyph(column.uuid, dr1x.uuid, dr1y.uuid)

		pantool = Metatool("PanTool", pid, String["width", "height"])

		renderers = [
			("Glyph", glyph.uuid),
			("LinearAxis", axis0.uuid),
			("LinearAxis", axis1.uuid),
			("Grid", grid0.uuid),
			("Grid", grid1.uuid)
		]
		tools = Dict{String, UUID}([
			"PanTool" => pantool.uuid
		])
		plot = Plot(pid,
					column.uuid,
					dr1x.uuid,
					dr1y.uuid,
					renderers,
					tools)
		obs = Any[]

		push!(obs, obdict(grid0, doc))
		push!(obs, obdict(dr1y, doc))
		push!(obs, obdict(column, doc))
		push!(obs, obdict(pantool, doc))
		push!(obs, obdict(dr1x, doc))
		push!(obs, obdict(axis0, doc))
		push!(obs, obdict(glyph, doc))
		push!(obs, obdict(plotcontext, doc))
		push!(obs, obdict(ticker0, doc))
		push!(obs, obdict(plot, doc))
		push!(obs, obdict(axis1, doc))
		push!(obs, obdict(tickform0, doc))
		push!(obs, obdict(tickform1, doc))
		push!(obs, obdict(grid1, doc))
		push!(obs, obdict(ticker1, doc))

		(json(obs, indent), plotcontext.uuid)
	end

	get_resources_dir() = Pkg.dir("Bokeh", "deps", "resources")

	DEFAULT_PATH = "_default _resources _directory"
	function gettemplate(template::String="basic.html", path::String=DEFAULT_PATH)
		path = path == DEFAULT_PATH ? get_resources_dir() : path
		fname = joinpath(path, template)
		open(readall, fname, "r")
	end

	function bokehjs_paths(minified::Bool=true)
		dir = Pkg.dir("Bokeh", "deps", "bokehjs")
		jspath = joinpath(dir, "js", minified ? "bokeh.min.js" : "bokeh.js")
		csspath = joinpath(dir, "css", minified ? "bokeh.min.css" : "bokeh.css")
		(jspath, csspath)
	end

	function rendertemplate(fname::String="bokeh_plot.html")
		template = gettemplate()
		jspath, csspath = bokehjs_paths(false)
		allmodels, pid = genmodels(2)
		open("models.json", "w") do f
			print(f, allmodels)
		end
		context = Dict{String, String}([
			"model_id" => string(pid),
			"all_models" => allmodels,
			"div_id" => string(uuid4()),
			"js_path" => jspath,
			"css_path" => csspath
		])
		result = render(template, context)
		open(fname, "w") do f
			print(f, result)
		end
	end
end






