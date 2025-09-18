class_name Player 

extends Area2D

@export var animation_speed = 1
@onready var raycast = $RayCast2D
@onready var anim = $AnimatedSprite2D
@onready var Bullet = preload("res://scenes/bullet.tscn")

var current_cell: Vector2i

signal player_moved

const TILE_SIZE = 24
var moving: bool = false

var inputs: Dictionary = {
	"right": Vector2i.RIGHT,
	"left": Vector2i.LEFT,
	"up": Vector2i.UP,
	"down": Vector2i.DOWN
}

var shootInputs: Dictionary = {
	"shootRight" : Vector2.RIGHT,
	"shootLeft" : Vector2.LEFT,
	"shootUp" : Vector2.UP,
	"shootDown" : Vector2.DOWN
}

func _ready() -> void:
	#position = manager.cell_to_world(self.current_cell)
	#manager.occupy_cell(self.current_cell)
	current_cell = GridManager.world_to_cell(global_position)
	GridManager.occupy_cell(current_cell, GridManager.EntityType.Player)
	GridManager.set_player(self)

func _unhandled_input(event: InputEvent) -> void:
	if moving:
		return
	
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			update_raycast(dir)
			
			if raycast.is_colliding():
				return

			move(dir)
			animate(dir)

func _process(delta: float) -> void:
	for dir in shootInputs.keys():
		if Input.is_action_just_pressed(dir):
			shoot(shootInputs[dir])

func move(dir) -> void:
	moving = true
	await GridManager.move_entity(self, GridManager.EntityType.Player, current_cell + inputs[dir])
	GridManager.move_enemies()
	moving = false
	anim.animation = "idle"

func animate(dir) -> void:
	match inputs[dir]:
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

func jump_animation(px_height: int) -> void:
	var jump_tween = create_tween()
	jump_tween.tween_property(anim, "position:y", -px_height, (1.0 / animation_speed) / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(anim, "position:y", 0, (1.0 / animation_speed) / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await jump_tween.finished
	TurnManager.next_turn(TurnManager.TurnState.Enemies)
	emit_signal("turn_change")

func update_raycast(dir) -> void:
	raycast.target_position = inputs[dir] * TILE_SIZE / 2
	raycast.force_raycast_update()

func shoot(dir: Vector2) -> void:
	match dir:
		Vector2.RIGHT:
			anim.flip_h = false
			anim.animation = "shootRight"
		Vector2.LEFT:
			anim.flip_h = true
			anim.animation = "shootRight"
		Vector2.UP:
			anim.animation = "shootUp"
		Vector2.DOWN:
			anim.animation = "shootDown"
	
	# Create and launch the bullet
	var bullet_instance = Bullet.instantiate()
	bullet_instance.position = position + dir * (TILE_SIZE / 2)
	bullet_instance.set_direction(dir)
	get_parent().add_child(bullet_instance)
