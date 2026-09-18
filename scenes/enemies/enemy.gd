class_name Enemy
extends CharacterBody2D

## Vijand die recht op de speler afloopt.
##
## De vijand kijkt zelf alleen naar muren (`collision_mask` = world). Dat de
## speler geraakt wordt en dat projectielen de vijand raken, wordt straks
## afgehandeld door Area2D's aan de andere kant — zie docs/collision-layers.md.

## Loopsnelheid in pixels per seconde.
@export var speed: float = 120.0

## Schade die deze vijand aan de SPELER doet bij aanraking.
##
## Heet bewust niet `damage`: dat verwart met de levenspunten van de vijand zelf,
## die hieronder staan. Het aantal treffers dat de speler overleeft is diens
## max_health gedeeld door deze waarde; met 1000 levenspunten en 100 schade zijn
## dat er tien. Hoe snel die treffers binnenkomen hangt af van onkwetsbaar_tijd
## op de speler, niet van hoe veel vijanden er tegen je aan staan. In fase 6 gaat
## deze waarde omhoog naarmate een run langer duurt.
@export var contactschade: int = 100

## Levenspunten van de vijand zelf.
##
## Anders dan bij de speler is 100 hier ruim genoeg. Bij de speler telt elk
## schadepunt op, dus daar maakt afronding verschil. Hier telt alleen of je onder
## een drempel komt: het aantal benodigde treffers is een heel getal, en dat
## wordt niet fijner van grotere getallen.
@export var max_health: int = 100

## Hoe lang de vijand wit oplicht na een treffer, in seconden.
@export var flits_tijd: float = 0.08

var health: int

## Resterende flitstijd. Bewust een simpele float die afgeteld wordt in plaats
## van een Tween per treffer: een Tween is een object dat je bij elke treffer
## aanmaakt en weggooit, en met honderden vijanden is dat precies het gedrag dat
## object pooling in fase 7 juist moet voorkomen.
var _flits_resterend: float = 0.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _doel: Node2D


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	_zoek_doel()


## Brengt schade toe. De vijand beslist zelf wanneer hij doodgaat; de kogel
## bepaalt alleen hoeveel schade hij doet.
func neem_schade(bedrag: int) -> void:
	# Twee pijlen kunnen in dezelfde frame aankomen. Zonder deze controle gaat de
	# tweede door een vijand die al dood is, wordt er een kogel verspild en zou
	# er straks twee keer experience uit vallen.
	if health <= 0:
		return

	# Klemmen op nul, net als bij de speler: dan staat er nooit een negatieve
	# waarde in beeld of in een log.
	health = maxi(health - bedrag, 0)
	_flits_resterend = flits_tijd

	if health == 0:
		_ga_dood()


## Eén plek waar de vijand verdwijnt. Hier komt in fase 6 de experience-drop, en
## in fase 7 "terug naar de pool" in plaats van queue_free.
func _ga_dood() -> void:
	queue_free()


## Zet de vijand op een startpositie. De spawner roept dit aan direct na het
## aanmaken. In fase 7 roept de object pool dezelfde functie aan bij het
## hergebruiken van een vijand, zodat er dan niets aan deze scene hoeft te
## veranderen.
func spawn_op(positie: Vector2) -> void:
	# `position` en niet `global_position`: deze functie wordt aangeroepen
	# voordat de vijand in de scene-boom hangt, en global_position heeft dan geen
	# betekenis. De spawner geeft daarom een positie in zijn eigen stelsel door.
	position = positie
	velocity = Vector2.ZERO

	# Bij een verse vijand doet _ready dit straks zelf; bij een vijand uit de
	# object pool in fase 7 hangt hij al in de boom en is dit wel nodig.
	if is_inside_tree():
		_zoek_doel()


func _physics_process(delta: float) -> void:
	_tel_flits_af(delta)

	if not is_instance_valid(_doel):
		# Speler is weg (game over of nog niet klaar): blijf staan.
		velocity = Vector2.ZERO
		_sprite.stop()
		return

	# direction_to levert een genormaliseerde vector op, dus de vijand loopt
	# even snel ongeacht hoe ver de speler weg is.
	var richting := global_position.direction_to(_doel.global_position)
	velocity = richting * speed
	move_and_slide()

	_update_animatie(richting)


func _tel_flits_af(delta: float) -> void:
	if _flits_resterend <= 0.0:
		return

	_flits_resterend -= delta
	if _flits_resterend <= 0.0:
		_sprite.modulate = Color.WHITE
	else:
		# Ver boven 1 zodat de vijand echt oplicht en je ziet dat je raakt.
		_sprite.modulate = Color(4.0, 4.0, 4.0)


func _zoek_doel() -> void:
	_doel = get_tree().get_first_node_in_group("player")


func _update_animatie(richting: Vector2) -> void:
	_sprite.play()
	# De sprite kijkt naar rechts; spiegel hem als de vijand naar links loopt.
	if not is_zero_approx(richting.x):
		_sprite.flip_h = richting.x < 0.0
