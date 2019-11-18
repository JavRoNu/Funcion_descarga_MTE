
# title: funcion mte_get()
# version: 1.0
# mail: javier.rodriguez.nunez@gmail.com
# date: 2019-11-15
#
# Built in :
# R version 3.5.1 (2018-07-02)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
# Running under: Windows 10 x64 (build 18362)


  
mte_get <- function(
  # Nombre de usuario de acceso a la bbdd del master.
  usuario = NULL,
  # contraseña de acceso a la bbdd del master.  
  contra = NULL,
  # carpeta donde guardar los archivos, por defecto el directorio de trabajo.  
  carpeta = getwd(),
  # lista de asignaturas a descargar o un vector numerico con el codigo o la palabra "all"
  # para descargarse todas. all tiene preferencia. # dejar vacio para entrar en el
  # modo de selección interactivo. Si hay más de una asignatura generara carpetas para cada una.
  asig = NULL,
  # Indica si debe sobrescribir archivos existentes, por defecto el nombre asignado es el del archivo.
  # es decir se elimina el prefijo Mat_xxxx_x_.En caso de TRUE se sobrescribiran archivos en la carpeta de descarga
  # con dicho nombre. En caso de FALSE creara una copia con el n delante:
  # "scriptAED.R" pasara a ser "1scriptAED.R" si este tambien existe..."2scriptAED.R" y asi sucesivamente.
  sobrescribir= F,
  # Indica el modo para descargar los archivos de las asignaturas seleccionadas:
  #
  #   "int" : modo interactivo(default) saldra la lista interactiva y se seleccionaran los archivos,
  #           de modo analogo a las asignaturas tmb podeis escribir "all".
  #
  #   "act" : modo actualizar descarga todos los archivos que no esten en la carpeta pero si en el
  #           repositorio
  #
  #   "all" : descarga todos los archivos del repositorio.
  #
  modoArchivos = "int",
  ) {
  # verificiación de arugmentos 

  if (!dir.exists(carpeta))
    stop("El directorio proporcionado no existe o esta mal escrito.")

  if (!is.logical(sobrescribir))
    stop("Sobrescribir debe ser un argumento lógico.")
  
  if (!modoArchivos %in% c("int","act","all"))
    stop('El modo de descarga de archivos debe ser "int","act" o "all".')
  
    }

# borrar
usuario <- "javierluis.rodriguez"
contra <- "xa1234bi"


# COMPROBAR CONEXIONA A INTERNET
if (!curl::has_internet())
  stop("Oops!! parece que no podemos conectarnos a internet.")

# Paquetes
for (i in c("rvest","magrittr","stringr")) {
  if (!i %in% rownames(installed.packages()))
    install.packages(i)
  library(i,character.only = T)
}


url <- "http://eio.usc.es/pub/mte/index.php/es/acceder"

# comienzo sesion y error de disponibilidad del servidor
tryCatch(
  expr = {ses <- html_session(url, encoding = "UTF-8")},
  error = stop("Oops!! parece que el servidor del máster esta caído.")
)

# login
f.log <- ses %>%
  html_node("form") %>%
  html_form() %>%
  set_values("nombreUsuario" = usuario,
             "contraseña" = contra)

ses2 <- submit_form(ses,f.log,"login") 

# ERROR ACCESO A TU CUENTA , CONTRASEÑA O NOMBRE DE USUARIO
if (grepl("errorUsuario",ses2$url))
  stop("Nombre usuario y/o contraseña incorrectos.")


url2 <- "http://eamo.usc.es/eipc1/base/BASEMASTER/FORMULARIOS-PHP/MateriasAlumno.php?al=SI"

s.opt <-  ses2 %>% jump_to(url2)

# Nombres asig
op <- s.opt %>%
  read_html(encoding = "UTF-8") %>%
  html_nodes(xpath = '//*[@id="element_5_6"]/option') %>%
  html_text(trim = TRUE)

op <- op[-1]

