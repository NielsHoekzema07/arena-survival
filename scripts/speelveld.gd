class_name Speelveld
extends RefCounted

## Afmetingen van de arena, op één plek vastgelegd.
##
## Dit is geen node en hoort niet in een scene: het zijn alleen constanten en
## hulpfuncties. Door `class_name` is Speelveld overal beschikbaar zonder
## autoload, ook in @tool-scripts.
##
## GROOTTE aanpassen is genoeg: arena.gd zet vloer en muren erop, player.gd de
## camera-limieten, en de spawner kiest zijn posities hierbinnen.

const GROOTTE := Vector2(5000,3000)


## Het speelveld als rechthoek, met (0, 0) in het midden.
static func rect() -> Rect2:
	return Rect2(-GROOTTE * 0.5, GROOTTE)


## Het speelveld, een stuk naar binnen. Handig om te controleren of een
## spawnpositie niet in of achter een muur ligt.
static func rect_met_marge(marge: float) -> Rect2:
	return rect().grow(-marge)
