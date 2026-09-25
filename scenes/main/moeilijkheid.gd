class_name Moeilijkheid
extends Node

## Houdt bij hoe lang de run duurt en rekent daaruit de moeilijkheidsfactoren.
##
## Staat los van de spawner omdat meer dingen dit willen weten: de HUD toont de
## golf, en het experience-systeem uit fase 6 wil de runtijd hebben. Zelfde
## gedachte als Speelveld - een plek die de waarheid heeft.
##
## De schaling gebeurt in stappen van `golf_duur` seconden en niet vloeiend. Een
## speler merkt een sprongetje wel en een langzame glijdende schaal niet, en
## voor het meetwerk in fase 7 is het handig om per golf te kunnen meten in
## plaats van op een willekeurig moment.
##
## LET OP: deze factoren worden bij het spawnen toegepast op de waarden uit het
## VijandType. Ze worden NIET in de .tres geschreven. Een resource is gedeeld;
## zou je erin schrijven, dan werden vijanden die al op het scherm staan met
## terugwerkende kracht sterker en had je na een herstart geen schone
## beginwaarden meer.

signal golf_veranderd(nieuwe_golf: int)

## Seconden per golf.
@export var golf_duur: float = 30.0

@export_group("Spawnfrequentie")

## Het spawninterval wordt per golf met deze factor vermenigvuldigd. Onder de 1
## betekent dus sneller spawnen.
@export var spawn_versnelling: float = 0.9

## Ondergrens op het spawninterval. Zonder deze klem loopt het interval richting
## nul en spawn je uiteindelijk elke frame een vijand.
@export var min_spawn_interval: float = 0.15

@export_group("Vijandsterkte")

## Hoeveel de levenspunten per golf oplopen. 0,15 is +15 procent per golf,
## opgeteld en niet samengesteld.
@export var hp_groei_per_golf: float = 0.15

## Hoeveel de contactschade per golf oploopt.
@export var schade_groei_per_golf: float = 0.10

## Verstreken tijd sinds het begin van de run, in seconden.
var verstreken: float = 0.0

## Huidige golf, begint op 0.
var golf: int = 0


func _ready() -> void:
	add_to_group("moeilijkheid")


func _process(delta: float) -> void:
	verstreken += delta

	var nieuwe_golf := int(verstreken / golf_duur)
	if nieuwe_golf != golf:
		golf = nieuwe_golf
		golf_veranderd.emit(golf)


## Het spawninterval voor de huidige golf, gegeven het basisinterval.
func spawn_interval_voor(basis: float) -> float:
	return maxf(basis * pow(spawn_versnelling, golf), min_spawn_interval)


## Waarmee de levenspunten uit het VijandType vermenigvuldigd worden.
func hp_factor() -> float:
	return 1.0 + hp_groei_per_golf * golf


## Waarmee de contactschade uit het VijandType vermenigvuldigd wordt.
func schade_factor() -> float:
	return 1.0 + schade_groei_per_golf * golf
