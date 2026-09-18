# Vijandtypes en balansinstellingen

Overzicht van de vijandtypes en de waarden waarmee ze onderscheiden worden.
Dit is het bewijsstuk dat het Plan van Aanpak in week 6 vraagt.

## Opzet

Er is **één** `enemy.gd` en **één** `enemy.tscn`. Een type is een resource
(`VijandType`) met alleen data erin, opgeslagen als `.tres` in
`scenes/enemies/types/`. De spawner trekt bij elke spawn een type en geeft het
mee aan `spawn_op()`.

Dat is bewust zo, om twee redenen:

- Het Plan van Aanpak vraagt vijandtypes te onderscheiden via instelbare waarden
  in plaats van via aparte scriptklassen per type.
- In fase 7 is er dan **één** object pool nodig in plaats van een pool per type.
  Een vijand die uit de pool komt krijgt gewoon een ander type toegewezen.

Een vierde type toevoegen is een `.tres` aanmaken en in de lijst op de spawner
zetten. Er hoeft geen regel code bij.

## De drie types

| | Clawed Abomination | Depraved Blackguard | Crimson Imp |
|---|---|---|---|
| Rol | traag, taai, weinig schade | middenmoot | snel, breekbaar, hard |
| Levenspunten | 175 | 105 | 70 |
| Treffers tot dood (bij 35 schade) | 5 | 3 | 2 |
| Loopsnelheid | 70 px/s | 120 px/s | 210 px/s |
| Contactschade | 60 | 100 | 150 |
| Spritevergroting | 4,2× | 3,5× | 3,0× |
| Botsingsstraal | 28 | 24 | 19 |
| Spawngewicht | 30 | 30 | 30 |

De gewichten zijn relatief, niet in procenten: drie types met gewicht 30 leveren
elk een derde op. Zo kun je later een vierde type toevoegen zonder alle andere
getallen opnieuw te laten optellen tot honderd.

## Waarom deze getallen

**De levenspunten hangen aan het wapen.** Om bij te blijven geldt:

```
schoten per seconde  >=  treffers per kill  x  spawns per seconde
```

Het wapen doet 35 schade en vuurt vier keer per seconde. Gemiddeld over de drie
types zijn dat (5 + 3 + 2) / 3 = 3,3 treffers per kill, dus ongeveer 1,2 kills
per seconde tegen 1 spawn per seconde. Genoeg marge om vooruit te komen, niet zo
veel dat het saai wordt.

Pas je de spawnfrequentie of de wapenschade aan, reken deze som dan opnieuw.
Zet je de levenspunten van de Abomination bijvoorbeeld op 260, dan zijn dat acht
treffers en kom je onder de 1,0 kills per seconde — dan loopt het aantal
vijanden onherroepelijk op.

**Contactschade werkt anders dan je verwacht.** De speler is na een treffer 0,5
seconde onkwetsbaar, dus hij krijgt hooguit **twee treffers per seconde**,
ongeacht hoeveel vijanden er tegen hem aan staan. De "dps" van een type is
daarmee gewoon zijn contactschade maal twee. Met 1000 levenspunten overleeft de
speler dus ongeveer:

| Type | schade per treffer | dps | seconden |
|---|---|---|---|
| Clawed Abomination | 60 | 120 | 8,3 |
| Depraved Blackguard | 100 | 200 | 5,0 |
| Crimson Imp | 150 | 300 | 3,3 |

**Botsingsstraal hoort bij de spritevergroting.** Staan die uit verhouding, dan
raakt een vijand je terwijl hij nog zichtbaar naast je loopt, of andersom. Let
er ook op dat vijanden elkaar opzij duwen: een grotere straal betekent dat een
Abomination meer ruimte inneemt in een kluwen.

## Nog te doen in fase 6

De waarden hierboven zijn de startwaarden. De moeilijkheidsgraad moet nog
oplopen met de speeltijd — spawnfrequentie omhoog, en levenspunten en
contactschade schalen mee. De logische plek daarvoor is de spawner, die dan de
waarden van het gekozen type vermenigvuldigt voordat hij ze doorgeeft.
