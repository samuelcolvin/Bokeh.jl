import numpy as np
from bokeh.plotting import *
from bokeh.document import Document
from bokeh.protocol import serialize_json

output_file("twolines.html", title="twolines example")

hold()

figure(tools="")

x = np.linspace(0, 10,5)
y1 = map(np.sin, x)
y2 = map(np.cos, x)

line(x, y1, color='#A6CEE3', legend='line 1')
plot = line(x, y2, color='#B2DF8A', legend='line 2')

show()  # open a browser

doc = Document()
doc.add(plot)
json = serialize_json(doc.dump(), indent=2)
fn = 'twolines.json'
open(fn, 'w').write(json)

