class_name Player 

extends Area2D

signal player_health_change(value)
signal belt_changed(value)

@export var animation_speed: float = 1.0
@onready var raycast = $RayCast2D
@onready var anim = $SpritesRoot/AnimatedSprite2D

var win_ui: PackedScene = preload("res://scenes/UI/win_ui.tscn")
var game_over_ui: PackedScene = preload("res://scenes/UI/game_over.tscn")

var player_direction: Vector2i

@onready var belt : Array = ["Regular", "Regular", "Regular", "Regular", "Regular", "Regular"]
#@onready var belt : Array = ["Shotgun", "Shotgun", "Shotgun", "Shotgun", "Shotgun", "Shotgun"]
#@onready var belt : Array = ["Dynamite", "Dynamite", "Dynamite", "Dynamite", "Dynamite"]
#@onready var belt : Array = ["Regular", "Mortar", "Dynamite", "Regular", "Dynamite", "Mortar"]
#@onready var belt : Array = ["Regular", "Regular", "Regular", "Regular", "Regular", "Regular"]
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
		_pass_turn()

func animate() -> void:
	match player_direction:
		Vector2i.RIGHT:
			jump_animation(10)
			anim.play("jump_side")
			anim.flip_h = false
		Vector2i.LEFT:
			jump_animation(10)
			anim.play("jump_side")
			anim.flip_h = true
		Vector2i.UP:
			jump_animation(5)
			anim.play("jump_top")
		Vector2i.DOWN:
			jump_animation(5)
			anim.play("jump_down")

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
		anim.play("reload")
		await anim.animation_finished
		set_idle_animation()
		return
	match player_direction:
		Vector2i.RIGHT:
			anim.flip_h = false
			anim.play("aimRight")
			await anim.animation_finished
			$ShootAudioStream.play()
			anim.play("shootRight")
		Vector2i.LEFT:
			anim.flip_h = true
			anim.play("aimRight")
			await anim.animation_finished
			$ShootAudioStream.play()
			anim.play("shootRight")
		Vector2i.UP:
			anim.play("aimUp")
			await anim.animation_finished
			$ShootAudioStream.play()
			anim.play("shootUp")
		Vector2i.DOWN:
			anim.play("aimDown")
			await anim.animation_finished
			$ShootAudioStream.play()
			anim.play("shootDown")

	# Choose a random bullet from the remaining bullets
	var random_chamber = randi() % remaining_bullets.size()
	var bullet_type = remaining_bullets[random_chamber]

	# Remove the bullet from the remaining bullets
	remaining_bullets.remove_at(random_chamber)

	# Create and shoot the bullet
	BulletFactory.shoot_bullet(bullet_type, position, player_direction, self)
	await anim.animation_finished
	set_idle_animation()
	$ShootAudioStream.play()

func _pass_turn():
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()

func reload() -> void:
	remaining_bullets.clear()
	remaining_bullets = belt.duplicate()
	print("Reloaded! Now have %d bullets." % remaining_bullets.size())
	_pass_turn()

func die():
	# todo player animation
	game_over()

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
			win()
		elif pickup_name =="Beer":
			print($HealthComponent.currentHealth)
			$HealthComponent.heal(2)
			print($HealthComponent.currentHealth)
		else:
			var index = randi_range(0, belt.size())
			var random_pos = randi() % belt.size()
			belt.remove_at(index)
			belt.insert(random_pos, pickup_name)
			belt_changed.emit(pickup_name)
			reload()

func game_over() -> void:
	set_process_input(false)
	var ui = game_over_ui.instantiate()
	get_parent().get_node_or_null("UICanvasLayer").add_child(ui)

func win() -> void:
	set_process_input(false)
	var ui = win_ui.instantiate()
	get_parent().get_node_or_null("UICanvasLayer").add_child(ui)
