using JSON
using ArgParse

s = ArgParseSettings()
@add_arg_table s begin
    "jons_file"
        help = "json file path"
        required = true
end
parsed_args = parse_args(ARGS, s)
text = open(readall, parsed_args["jons_file"], "r")
js = JSON.parse(text)
for ob in js
	println(ob["type"], ":")
	k = keys(ob["attributes"])
	println("  attributes: ", join(k, ", "))
end