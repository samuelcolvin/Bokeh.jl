from __future__ import division

from bokeh.plotting import *
from bokeh.document import Document
from bokeh.protocol import serialize_json

x = range(6)
y = [xx**2 for xx in x]

output_file("scatter.html")

plot = circle(x, y, fill_alpha=0.2, size=10)

show()

doc = Document()
doc.add(plot)
json = serialize_json(doc.dump(), indent=2)
fn = 'scatter.json'
open(fn, 'w').write(json)