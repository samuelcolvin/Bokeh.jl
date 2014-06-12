module Bokeh
	include("objects.jl")
	using JSON

	function obdict(ob::PlotObject, doc::UUID)
		d = Dict{String, VALUE_TYPES}()
		d["id"] = string(ob.uuid)
		d["type"] = typeof(ob)
		attrs = Dict{String, Any}()
		attrs["id"] = d["id"]
		attrs["doc"] = string(doc)
		extra_attrs = typeof(ob).names
		for name in extra_attrs[2:end]
			key = string(name)
			# key = begingswith(key, "_") ? key[2:end] : key
			attrs[key] = ob.(name)
		end
		d["attributes"] = attrs
		d
	end

	function test()
		obs = Any[]
		pid= uuid4()

		p = PlotContext(pid)
		doc = uuid4()
		push!(obs, obdict(p, doc))

		axis0 = Axis(0, pid)
		push!(obs, obdict(axis0, doc))

		axis1 = Axis(1, pid)
		push!(obs, obdict(axis1, doc))

		column_names = String["x", "y"]
		data = Dict{String, Array{Number, 1}}()
		data["x"] = [1, 2, 3, 4, 5]
		data["y"] = [1, 4, 9, 16, 25]
		column = ColumnDataSource(column_names, data)
		push!(obs, obdict(column, doc))

		dr1y = DataRange1d(column.uuid, String["y"])
		push!(obs, obdict(dr1y, doc))

		dr1x = DataRange1d(column.uuid, String["x"])
		push!(obs, obdict(dr1x, doc))

		glyph = Glyph(column.uuid, dr1x.uuid, dr1y.uuid)
		push!(obs, obdict(glyph, doc))

		renderers = [
			("Glyph", glyph.uuid),
			("Axis", axis0.uuid),
			("Axis", axis1.uuid),
		]
		plot = Plot(column.uuid,
					dr1x.uuid,
					dr1y.uuid,
					renderers
					)
		JSON.print(obs, 2)
	end
end
