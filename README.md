# ?Que es la bailabilidad?
[![Twitter Follow](https://img.shields.io/twitter/follow/espadrine.svg?style=social&label=Sigueme%20en%20@flamenquino)](https://twitter.com/flamenquino)

Este micro-proyecto surge en 2018 cuando, tras escuchar ya repetidas veces [*Ocho Lineas*][1], donde tras unos versos, Sho-Hai suelta

*M?sica idonea para beber y :point_right::ok_hand:, ?bailar con esto? ?Te va a costar!*

A raiz de ahi, me vino a la cabeza la idea de demostrarlo. ?Y si era verdad?


### De idea a aplicaci?n

Esta secci?n tengo que detallarla a?n aunque, en general, segu? estos pasos:
  1. Buscar una aplicaci?n o algoritmo que devolviese estad?sticas sobre una canci?n. **Respuesta: Spotify.**
  2. Buscar una base de datos con la que comprar la canci?n. ?Qu? canciones son realmente "bailables"? **Respuesta: Hits de Los40.**
  3. Crear una rutina, usando R, para crear un stream desde el registro de Los40 a Spotify, y terminar obtieniendo datos.
  4. Mostrar estos datos, usando Shiny, mediante *forms* y un simple *scatterplot*.
  

Se muestra ***tempo~danceability*** en el *scatterplot* para mostrar que, normalmente, las canciones bailables en este tipo de rankings, que pertenecen en su mayoría a canciones de discoteca, tienen un tempo medio de 120-130 *bpm*. Además, los resultados visibles en el *scatterplot* son **interactivos**, de forma que si haces *click* en un punto, éste te redirige a la **página de Spotify del single**.


> Resultado: ejecuta `app.R`. **También puedes ver una [demo online aquí][2]**.


_Un proyecto de [Quim Terrasa][0]._

[0]: https://espetro.github.io
[1]: https://youtu.be/0IbK43e3vXs?t=75
[2]: https://espetro.shinyapps.io/danzabilidad/