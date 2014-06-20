from __future__ import division

import numpy as np
from six.moves import zip
from bokeh.plotting import *
from bokeh.objects import Range1d
from bokeh.document import Document
from bokeh.protocol import serialize_json

output_file("scatter.html")

x = [0, 1, 0.5, 0.5]
y = [0, 0, 0.5, -0.5]

plot = scatter(x, y, size=12, color="red", alpha=0.5, tools="")

show()  # open a browser

doc = Document()
doc.add(plot)
json = serialize_json(doc.dump(), indent=2)
fn = 'scatter.json'
open(fn, 'w').write(json)