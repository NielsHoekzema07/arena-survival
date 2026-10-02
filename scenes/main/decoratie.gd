class_name Decoratie
extends Node2D

## Strooit stenen, struikjes en bloemen over het veld.
##
## Puur decor: geen botsing, geen logica, geen _process. Ze bestaan alleen om
## het gras te onderbreken - zonder iets erop is een groot veld met een
## herhalende textuur nogal eentonig.
##
## Moet NA de Vijvers-node in main.tscn staan: er wordt opgevraagd waar het
## water ligt, zodat er geen struik midden in een vijver komt te staan.

## Het vel met de motieven, vier stuks van 16x16 naast elkaar.
@export var motieven: Texture2D

## Hoeveel er neergezet worden. Het zijn losse Sprite2D-nodes, dus dit telt mee
## in het aantal nodes - houd het in de gaten bij de metingen van fase 7.
@export var aantal: int = 130

@export var motief_formaat: int = 16
@export var schaal: float = 3.0

## Hoe ver van de arenamuur ze wegblijven.
@export var marge_rand: float = 70.0

## Vrije cirkel rond het startpunt van de speler.
@export var vrije_zone_midden: float = 130.0

## Vaste waarde geeft elke run dezelfde decoratie; 0 is elke run anders.
@export var vaste_seed: int = 0


func _ready() -> void:
	_strooi()


func _strooi() -> void:
	if motieven == null:
		push_warning("Decoratie heeft geen motieven-textuur.")
		return

	var rng := RandomNumberGenerator.new()
	if vaste_seed != 0:
		rng.seed = vaste_seed
	else:
		rng.randomize()

	var vijvers: Vijvers = get_tree().get_first_node_in_group("vijvers")
	var veld := Speelveld.rect_met_marge(marge_rand)
	var aantal_motieven := motieven.get_width() / motief_formaat

	# De uitsnedes een keer aanmaken en delen. Een AtlasTexture is een resource:
	# honderd sprites kunnen naar dezelfde wijzen, er hoeven er geen honderd
	# gemaakt te worden.
	var uitsnedes: Array[AtlasTexture] = []
	for i in aantal_motieven:
		var atlas := AtlasTexture.new()
		atlas.atlas = motieven
		atlas.region = Rect2(i * motief_formaat, 0, motief_formaat, motief_formaat)
		uitsnedes.append(atlas)

	var geplaatst := 0
	var pogingen := 0
	while geplaatst < aantal and pogingen < aantal * 20:
		pogingen += 1

		var pos := Vector2(
			rng.randf_range(veld.position.x, veld.end.x),
			rng.randf_range(veld.position.y, veld.end.y)
		)

		if pos.length() < vrije_zone_midden:
			continue
		if vijvers != null and vijvers.ligt_in_vijver(pos, 30.0):
			continue

		_zet_neer(pos, uitsnedes[rng.randi_range(0, uitsnedes.size() - 1)], rng)
		geplaatst += 1


func _zet_neer(pos: Vector2, uitsnede: AtlasTexture, rng: RandomNumberGenerator) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = uitsnede
	sprite.position = pos
	sprite.scale = Vector2.ONE * schaal
	# Nearest, anders wordt 16x16 pixelart wazig bij het opschalen.
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Spiegelen scheelt dat je dezelfde steen overal herkent.
	sprite.flip_h = rng.randf() < 0.5
	add_child(sprite)
