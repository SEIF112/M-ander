class_name Helper
extends RefCounted

static func check(cond: bool, name: String):
	var prefix := "PASS: " if cond else "FAIL: "
	print(prefix + name)
