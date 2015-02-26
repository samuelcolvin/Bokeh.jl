using Bokeh
using Base.Test

# check js and css files are there (in case they've been downloaded)
bkfiles = readdir(joinpath(dirname(@__FILE__), "..", "deps", "bokehjs"))
@test length(filter(x -> endswith(x, ".js"), bkfiles))  == 2
@test length(filter(x -> endswith(x, ".css"), bkfiles)) == 2

# try setting all possible params
# some lime autoopen actually need to be set for travis
Bokeh.debug(true)
Bokeh.debug(false)
w = width()
width(w)
h = height()
height(h)
dft_glyphs = glyphs()
glyphs(dft_glyphs)
dft_size = glyphsize()
glyphsize(dft_size)
t = title()
title(t)
Bokeh.noshow(true)
Bokeh.filewarnings(false)

# check they're correct:
# Bokeh.parse_spec("r--") |> println

# Bokeh.parse_spec("r:") |> println

exdir = Pkg.dir("Bokeh", "test", "test-cases")
testingdir = "/tmp/bokeh_js_testing"
mkpath(testingdir)
cd(testingdir)
for ex in filter(f -> endswith(f, ".jl"), readdir(exdir))
	evalfile(joinpath(exdir, ex))
	hold(false)
end
