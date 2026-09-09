class_name EnemySpawner
extends Node2D

## Zet met een vast interval vijanden neer op een cirkel rond de speler, net
## buiten beeld. In fase 6 gaat het interval omlaag naarmate de run langer
## duurt; in fase 7 komen de vijanden uit een object pool in plaats van uit
## Instantiate().

## Welke vijandscene er gespawnd wordt.
@export var enemy_scene: PackedScene

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
	# Eerst in de boom hangen, dan pas positioneren: _ready moet gedraaid
	# hebben voordat spawn_op de speler opzoekt.
	add_child(vijand)
	vijand.spawn_op(_kies_spawnpositie())


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
