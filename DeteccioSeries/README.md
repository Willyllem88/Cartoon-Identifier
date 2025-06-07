# Cartoon-Identifier

Part del projecte encarregada de la detecció de sèries de dibuixos animats a partir d'imatges. Les classifica en 8 categories diferents.

## Requeriments:

Es necessiten les següents llibreries de MATLAB:

- Statistics and Machine Learning Toolbox
- Image Processing Toolbox

## Instruccions d'ús:

Per executar la part del projecte orientada a l'usuari, cal executar el fitxer `main.m`. Aquest fitxer conté el codi necessari per carregar les imatges i classificar-les en les diferents categories de sèries de dibuixos animats.

La resta de fitxers s'expliquen a la documentació del projecte, però no cal executar-los directament. Són utilitzats internament pel fitxer `main.m`. I per entrenar el model de classificació.

## Fitxers importants:

- `main.m`: Fitxer principal que executa el projecte.
- `seriesClassification.mat`: Model de classificació entrenat que s'utilitza per classificar les imatges.
- `classifier.m`: script que genera les taules d'entrenament del model de classificació.
- `extreureCaracteristiques.m`: script que extreu les característiques de les imatges per al model de classificació.
- `spilt_train_test.m`: script que divideix les dades en un conjunt d'entrenament i un conjunt de prova.