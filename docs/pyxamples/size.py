from __future__ import division

from bokeh.plotting import *
from bokeh.document import Document
from bokeh.protocol import serialize_json

x = range(6)
y = [xx**2 for xx in x]

output_file("size.html")

plot = figure(plot_height=400, plot_width=600)

plot.line(x, y)

show(plot)

doc = Document()
doc.add(plot)
json = serialize_json(doc.dump(), indent=2)
open('size.json', 'w').write(json)
