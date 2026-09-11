class_name Hud
extends CanvasLayer

## Schermweergave die los van de camera staat.
##
## Een CanvasLayer valt buiten de camera-transform en tekent in
## schermcoordinaten. Daardoor blijft de balk rechtsonder staan, ook terwijl de
## speler door de arena loopt.
##
## De HUD houdt zelf geen levenspunten bij: die staan in player.gd. Hier wordt
## alleen weergegeven wat de speler doorgeeft via zijn signalen.
##
## De node staat op process_mode = ALWAYS, zodat het herstarten blijft werken
## nadat get_tree().paused is aangezet bij game over.

@onready var _health_bar: ProgressBar = $RechtsOnder/HealthBar
@onready var _game_over: Control = $GameOver


func _ready() -> void:
	_game_over.hide()

	var speler := get_tree().get_first_node_in_group("player")
	if speler == null:
		push_warning("Hud vindt geen speler. Staat de Hud-node wel na Player in main.tscn?")
		return

	speler.health_changed.connect(_op_health_changed)
	speler.died.connect(_op_speler_dood)

	# De speler zet zijn levenspunten in _ready, en dat gebeurt voordat deze
	# node aan de beurt is. Die eerste emit missen we dus; daarom hier eenmalig
	# de huidige stand ophalen.
	_op_health_changed(speler.health, speler.max_health)


func _unhandled_input(event: InputEvent) -> void:
	if not _game_over.visible:
		return

	if event.is_action_pressed("ui_accept"):
		herstart()


## Begint een nieuwe run. De pauze moet eerst uit, anders start de nieuwe scene
## meteen stilgezet op.
func herstart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _op_health_changed(huidig: int, maximum: int) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = huidig


func _op_speler_dood() -> void:
	_game_over.show()
	get_tree().paused = true
