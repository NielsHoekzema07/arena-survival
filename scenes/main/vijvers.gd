class_name Vijvers
extends Node2D

## Zet bij het starten van een run een aantal vijvers in de arena neer.
##
## Een vijver is drie dingen tegelijk: een donkere oeverrand, een watervlak, en
## een StaticBody2D op de laag `world`. Door die laatste gelden ze automatisch
## als muur voor zowel de speler als de vijanden - allebei hebben `world` al in
## hun collision_mask staan, dus er hoeft niets aan die scenes te veranderen.
##
## De vijvers worden in code gemaakt en niet in de scene gezet, zodat elke run
## er anders uitziet en de arenagrootte vanzelf gevolgd wordt.

## Hoeveel vijvers er geprobeerd worden. Er kunnen er minder komen als er geen
## plek meer vrij is.
@export var aantal: int = 7

@export var straal_min: float = 90.0
@export var straal_max: float = 210.0

## Hoe ver een vijver minimaal van de arenamuur blijft.
@export var marge_rand: float = 160.0

## Vrije cirkel rond het midden. De speler begint op (0, 0) en moet niet in of
## tegen een vijver starten.
@export var vrije_zone_midden: float = 420.0

## Minimale ruimte tussen twee vijvers, zodat er altijd doorheen te lopen is.
@export var tussenruimte: float = 140.0

## Vaste waarde geeft elke run dezelfde vijvers; 0 is elke run anders. Handig om
## op vast te zetten als je aan het meten bent in fase 7.
@export var vaste_seed: int = 0

@export_group("Uiterlijk")
@export var waterkleur: Color = Color(0.29, 0.55, 0.68, 1.0)
@export var oeverkleur: Color = Color(0.60, 0.56, 0.40, 1.0)
@export var oeverbreedte: float = 1.10

## Middelpunt en straal van elke vijver, voor de controle of een punt erin ligt.
var _vijvers: Array[Dictionary] = []


func _ready() -> void:
	add_to_group("vijvers")
	_genereer()


## Of een punt in of vlak naast een vijver ligt. De spawner gebruikt dit om te
## voorkomen dat er een vijand midden in het water verschijnt.
func ligt_in_vijver(punt: Vector2, extra_marge: float = 0.0) -> bool:
	for v in _vijvers:
		if punt.distance_to(v["midden"]) < v["straal"] + extra_marge:
			return true
	return false


func _genereer() -> void:
	var rng := RandomNumberGenerator.new()
	if vaste_seed != 0:
		rng.seed = vaste_seed
	else:
		rng.randomize()

	var veld := Speelveld.rect_met_marge(marge_rand)

	# Begrensd aantal pogingen: bij een volle arena vindt hij anders nooit meer
	# een vrije plek en blijft de lus hangen.
	var pogingen := 0
	while _vijvers.size() < aantal and pogingen < aantal * 40:
		pogingen += 1

		var straal := rng.randf_range(straal_min, straal_max)
		var pos := Vector2(
			rng.randf_range(veld.position.x + straal, veld.end.x - straal),
			rng.randf_range(veld.position.y + straal, veld.end.y - straal)
		)

		if pos.length() < vrije_zone_midden + straal:
			continue
		if _te_dicht_bij_andere(pos, straal):
			continue

		_maak_vijver(pos, straal, rng)


func _te_dicht_bij_andere(pos: Vector2, straal: float) -> bool:
	for v in _vijvers:
		if pos.distance_to(v["midden"]) < straal + v["straal"] + tussenruimte:
			return true
	return false


func _maak_vijver(pos: Vector2, straal: float, rng: RandomNumberGenerator) -> void:
	var vorm := _blob(straal, rng)

	var vijver := Node2D.new()
	vijver.position = pos

	var oever := Polygon2D.new()
	oever.polygon = _geschaald(vorm, oeverbreedte)
	oever.color = oeverkleur
	vijver.add_child(oever)

	var water := Polygon2D.new()
	water.polygon = vorm
	water.color = waterkleur
	vijver.add_child(water)

	# De botsing volgt het watervlak, niet de oever: je mag met je voeten net
	# in de rand staan, dat ziet er natuurlijker uit dan stoppen op het gras.
	var lichaam := StaticBody2D.new()
	lichaam.collision_layer = 16  # world
	lichaam.collision_mask = 0
	var botsing := CollisionPolygon2D.new()
	botsing.polygon = vorm
	lichaam.add_child(botsing)
	vijver.add_child(lichaam)

	add_child(vijver)
	_vijvers.append({"midden": pos, "straal": straal * oeverbreedte})


## Een onregelmatige cirkel, zodat het geen perfecte ronde plas wordt.
func _blob(straal: float, rng: RandomNumberGenerator) -> PackedVector2Array:
	var hoeken := 16

	var ruw: Array[float] = []
	for i in hoeken:
		ruw.append(rng.randf_range(0.76, 1.16))

	# Gemiddelde van de buren nemen, anders wordt het een ster in plaats van een
	# plas. De modulo zorgt dat de laatste punt netjes op de eerste aansluit.
	var punten := PackedVector2Array()
	for i in hoeken:
		var glad: float = (ruw[(i - 1 + hoeken) % hoeken] + ruw[i] + ruw[(i + 1) % hoeken]) / 3.0
		punten.append(Vector2.RIGHT.rotated(TAU * i / hoeken) * straal * glad)
	return punten


func _geschaald(punten: PackedVector2Array, factor: float) -> PackedVector2Array:
	var uit := PackedVector2Array()
	for p in punten:
		uit.append(p * factor)
	return uit
