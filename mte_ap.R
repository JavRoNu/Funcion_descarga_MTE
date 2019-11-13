
# master download data

library(rvest)

usuario <- "javierluis.rodriguez"
contra <- "xa1234bi"


url <- "http://eio.usc.es/pub/mte/index.php/es/acceder"
ses <- html_session(url,encoding = "UTF-8")


form <- ses %>% 
             html_node("form") %>%
                           html_form() %>%
                                   set_values("nombreUsuario" = usuario,
                                              "contraseña" = contra)

ses2 <- submit_form(ses,form) 

url2 <- "http://eamo.usc.es/eipc1/base/BASEMASTER/FORMULARIOS-PHP/MateriasAlumno.php?al=SI"

user.asig <-  ses2 %>% jump_to(url2)

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
 