using Bokeh

Bokeh.includejs(true)  # this is required as these files will be published online
Bokeh.noshow(true)
Bokeh.filewarnings(false)
exdir = dirname(@__FILE__)
cd(exdir)
for jl_src in filter(f -> endswith(f, ".jl") && f != "build_all.jl", readdir(exdir))
	glyphsize(6)
	hold(false)
	plotfile(replace(jl_src, ".jl", ".html"))
	evalfile(jl_src)
end
