# Mapa Interativo da Batimetria da Lagoa da Conceição
# Marcio Baldissera Cure
# 01/05/2026
# Dados obtidos em https://geoportal.pmf.sc.gov.br/downloads/camadas-em-sig-do-mapa

library(tidyverse)
library(sf)
library(leaflet)
library(leaflet.extras)
library(htmlwidgets)
library(htmltools)

bat <- st_read("./batimetria_lagoa_conceicao/batimetria_lagoa_conceicao.shp") #|> 
#  mutate(z = -z) |> filter(z > 0)
canal <- st_read("./canal_barra_lagoa/canal_barra_lagoa.shp")


# Converter para o sistema de coordenadas do Leaflet (WGS84)
batimetria_latlong <- st_transform(bat, crs = 4326)

pal <- colorNumeric(
  palette = "YlGnBu", # Poderia ser tb "Blues", "viridis", "mako"
  domain = batimetria_latlong$z,
  reverse = TRUE # TRUE para que cores escuras sejam o fundo
)

# Mapa
mapa <- leaflet(batimetria_latlong) |> 
  # Adiciona Camada de Satélite (Esri)
  addProviderTiles(providers$Esri.WorldImagery, group = "Satélite") |> 
  # Adiciona Camada de Ruas (OpenStreetMap)
  addTiles(group = "Mapa de Ruas") |> 
  
  # Adiciona o shape da Batimetria
  addPolygons(
    fillColor = ~pal(z), 
    fillOpacity = 0.7, 
    color = "white", 
    weight = 0.5, 
    group = "Batimetria",
    popup = ~paste0("<div style='font-size: 17px; padding: 10px;'>",
                    "<b>Profundidade:</b> ", z, " m",
                    "</div>"),
    popupOptions = popupOptions(maxWidth = 300, minWidth = 150),
  ) |> 
  prependContent(tags$style(HTML("
    .leaflet-control-layers-toggle { width: 50px !important; height: 50px !important; } /* Botão de camadas */
    .leaflet-control-zoom-in, .leaflet-control-zoom-out { width: 40px !important; height: 40px !important; line-height: 40px !important; } /* Botão +/- */
    .info.legend { font-size: 16px !important; padding: 10px !important; } /* Tamanho da Legenda */
    .info.legend i { width: 25px !important; height: 25px !important; } /* Tamanho dos quadradinhos da legenda */")
                            )) |> 
  
  # Controle de Camadas (Ligar/Desligar)
  addLayersControl(
    baseGroups = c("Satélite", "Mapa de Ruas"), # Apenas um fundo por vez
    overlayGroups = c("Batimetria"),           # Pode ligar/desligar por cima
    options = layersControlOptions(collapsed = FALSE)
  ) |> 
  
  # Adiciona Botão de Localização do usuário
  addControlGPS(
    options = gpsOptions(
      position = "topleft", 
      activate = TRUE, 
      autoCenter = TRUE, 
      maxZoom = 16,
      setView = TRUE
    )
  ) |> 
  
  addLegend(
    pal = pal, 
    values = ~z, 
    title = "Profundidade (m)", 
    position = "bottomright"
  )


htmlwidgets::saveWidget(mapa, "batimetria_lagoa_da_conceicao_2.html")
