extends Node2D

# Luck factor for random number generation : can only have values between 0 and 1
@export var luck : float = 0.5

func _ready() -> void:
	luck = clamp(luck, 0.0, 1.0)

	# Luck factor for random number generation: can be between -0.5 and 0.5 to model unluckiness
	var luck_factor : float = luck - 0.5
	print("Luck factor : " + str(luck_factor))
	var rng = RandomNumberGenerator.new()

	var number_of_tests = 10000
	var cumulative_random_value = 0.0
	var min_random_value = clamp(0.0 + luck_factor, 0.0, 1.0)
	var max_random_value = clamp(1.0 + luck_factor, 0.0, 1.0)
	print("Min random value : " + str(min_random_value))
	print("Max random value : " + str(max_random_value))
	for i in range(number_of_tests):
		var random_value = rng.randf_range(min_random_value, max_random_value)
		
		cumulative_random_value += random_value

	print("Average random value : " + str(cumulative_random_value / number_of_tests))
