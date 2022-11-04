class_name Fighter
extends "fighter_body.gd"

var device: int setget set_device
var gravity: float = Math.Physics.calc_projectile_g(.5, 10)
var opponent_global_pos: Vector3

var _is_sprite_following := true
var _ai: FighterAI

onready var _sprite: Sprite3D = $Sprite
onready var _floor_cast: RayCast = $Sprite/GroundCast
onready var _hit_state_manager: Fray.Collision.HitStateManager3D = $Sprite/HitStateManager
#onready var _combat_sm: CombatStateMachine = $CombatStateMachine
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _animation_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	FrayInput.connect("input_detected", self, "_on_FrayInput_input_detected")
	_sprite.set_as_toplevel(true)
	#_setup_impl(_combat_sm)


func _process(_delta: float) -> void:
	if _is_sprite_following:
		_sprite.global_translation = global_translation


func _physics_process(delta: float) -> void:
	if _ai != null:
		_ai.physics_update(delta)

	velocity.y += gravity * delta

	if is_left_of_opponent() and _sprite.scale.x != 1 or not is_left_of_opponent() and _sprite.scale.x == 1:
		_switched_sides_impl()

	move_and_push()

	if is_on_ground():
		velocity.y = 0


func move(dir: int, move_speed: float) -> void:
	velocity.x = dir * move_speed


func jump(displacement: Vector2, is_relative: bool = true) -> void:
	if is_relative:
		displacement.x *= val_by_side(1, -1)
	velocity = Vector3(
		Math.Physics.calc_projectile_vx(.4, displacement.x), 
		Math.Physics.calc_v_to_reach(gravity, displacement.y), 0)


func is_on_ground() -> bool:
	return _floor_cast.is_colliding() and not _floor_cast.get_collider() is get_script()


## Returns 'a' value if left of opponent else returns 'b'
func val_by_side(a, b):
	return a if is_left_of_opponent() else b
	

func is_left_of_opponent() -> bool:
	return Math.is_vec_facing(
		global_translation.direction_to(opponent_global_pos), 
		Vector3.RIGHT, 0, 1)


func set_device(id: int) -> void:
	device = id
	_ai = null


func set_ai(ai: FighterAI) -> void:
	ai.initialize(self)
	device = ai.get_virtual_device_id()
	_ai = ai


func get_animation_player() -> AnimationPlayer:
	return _animation_player


func get_animation_tree() -> AnimationTree:
	return _animation_tree


func _interpolate_sprite(t: float, p0: Vector3, p1: Vector3) -> void:
	_is_sprite_following = false
	global_translation = Math.quadratic_interpolate(p0, p1, global_translation, t)
	if t >= 1:
		_is_sprite_following = true


func _switched_sides_impl() -> void:
	_sprite.scale.x = 1 if is_left_of_opponent() else -1


func _repositioned_impl(from: Vector3) -> void:
	var tween := create_tween()
	tween.tween_method(self, "_interpolate_sprite", 0.0, 1.0, 0.2, [from, global_translation])

"""
func _setup_impl(__combat_sm: CombatStateMachine) -> void:
	pass
"""
"""
func _on_FrayInput_input_detected(input_event: Fray.Input.FrayInputEvent) -> void:
	if input_event.is_just_pressed() and input_event.filtered and input_event.device == device:
		_combat_sm.buffer_button(input_event.input, input_event.pressed)
"""