# Estos scripts han sido desarrollados por Quino (espetro), durante mayo de 2018
# para un proyecto personal


# === Conversion de CSV a JSON ===
# De cara a la visualizacion, las librerias de JS leen los datos en formato JSON.
# Por ello, es preferible ordenar los datos previamente para no tener que hacer
# manipulaciones en JavaScript.

write.csv(songFinal, file = "results_all_songs_spotify.csv")

json <- toJSON(x = songFinal, "rows")

# 'write_json' coloca \" a ambos lados del JSON; usamos write
write(json, file = "results_features_json.json")
