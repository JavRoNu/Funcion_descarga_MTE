# PRIMERAS OPERACIONES

2+2
1+2*4
2+3 
log(4) #
exp(5) # exp(5)
sqrt(16) # raiz cuadrada de 16
pi # R reconoce el número pi

2+2;1+2*4
sin(2*pi) # función seno

# ASIGNACIÓN

a=3+5
a
a=3+5;a
a<-1:10; a #secuencia de númerosa
A<-"casa"; A


n=50000
x=runif(n,min=0,max=10)
y=runif(n,min=0,max=10)
par(mfcol=c(2,3))
hist(x); hist(y); hist(x+y); hist(sqrt(x**2+y**2)); plot(x,y)



# EJEMPLO DE DATOS SIMULADOS

x <- rnorm(n = 200, mean = 105, sd = 2) #datos normales
head(x) # visualizción primeros datos
summary(x) # resumen estadístico 
par(mfcol=c(1,2)) # se divide pantalla gráfica en 2x1
hist(x) #histograma
boxplot(x,horizontal=TRUE) # gráfico de cajas


# OBJETOS EN MEMORIA

ls() # objetos en memoria
b="hola"
rm(b) # borramo objeto b
ls()
rm(list=ls())  # borrado de toda la memoria 
ls() # character(0) significa que no hay objetos en memoria

# GUARDANDO ÁREA DE TRABAJO

rm(list=ls()) # primero borramos toda la mamoria
x<-20
y<-34
z<-"casa"
save.image(file="prueba.RData") # guarda area de trabajo en prueba.RData

save(x,y,file="prueba2.RData") # guardo los objetos x e y
load("prueba2.RData") # carga área de trabajo

# DIRECTORIO DE TRABAJO

getwd() # devuelve el directorio de trabajo
setwd("c:/datos") # establece directorio de trabjo
    # Importante la barra utilizada
    # NO funciona setwd("c:\datos")

# AYUDA

help(rnorm) # ayuda de la función rnorm
?rnorm #de forma equivalente

help(help) # Ayuda sobre la función help 
# o bién help (help)

help.search("median")

# INSTALACIÓN DE PAQUETES

install.packages("Rcmdr",dependencies = TRUE)
library(Rcmdr)
help(package="Rcmdr")

