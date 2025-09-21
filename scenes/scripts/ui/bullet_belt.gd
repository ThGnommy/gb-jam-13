extends Control

@export var player: Player
@onready var ui_belt = $Belt

var bullet_map: Dictionary = {
	"Regular": "res://assets/sprites/Player/StandardBullet.png",
	"Dynamite": "res://assets/sprites/Player/DynamiteBullet.png",
	"Mortar": "res://assets/sprites/Player/MortarBullet.png",
	"Shotgun": "res://assets/sprites/Player/ShotgunBullet.png"
}


var already_shot : Array[int]
func _ready() -> void:
	player.belt_changed.connect(_on_player_belt_changed)
	player.belt_shot.connect(_on_player_belt_shot)
	player.reload_signal.connect(_on_player_reload_signal)
	_on_player_reload_signal()

func set_bullet(index, type):
	if not ui_belt:
		return
	var rect: TextureRect = ui_belt.get_child(index)
	rect.texture = load(bullet_map[type])

func update_belt() -> void:
	if not ui_belt:
		return
	var bullet_belt = player.belt
	for i in ui_belt.get_children().size():
		set_bullet(i, bullet_belt[i])


func _on_player_belt_shot(index: Variant) -> void:
	var offset = 0

	for already in already_shot:
		if index + offset>= already:
			offset += 1
	set_bullet_active(index + offset, false)
	already_shot.append(index + offset)
	already_shot.sort()


func set_bullet_active(index, active: bool):
	var cross : Control = ui_belt.get_child(index).get_child(0)
	cross.visible = not active

func is_active(index):
	var cross : Control = ui_belt.get_child(index).get_child(0)
	return cross.visible

func _on_player_belt_changed(value: Variant) -> void:
	update_belt()


func _on_player_reload_signal() -> void:
	if not ui_belt:
		return
	already_shot.clear()
	update_belt()
	for i in ui_belt.get_children().size():
		set_bullet_active(i, true)
