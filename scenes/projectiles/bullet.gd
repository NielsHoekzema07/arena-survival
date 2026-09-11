class_name Bullet
extends Area2D

## Projectiel dat in een rechte lijn vliegt en de eerste vijand uitschakelt die
## het raakt.
##
## De kogel vliegt langs zijn eigen +X-as (`transform.x`). De sprite en de
## collision shape zijn daarom 90 graden gedraaid in Bullet.tscn, want het
## plaatje wijst van zichzelf omhoog.

## Snelheid in pixels per seconde.
@export var speed: float = 750.0


func _ready() -> void:
	add_to_group("bullets")
	# In code verbonden en niet in de scene: zo blijft het werken als de kogel
	# in fase 7 uit een object pool komt en niet opnieuw uit de scene ontstaat.
	body_entered.connect(_op_body_geraakt)


## Zet de kogel klaar op een positie en laat hem een kant op wijzen.
## `richting` moet genormaliseerd zijn.
func spawn_op(positie: Vector2, richting: Vector2) -> void:
	global_position = positie
	rotation = richting.angle()


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

	# Buiten het speelveld heeft de kogel geen nut meer. Zonder dit blijven ze
	# eindeloos bestaan en loopt het aantal nodes op.
	if not Speelveld.rect().has_point(global_position):
		_ruim_op()


func _op_body_geraakt(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.queue_free()
		_ruim_op()


## Eén plek waar de kogel verdwijnt. In fase 7 wordt dit "terug naar de pool"
## in plaats van queue_free, en hoeft er verder niets te veranderen.
func _ruim_op() -> void:
	queue_free()
