function openhtmldoc(filepath::String)
    @linux_only run(`xdg-open $filepath`)
    @osx_only run(`open $filepath`)
    @windows_only run(`cmd /c start $filepath`)
end

_basic(p::Plot) = "Plot(\"$(p.title)\" with $(length(p.datacolumns)) datacolumns)"

function Base.writemime(io::IO, ::MIME"text/html", p::Plot)
    print(io, renderplot(p, true))
    print(io, "<p>", _basic(p), "</p>")
end

function Base.writemime(io::IO, ::MIME"text/plain", p::Plot)
    print(io, _basic(p))
end

# seems we have to override show as well as writemime
Base.show(io::IO, p::Plot) = print(io, _basic(p))

if !isdefined(Main, :IJulia)
	type BokehDisplay <: Display; end
    pushdisplay(BokehDisplay())

	function Base.display(d::BokehDisplay, p::Plot)
		display("text/plain", p)
		AUTOOPEN && showplot(p)
    end
end

function showplot(p::Plot)
    html = renderplot(p, false)
	if ispath(p.filename) 
		println()
		warn("$(p.filename) already exists, overwriting")
	end
	open(p.filename, "w") do f
		print(f, html)
	end
    openhtmldoc(p.filename)
end

showplot() = showplot(CURPLOT)

function setupnotebook()
	jspath, csspath = _bokehjs_paths(!DEBUG)
	jscss = _render_jscss(jspath, csspath, true)
	display("text/html", jscss)
	display("text/html", "<p>BokehJS successfully loaded.</p>")
end
