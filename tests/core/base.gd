extends Node
class_name TestBase

var _name: String = "UnnamedTest"

var passes: int
var fails: int
var fail_messages: Array[String]

func _init():
	passes = 0
	fails = 0
	fail_messages = []



func get_test_name() -> String:
	return _name

func run() -> void:
	push_error("TestBase.run() wurde nicht überschrieben!")

# --- Assertions -------------------------------------------------------------

func assert_equal(a, b, msg: String = "") -> void:
	if a != b:
		_push_fail("assert_equal", "%s != %s %s" % [a, b, msg])
	else:
		_push_pass("assert_equal", msg)

func assert_not_equal(a, b, msg: String = "") -> void:
	if a == b:
		_push_fail("assert_not_equal", "%s == %s %s" % [a, b, msg])
	else:
		_push_pass("assert_not_equal", msg)

func assert_range(value: float, min: float, max: float, msg: String = "") -> void:
	if value < min or value > max:
		_push_fail("assert_range", "%s not in [%s, %s] %s" % [value, min, max, msg])
	else:
		_push_pass("assert_range", msg)


# --- Output helpers ---------------------------------------------------------

func _push_pass(name: String, msg: String = "") -> void:
	passes += 1
	if msg == "":
		print("  PASS: ", name)
	else:
		print("  PASS: ", name, " → ", msg)

func _push_fail(name: String, reason: String) -> void:
	fails += 1
	var msg := "%s → %s" % [name, reason]
	fail_messages.append(msg)
	print("  FAIL: ", msg)
