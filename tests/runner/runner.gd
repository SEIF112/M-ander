extends Node2D

func _ready():
	print("\n=== RUNNING TESTS ===\n")

	var tests := _find_tests("res://tests")

	var total_tests := 0
	var total_passes := 0
	var total_fails := 0

	var executed_tests: Array = []   # ← hier speichern wir die Instanzen

	for path in tests:
		var script := load(path)
		var instance = script.new()

		print("\nRunning: ", instance.get_test_name())
		instance.run()

		total_tests += 1
		total_passes += instance.passes
		total_fails += instance.fails

		executed_tests.append(instance)   # ← speichern

	print("\n=== ALL TESTS DONE ===\n")
	print("Total tests: ", total_tests)
	print("Total passes: ", total_passes)
	print("Total fails: ", total_fails)

	if total_fails > 0:
		print("\n=== FAIL DETAILS ===")
		for instance in executed_tests:
			if instance.fail_messages.size() > 0:
				print("\nTest: ", instance.get_test_name())
				for msg in instance.fail_messages:
					print("  ", msg)


func _find_tests(root: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(root)

	if dir == null:
		push_error("TestRunner: Konnte Ordner nicht öffnen: " + root)
		return result

	dir.list_dir_begin()
	var file := dir.get_next()

	while file != "":
		if dir.current_is_dir():
			if not file.begins_with("."):
				result += _find_tests(root + "/" + file)
		else:
			if file.ends_with(".gd") and file.contains("test_"):
				var path := root + "/" + file
				var script := load(path)

				# Nur echte Tests laden:
				if script is GDScript:
					var instance = script.new()

					# Muss von TestBase erben
					if instance is TestBase:
						# Muss eine run()-Methode haben
						if instance.has_method("run"):
							result.append(path)

		file = dir.get_next()

	dir.list_dir_end()
	return result
