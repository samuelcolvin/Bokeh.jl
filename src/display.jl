function openhtmldoc(filepath::AbstractString)
    NOSHOW && return
    @linux_only run(`xdg-open $filepath`)
    @osx_only run(`open $filepath`)
    @windows_only run(`cmd /c start $filepath`)
end

_basic(p::Plot) = "Plot(\"$(p.title)\" with $(length(p.datacolumns)) datacolumns)"

function Base.writemime(io::IO, ::MIME"text/html", p::Plot)
    print(io, renderplot(p, true))
    print(io, "<p>", _basic(p), "</p>")
end

Base.writemime(io::IO, ::MIME"text/plain", p::Plot) = print(io, _basic(p))

# If in the notebook, activate a notebook display
if !isdefined(Main, :IJulia)
    type BokehDisplay <: Display; end
    pushdisplay(BokehDisplay())

    function Base.display(d::BokehDisplay, p::Plot)
        display("text/plain", p)
        AUTOOPEN && showplot(p)
    end
end

function showplot(p::Plot, filename::NullString=nothing)
    genplot(p, filename)
    openhtmldoc(filename == nothing ? p.filename : filename)
end

showplot() = showplot(CURPLOT)
showplot(filename::AbstractString) = showplot(CURPLOT, filename)

function setupnotebook()
    jspath, csspath = _bokehjs_paths(!DEBUG)
    jscss = _render_jscss(jspath, csspath, true)
    display("text/html", jscss)
    display("text/html", "<p>BokehJS successfully loaded.</p>")
end
