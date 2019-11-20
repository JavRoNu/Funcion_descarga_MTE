# Minimiza:−6x1−6x2
# Sujeto a:
#   −x1−8x2≤1
#   −7x1−x2≤4 
#   2x1+x2 ≤ 2
#   x1, x2≥0

f.obj <- c(-6,-6)
mtz <- matrix(c(-1,-7,2,-8,-1,1),ncol = 2)
ig <- c(1,4,2)

# Grafica vacia
plot.new()
plot.window(xlim=c(-1,5),
            ylim=c(-1,5)
            )
# ejes
axis(1,pos=0,labels=FALSE,lwd=1,lwd.ticks=0)
axis(2,pos=0,labels=FALSE,lwd=1,lwd.ticks=0)

# restricciones



# −x1−8x2≤1
# x \ y
# 0   9
# 1   0


# −7x1−x2≤4 
# x    |  y
# 0   |  -4
# 0.5714286 | 0

# 2x1+x2 ≤ 2
# x | y
# 0 |  2
# 1 | 0

plot(1:10)
