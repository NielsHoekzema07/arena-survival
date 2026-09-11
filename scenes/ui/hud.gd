class_name Hud
extends CanvasLayer

## Schermweergave die los van de camera staat.
##
## Een CanvasLayer valt buiten de camera-transform en tekent in
## schermcoordinaten. Daardoor blijft de balk rechtsonder staan, ook terwijl de
## speler door de arena loopt.
##
## De HUD houdt zelf geen levenspunten bij: die staan in player.gd. Hier wordt
## alleen weergegeven wat de speler doorgeeft via het health_changed-signaal.

@onready var _health_bar: ProgressBar = $RechtsOnder/HealthBar


func _ready() -> void:
	var speler := get_tree().get_first_node_in_group("player")
	if speler == null:
		push_warning("Hud vindt geen speler. Staat de Hud-node wel na Player in main.tscn?")
		return

	speler.health_changed.connect(_op_health_changed)

	# De speler zet zijn levenspunten in _ready, en dat gebeurt voordat deze
	# node aan de beurt is. Die eerste emit missen we dus; daarom hier eenmalig
	# de huidige stand ophalen.
	_op_health_changed(speler.health, speler.max_health)


func _op_health_changed(huidig: int, maximum: int) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = huidig
