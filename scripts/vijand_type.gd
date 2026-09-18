class_name VijandType
extends Resource

## Alle waarden die een vijandtype onderscheiden, als losse resource.
##
## Er is bewust maar één Enemy-script en één enemy.tscn. Een type is data, geen
## eigen klasse: dat is wat het Plan van Aanpak bedoelt met "vijandtypes
## onderscheiden via instelbare waarden in plaats van via aparte scriptklassen".
##
## Het levert ook iets op voor fase 7. Met aparte scenes per type zou je straks
## een object pool per type nodig hebben; nu is het één pool met objecten die je
## bij het hergebruiken een ander type geeft.
##
## Een nieuw type toevoegen is dus: een .tres aanmaken, geen regel code.

## Alleen voor jezelf, om het type te herkennen in de editor en in logs.
@export var naam: String = ""

## De vier loopframes. In de .tres staan dat AtlasTexture-uitsnedes uit een
## spritesheet van 64x16, zodat er één bestand per vijand nodig is.
@export var sprite_frames: SpriteFrames

## Hoeveel keer het 16x16-plaatje vergroot wordt.
@export var sprite_schaal: float = 3.0

## Straal van de botsingscirkel. Hoort ongeveer bij de sprite_schaal te passen,
## anders klopt het beeld niet met waar de vijand daadwerkelijk raakt.
@export var straal: float = 22.0

@export_group("Gedrag")

## Loopsnelheid in pixels per seconde.
@export var speed: float = 120.0

## Levenspunten. Deel door de schade van het wapen voor het aantal treffers.
@export var max_health: int = 100

## Schade aan de speler bij aanraking.
##
## Let op: door de onkwetsbaarheid van 0,5 s krijgt de speler hooguit twee
## treffers per seconde, ongeacht hoeveel vijanden er tegen hem aan staan. De
## "dps" van een type is dus gewoon deze waarde maal twee.
@export var contactschade: int = 100

## Relatief gewicht bij het spawnen. Drie types met alle drie 30 leveren elk een
## derde op; de getallen hoeven niet op te tellen tot 100.
@export var spawngewicht: float = 30.0
