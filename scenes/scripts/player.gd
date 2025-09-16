class_name Player 

extends Area2D

@export var animation_speed = 1
@onready var raycast = $RayCast2D
@onready var anim = $AnimatedSprite2D

@export var current_cell: Vector2i
@export var manager: Node

signal player_moved

const TILE_SIZE = 24
var moving: bool = false

var inputs: Dictionary = {
	"right": Vector2i.RIGHT,
	"left": Vector2i.LEFT,
	"up": Vector2i.UP,
	"down": Vector2i.DOWN
}

func _ready() -> void:
	position = manager.cell_to_world(self.current_cell)
	manager.occupy_cell(self.current_cell)

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

func move(dir) -> void:
	moving = true
	await manager.move_enemy(self, current_cell + inputs[dir])
	player_moved.emit()
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

func update_raycast(dir) -> void:
	raycast.target_position = inputs[dir] * TILE_SIZE / 2
	raycast.force_raycast_update()
