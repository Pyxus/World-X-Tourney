class_name Fighter
extends "fighter_body.gd"

var device: int
var gravity: float = Math.Physics.calc_projectile_g(.5, 10)
var opponent_global_pos: Vector3

var _is_sprite_following := true

onready var _sprite: Sprite3D = $Sprite
onready var _floor_cast: RayCast = $Sprite/GroundCast
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _hit_state_manager: Fray.Collision.HitStateManager3D = $Sprite/HitStateManager
onready var _combat_sm: Fray.State.CombatStateMachine = $CombatStateMachine
onready var _controller: Fray.Input.Controller = $Controller

func _ready() -> void:
	FrayInput.connect("input_detected", self, "_on_FrayInput_input_detected")
	_sprite.set_as_toplevel(true)


func _process(_delta: float) -> void:
	if _is_sprite_following:
		_sprite.global_translation = global_translation


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if is_left_of_opponent() and _sprite.scale.x != 1 or not is_left_of_opponent() and _sprite.scale.x == 1:
		_switched_sides_impl()
	
	_update_velocity_impl()
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


func _interpolate_sprite(t: float, p0: Vector3, p1: Vector3) -> void:
	_is_sprite_following = false
	global_translation = Math.quadratic_interpolate(p0, p1, global_translation, t)
	if t >= 1:
		_is_sprite_following = true


func _switched_sides_impl() -> void:
	#_sprite.scale.x = 1 if is_left_of_opponent() else -1
	pass


func _repositioned_impl(from: Vector3) -> void:
	var tween := create_tween()
	tween.tween_method(self, "_interpolate_sprite", 0.0, 1.0, 0.2, [from, global_translation])


func _update_velocity_impl() -> void:
	if _controller.is_pressed("left"):
		velocity.x = -5
		_animation_player.play("walk_forward")
	elif _controller.is_pressed("right"):
		velocity.x = 5
		_animation_player.play_backwards("walk_forward")
	else:
		velocity.x = 0
		_animation_player.play("idle")
	
	if _controller.is_just_pressed("up"):
		jump(Vector2(0, 10))
	pass


func _on_FrayInput_input_detected(input_event: Fray.Input.FrayInputEvent) -> void:
	if input_event.is_just_pressed() and input_event.filtered and input_event.device == device:
		_combat_sm.buffer_button(input_event.input, input_event.pressed)
