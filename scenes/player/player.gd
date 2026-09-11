class_name Player
extends CharacterBody2D

## Wordt uitgezonden zodra de levenspunten veranderen. De HUD luistert hiernaar.
signal health_changed(huidig: int, maximum: int)

## Loopsnelheid in pixels per seconde.
@export var speed: float = 300.0

## Aantal levenspunten waarmee een run begint.
@export var max_health: int = 5

## Huidige levenspunten. Via de setter wordt de waarde begrensd en wordt het
## signaal uitgezonden, zodat elke plek die dit aanpast automatisch de HUD
## bijwerkt. In fase 5 doet neem_schade() hier simpelweg `health -= schade`.
var health: int:
	set(waarde):
		var nieuw := clampi(waarde, 0, max_health)
		if nieuw == health:
			return
		health = nieuw
		health_changed.emit(health, max_health)

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	# Vijanden zoeken de speler op via deze groep, niet via een vast pad.
	add_to_group("player")
	health = max_health
	_begrens_camera()


## Zorgt dat de camera niet buiten het speelveld kijkt. Staat hier in code en
## niet in de scene, zodat de arena-afmeting op één plek vastligt.
func _begrens_camera() -> void:
	var veld := Speelveld.rect()
	_camera.limit_left = int(veld.position.x)
	_camera.limit_top = int(veld.position.y)
	_camera.limit_right = int(veld.end.x)
	_camera.limit_bottom = int(veld.end.y)


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
