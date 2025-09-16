extends Node

var currentHealth : int = 0
var maxHealth : int = 0

func init(health: int):
	maxHealth = health
	currentHealth = health
	check()

func check():
	assert (currentHealth > 0 and currentHealth < maxHealth)

func take_damage(damage: int):
	if currentHealth - damage < 1:
		handle_death()
	else:
		currentHealth -= damage
	
func handle_death():
	if get_parent().has_method("die"):
		get_parent().die()

	# Is it risky to call queue_free anyway?
	queue_free()
