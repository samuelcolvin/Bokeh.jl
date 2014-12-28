# nice idea but with the current need to build js ourselves
# it makes more sense to include it.

# function getfile(fname)
# 	url = "http://cdn.pydata.org/" * fname
# 	path = Pkg.dir("Bokeh", "deps", "bokehjs", fname)
# 	println("downloading from $url to $path")
# 	download(url, path)
# end

# bokehjs = "bokeh-0.7.0"
# getfile("$bokehjs.js")
# getfile("$bokehjs.min.js")
# getfile("$bokehjs.css")
# getfile("$bokehjs.min.css")