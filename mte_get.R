# title: funcion mte_get()
# version: 1.0
# author: javier.rodriguez.nunez@gmail.com
# date: 2019-11-21
#
# Built in :
# R version 3.5.1 (2018-07-02)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
# Running under: Windows 10 x64 (build 18362)


mte_get <- function(
  usuario = NULL,
  contra = NULL,
  carpeta = getwd(),
  asig = NULL,
  sobrescribir= F,
  modoArchivos = "int"
) {
  # verificiación de arugmentos 
   if(!is.character(usuario)) {
    usuario <-  readline("Usuario: ")
   }
     
  if(!is.character(contra)) {
    contra <- readline("Contraseña: ")
  }
    
  if (!dir.exists(carpeta))
    stop("El directorio proporcionado no existe o esta mal escrito.")
  
  if (!is.logical(sobrescribir))
    stop("Sobrescribir debe ser un argumento lógico.")
  
  if (!modoArchivos %in% c("int","act","todo"))
    stop('El modo de descarga de archivos debe ser "int","act" o "todo".')
  
  
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
  
  
  tryCatch(
    expr = {
      ses <- html_session(url, encoding = "UTF-8")
    },
    error = function(e) {
      stop("Oops!! parece que el servidor del máster esta caído.")
    }
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
  if (grepl("todo", asig, ignore.case = T)) {
    
    asig <- seq(length(op))
    
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
  
  # creación de las carpetas
  d.name <- character(max(asig))
  
  if (length(asig) > 1) {
    
    
    for (i in asig) {
      
      das <- str_extract(op[i],"(^.{1,})\\.") %>% 
        str_replace("\\.","")
      
      d.name[i] <- paste0(carpeta, "/",das)
      
      if (!dir.exists(d.name[i])) dir.create(d.name[i])
      
    }
    
    message("Selecionadas más de una asignatura, empleando subcarpetas.")
    
  } else{
    
    d.name[1:length(d.name)] <- carpeta
  }
  # borra 

  if (max(asig) != length(d.name))
    stop("El nº de carpetas y asignaturas no coincide.")
  
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
    
    tx <<- tx
    
    if ( length(tx) == 1 |  ((length(tx)-1) %% 3) != 0){
      message(paste0("No hay archivos disponibles para ",op[i],"."))
      Sys.sleep(2)
      next()
    }

    nms <- tx[seq(2, length(tx), by = 3)] %>%
      str_remove("\\.[a-zA-Z0-9_]{1,}$")

    fech <- tx[seq(3, length(tx), by = 3)]

    ext <- tx[seq(4, length(tx), by = 3)] %>%
      str_extract_all("\\.[a-zA-Z0-9_]{1,}$")
    nms <- paste0(nms, ext)
    
    
    links <- s.asig %>%
      #read_html(encoding = "UTF-8") %>%
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
      
      if (grepl("todo", arch, ignore.case = T)) {
        arch <- seq(length(nms))
        
      } else {
        arch <-
          str_extract_all(arch , "[0-9]{1,2}") %>%
          unlist() %>%
          as.numeric()
      }
      
    } else arch <- seq(length(nms))
    
    
    if (any(arch <= 0 | arch > length(nms)))
      stop("El nº referido al archivo es incorrecto.")
    
    for (i2 in arch) {
      
      # descarga
  
      dwn <- jump_to(s.asig, URLencode(links[i2],reserved = FALSE))
      
      fnm <- paste0(d.name[i], "/", nms[i2])
      fnm2 <<- fnm 

      if (!sobrescribir) {
        n <- 1
        while (file.exists(fnm)) {
          fnm <- paste0(d.name[i], "/(", n, ")", nms[i2])
          n <- n + 1
        }
      }
      
      tryCatch(expr = {                          
      download.file(dwn$url, fnm, mode = "wb",
                    method = "curl",quiet = T)
      
      message(paste0("Archivo:  ",nms[i2]," descargado."))
      }, error = function(e) {
        message(paste0("El archivo ",nms[i2],"no se ha podido descargar!!"))
      })
      
    }
  }
}
