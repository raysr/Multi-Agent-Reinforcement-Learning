extensions [py]
breed [hunters hunter]
breed [preys prey]
breed [experts expert]
breed [scouts scout]
breed [observators observator]
observators-own [reward-list]
hunters-own [reward-list]


to setup
  clear-all

  ; Mise en place de l'environnement python  et affectation de l'ensemble des paramètres de l'interface netlogo vers celui-ci.
  py:setup py:python3
  py:run "from  projet import *"
  py:set "radius_hunter" radius-hunters
   py:set "radius_scout" radius-scouts
  py:set "beta" beta
  py:set "gamma" gamma
  py:set "share_q_table" share-q-table
  py:set "mean_frequency" mean-frequency
  py:set "number_to_catch" number-to-catch
  py:set "epsilon" epsilon
  py:set "decay_rate" decay-rate
   py:set "teaching" teaching
  py:set "passive" passive
    py:set "communicating_hunters" communicating-hunters
   py:run "rl = RL(beta, gamma, 11, 11, radius=radius_hunter, radius_scout=radius_scout ,world_wraps=True, sharing_q_table=share_q_table, mean_frequency=mean_frequency, number_to_catch=number_to_catch, epsilon=epsilon, decay_rate=decay_rate, communicating_hunters = communicating_hunters, teaching=teaching, passive=passive)"


  ; Affectation des shapes à chaque breed existant
  set-default-shape hunters "cat"
  set-default-shape preys "mouse side"
  set-default-shape scouts "butterfly"
  set-default-shape experts "dog"
  set-current-plot "Steps by Episode"
  create-temporary-plot-pen ("Steps")


  ; Couleur du fond
  ask patches [
  set pcolor 62
  ]


  ; Creation du nombre choisi de chasseurs et initialisation du plot
  create-hunters number-hunters
  [
    set reward-list []
    create-temporary-plot-pen (word who)
    set-plot-pen-color blue
    set xcor random max-pxcor
    set ycor random max-pycor
    py:set "xcor" xcor
    py:set "ycor" ycor
    py:run "rl.add_hunter( xcor, ycor)"   ; Creation de l'equivalence au niveau de python
    set size 1
    set color black
  ]

   ; Creation du nombre choisi d'eclaireurs
  create-scouts number-scouts
  [
  set xcor random max-pxcor
    set ycor random max-pycor
          py:set "xcor" xcor
    py:set "ycor" ycor
    py:run "rl.add_scout( xcor, ycor)" ; Creation de l'equivalence au niveau de python
    set size 1
    set color 124
  create-links-to hunters
  ]

   ; Creation du nombre choisi de proies
  create-preys number-preys
  [
    set xcor random max-pxcor
    set ycor random max-pycor
    py:set "xcor" xcor
       py:set "ycor" ycor
    py:run "rl.add_prey( xcor, ycor)" ; Creation de l'equivalence au niveau de python
    set size 1
    set color grey
  ]

   ; Creation du nombre choisi d'experts
    create-experts experts-number
  [
    set xcor random max-pxcor
    set ycor random max-pycor
    py:set "xcor" xcor
       py:set "ycor" ycor
    py:run "rl.add_expert( xcor, ycor)" ; Creation de l'equivalence au niveau de python
    set size 1
    set color blue
  ]
end

to go
  let steps py:runresult "rl.iteration()"
  ask turtles [
  py:set "id" who
    let x py:runresult "rl.agents[id].posx"
    let y py:runresult "rl.agents[id].posy"
    set xcor x
    set ycor y

  ]

  if ( steps > 0 ) [

   plot steps
  ]
end

; Récupére les paramètres du systèmes, ainsi que des informations concernant chacun des agents et les affiche dans l'output
to print-infos
    let pprint py:runresult "rl.pprint()"
    clear-output
    output-print pprint
end

; Fonction permettant l'ajout d'un chasseur
to add-hunter
    create-hunters 1
  [
    set reward-list []
    set xcor random max-pxcor
    set ycor random max-pycor
    py:set "xcor" xcor
    py:set "ycor" ycor
    py:run "rl.add_hunter( xcor, ycor)"
    set size 1
    set color red
  ]
end


; Fonction permettant la suppression d'un agentt
to delete-agent
    py:set "id" agent-id
  py:run "rl.delete_agent(id)"
  ask  turtle agent-id [ die ]
end

; Récupére depuis un ID la Q-Table de l'agent concerné et la print dans la console
to print-q-table-states
  py:set "agent_id" agent-id
  py:run "rl.print_q(agent_id)"
end
@#$#@#$#@
GRAPHICS-WINDOW
559
32
1218
692
-1
-1
59.2
1
10
1
1
1
0
1
1
1
0
10
0
10
0
0
1
ticks
30.0

