
# master download data

library(rvest)
library(magrittr)


usuario <- "javierluis.rodriguez"
contra <- "xa1234bi"


url <- "http://eio.usc.es/pub/mte/index.php/es/acceder"
ses <- html_session(url,encoding = "UTF-8")


f.log <- ses %>%
  html_node("form") %>%
  html_form() %>%
  set_values("nombreUsuario" = usuario,
             "contraseña" = contra)

ses2 <- submit_form(ses,f.log,"login") 

url2 <- "http://eamo.usc.es/eipc1/base/BASEMASTER/FORMULARIOS-PHP/MateriasAlumno.php?al=SI"

user.asig <-  ses2 %>% jump_to(url2)

# # valores
# val <- user.asig %>%
#   html_nodes(xpath = '//*[@id="element_5_6"]/option') %>%
#   html_attr("value")
# 
# val <- val[grepl("[0-9]{2}-[0-9]{4}", val)]

# Nombres
op <- user.asig %>%
  read_html(encoding = "UTF-8") %>%
  html_nodes(xpath = '//*[@id="element_5_6"]/option') %>%
  html_text(trim = TRUE)

op <- op[nchar(op) > 5]

# display asignaturas 
cat(
  "Asignaturas disponibles : \n",
  paste0(" ", seq(length(op)), " --- ",op, "\n")
)

pick.asig <- readline("Selecciona asignatura/s :") %>%
str_extract_all(,pattern = "[0-9]{1,2}") %>%
  unlist() %>%
  as.numeric()




# error en el nº de asignaturas
# psoibilidad de un grepl para los characters que no tengan curso



# form asignatura
f.asig <- user.asig %>%
  html_nodes("form") %>%
  html_form() %>%
  '[['(2) %>%
  set_values("nom_materia" = f.asig$fields$nom_materia$options[i + 1])

a <- submit_form(user.asig, f.asig, "submit")

t.mat <- a %>% read_html(encoding = "UTF-8") %>%
  html_nodes(xpath = '//*[@id="li_4"]/table[2]') %>% html_nodes("a")

# nombres y links
disp <- t.mat %>% html_text() %>% trimws()
link <- t.mat %>% html_attr("href")
nms <- sapply(strsplit(link,split = "Mat_[0-9]{1,}_?[0-9]{1,}_"), function(x) x[2])
# falta añadir las fechas de incorporación del arhcivo


# display archivos disponibles
cat(
  "Archivos disponibles a",
  as.character(Sys.Date()),
  " : \n",
  paste0(" ", seq(length(disp)), " --- ", disp, "\n")
# descarga
)

dwn <- jump_to(a,link[2]) 
download.file(dwn$url,disp[2],mode = "wb")

