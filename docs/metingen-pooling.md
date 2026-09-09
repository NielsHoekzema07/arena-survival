# Metingen: object pooling

Meetrapport voor fase 7. Vul dit tijdens het meten in, niet achteraf uit het hoofd.

## Testmachine

Deze gegevens horen erbij, anders zijn de getallen niet te plaatsen.

| Onderdeel | Waarde |
|---|---|
| Processor | |
| Videokaart | |
| Werkgeheugen | |
| Besturingssysteem | Windows 11 |
| Godot-versie | 4.7.2-stable |
| Renderer | GL Compatibility |

## Meetmethode

- Beide varianten draaien in een **release-export**, niet in de editor — de editor kost zelf frametijd en vertekent het resultaat.
- Per meetpunt draait de test 30 seconden; de eerste 5 seconden tellen niet mee (opwarmen).
- Gemeten wordt met `Performance.get_monitor()`:
  - `TIME_PROCESS` en `TIME_PHYSICS_PROCESS` — frametijd in ms
  - `OBJECT_NODE_COUNT` — controle dat het aantal objecten echt klopt
- **Frametijd in ms is de hoofdmeting, niet FPS.** FPS blijft op een snelle pc lang op 60 plakken door vsync, terwijl de frametijd het verschil al laat zien. Dit is de beheersmaatregel uit het Plan van Aanpak voor het risico dat de testhardware te krachtig is.
- Baseline (zonder pooling) is terug te halen via de git-tag `v1-geen-pooling`.

## Resultaten

### Zonder pooling

| Objecten | Gem. frametijd (ms) | Hoogste frametijd (ms) | Gem. FPS |
|---|---|---|---|
| 50 | | | |
| 100 | | | |
| 200 | | | |
| 500 | | | |
| 1000 | | | |

### Met pooling

| Objecten | Gem. frametijd (ms) | Hoogste frametijd (ms) | Gem. FPS |
|---|---|---|---|
| 50 | | | |
| 100 | | | |
| 200 | | | |
| 500 | | | |
| 1000 | | | |

## Grafiek

Objecten op de x-as, frametijd in ms op de y-as, twee lijnen.

## Conclusie

Let bij het schrijven op de **hoogste** frametijd, niet alleen het gemiddelde. Het effect van pooling zit vooral in het wegvallen van pieken door garbage collection en node-allocatie; dat is precies wat een speler als hapering ervaart.
