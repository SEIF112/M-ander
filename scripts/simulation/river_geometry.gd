class_name RiverGeometry
extends RefCounted

## Position eines Tiles in Tile-Breiten. Das Zeilen-Offset ist eingerechnet: x = q + r/2
static func tile_x(tile: Tile) -> float:
	return tile.axial_q + tile.axial_r / 2.0


## Schwerpunkt (x) der aktiven Wassertiles jeder Zeile, NAN für Zeilen ohne Wasser
static func row_centroids(map_data: MapData) -> PackedFloat64Array:
	var rows := 0
	for key: Vector2i in map_data.tiles:
		rows = maxi(rows, key.y + 1)
	var sums := PackedFloat64Array()
	sums.resize(rows)
	var counts := PackedInt32Array()
	counts.resize(rows)
	for tile: Tile in map_data.tiles.values():
		if tile.water_state == Enums.WaterState.RIVER_ACTIVE:
			sums[tile.axial_r] += tile_x(tile)
			counts[tile.axial_r] += 1
	var result := PackedFloat64Array()
	result.resize(rows)
	for row in rows:
		result[row] = sums[row] / counts[row] if counts[row] > 0 else NAN
	return result


## Zweite Differenz der Schwerpunkte, normiert auf span².
## > 0: Fluss knickt nach +x ab (Innenseite rechts), < 0: nach -x (Innenseite links)
static func curvature(centroids: PackedFloat64Array, row: int, span: int = 2) -> float:
	span = maxi(span, 1)
	if row - span < 0 or row + span >= centroids.size():
		return 0.0
	var above := centroids[row - span]
	var here := centroids[row]
	var below := centroids[row + span]
	if is_nan(above) or is_nan(here) or is_nan(below):
		return 0.0
	return (below - 2.0 * here + above) / float(span * span)


## Krümmung auf -1..1 normiert
static func curve_strength(k: float, k_ref: float) -> float:
	return clampf(k / maxf(k_ref, 0.0001), -1.0, 1.0)


## side: -1 = linkes Ufer, +1 = rechtes. s > 0: Innenufer rechts, Außenufer links.
## Faktor auf die Erosion (Mittel beider Ufer bleibt 1)
static func erosion_weight(side: int, s: float) -> float:
	return maxf(1.0 - side * s, 0.0)


## Faktor auf die Ablagerung (nur Innenufer, nie negativ)
static func deposition_weight(side: int, s: float) -> float:
	return maxf(side * s, 0.0)


## Alles auf einmal pro Tick berechnen
static func analyze(map_data: MapData, span: int, k_ref: float) -> RiverShape:
	var shape := RiverShape.new()
	shape.centroids = row_centroids(map_data)
	shape.strengths.resize(shape.centroids.size())
	for row in shape.centroids.size():
		shape.strengths[row] = curve_strength(curvature(shape.centroids, row, span), k_ref)
	return shape


class RiverShape:
	var centroids := PackedFloat64Array()
	var strengths := PackedFloat64Array()   # s pro Zeile

	func strength_at(row: int) -> float:
		if row < 0 or row >= strengths.size():
			return 0.0
		return strengths[row]

	## -1 links vom Zeilenschwerpunkt, +1 rechts, 0 ohne Fluss in der Zeile
	func side_of(tile: Tile) -> int:
		if tile.axial_r < 0 or tile.axial_r >= centroids.size():
			return 0
		var c := centroids[tile.axial_r]
		if is_nan(c):
			return 0
		return -1 if RiverGeometry.tile_x(tile) < c else 1
