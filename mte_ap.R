
# master download data

library(rvest)

usuario <- "javierluis.rodriguez"
contra <- "xsa123aaaa4bi"


url <- "http://eio.usc.es/pub/mte/index.php/es/acceder"
ses <- html_session(url,encoding = "UTF-8")


form <- ses %>% 
             html_node("form") %>%
                           html_form() #%>%
                                   set_values("nombreUsuario" = usuario,
                                              "contraseña" = contra)

ses2 <- submit_form(ses,form,"login") 

url2 <- "http://eamo.usc.es/eipc1/base/BASEMASTER/FORMULARIOS-PHP/MateriasAlumno.php?al=SI"

user.asig <-  ses2 %>% jump_to(url2)

url3 <- "http://eamo.usc.es/eipc1/base/BASEMASTER/FORMULARIOS-PHP/detalleMateriasAlumno.php"

laasig <- ses2 %>% jump_to(url3) 

# valores
val <- user.asig %>% 
  html_nodes(xpath = '//*[@id="element_5_6"]/option') %>%
  html_attr("value") 

val <- val[grepl("[0-9]{2}-[0-9]{4}",val)]

# Nombres
op <- user.asig %>% 
  read_html(encoding = "UTF-8") %>%
  html_nodes(xpath = '//*[@id="element_5_6"]/option') %>%
  html_text(trim = TRUE)

op <- op[nchar(op) > 5]

# error en el nº de asignaturas

# submit
form.asig <- user.asig %>% html_nodes("form")
form.asig <- form.asig[2]  %>% html_form() %>% set_values("select" = op[1])
