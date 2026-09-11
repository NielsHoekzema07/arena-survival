@tool
class_name Arena
extends Node2D

## Bouwt de vloer en de vier muren op uit Speelveld.GROOTTE.
##
## Waarom dit nodig is: de vorm van een Polygon2D en de afmeting van een
## RectangleShape2D staan opgeslagen in main.tscn, terwijl GROOTTE een const in
## een script is. Zonder dit script zou je die twee met de hand gelijk moeten
## houden.
##
## @tool zorgt dat de arena ook in de editor meteen de juiste maat heeft.
## Let op: na het aanpassen van GROOTTE moet de editor het script opnieuw
## inlezen. Dat gebeurt zodra je speelveld.gd opslaat; zie je het niet
## veranderen, gebruik dan Project -> Reload Current Project.

## Dikte van de muren in pixels. De muren liggen net buiten het speelveld, dus
## de binnenkant valt precies op de rand.
const MUURDIKTE := 32.0

@onready var _vloer: Polygon2D = $Vloer
@onready var _boven: CollisionShape2D = $Muren/Boven
@onready var _onder: CollisionShape2D = $Muren/Onder
@onready var _links: CollisionShape2D = $Muren/Links
@onready var _rechts: CollisionShape2D = $Muren/Rechts


func _ready() -> void:
	bouw_op()


## Zet vloer en muren op de maat van Speelveld.GROOTTE.
func bouw_op() -> void:
	var half := Speelveld.GROOTTE * 0.5

	_vloer.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y),
	])

	# De horizontale muren lopen door tot voorbij de hoeken, zodat er geen gat
	# in de hoek blijft zitten waar de speler doorheen kan glijden.
	var horizontaal := Vector2(Speelveld.GROOTTE.x + MUURDIKTE * 2.0, MUURDIKTE)
	var verticaal := Vector2(MUURDIKTE, Speelveld.GROOTTE.y)

	_zet_muur(_boven, Vector2(0.0, -half.y - MUURDIKTE * 0.5), horizontaal)
	_zet_muur(_onder, Vector2(0.0, half.y + MUURDIKTE * 0.5), horizontaal)
	_zet_muur(_links, Vector2(-half.x - MUURDIKTE * 0.5, 0.0), verticaal)
	_zet_muur(_rechts, Vector2(half.x + MUURDIKTE * 0.5, 0.0), verticaal)


## Elke muur krijgt een eigen RectangleShape2D. Dat is met opzet: in de scene
## deelden Boven en Onder dezelfde vorm, en dan pas je er ongemerkt twee tegelijk
## aan.
func _zet_muur(muur: CollisionShape2D, positie: Vector2, afmeting: Vector2) -> void:
	var vorm := RectangleShape2D.new()
	vorm.size = afmeting
	muur.shape = vorm
	muur.position = positie