# selección de asignaturas
if (is.null(asig)) {
  
  
  cat("Asignaturas disponibles : \n",
      paste0(" ", seq(length(op)), " --- ", op, "\n"))
  
  asig <- readline("Selecciona asignatura/s :")
}


# detección de all y extración nºs
  if (grepl("all", asig, ignore.case = T)) {
    
    asign <- seq(length(op))
    
  } else {
    
    asig <-
      str_extract_all(asig ,"[0-9]{1,2}") %>%
      unlist() %>%
      as.numeric()
  }

# error en el nº de asignaturas (no esta contenido)
# posibilidad de un grepl para los characters que no tengan curso

if (any(asig <= 0 | asig > length(op)))
  stop("El nº referido a la asignatura es incorrecto.")


# form asignatura 
f.asig <- s.opt %>%
  html_nodes("form") %>%
  html_form() %>%
  '[['(2) 

# LOOP DE ASIGNATURAS

if (length(asig) > 1) {
  
  use.asigdir <- T
  
  d.name <- NULL
  
  for (i in asig) {
    
    d.name[i] <- paste0(carpeta, "/", str_replace(op[i], " ", "_"))
    
    if (!dir.exists(d.name)) dir.create(d.name)
    
  }
  
  message("Selecionadas más de una asignaturas, empleando subcarpetas.")
  
} else d.name <- carpeta

for (i in asig) {
  f.asig2 <-
    set_values(f.asig, "nom_materia" = f.asig$fields$nom_materia$options[i + 1]) # **
  # el más uno es por el campo vacio
  
  s.asig <- submit_form(s.opt, f.asig2, "submit")
  
  # hay que sacar las fechas
  tx <- s.asig %>% read_html(encoding = "UTF-8") %>%
    html_node(xpath = '//*[@id="li_4"]/table[2]') %>%
    html_children() %>%
    html_text() %>%
    trimws()
  
  
  nms <- tx[seq(2, length(tx), by = 3)] %>%
    str_remove("\\.[a-zA-Z0-9_]{1,}$")
  
  fech <- tx[seq(3, length(tx), by = 3)]
  
  est <- tx[seq(4, length(tx), by = 3)] %>%
    str_extract("\\.[a-zA-Z0-9_]{1,}$")
  
  nms <- paste0(nms, est)
  
  
  links <- s.asig %>%
    read_html(encoding = "UTF-8") %>%
    html_nodes(xpath = '//*[@id="li_4"]/table[2]') %>%
    html_nodes("a") %>%
    html_attr("href")
  
  # display archivos disponibles
  if (modoArchivos == "act") {
    
      u.arch <- list.files(d.name[i])
    
      arch <- which(!nms %in% u.arch)
    
  } else if (modoArchivos == "int") {
    cat(op[i],
        "\n",
        'Archivos disponibles :\n',
        paste0(" ", seq(length(nms)), " -- ", fech, " -- ", nms, "\n"))
    arch <- readline("Selecione los archivos : ") 
    
    if (grepl("all", arch, ignore.case = T)) {
      arch <- seq(length(nms))
      
    } else {
      arch <-
        str_extract_all(arch , "[0-9]{1,2}") %>%
        unlist() %>%
        as.numeric()
    }
    
  } else
    arch <- seq(length(nms))
  
  
  for (i2 in arch) {
    # descarga
    dwn <- jump_to(s.asig, links[i2])
    
    if (sobrescibir) {
      download.file(dwn$url, disp[i2], mode = "wb", method = "libcurl")
    } else{
      down_no_overwrite(dwn$url, disp[f])
    }
    
    
  }
  
}


# funciones de soporte

down_no_overwrite <- function(url, folder) {
  
  filename <- basename(url)
  
  base <- tools::file_path_sans_ext(filename)
  
  ext <- tools::file_ext(filename)
  
  file_exists <- grepl(base, list.files(folder), fixed = TRUE)
  
  if (any(file_exists))
  {
    filename <- paste0(base, " (", sum(file_exists), ")", ".", ext)
  }
  
  download.file(url, file.path(folder, filename), mode = "wb", method = "libcurl")
}


