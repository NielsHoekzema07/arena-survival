# Arena Survival — Technische Specialisatie

2D top-down arena survival game, gebouwd in Godot 4 als opdracht voor Technische Specialisatie (SD3A, Graafschap College).

**Student:** Niels Hoekzema
**Verdiepingsonderwerp:** object pooling en performance-optimalisatie

## Wat is het

Je bestuurt een personage in een afgebakende arena. Er komen doorlopend vijanden op je af. Je wapen schiet projectielen; verslagen vijanden laten experience achter. Bij een level-up kies je uit een aantal upgrades. Hoe langer je leeft, hoe zwaarder het wordt. Bij te veel schade is het game over en start je een nieuwe run.

## Installeren en spelen

**Spelen:** download de laatste release onder Releases, pak het zip-bestand uit en start het uitvoerbare bestand. Een webversie volgt.

**Zelf openen:**

1. Installeer Godot 4.7.2 (zie hieronder welke build)
2. Clone deze repository
3. Open Godot, kies *Import*, en selecteer de `project.godot` in de projectmap
4. Druk op F5 om te starten

## Besturing

| Toets | Actie |
|---|---|
| W A S D | Bewegen |
| Esc | Pauzeren |

## Projectstructuur

```
assets/          Grafische assets, geluid en fonts (CC0)
scenes/
  main/          Hoofdscene en arena
  player/        Speler
  enemies/       Vijandtypes
  projectiles/   Projectielen
  pickups/       Experience en drops
  ui/            HUD, menu, pauzescherm, upgrade-keuze
scripts/
  autoload/      Globale singletons (game state, signalen)
  pooling/       Object pool — het verdiepingsonderwerp
docs/            Logboek, meetresultaten en ontwerpnotities
```

## Documentatie

- [Logboek](docs/logboek.md) — per week bestede uren, resultaten en problemen
- [Collision layers](docs/collision-layers.md) — welk objecttype detecteert welk ander type
- [Later-lijst](docs/later-lijst.md) — bewust buiten scope gehouden ideeën
- [Metingen object pooling](docs/metingen-pooling.md) — FPS en frametijd, met en zonder pooling

De nagebouwde tutorial uit fase 2 (*Your first 2D game*) staat in een aparte repository: `dodge-the-creeps`.

## Gebruikte software

| Software | Versie |
|---|---|
| Godot Engine | 4.7.2-stable |
| Git | 2.47 |

## Assets

Alle grafische assets en geluiden zijn CC0 of vrij te gebruiken. Herkomst per bestand staat in [docs/assets-herkomst.md](docs/assets-herkomst.md).
