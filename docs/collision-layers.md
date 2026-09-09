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
| Speler | `player` | `enemy`, `pickup`, `world` |
| Vijand | `enemy` | `player`, `player_bullet`, `world` |
| Projectiel | `player_bullet` | `enemy`, `world` |
| Experience-orb | `pickup` | `player` |
| Muur | `world` | — |

## Aandachtspunten

- Vijanden zitten niet in elkaars mask, dus ze duwen elkaar niet weg. Als ze straks op één hoop gaan staan is dat de oorzaak.
- Een projectiel kijkt naar `world` om zichzelf op te ruimen bij de arenarand.
- Bij object pooling wordt een object niet vernietigd maar uitgeschakeld. Zet dan zowel `monitoring` als `monitorable` uit, anders blijft een "dood" object nog collisions veroorzaken. Dit is de bekendste bug bij pooling — noteer hem in het logboek als je hem tegenkomt.