SLIDER
7
10
180
43
number-hunters
number-hunters
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
8
98
180
131
number-preys
number-preys
1
10
1.0
1
1
NIL
HORIZONTAL

BUTTON
398
355
471
388
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
483
355
546
388
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
16
404
542
671
Steps by Episode
NIL
NIL
0.0
300.0
0.0
10.0
true
false
"" ""
PENS

SLIDER
206
11
378
44
radius-hunters
radius-hunters
1
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
7
54
179
87
number-scouts
number-scouts
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
202
55
374
88
radius-scouts
radius-scouts
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
7
167
185
200
beta
beta
0.05
1
0.8
0.05
1
NIL
HORIZONTAL

SLIDER
217
168
389
201
gamma
gamma
0
1
0.9
0.05
1
NIL
HORIZONTAL

SWITCH
142
294
296
327
share-q-table
share-q-table
1
1
-1000

BUTTON
275
353
391
386
1-iteration
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
11
208
184
241
mean-frequency
mean-frequency
0
500
0.0
10
1
NIL
HORIZONTAL

SLIDER
220
209
392
242
number-to-catch
number-to-catch
1
2
1.0
1
1
NIL
HORIZONTAL

SLIDER
13
248
184
281
epsilon
epsilon
0
1
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
217
248
394
281
decay-rate
decay-rate
0
0.001
3.0E-5
0.00001
1
NIL
HORIZONTAL

OUTPUT
1225
29
1709
582
12

SWITCH
332
296
537
329
communicating-hunters
communicating-hunters
1
1
-1000

BUTTON
1453
661
1624
694
NIL
print-q-table-states
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1257
650
1418
710
agent-id
0.0
1
0
Number

BUTTON
1410
603
1514
636
NIL
print-infos
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
13
292
133
325
teaching
teaching
1
1
-1000

SLIDER
202
101
374
134
experts-number
experts-number
0
1
0.0
1
1
NIL
HORIZONTAL

SWITCH
22
349
272
382
passive
passive
1
1
-1000

@#$#@#$#@
## QUE FAIT LE MODELE ?
Ce modèle  permet l'evaluation  d'agents basés sur l'apprentissage par renforcement dans un environnement de type chasseur et proie ( chat et souris ) et d'analyser la performance de méthodes de coopération et communication.

## COMMENT CELA FONCTIONNE ?
Pour tester chaque scénario il faut désactiver l'ensemble des switchs  des autres scénarios,  exception faite du dernier ou le switch "passive" ne  fonctionne qu'en activant la communication.
Les différents scénarios pertinent à essayer sont décrits plus bas dans la section dédiée.

## ELEMENTS DE L'INTERFACE
### number-hunters
Nombre de chasseurs.

### number-scouts
Nombre d'éclaireurs.

### number-preys
Nombre de proies.

