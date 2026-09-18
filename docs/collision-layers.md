# Collision layers en masks

Godot heeft twee losse begrippen die makkelijk door elkaar lopen:

- **Layer** — waar dit object *in zit*, dus waardoor het gezien kan worden
- **Mask** — waar dit object *naar kijkt*, dus wat het zelf detecteert

Een projectiel dat vijanden moet raken zit dus in laag `player_bullet` en kijkt naar `enemy`.

## Indeling

Deze namen zijn ingesteld in Project Settings → Layer Names → 2D Physics. Gebruik altijd de naam in de editor, nooit het nummer in code.

| # | Naam | Wat zit erin |
|---|---|---|
| 1 | `player` | De speler |
| 2 | `enemy` | Alle vijandtypes |
| 3 | `player_bullet` | Projectielen van de speler |
| 4 | `pickup` | Experience-orbs en andere drops |
| 5 | `world` | Muren en de arena-begrenzing |

## Wie ziet wie

| Object | Layer | Mask (kijkt naar) |
|---|---|---|
| Speler (`CharacterBody2D`) | `player` | `world` |
| Hurtbox van de speler (`Area2D`, fase 5) | `player` | `enemy` |
| Oppakbereik van de speler (`Area2D`, fase 6) | `player` | `pickup` |
| Vijand (`CharacterBody2D`) | `enemy` | `enemy`, `world` |
| Projectiel | `player_bullet` | `enemy`, `world` |
| Experience-orb | `pickup` | `player` |
| Muur | `world` | — |

### Detectie is eenrichtingsverkeer

Dit is de regel waar de hele tabel op rust: **maar één van de twee partijen heeft de ander in zijn mask nodig.** Een `Area2D` merkt een lichaam op zodra de layer van dat lichaam in de mask van de Area zit. Andersom hoeft niet.

Daarom staat er bij de vijand alleen `world`. De vijand hoeft niet naar `player_bullet` te kijken om geraakt te kunnen worden: het projectiel is een `Area2D` die naar `enemy` kijkt, en dat is genoeg. Hetzelfde geldt voor de speler raken — dat doet de hurtbox van de speler.

Dubbel instellen is niet fout, maar het kost onnodig werk per frame en het maakt het lastiger te volgen wie nu eigenlijk wat detecteert. Dat scheelt bij 300+ objecten in fase 7 echt iets.

### Waarom de speler zelf alleen naar `world` kijkt

Een `CharacterBody2D` wordt door `move_and_slide()` tegengehouden door alles in zijn mask. Als `enemy` daarin zou zitten, zou de speler tegen vijanden aan botsen en klem komen te zitten zodra er een groep om hem heen staat — precies wat je in dit genre niet wilt: vijanden moeten door je heen kunnen lopen en schade doen door aanraking.

Daarom is het opgesplitst: de body botst alleen tegen muren, en losse `Area2D`-kinderen detecteren aanraking met vijanden en het oppakken van experience. Die twee komen in fase 5 en 6; nu is alleen de body er.

### Waarom vijanden elkaar wél zien, en wat dat kost

`enemy` staat in hun eigen mask, zodat ze niet door elkaar heen lopen. Zonder
dat kruipen ze uiteindelijk allemaal op precies hetzelfde punt.

Dat is niet gratis. Gemeten op de ontwikkelmachine (RTX 3060 laptop, GL
Compatibility, headless, vijanden verspreid gespawnd en daarna samengedromd
rond de speler), gemiddelde `TIME_PHYSICS_PROCESS`:

| Vijanden | mask zonder `enemy` | mask met `enemy` |
|---|---|---|
| 200 | 1,74 ms | 4,62 ms |
| 500 | 7,30 ms | 19,99 ms |

Bij 200 vijanden is het goed te doen; bij 500 zit je met 20 ms al over het
budget van 16,7 ms dat 60 FPS toestaat. Het aantal contacten groeit sneller dan
het aantal vijanden, want elke vijand raakt zijn buren.

Dit is los van object pooling: pooling bespaart het aanmaken en vernietigen van
objecten, niet het doorrekenen van contacten. Bij de metingen in fase 7 moeten
deze twee dus uit elkaar gehouden worden, anders schrijf je winst toe aan het
verkeerde mechanisme.

## Aandachtspunten

- Vijanden zitten niet in elkaars mask, dus ze duwen elkaar niet weg. Als ze straks op één hoop gaan staan is dat de oorzaak.
- Een projectiel kijkt naar `world` om zichzelf op te ruimen bij de arenarand.
- Bij object pooling wordt een object niet vernietigd maar uitgeschakeld. Zet dan zowel `monitoring` als `monitorable` uit, anders blijft een "dood" object nog collisions veroorzaken. Dit is de bekendste bug bij pooling — noteer hem in het logboek als je hem tegenkomt.
