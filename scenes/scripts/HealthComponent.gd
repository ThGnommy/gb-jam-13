extends Node2D

signal health_change

@export var currentHealth : int = 1
@export var maxHealth : int = 1
@onready var is_disabled = false

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
		currentHealth += healAmount
	health_change.emit()

func take_damage(damage: int):
	if is_disabled:
		return
	assert(damage >= 0)
	if currentHealth - damage < 1:
		currentHealth = 0
		handle_death()
	else:
		currentHealth -= damage

	health_change.emit()
	
func disable():
	is_disabled = true  # Like Fabio
	
func handle_death():
	assert(get_parent().has_method("die"))
	get_parent().die()
