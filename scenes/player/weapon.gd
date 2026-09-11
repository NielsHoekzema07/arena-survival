class_name Weapon
extends Node2D

## Schiet automatisch op de dichtstbijzijnde vijand binnen bereik.
##
## Hangt als kind onder de speler, maar de kogels worden bewust NIET onder de
## speler gehangen: dan zouden ze met hem meebewegen. Ze gaan naar de node in de
## groep "projectielen" in de hoofdscene.

## Welke kogelscene er geschoten wordt.
@export var bullet_scene: PackedScene

## Seconden tussen twee schoten.
@export var vuur_interval: float = 1:
	set(waarde):
		vuur_interval = maxf(waarde, 0.05)
		if is_instance_valid(_timer):
			_timer.wait_time = vuur_interval

## Maximale afstand waarop nog geschoten wordt. Vijanden verder weg worden
## genegeerd, zodat je niet op iets buiten beeld staat te vuren.
@export var bereik: float = 200.0

var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = vuur_interval
	_timer.autostart = true
	_timer.timeout.connect(_probeer_vuren)
	add_child(_timer)


func _probeer_vuren() -> void:
	var doel := dichtstbijzijnde_vijand()
	if doel == null:
		return
	_vuur_op(doel)


## Zoekt de vijand die het dichtst bij is en binnen bereik ligt.
## Geeft null terug als er niets in de buurt is.
func dichtstbijzijnde_vijand() -> Node2D:
	var beste: Node2D = null

	# Vergelijken op de afstand in het kwadraat. Dat scheelt een wortel per
	# vijand, en voor "welke is het dichtst bij" geeft het dezelfde uitkomst.
	# Daarom staat ook het bereik hier in het kwadraat.
	var kleinste_afstand := bereik * bereik

	for vijand: Node2D in get_tree().get_nodes_in_group("enemies"):
		var afstand := global_position.distance_squared_to(vijand.global_position)
		if afstand < kleinste_afstand:
			kleinste_afstand = afstand
			beste = vijand

	return beste


func _vuur_op(doel: Node2D) -> void:
	if bullet_scene == null:
		push_warning("Weapon heeft geen bullet_scene ingesteld.")
		return

	var container := get_tree().get_first_node_in_group("projectielen")
	if container == null:
		push_warning("Geen node in de groep 'projectielen' gevonden.")
		return

	var kogel := bullet_scene.instantiate() as Bullet
	container.add_child(kogel)
	kogel.spawn_op(global_position, global_position.direction_to(doel.global_position))
