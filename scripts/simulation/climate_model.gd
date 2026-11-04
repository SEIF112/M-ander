class_name ClimateModel
extends RefCounted

## 0.0 = Winter (Jahresbeginn), 1.0 = Hochsommer (Jahresmitte)
static func season(tick: int, ticks_per_year: int) -> float:
	var year_fraction := float(tick % ticks_per_year) / float(ticks_per_year)
	return (1.0 - cos(TAU * year_fraction)) / 2.0


## offset: Temperaturänderung durch Ereignisse (Kältephase negativ)
static func temperature(season_value: float, min_temp: float, max_temp: float, offset: float = 0.0) -> float:
	return lerpf(min_temp, max_temp, season_value) + offset


## Anteil der Vegetation, den das Klima gerade erlaubt (0..1).
## factor: Ereignisse wie Hitzewelle/Dürre (1.0 = neutral)
static func vegetation_level(temp: float, min_temp: float, max_temp: float,
		max_veg_percent: float, factor: float = 1.0) -> float:
	var warmth := 1.0
	if not is_equal_approx(min_temp, max_temp):
		warmth = clampf(inverse_lerp(min_temp, max_temp, temp), 0.0, 1.0)
	return max_veg_percent / 100.0 * warmth * factor


## Das Ziel, dem sich die Vegetationsdichte eines Tiles annähert
static func vegetation_target(potential: float, level: float) -> float:
	return potential * level


## Ein Schritt in Richtung Ziel, ohne Überschwingen (response 0..1)
static func vegetation_step(current: float, target: float, response: float) -> float:
	return lerpf(current, target, clampf(response, 0.0, 1.0))


## Grundwasser normiert auf 0..1 (1 = Grundwasser nahe der Oberfläche, nasser Boden)
static func groundwater_norm(value: float, value_range: Vector2) -> float:
	if is_equal_approx(value_range.x, value_range.y):
		return 0.5
	return clampf(inverse_lerp(value_range.x, value_range.y, value), 0.0, 1.0)
