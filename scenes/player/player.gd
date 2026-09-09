class_name Player
extends CharacterBody2D

## Loopsnelheid in pixels per seconde.
@export var speed: float = 300.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	# Vijanden zoeken de speler straks op via deze groep, niet via een vast pad.
	add_to_group("player")


func _physics_process(_delta: float) -> void:
	# get_vector levert een genormaliseerde vector, dus diagonaal lopen
	# gaat niet sneller dan recht vooruit.
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed

	# move_and_slide rekent zelf met de physics-delta, vandaar dat de delta
	# van _physics_process hier niet gebruikt wordt.
	move_and_slide()

	_update_animation(direction)


func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		_sprite.stop()
		return

	_sprite.play()

	# De grootste component bepaalt of de speler er van opzij of van
	# voor/achter uitziet.
	if absf(direction.x) > absf(direction.y):
		_sprite.animation = &"walk"
		_sprite.flip_v = false
		_sprite.flip_h = direction.x < 0.0
	else:
		_sprite.animation = &"up"
		_sprite.flip_v = direction.y > 0.0
		_sprite.flip_h = false
