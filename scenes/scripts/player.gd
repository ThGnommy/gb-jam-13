class_name Player 

extends Area2D

signal player_health_change(value)
signal belt_changed(value)
signal belt_shot(index)
signal reload_signal

@export var animation_speed: float = 1.0
@export var camera: Camera2D
@onready var raycast = $RayCast2D
@onready var anim = $SpritesRoot/AnimatedSprite2D

var dead = false
var win_ui: PackedScene = preload("res://scenes/UI/win_ui.tscn")
var game_over_ui: PackedScene = preload("res://scenes/UI/game_over.tscn")
var remaining_bullets_indexes : Array = []
var player_direction: Vector2i

@onready var belt : Array = ["Regular", "Regular", "Regular", "Regular", "Regular", "Regular"]
#@onready var belt : Array = ["Shotgun", "Shotgun", "Shotgun", "Shotgun", "Shotgun", "Shotgun"]
#@onready var belt : Array = ["Dynamite", "Dynamite", "Dynamite", "Dynamite", "Dynamite"]
#@onready var belt : Array = ["Regular", "Mortar", "Dynamite", "Regular", "Dynamite", "Mortar"]
#@onready var belt : Array = ["Regular", "Regular", "Regular", "Regular", "Regular", "Regular"]
#@onready var belt : Array = ["Mortar"]

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
	set_player_direction("right")
	TurnManager.add_entity_from_current_turn(self)
	current_cell = GridManager.world_to_cell(global_position)
	GridManager.occupy_cell(current_cell, GridManager.EntityType.Player, self)
	GridManager.set_player(self)
	reload()

func _unhandled_input(event: InputEvent) -> void:
	if moving or dead or shooting:
		return
	
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			set_player_direction(dir)
			set_idle_animation()

	if event.is_action("fire"):
		shoot()

	if event.is_action("move"):
		if not TurnManager.is_turn_of(TurnManager.TurnState.Player):
			return
		move()
		animate()

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
		Vector2i.LEFT:
			jump_animation(10)
		Vector2i.UP:
			jump_animation(5)
		Vector2i.DOWN:
			jump_animation(5)

func set_idle_animation():
	print("idle")
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
	match player_direction:
		Vector2i.RIGHT:
			anim.flip_h = false
			anim.play("jump_side")
		Vector2i.LEFT:
			anim.flip_h = true
			anim.play("jump_side")
			print(anim.animation)
		Vector2i.UP:
			anim.play("jump_top")
		Vector2i.DOWN:
			anim.play("jump_down")
	var jump_tween = create_tween()
	jump_tween.tween_property(anim, "position:y", -px_height, 1.0 / animation_speed / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(anim, "position:y", 0, 1.0 / animation_speed / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await jump_tween.finished
	set_idle_animation()


func update_raycast(dir) -> void:
	raycast.target_position = inputs[dir] * GridManager.CELL_SIZE / 2
	raycast.force_raycast_update()

func shoot() -> void:
	if shooting or moving:
		return

	if TurnManager.is_turn_of(TurnManager.TurnState.Enemies):
		return
	shooting = true

	if remaining_bullets_indexes.size() == 0:
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
	remaining_bullets_indexes.shuffle()
	assert(remaining_bullets_indexes.size() > 0)
	var random_chamber = remaining_bullets_indexes.pop_front()
	var bullet_type = belt[random_chamber]

	# Remove the bullet from the remaining bullets
	belt_shot.emit(random_chamber)

	# Create and shoot the bullet
	BulletFactory.shoot_bullet(bullet_type, position, player_direction, self)
	await anim.animation_finished
	set_idle_animation()
	$ShootAudioStream.play()

func _pass_turn():
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()

func reload() -> void:
	remaining_bullets_indexes = [0,1,2,3,4,5]
	reload_signal.emit()
	_pass_turn()

func die():
	# todo player animation
	dead = true
	game_over()

func player_turn():
	moving = false
	shooting = false

func set_player_direction(dir) -> void:
	player_direction = inputs[dir]
	camera.position = Vector2.ZERO
	camera.position += Vector2(inputs[dir]) * 32

func _on_health_component_health_change() -> void:
	player_health_change.emit($HealthComponent.currentHealth)

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var parent = area.get_parent()
	if parent is PickUp:
		var pickup_name = parent.pickup()
		parent.delete()
		if pickup_name == "Lucky":
			win()
		elif pickup_name == "ToLevel2":
			go_to_level("res://scenes/levels/Level2.tscn")
		elif pickup_name == "ToLevel3":
			go_to_level("res://scenes/levels/Level3.tscn")
		elif pickup_name == "ToLevel4":
			go_to_level("res://scenes/levels/Level4.tscn")
		elif pickup_name == "ToLevel5":
			go_to_level("res://scenes/levels/Level5.tscn")
		elif pickup_name =="Beer":
			print($HealthComponent.currentHealth)
			$HealthComponent.heal(2)
			print($HealthComponent.currentHealth)
		else:
			var index = randi_range(0, belt.size() - 1)
			assert(index != 6)
			var random_pos = randi() % belt.size()
			assert(belt.size() == 6)
			belt.remove_at(index)
			assert(belt.size() == 5)
			belt.insert(random_pos, pickup_name)
			assert(belt.size() == 6)
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

func go_to_level(path: String):
	get_tree().change_scene_to_file(path)
