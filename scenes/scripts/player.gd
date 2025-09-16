extends Area2D

@export var animation_speed = 1
@onready var raycast = $RayCast2D
@onready var anim = $AnimatedSprite2D

const TILE_SIZE = 24
var moving: bool = false

var inputs: Dictionary = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}

func _ready() -> void:
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE / 2

func _unhandled_input(event: InputEvent) -> void:
	if moving:
		return
	
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			animate(dir)
			move(dir)

func move(dir) -> void:
	raycast.target_position = inputs[dir] * TILE_SIZE / 2
	raycast.force_raycast_update()
	if !raycast.is_colliding():
		var tween = create_tween()
		var direction = position + inputs[dir] * TILE_SIZE
		tween.tween_property(self, "position", direction, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		await tween.finished
		moving = false
		anim.animation = "idle"

func animate(dir) -> void:
	match inputs[dir]:
		Vector2.RIGHT:
			jump(10)
			anim.animation = "jump_side"
			anim.flip_h = false
		Vector2.LEFT:
			jump(10)
			anim.animation = "jump_side"
			anim.flip_h = true
		Vector2.UP:
			jump(5)
			anim.animation = "jump_top"
		Vector2.DOWN:
			jump(5)
			anim.animation = "jump_down"

func jump(height: int) -> void:
	var jump_tween = create_tween()
	jump_tween.tween_property(anim, "position:y", -height, (1.0 / animation_speed) / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(anim, "position:y", 0, (1.0 / animation_speed) / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
