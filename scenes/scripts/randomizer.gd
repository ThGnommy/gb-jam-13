extends Node2D

# Luck factor for random number generation : can only have values between 0 and 1
@export var luck : float = 0.5
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	luck = clamp(luck, 0.0, 1.0)

	# Luck factor for random number generation: can be between -0.5 and 0.5 to model unluckiness
	var luck_factor : float = luck - 0.5
	print("Luck factor : " + str(luck_factor))
	rng = RandomNumberGenerator.new()

	var number_of_tests = 10000
	var cumulative_random_value = 0.0
	for i in range(number_of_tests):
		var random_value = get_random_value()
		cumulative_random_value += random_value
	print("Average random value : " + str(cumulative_random_value / number_of_tests))

func get_random_value() -> float:
	assert(Globals.is_equal_approx(luck, 0) || luck > 0.0)
	assert(Globals.is_equal_approx(luck, 1) || luck < 1.0)
	assert(rng != null)

	var luck_factor : float = luck - 0.5
	var min_random_value : float = clamp(0.0 + luck_factor, 0.0, 1.0)
	var max_random_value : float = clamp(1.0 + luck_factor, 0.0, 1.0)
	return rng.randf_range(min_random_value, max_random_value)
