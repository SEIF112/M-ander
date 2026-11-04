class_name Tile
extends Resource

## Ein einzelnes Hex-Feld. EIN Tile-Typ für alles - ob es sich gerade wie
## "Wasser" oder "Boden" verhält, entscheidet water_state, nicht eine
## eigene Klasse. Felder wie sediment_amount/hardness sind je nach
## aktuellem water_state nur bedingt bedeutungsvoll (siehe Kommentare unten).

@export var axial_q: int = 0
@export var axial_r: int = 0

@export var material: Enums.TileMaterial = Enums.TileMaterial.EARTH
@export var water_state: Enums.WaterState = Enums.WaterState.NONE

## Kontinuierlicher Zustand zwischen Land und Wasser.
## < 0: Land (-1.0 = unberührt, nahe 0 = stark angegriffen)
## >= 0: Wasser (je höher, desto stabiler)
## Nach einem Wechsel zurücksetzen: Land -> Wasser = +river_depth, Wasser -> Land = -1.0
@export var bank_balance: float = -1.0

## Nur bedeutungsvoll, wenn water_state == NONE (also Boden).
## Wird von MapChanger pro Schritt aus material.hardness,
## vegetation_density und der aktuellen globalen Temperatur berechnet
## (siehe MapChanger.calculate_effective_resistance).
@export var resistance: float = 0.0


## Nur bedeutungsvoll, wenn water_state == NONE (also Boden).
## Rein saisonal berechnet (siehe MapChanger.calculate_vegetation_density).
@export var vegetation_density: float = 0.0
@export var max_vegetation_potential: float = 1.0

# TODO (spätere Erweiterung, nicht für MVP):
# groundwater_level pro Tile statt global in SimulationSettings.
# Grund: Grundwasser steigt vermutlich näher am Fluss - relevant für
# Projektziel "Landnutzung in Flussnähe".
# Umsetzung: neues Feld @export var groundwater_level: float hier ergänzen,
# initial aus settings.groundwater_table befüllen (MapData.generate_empty),
# danach lokal durch Mapgenerator anpassbar (z.B. Nachbarschafts-Distanz zum Fluss).

# Temperatur bewusst NICHT hier - ist ein globaler Wert, siehe
# SimulationSettings.min_temperature/max_temperature.
