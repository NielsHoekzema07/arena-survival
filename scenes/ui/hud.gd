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
@onready var _golf_label: Label = $LinksBoven/GolfLabel
@onready var _tijd_label: Label = $LinksBoven/TijdLabel

var _moeilijkheid: Moeilijkheid


func _ready() -> void:
	_game_over.hide()

	_moeilijkheid = get_tree().get_first_node_in_group("moeilijkheid")
	if _moeilijkheid != null:
		_moeilijkheid.golf_veranderd.connect(_op_golf_veranderd)
		_op_golf_veranderd(_moeilijkheid.golf)

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


func _process(_delta: float) -> void:
	if _moeilijkheid == null:
		return

	var seconden := int(_moeilijkheid.verstreken)
	_tijd_label.text = "%d:%02d" % [seconden / 60, seconden % 60]


func _op_golf_veranderd(golf: int) -> void:
	_golf_label.text = "Golf %d" % golf


func _op_health_changed(huidig: int, maximum: int) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = huidig


func _op_speler_dood() -> void:
	_game_over.show()
	get_tree().paused = true
