class_name EnemySpawner
extends Node2D

## Zet met een vast interval vijanden neer op een cirkel rond de speler, net
## buiten beeld. In fase 6 gaat het interval omlaag naarmate de run langer
## duurt; in fase 7 komen de vijanden uit een object pool in plaats van uit
## Instantiate().

## Welke vijandscene er gespawnd wordt. Er is er maar één; het type bepaalt hoe
## hij eruitziet en hoe sterk hij is.
@export var enemy_scene: PackedScene

## De types die gespawnd kunnen worden, met hun relatieve gewicht. Staan alle
## drie op gewicht 30, dus elk type komt een derde van de tijd voorbij.
@export var vijand_types: Array[VijandType] = []

## Seconden tussen twee spawns.
@export var spawn_interval: float = 1.0:
	set(waarde):
		spawn_interval = maxf(waarde, 0.05)
		if is_instance_valid(_timer):
			_timer.wait_time = spawn_interval

## Afstand tot de speler waarop gespawnd wordt. Moet groter zijn dan de halve
## beelddiagonaal (ongeveer 661 px bij 1152x648), anders zie je ze verschijnen.
@export var spawn_afstand: float = 700.0

## Bovengrens op het aantal levende vijanden, zodat een test niet eindeloos
## doorgroeit.
@export var max_vijanden: int = 200

## Hoe ver een spawnpositie minimaal van de muur moet liggen.
@export var muurmarge: float = 60.0

var _timer: Timer
var _doel: Node2D


func _ready() -> void:
	_doel = get_tree().get_first_node_in_group("player")

	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.autostart = true
	_timer.timeout.connect(_op_timer)
	add_child(_timer)


func _op_timer() -> void:
	if enemy_scene == null or not is_instance_valid(_doel):
		return
	if get_tree().get_node_count_in_group("enemies") >= max_vijanden:
		return

	var vijand := enemy_scene.instantiate() as Enemy

	# Eerst positioneren, dan pas in de boom hangen. Andersom wordt de vijand bij
	# de physics-server aangemeld op de positie van de spawner - het midden van
	# de arena - en ziet de hurtbox van de speler hem daar als treffer, ook al
	# staat hij een regel later 700 pixels verderop. Dat kostte de speler elke
	# spawn een treffer uit het niets.
	#
	# spawn_op zet een positie in het stelsel van de spawner, vandaar dat de
	# eigen global_position eraf gaat.
	vijand.spawn_op(_kies_spawnpositie() - global_position, _kies_type())
	add_child(vijand)


## Trekt een type op basis van de gewichten.
##
## Werkt met gewichten en niet met vaste percentages, zodat je in fase 6 een
## vierde type kunt toevoegen of een zwaar type zeldzamer kunt maken zonder alle
## andere getallen opnieuw te hoeven laten optellen tot honderd.
func _kies_type() -> VijandType:
	if vijand_types.is_empty():
		return null

	var totaal := 0.0
	for t in vijand_types:
		if t != null:
			totaal += maxf(t.spawngewicht, 0.0)

	if totaal <= 0.0:
		return vijand_types[0]

	var trekking := randf() * totaal
	for t in vijand_types:
		if t == null:
			continue
		trekking -= maxf(t.spawngewicht, 0.0)
		if trekking <= 0.0:
			return t

	# Alleen bereikbaar door afrondingsverschillen in het optellen hierboven.
	return vijand_types[-1]


## Kiest een willekeurige hoek op een cirkel rond de speler. Ligt dat punt
## buiten het speelveld, dan wordt een andere hoek geprobeerd; lukt dat na een
## paar pogingen niet, dan wordt het punt naar binnen getrokken.
func _kies_spawnpositie() -> Vector2:
	var veld := Speelveld.rect_met_marge(muurmarge)
	var midden := _doel.global_position

	for _poging in 12:
		var hoek := randf() * TAU
		var positie := midden + Vector2.RIGHT.rotated(hoek) * spawn_afstand
		if veld.has_point(positie):
			return positie

	# Terugvaloptie: op de cirkel, maar binnen de muren geduwd.
	var hoek_fallback := randf() * TAU
	var ruw := midden + Vector2.RIGHT.rotated(hoek_fallback) * spawn_afstand
	return ruw.clamp(veld.position, veld.end)
