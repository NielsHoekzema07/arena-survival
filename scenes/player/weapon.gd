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
@export var bereik: float = 200.0:
	set(waarde):
		bereik = maxf(waarde, 0.0)
		# De cirkel moet meegroeien zodra een upgrade het bereik verhoogt.
		queue_redraw()

@export_group("Bereikcirkel")

## Of de cirkel getekend wordt. Uitzetten als je hem in beeld te druk vindt.
@export var toon_bereik: bool = true:
	set(waarde):
		toon_bereik = waarde
		queue_redraw()

@export var cirkelkleur: Color = Color(0.45, 0.85, 1.0, 0.35):
	set(waarde):
		cirkelkleur = waarde
		queue_redraw()

@export var lijndikte: float = 2.0:
	set(waarde):
		lijndikte = maxf(waarde, 0.5)
		queue_redraw()

## Lengte van een streepje plus de tussenruimte, in pixels. Het aantal streepjes
## wordt hieruit berekend in plaats van vast te staan, zodat ze even lang
## blijven als het bereik verandert.
@export var streeplengte: float = 26.0:
	set(waarde):
		streeplengte = maxf(waarde, 4.0)
		queue_redraw()

## Welk deel van een streeplengte daadwerkelijk getekend wordt; de rest is gat.
@export var streepverhouding: float = 0.55:
	set(waarde):
		streepverhouding = clampf(waarde, 0.05, 1.0)
		queue_redraw()

var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = vuur_interval
	_timer.autostart = true
	_timer.timeout.connect(_probeer_vuren)
	add_child(_timer)


## Tekent het bereik als een gestreepte cirkel rond de speler.
##
## Staat in deze node en niet in een eigen node: Weapon is al een Node2D op de
## positie van de speler, dus de cirkel staat vanzelf goed en volgt hem mee.
func _draw() -> void:
	if not toon_bereik or bereik <= 0.0:
		return

	# Aantal streepjes uit de omtrek halen, zodat een streepje er bij bereik 200
	# net zo uitziet als bij bereik 800.
	var omtrek := TAU * bereik
	var aantal := maxi(int(omtrek / streeplengte), 8)
	var stap := TAU / aantal
	var streep := stap * streepverhouding

	for i in aantal:
		var van := stap * i
		draw_arc(Vector2.ZERO, bereik, van, van + streep, 3, cirkelkleur, lijndikte, true)


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

	var container := get_tree().get_first_node_in_group("projectielen") as Node2D
	if container == null:
		push_warning("Geen node in de groep 'projectielen' gevonden.")
		return

	var kogel := bullet_scene.instantiate() as Bullet

	# Eerst positioneren, dan pas in de boom hangen. Andersom bestaat de kogel
	# een frame lang op de positie van de container en kan hij daar al een
	# vijand raken die hij nooit is tegengekomen. Zelfde valkuil als bij de
	# vijandspawner.
	kogel.spawn_op(
		global_position - container.global_position,
		global_position.direction_to(doel.global_position)
	)
	container.add_child(kogel)
