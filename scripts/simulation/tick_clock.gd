class_name TickClock
extends RefCounted

var _accumulator := 0.0


## Gibt zurück, wie viele Ticks in diesem Frame laufen sollen.
## Bruchteile bleiben erhalten. Was über max_ticks hinausgeht, verfällt, damit ein
## langsamer Frame nicht zu einer Aufholschleife führt.
func advance(delta: float, ticks_per_second: float, speed: float, max_ticks: int) -> int:
	_accumulator += delta * ticks_per_second * speed
	var due := int(_accumulator)
	_accumulator -= due
	return mini(due, max_ticks)


func reset() -> void:
	_accumulator = 0.0