### radius-hunters
Rayon de vision des chasseurs ( si il y'en a ).

### radius-scouts
Rayon de vision des éclaireurs ( si il y'en a ).

### experts-number
Nombre d'agents expert.

### beta
Valeur Beta de l'algorithme de mise à jour de Q-Table

### gamma
Valeur Gamma de l'algorithme de mise à jour de Q-Table

### mean-frequency
Fréquence de mise à jour des Q-Table des chasseurs.

### epsilon
Valeur epsilon ( pourcentage d'actions aléatoires ) de l'algorithme.

### decay-rate
Valeur soustrait d'epsilon après chaque episode.

###  number-to-catch
Nombre de chasseurs nécessaires pour attraper une proie, si elle est égale à 1 il faudra que le chasseur soit sur la même case que la proie,  si elle est égale à 2 il faudra qu'il y'ait 2 chasseurs dans un rayon de 1 autour d'une même proie.

### teaching
Active l'échange  d'expériences réussis entre agents ( les autres switch doivent être désactivés ).

### share-q-table
Active le partage de sorte que tous les  agents partagent la même Q-Table

### communicating-hunters
Active la communication et echange d'états entre les chasseurs 

### passive
Son activation dépend de communicating-hunters, activer passive permet de faire en sorte que l'environnement

### 1-iteration
Réalisee  une seule iteration de chaque décision d'agent.

### setup
Permet de mettre en place l'ensemble des hyperparamètres définis et créer l'environnement dédié.


### go
Lance la fonction bouclant à l'infini et réalisant des  épisodes successifs.

### print-infos
Permet d'obtenir des infos générales sur l'instance d'apprentissage  ainsi que sur chacun des agents et  leurs hyperparamètres.

### print-q-tables
Après avoir préciser l'id de l'agent  voulu on peut visualiser sa Q-Table.


## SCENARIOS A ESSAYER
Pour l'ensemble des scénarios qui vont suivre certains paramètres  sont fixes :
Beta : 0.80
Gamma :  0.90
Epsilon : 0
Decay Rate : 0

### Agents ind́ependants
Number Scouts : 0
Number Experts : 0
frequency : 0
Desactiver l'ensemble des Switch
Number-to-catch : 1
Et tester plusieurs nombre de preys et hunters ainsi que différents radius pour le hunter.


### Premier Scenario : Partage de sensation
Number Scouts : 1
Number Hunters : 1
Number Experts : 0
frequency : 0
Desactiver l'ensemble des Switch
Number-to-catch : 1
Et tester plusieurs radius hunter et radius scout.


### Second Sćenario : Partage de politique de choix ou d’́episodes
#### Premier cas : Partage de Q-Table
Number Scouts : 0
Number Hunters : 2
Number Experts : 0
Desactiver l'ensemble des Switch sauf "share-q-table"
Et tester plusieurs radius hunter.

#### Deuxième cas : Synchronisation 
Number Scouts : 0
Number Hunters : 2
Number Experts : 0
Desactiver l'ensemble des Switch sauf "share-q-table"
Tester plusieurs "number-preys" et  ajuster la frequency de 20 à plus.

#### Troisième cas : Partage d’exṕeriences
Numbe Scouts : 0
Number Preys : 1 ou 2
Deux initialisations sont alors intéréssantes :
 - Number Hunters : 2 et Number Experts : 0
 - Number Hunters : 1 et Number Experts : 1


### Troisième Sćenario : Tâches jointes 
Number-to-catch : 2
Number-scouts : 0
Number-experts : 0

Ajuster : 
Number-preys : 1 ou 2
Communication : No 
Passive : Yes ou No ( nécessite que la valeur de  communication soit Yes )

## ASPECTS A OBSERVER
Observer les comportements émergents et décrits dans le rapport comme la manière qu'auront deux agents communiquants à se diriger vers la même proie ( dans le contexte du scénario de Tâche Jointe ) malgrés que l'un d'eux soit plus proche d'une autre proie.


## PERSPECTIVES
Permettre de visualiser en temps avec une couleur différentes les souris qu'un chat cible à un instant, ainsi que surligner chaque fois le champ de vision de chaque chat.

## FONCTIONNALITES NETLOGO SPECIALES
Ce modèle nécessite le  fichier python obligatoire et qui contient la logique de l'apprentissage par renforcement afin de fonctionner, au niveau de Netlogo cela fait  appel à l'extension "py", coté  python il faut la librairie de calculs  matriciels "numpy" seulement, l'ensemble des fonctionnalités  y étant codé directement sans  se baser sur d'autres  librairies externes.

## CREDITS AND REFERENCES
Github : https://github.com/raysr/Multi-Agent-Reinforcement-Learning
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dog
false
0
Polygon -7500403 true true 300 165 300 195 270 210 183 204 180 240 165 270 165 300 120 300 0 240 45 165 75 90 75 45 105 15 135 45 165 45 180 15 225 15 255 30 225 30 210 60 225 90 225 105
Polygon -16777216 true false 0 240 120 300 165 300 165 285 120 285 10 221
Line -16777216 false 210 60 180 45
Line -16777216 false 90 45 90 90
Line -16777216 false 90 90 105 105
Line -16777216 false 105 105 135 60
Line -16777216 false 90 45 135 60
Line -16777216 false 135 60 135 45
Line -16777216 false 181 203 151 203
Line -16777216 false 150 201 105 171
Circle -16777216 true false 171 88 34
Circle -16777216 false false 261 162 30

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

mouse side
false
0
Polygon -7500403 true true 38 162 24 165 19 174 22 192 47 213 90 225 135 230 161 240 178 262 150 246 117 238 73 232 36 220 11 196 7 171 15 153 37 146 46 145
Polygon -7500403 true true 289 142 271 165 237 164 217 185 235 192 254 192 259 199 245 200 248 203 226 199 200 194 155 195 122 185 84 187 91 195 82 192 83 201 72 190 67 199 62 185 46 183 36 165 40 134 57 115 74 106 60 109 90 97 112 94 92 93 130 86 154 88 134 81 183 90 197 94 183 86 212 95 211 88 224 83 235 88 248 97 246 90 257 107 255 97 270 120
Polygon -16777216 true false 234 100 220 96 210 100 214 111 228 116 239 115
Circle -16777216 true false 246 117 20
Line -7500403 true 270 153 282 174
Line -7500403 true 272 153 255 173
Line -7500403 true 269 156 268 177

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
