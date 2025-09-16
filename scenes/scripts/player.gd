extends Area2D

@export var animation_speed = 1
@onready var raycast = $RayCast2D

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
			move(dir)

func move(dir) -> void:
	raycast.target_position = inputs[dir] * TILE_SIZE / 2
	raycast.force_raycast_update()
	if !raycast.is_colliding():
		var tween = create_tween()
		var direction = position + inputs[dir] * TILE_SIZE
		tween.tween_property(self, "position", direction, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		print_debug("move")
		await tween.finished
		moving = false
