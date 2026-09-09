class_name Enemy
extends CharacterBody2D

## Vijand die recht op de speler afloopt.
##
## De vijand kijkt zelf alleen naar muren (`collision_mask` = world). Dat de
## speler geraakt wordt en dat projectielen de vijand raken, wordt straks
## afgehandeld door Area2D's aan de andere kant — zie docs/collision-layers.md.

## Loopsnelheid in pixels per seconde.
@export var speed: float = 120.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _doel: Node2D


func _ready() -> void:
	add_to_group("enemies")
	_zoek_doel()


## Zet de vijand op een startpositie. De spawner roept dit aan direct na het
## aanmaken. In fase 7 roept de object pool dezelfde functie aan bij het
## hergebruiken van een vijand, zodat er dan niets aan deze scene hoeft te
## veranderen.
func spawn_op(positie: Vector2) -> void:
	global_position = positie
	velocity = Vector2.ZERO
	_zoek_doel()


func _physics_process(_delta: float) -> void:
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


func _zoek_doel() -> void:
	_doel = get_tree().get_first_node_in_group("player")


func _update_animatie(richting: Vector2) -> void:
	_sprite.play()
	# De sprite kijkt naar rechts; spiegel hem als de vijand naar links loopt.
	if not is_zero_approx(richting.x):
		_sprite.flip_h = richting.x < 0.0
