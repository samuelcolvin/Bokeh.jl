using JSON

text = open(readall, "bokeh_example2.json", "r")
js = JSON.parse(text)
for ob in js
	println(ob["type"], ":")
	for (k, v) in ob
		println(" "^4, k)
	end
	println(" "^2, "attrs:")
	for (k2, v2) in ob["attributes"]
		println(" "^6, k2)
	end
end