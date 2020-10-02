# AXD3DLocalizer


## Localisation latérale de flux audios binauraux en temps réel

### Problématiques et contraintes :

Ce projet de recherche visait à répondre à un besoin d'un indicateur fiable en temps réel des attributs spatiaux des signaux audio binauraux ; en d'autres termes, d'un outil permettant la localisation dans l'espace de la source enregistrée d'une piste son 3D tel que le ferait le cerveau humain.

### Démarche de recherche :

Nous avons tout d'abord fait un tour d'horizon de l'état de l'art en matière de localisation de flux audios binauraux. Trois approches distinctes s'en détachent :

La première approche cherche à prédire la localisation perçue par des sujets précis soumis à des signaux binauraux, cette fois-ci uniquement en prenant en compte l'élévation, en s’appuyant sur la comparaison entre des valeurs précalculées connues et des valeurs de localisation cibles. Le modèle reçoit les HRTFs du sujet testé pour toutes les directions. Il calcule les Directional Transfer Function (DTF) correspondantes en calculant d’abord la Common Transfer Function, soit la partie commune à toutes les HRTFs, qui est ensuite retirée. 
Cela permet de ne travailler que sur la partie utile des HRTFs. Une représentation spectrale correspondant à chaque angle est ensuite calculée sur 28 bandes différentes par une banque de filtres gammatone. 
Le même traitement est appliqué sur le signal binaural de test : la DFT du sujet est soustraite et une représentation spectrale gammatone est calculée. L’Inter-Spectral Difference (ISD) est ensuite calculée bande par bande entre chaque représentation spectrale connue et la représentation spectrale cible, son écart-type est ensuite retenu comme métrique de distance.
Une fonction gaussienne dont l’écart-type U est calibré en fonction du sujet est enfin appliquée, suivie d’une pondération binaurale en fonction de l’angle latéral de la source afin d’obtenir une vecteur de probabilité de l’élévation de la source sonore.

La seconde se base sur la présence et l'extraction, au sein des spectres fréquenciels des signaux, de pics caractéristiques estimées pertinents pour la localisation binaurale. Ces portions de signal sont ensuite filtrées par bande par une banque de filtres (gammatone), et les ITD et ILD de chacune de ces bandes sont calculées. Ces ITD et ILD sont ensuite comparées aux valeurs d’ITD et d’ILD obtenues pour les HRTF d'une base de référence afin d’obtenir un azimut correspondant. 
Enfin, un azimut global est calculé en pondérant les azimuts correspondant aux ITDs et ILDs de chaque bande, selon l'intensité du signal dans chaque bande, ainsi que selon une pondération issue de l’effet Duplex (pondération de l’ITD et de l’ILD par l’audition humaine en fonction de la fréquence). 
La distinction avant-arrière n'est pas calculable par ce type d'approche et la localisation est donc limité à un axe gauche-droite.

Enfin, en reprenant le principe de la comparaison source / cible, une valeur d’ITD et une représentation spectrale gammatone sont calculées pour les HRTFs template et le signal cible. L’ISD et la différence d’ITD sont pondérées et les valeurs résultantes normalisées par la fonction z-score afin d’obtenir le vecteur de probabilité de la direction. 

Notons que les trois modèles cités s’appuient avant tout sur une modélisation de l’audition humaine plutôt que sur une modélisation du phénomène acoustique réel. 

## Solution algorithmique adoptée : 

Le modèle que nous avons développé et implémenté cherche à déterminer l'azimut d'un speaker situé dans une pièce pour lequel nous avons le BRIR. La latéralisation et la distinction avant-arrière sont estimées, l'élévation est ignorée. D'abord, le HRIR est extrait du BRIR, puis il est comparé à tous les HRIR d'une base de données. Cependant, l'estimation de l'angle latéral de la source est dissociée de la distinction avant-arrière.
La bande ILD et les différences ITD globales sont utilisées pour la latéralité, et l'écart-type de la différence spectrale est utilisé pour la distinction avant-arrière. Dans les deux cas, une valeur de proximité est attribuée aux angles latéraux ou hémisphères correspondant à chacun des HRIR de chaque sujet, et l'ensemble des valeurs obtenues est utilisé pour déduire l'azimut le plus probable.
La première étape consiste en l'extraction de l'HRTF de la BRIR.

Si le haut-parleur possède une réponse en fréquence absolument neutre, alors on trouve au début du signal une HRTF "pur". En pratique, le haut-parleur possède lui-même une réponse en fréquence et en phase qui ont traité le son direct, et le début du signal de la BRIR contient donc à la fois la réponse impulsionelle du haut-parleur et l’HRTF. Comme il n’est pas possible de compenser l’effet du haut-parleur à moins de connaître ses caractéristiques, on néglige donc cet aspect en considérant que le signal extrait de la BRIR ne contiendra que l’HRTF. 

La question se posant en suite est donc la suivante : quand termine le son direct et son HRIR, et quand comment la première réflexion ? La situation va nécessairement varier d’une BRIR à l’autre, et il est tout à fait possible que la première réflection débute alors que le son direct et son HRTF sont encore présents dans la réponse impulsionelle. Après plusieurs tests des valeurs susceptibles de donner de bons résultats de localisation, la valeur retenue pour la durée de l’HRIR a été fixée à 6 ms. A titre d’ordre de grande, certaines bases de données audios telles que MIT-KEMAR fournissent des HRIRs d’une durée de 12 ms (512 samples à 44,1 kHz) en version brute et 3 ms (128 samples) en version compacte. 

Par ailleurs, dans une réponse impulsionnelle, les transformations du signal dans les fréquences aiguës sont représentées en moins de temps (moins d’échantillons) que les variations dans les fréquences graves. Cependant, les parties du spectre présentant de plus fortes variations nécessiteront d’avantage d’échantillons pour être correctement représentés, et dans une HRTF la partie aiguë de la réponse en fréquence est souvent plus accidentée que la partie grave. Là aussi après tests, nous avons décidé d’appliquer un filtre passe-bas sur la fin de l’HRIR afin de conserver une éventuelle partie basse-fréquence qui n’aurait pas fini de s’exprimer alors que la première réflection aurait déjà débuté. 
 
Un dernier paramètre à prendre en compte est que l’HRIR du son direct ne termine pas nécessairement en même temps sur les deux canaux, précisément à cause du décalage temporel (ITD) causé par le trajet nécessaire pour atteindre l’oreille controlatérale (la plus éloignée de la source). Enfin, il est possible que l’HRIR ne démarre pas dès le début de la BRIR si celle-ci contient un peu de silence initial. 



