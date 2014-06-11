from bokeh.document import Document
from bokeh.glyphs import Line
from bokeh.objects import *
from bokeh.protocol import serialize_json
source = ColumnDataSource(data=dict(x=[1,2,3], y=[5,6,7]))
xdr = DataRange1d(sources=[source.columns('x')])
ydr = DataRange1d(sources=[source.columns('y')])
plot = Plot(title="Line", data_sources=[source], x_range=xdr, y_range=ydr)
glyph = Line(x="x", y="y", line_color="blue")
renderer = Glyph(data_source=source, xdata_range=xdr, ydata_range=ydr, glyph=glyph)
plot.renderers.append(renderer)
Axis(plot=plot, dimension=0)
Axis(plot=plot, dimension=1)
doc = Document()
doc.add(plot)
json = serialize_json(doc.dump(), indent=2)
print json
fn = 'bokeh_example.json'
open(fn, 'w').write(json)
print '\n================================'
print 'json written to %s' % fn