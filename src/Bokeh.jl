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
			attrs[string(name)] = ob.(name)
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
		axis = Axis(0, pid)
		axis = 
		push!(obs, obdict(axis, doc))
		column_names = String["x", "y"]
		data = Dict{String, Array{Number, 1}}()
		data["x"] = [1, 2, 3, 4, 5]
		data["y"] = [1, 4, 9, 16, 25]
		column = ColumnDataSource(column_names, data)
		push!(obs, obdict(column, doc))
		dr1 = DataRange1d(column.uuid, String["y"])
		push!(obs, obdict(dr1, doc))
		JSON.print(obs, 2)
	end
end
