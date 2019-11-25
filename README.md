# Descripción:
Es una función para interactuar y descargar archivos de la bbdd del máster directamente desde R. 

- No se si funciona en Linux o Mac (francamente espero que en Mac NO!).
- Acabo de hacerla igual peta.
- Tiene unos pocos mensajes de error pero tampoco es a prueba de bombas.


# Uso:

```r
mte_get(
  usuario = NULL,
  contra = NULL,
  carpeta = getwd(),
  asig = NULL,
  sobrescribir = FALSE,
  modoArchivos = "int"
)
```

# Argumentos:
 - **usuario**:  Nombre de usuario de acceso a la bbdd del máster.
  - **contra**: contraseña de acceso a la bbdd del máster. 
  - **carpeta**: carpeta donde guardar los archivos, por defecto el directorio de trabajo. Se generan subcarpetas automáticamente en la carpeta proporcionada si hay más de una asignatura.

  - **asig**: Lista de asignaturas a descargar o un vector numérico con el código o la palabra "todo"
para descargarse todas. todo tiene preferencia. Dejar vacío para entrar en el
modo de selección interactivo. Si hay más de una asignatura generara carpetas para cada una. 
   - **sobrescribir**: Indica si debe sobrescribir archivos existentes, por defecto el nombre asignado es el del archivo. es decir se elimina el prefijo Mat_xxxx_x_.En caso de TRUE se sobrescribirán archivos en la carpeta de descarga con dicho nombre. En caso de FALSE creara una copia con el n delante:"scriptAED.R" pasara a ser "(1)scriptAED.R" si este también existe..."(2)scriptAED.R" y así sucesivamente.
   
   - **modoArchivos**: Indica el modo para descargar los archivos de las asignaturas seleccionadas:
     - "int" : modo interactivo, saldrá la lista interactiva y se seleccionaran los archivos. De modo análogo a las asignaturas también podéis escribir "todo".
     - "act" : modo actualizar descarga todos los archivos que no estén en la carpeta pero si en el repositorio. 
     - "todo" : descarga todos los archivos del repositorio.

# Ejemplos:
Ejecutando el script para cargar la función con ```source()```, tened en cuenta el encoding.
```r
source("mte_get.R",encoding = "UTF-8")
```
Se puede ejecutar en modo interactivo con:
```r
mte_get()
```
También se pueden declarar los argumentos con anterioridad.
```r
mte_get(usuario = "Paco.Mermela", contra = "gato44",carpeta = "C:/Users/Paco/Master")
```
## Uso de la consola en modo interactivo:

Cuando en el modo interactivo nos salen los listados en la consola se nos piden los nºs correspondientes. Para indicar varios basta con que esten separados, es decir:
```r
Selecione Asignaturas: 1 12 4

```
Es lo mismo que:

```r
Selecione Asignaturas: adaoanmf@1,  12 hf$faa 4s
```
En ambos casos solo tendra en cuenta los valores númericos (1,12,4) salvo que escribamos:
```r
Selecione Archivos: todo
```
en cuyo caso selecciona todos los archivos o asignaturas.

## ¿Como hago para descargarme todo?

Para descargar en *bulk* los materiales que tengas disponibles en el máster pasas el argumento "todo" tanto para archivos como asignaturas.

```r
mte_get(
  usuario ="Paco.Mermela",
  contra = "gato44",
  carpeta = "C:/Users/Paco/Master",
  asig = "todo",
  modoArchivos = "todo"
)
```

