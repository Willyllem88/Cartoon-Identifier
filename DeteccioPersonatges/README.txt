===================================
=== README DETECCIO PERSONATGES ===
===================================

(Aquesta carpeta conte la part de deteccio de personatge. En particular es detecta, *Bob Esponja*)
(Tambe comentem que cada script te una breu descripcio del que fa, per si ajuda a la comprensio de la practica)

=== Com executar? ===

Per executar aquesta part del projecte, nomes cal executar el main.m (a matlab o com sigui). Un cop s'exeucta, l'usuari ha d'introduir l'opcio 1 o 2:

Amb l'opcio (1), l'usuari podra selccionar una imatge al seu sistema de  carpetes, i el programa imprimira si creu que hi ha el personatge spongebob o no.

Amb l'opcio (2), l'usuari podra seleccionar una carpeta de TEST (que contingui subcarpetes "positives" i "negatives" amb aquests noms!). El programa llavors, predira cada imatge, i finalment es mostra la matriu de confussio donada per les imatges de TEST.

=== Estructura de directoris ===

== ./ ==

· main.m: script principal
· extract_featuers_spongebob: extreu features d'un patch (window de 128x128) d'una imatge.
· test_image_spongebob: opcio1 del main.m
· test_folder_spongebob: opcio2 del main.m
· trainedModel_FineTree: model Fine Tree obtingut amb el classification learner, que reconeix si un patch (window de 128x128) es d'un bob esponja o no
· detection_spongebob: script que donada una imatge, retorna si a l'imatge hi apareix un bob esponja o no (el funcionament es detalla a la documentacio i script)

== TRAIN ==

· positives: carpeta que conte patches (imatges 128x128) on el bob esponja hi es present.
· negatives: carpeta que conte patches (imatges 128x128) on el bob esponja NO hi es present.

== TEST (i TEST2) ==
conte imatges de TEST, separades en subcarpetes "positives" i "negatives"

== spongebob_dataset ==

Dataset d'imatges de la seria de Bob Esponja. given_spongebob_dataset inclou les imatges que es donaven amb l'enunciat de la practica. extended_spongebob_data son imatges noves que hem obtingut nosaltres mateixos, utilitzant un script de python que es troba a la mateixa carpeta.

== scripts_to_train_model ==

Inclou tot el relacionat per obtenir un model (graices al classification learner) utilitzant les imatges de TRAIN. Els detalls de cada script son a la descripcio de cada script respectivament.

== scripts_to_get_TRAIN ==

Inclou tot el relacionat per obtenir les imatges de TRAIN. Els detalls de cada script son a la descripcio de cada script respectivament. Comtenem que els patches de TRAIN s'obtenen a partir de les imatges de /spongebob_dataset, que han sigut "labelajades" gracies al imageLabeler de matlab


