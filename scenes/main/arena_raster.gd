@tool
class_name ArenaRaster
extends Node2D

## Tekent een raster over de arenavloer, zodat je bij het testen ziet dat de
## camera meebeweegt. Puur visueel: er zit geen spellogica aan vast.
##
## @tool zorgt dat het raster ook in de editor getekend wordt, niet alleen
## tijdens het spelen.

## Afmeting van de arena, standaard die van Speelveld.
@export var arena_grootte: Vector2 = Speelveld.GROOTTE:
	set(waarde):
		arena_grootte = waarde
		queue_redraw()

## Afstand tussen twee rasterlijnen in pixels.
@export var celgrootte: float = 64.0:
	set(waarde):
		celgrootte = maxf(waarde, 8.0)
		queue_redraw()

## Elke zoveelste lijn wordt zwaarder getekend, dat geeft houvast bij het kijken.
@export var zware_lijn_elke: int = 4:
	set(waarde):
		zware_lijn_elke = maxi(waarde, 1)
		queue_redraw()

@export var lijnkleur: Color = Color(1.0, 1.0, 1.0, 0.05):
	set(waarde):
		lijnkleur = waarde
		queue_redraw()

@export var zware_lijnkleur: Color = Color(1.0, 1.0, 1.0, 0.12):
	set(waarde):
		zware_lijnkleur = waarde
		queue_redraw()

@export var randkleur: Color = Color(0.4, 0.85, 1.0, 0.5):
	set(waarde):
		randkleur = waarde
		queue_redraw()


func _draw() -> void:
	var half := arena_grootte * 0.5

	# Verticale lijnen, van het midden naar buiten zodat de zware lijnen
	# symmetrisch liggen.
	var kolommen := int(half.x / celgrootte)
	for i in range(-kolommen, kolommen + 1):
		var x := i * celgrootte
		var kleur := zware_lijnkleur if i % zware_lijn_elke == 0 else lijnkleur
		draw_line(Vector2(x, -half.y), Vector2(x, half.y), kleur, 1.0)

	# Horizontale lijnen.
	var rijen := int(half.y / celgrootte)
	for i in range(-rijen, rijen + 1):
		var y := i * celgrootte
		var kleur := zware_lijnkleur if i % zware_lijn_elke == 0 else lijnkleur
		draw_line(Vector2(-half.x, y), Vector2(half.x, y), kleur, 1.0)

	# Duidelijke rand, zodat je ziet waar de muren staan.
	draw_rect(Rect2(-half, arena_grootte), randkleur, false, 3.0)
