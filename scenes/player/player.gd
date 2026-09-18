class_name Player
extends CharacterBody2D

## Wordt uitgezonden zodra de levenspunten veranderen. De HUD luistert hiernaar.
signal health_changed(huidig: int, maximum: int)

## Wordt eenmalig uitgezonden zodra de levenspunten op nul staan.
signal died

## Loopsnelheid in pixels per seconde.
@export var speed: float = 300.0

## Seconden onkwetsbaar na een treffer.
##
## Zonder deze periode wordt er elke physics-frame opnieuw schade toegepast
## zolang een vijand tegen je aan staat. Bij 60 frames per seconde ben je dan
## binnen een halve seconde dood, ook met 1000 levenspunten.
@export var onkwetsbaar_tijd: float = 0.5

## Aantal levenspunten waarmee een run begint.
##
## Bewust 1000 en niet 100: schade wordt later vermenigvuldigd (vijanden die
## opschalen, upgrades in procenten) en health is een int. Bij kleine getallen
## rondt zo'n vermenigvuldiging weg - 3 schade keer 0.9 is weer 3 - waardoor een
## upgrade niets lijkt te doen. Met 1000 als basis blijft elke stap zichtbaar.
@export var max_health: int = 1000

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

## Resterende onkwetsbaarheid in seconden. Groter dan nul betekent onaanraakbaar.
var _onkwetsbaar_resterend: float = 0.0

var _is_dood: bool = false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _camera: Camera2D = $Camera2D
@onready var _hurtbox: Area2D = $Hurtbox


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


func _physics_process(delta: float) -> void:
	if _is_dood:
		return

	# get_vector levert een genormaliseerde vector, dus diagonaal lopen
	# gaat niet sneller dan recht vooruit.
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed

	# move_and_slide rekent zelf met de physics-delta, vandaar dat de delta
	# hier alleen voor de onkwetsbaarheid gebruikt wordt.
	move_and_slide()

	_update_animation(direction)
	_tel_onkwetsbaarheid_af(delta)
	_controleer_aanraking()


## Brengt schade toe. Doet niets zolang de speler onkwetsbaar of al dood is.
func neem_schade(schade: int) -> void:
	if _is_dood or _onkwetsbaar_resterend > 0.0:
		return

	health -= schade

	if health <= 0:
		_ga_dood()
	else:
		_onkwetsbaar_resterend = onkwetsbaar_tijd


func _tel_onkwetsbaarheid_af(delta: float) -> void:
	if _onkwetsbaar_resterend <= 0.0:
		return

	_onkwetsbaar_resterend -= delta

	if _onkwetsbaar_resterend <= 0.0:
		_sprite.modulate.a = 1.0
		return

	# Knipperen, zodat je ziet dat je even niet geraakt kunt worden.
	_sprite.modulate.a = 0.35 if fmod(_onkwetsbaar_resterend, 0.2) < 0.1 else 1.0


## Kijkt of er een vijand tegen de speler aan staat.
##
## Bewust elke frame opnieuw kijken in plaats van op het body_entered-signaal:
## een vijand die al tegen je aan stond toen de onkwetsbaarheid afliep, komt niet
## opnieuw "binnen" en zou je dus nooit meer raken.
func _controleer_aanraking() -> void:
	if _onkwetsbaar_resterend > 0.0:
		return

	for lichaam in _hurtbox.get_overlapping_bodies():
		if lichaam is Enemy:
			neem_schade((lichaam as Enemy).contactschade)
			return


func _ga_dood() -> void:
	_is_dood = true
	velocity = Vector2.ZERO
	_sprite.stop()
	_sprite.modulate.a = 0.3
	died.emit()


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
