extends Node2D

signal health_change

@export var currentHealth : int = 1
@export var maxHealth : int = 1

func init(health: int):
	maxHealth = health
	currentHealth = health
	check()

func check():
	assert (currentHealth > 0 and currentHealth < maxHealth)

func heal(healAmount : int):
	assert(healAmount >= 0)
	if currentHealth + healAmount > maxHealth:
		currentHealth = maxHealth
	else:
		currentHealth += maxHealth

func take_damage(damage: int):
	assert(damage >= 0)
	if currentHealth - damage < 1:
		currentHealth = 0
		handle_death()
	else:
		currentHealth -= damage

	health_change.emit()
	
func handle_death():
	assert(get_parent().has_method("die"))
	get_parent().die()
