class_name ErosionModel
extends RefCounted

## Widerstand eines Landtiles: höher = schwerer abzutragen.
## Die Basishärte bleibt unverändert, alles andere ist ein Faktor darauf.
static func effective_resistance(tile: Tile, mat: MaterialData, temperature: float,
		groundwater_norm: float, tuning: SimulationTuning) -> float:
	var vegetation := 1.0 + mat.vegetation_effect * tile.vegetation_density
	var frost := mat.freeze_factor if temperature < 0.0 else 1.0
	var groundwater := 1.0 - tuning.groundwater_softening * groundwater_norm
	return maxf(tile.base_hardness * vegetation * frost * groundwater, 0.01)


## Zufallsfaktor um 1.0 (z.B. 0.8 bis 1.2). Der Aufrufer reicht den Zufallsgenerator "simulation" durch.
static func jitter_factor(rng: RandomNumberGenerator, tuning: SimulationTuning) -> float:
	return 1.0 + rng.randf_range(-tuning.jitter, tuning.jitter)


## Wie viel bank_balance ein Landtile in diesem Tick gewinnt.
## bank_weight kommt aus RiverGeometry.erosion_weight, water_factor aus Ereignissen (1.0 = normal).
static func erosion_gain(sim: SimulationSettings, tuning: SimulationTuning, resistance: float,
		bank_weight: float, water_factor: float = 1.0, jitter: float = 1.0) -> float:
	var force := sim.river_speed * sim.water_amount * water_factor
	return force * bank_weight * jitter / (resistance * tuning.erosion_scale)


## Wie viel bank_balance ein Wassertile am Innenufer in diesem Tick verliert.
## deposition_weight kommt aus RiverGeometry.deposition_weight.
static func deposition_loss(sim: SimulationSettings, tuning: SimulationTuning,
		deposition_weight: float) -> float:
	return sim.sediment_amount * tuning.deposition_rate * deposition_weight


static func becomes_water(balance: float) -> bool:
	return balance >= 0.0


static func becomes_land(balance: float) -> bool:
	return balance < 0.0


static func make_water(tile: Tile, tuning: SimulationTuning) -> void:
	tile.water_state = Enums.WaterState.RIVER_ACTIVE
	tile.bank_balance = tuning.river_depth
	tile.vegetation_density = 0.0


static func make_land(tile: Tile) -> void:
	tile.water_state = Enums.WaterState.NONE
	tile.bank_balance = -1.0
	tile.vegetation_density = 0.0
	

#Erklärung
#Ein Wert für alles: bank_balance schiebt sich pro Tick ein Stück. Bei Land wächst er durch Erosion, bei Wasser sinkt er durch Ablagerung. Wer die Grenze 0 überschreitet, wechselt den Zustand und wird danach zurückgesetzt. Dadurch flackern die Randzonen nicht: Ein frisch gewechseltes Tile braucht wieder eine volle Spanne bis zum nächsten Wechsel.
#Widerstand: Er ist ein Produkt aus Basishärte und drei Faktoren. Das Produkt macht jeden Faktor einzeln testbar und austauschbar, und ein neuer Faktor (zum Beispiel später Grundwasser pro Tile) kommt als vierte Zahl dazu.
#Der Teiler: Je höher der Widerstand, desto kleiner der Zuwachs. Hartes Gestein erodiert langsamer und braucht trotzdem keinen eigenen Code.
#Start mit Zahlen: Mit den Schiebereglern aus deinem Formular (5 und 50) braucht ein Erdtile am Außenufer ohne Vegetation etwa ein Jahr bis zum Wechsel, am geraden Fluss rund 1,6 Jahre. Stein dauert etwa dreimal so lang. Das sind Startwerte, die wir später am Gleichgewichtstest einstellen.
#Neues Land ohne Pflanzen: make_land setzt die Vegetation auf 0. Das Tile wächst dann über vegetation_step langsam zu. Auf deinem Satellitenbild entspricht das den hellen Flächen mit Pionierpflanzen auf der Innenseite der Bögen.
