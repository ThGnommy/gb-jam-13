class_name Player 

extends Area2D

signal player_health_change(value)
signal belt_changed(value)

@export var animation_speed: float = 1.0
@onready var raycast = $RayCast2D
@onready var anim = $SpritesRoot/AnimatedSprite2D

var player_direction: Vector2i

#@onready var belt : Array = ["Regular", "Regular", "Regular", "Regular", "Regular", "Regular"]
#@onready var belt : Array = ["Shotgun", "Shotgun", "Shotgun", "Shotgun", "Shotgun", "Shotgun"]
#@onready var belt : Array = ["Dynamite", "Dynamite", "Dynamite", "Dynamite", "Dynamite"]
# @onready var belt : Array = ["Regular", "Mortar", "Dynamite", "Regular", "Dynamite", "Mortar"]
@onready var belt : Array = ["Regular", "Regular", "Regular", "Regular", "Regular", "Regular"]
#@onready var belt : Array = ["Mortar"]

var remaining_bullets : Array

var current_cell: Vector2i

var moving: bool = false
var shooting: bool = false

var inputs: Dictionary = {
	"right": Vector2i.RIGHT,
	"left": Vector2i.LEFT,
	"up": Vector2i.UP,
	"down": Vector2i.DOWN
}

func _ready() -> void:
	player_direction = Vector2.RIGHT
	TurnManager.add_entity_from_current_turn(self)
	current_cell = GridManager.world_to_cell(global_position)
	print("Player current cell, ", current_cell)
	GridManager.occupy_cell(current_cell, GridManager.EntityType.Player, self)
	GridManager.set_player(self)
	reload()

func _unhandled_input(event: InputEvent) -> void:
	if moving:
		return
	
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			set_player_direction(dir)
			set_idle_animation()

	if event.is_action_pressed("fire"):
		shoot()

	if event.is_action_pressed("move"):
		if not TurnManager.is_turn_of(TurnManager.TurnState.Player):
			return
		move()
		animate()
		set_idle_animation()

func move() -> void:
	if TurnManager.is_turn_of(TurnManager.TurnState.Player):
		$JumpAudioStream.play()
		moving = true
		await GridManager.move_entity(self, GridManager.EntityType.Player, current_cell + player_direction)
		moving = false
		TurnManager.remove_entity_from_current_turn(self)
		TurnManager.try_update_to_next_turn()

func animate() -> void:
	match player_direction:
		Vector2i.RIGHT:
			jump_animation(10)
			anim.animation = "jump_side"
			anim.flip_h = false
		Vector2i.LEFT:
			jump_animation(10)
			anim.animation = "jump_side"
			anim.flip_h = true
		Vector2i.UP:
			jump_animation(5)
			anim.animation = "jump_top"
		Vector2i.DOWN:
			jump_animation(5)
			anim.animation = "jump_down"

func set_idle_animation():
	match player_direction:
		Vector2i.RIGHT:
			anim.play("idle")
			anim.flip_h = false
		Vector2i.LEFT:
			anim.play("idle")
			anim.flip_h = true
		Vector2i.UP:
			anim.play("idle_top")
		Vector2i.DOWN:
			anim.play("idle_down")

func jump_animation(px_height: int) -> void:
	var jump_tween = create_tween()
	jump_tween.tween_property(anim, "position:y", -px_height, 1.0 / animation_speed / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(anim, "position:y", 0, 1.0 / animation_speed / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await jump_tween.finished

func update_raycast(dir) -> void:
	raycast.target_position = inputs[dir] * GridManager.CELL_SIZE / 2
	raycast.force_raycast_update()

func shoot() -> void:
	if shooting:
		return

	if TurnManager.is_turn_of(TurnManager.TurnState.Enemies):
		return
	shooting = true

	if remaining_bullets.size() == 0:
		reload()
		$ReloadAudioStream.play()
		anim.animation = "reload"
		await anim.animation_finished
		set_idle_animation()
		return

	match player_direction:
		Vector2i.RIGHT:
			anim.flip_h = false
			anim.animation = "shootRight"
			await anim.animation_finished
			set_idle_animation()
		Vector2i.LEFT:
			anim.flip_h = true
			anim.animation = "shootRight"
			await anim.animation_finished
			set_idle_animation()
		Vector2i.UP:
			anim.animation = "shootUp"
			await anim.animation_finished
			set_idle_animation()
		Vector2i.DOWN:
			anim.animation = "shootDown"
			await anim.animation_finished
			set_idle_animation()

	# Choose a random bullet from the remaining bullets
	var random_chamber = randi() % remaining_bullets.size()
	var bullet_type = remaining_bullets[random_chamber]

	# Remove the bullet from the remaining bullets
	remaining_bullets.remove_at(random_chamber)

	# Create and shoot the bullet
	var bullet_instance : Bullet = BulletFactory.create_bullet(bullet_type)
	bullet_instance.position = position + player_direction * (GridManager.CELL_SIZE * BulletFactory.bullet_offset_mult(bullet_type))
	get_parent().add_child(bullet_instance)
	bullet_instance.set_direction(player_direction)
	$ShootAudioStream.play()
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()

func reload() -> void:
	remaining_bullets.clear()
	remaining_bullets = belt.duplicate()
	print("Reloaded! Now have %d bullets." % remaining_bullets.size())
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()


func die():
	return
	queue_free()

func player_turn():
	moving = false
	shooting = false

func set_player_direction(dir) -> void:
	player_direction = inputs[dir]

func _on_health_component_health_change() -> void:
	player_health_change.emit($HealthComponent.currentHealth)

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var parent = area.get_parent()
	if parent is PickUp:
		var pickup_name = parent.pickup()
		parent.delete()
		if pickup_name == "Lucky":
			print("Win")
		elif pickup_name =="Beer":
			print($HealthComponent.currentHealth)
			$HealthComponent.heal(2)
			print($HealthComponent.currentHealth)
		else:
			var index = randi_range(0, belt.size())
			belt.remove_at(index)
			belt.append(pickup_name)
			belt_changed.emit(pickup_name)
			reload()
			
