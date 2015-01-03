using Bokeh

x = linspace(-3pi, 3pi)
y1 = cos(x)
plot(x,y1)

# hold works very similarly to hold in other plotting libraries
hold(true)

y2 = sin(x)./x
plot(x, y2, "r")
showplot("holding.html")
# under the bonnet it's just causing the plot function not to overwrite
# CURPLOT but rather to extend it


# we can do something similar bey specifying exactly which plot we wish to 
# extend
hold(false)
# becaues hold is false p1 and p2 are seperate plots
p1 = plot(x, y1, plotfile="plotobject1.html")
p2 = plot(x, y2, plotfile="plotobject2.html")

y3 = y1 - y2

# if we switched hold on this would extend p2, instead we specify that it should
# extend p1
plot(x, y3, "r--", extend = p1)
showplot(p1)
showplot(p2)