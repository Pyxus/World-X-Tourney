extends KinematicBody

const _OPPOSITE_COLLISION = 0

var velocity: Vector3

## Moves this body along the vector 'rel_vec'. The body will attempt to push any
## FighterBody it encouters and will otherwise stop when a collision occurs.
func move_and_push() -> KinematicCollision:
	var collision := move_and_collide(velocity * _get_delta())
	if collision:
		if collision.collider is get_script():
			_push_impl(collision)
		
		move_and_collide(collision.remainder.slide(collision.normal))
	return collision

func test_wall_collision(rel_vec: Vector3) -> bool:
	var collision := move_and_collide(-rel_vec, true, true, true)
	return collision != null and not collision.collider is get_script()

## Returns delta based on current frame type
## Warning: Probably not thread-safe
func _get_delta() -> float:
	return get_physics_process_delta_time() if Engine.is_in_physics_frame() else get_process_delta_time()
	
## Virtual method used to implement pushing behavior.
## Default implementation is an inelastic push
func _push_impl(collision: KinematicCollision) -> void:
	var other: KinematicBody = collision.collider
	var is_top_collision := Math.is_vec_facing(collision.normal, Vector3.UP)
	var is_side_collision := (
		Math.is_vec_facing(collision.normal, Vector3.RIGHT)
		or Math.is_vec_facing(collision.normal, Vector3.LEFT))
	
	if is_top_collision:
		var dir_to_other := global_translation.direction_to(other.global_transform.origin)
		var is_left_of_other := Math.is_vec_facing(dir_to_other, Vector3.RIGHT, 0, 1)
		var is_perfect_stack := is_zero_approx(dir_to_other.dot(Vector3.RIGHT))
		var flip := 1 if is_left_of_other else -1
		var my_shape_extents: Vector3 = collision.local_shape.shape.extents
		var other_shape_extents: Vector3 = collision.collider_shape.shape.extents
		var my_x_limit: float = global_translation.x + (my_shape_extents.x * flip)
		var other_x_limit: float = other.global_translation.x - (other_shape_extents.x * flip)
		var other_rel_vec := Vector3(my_x_limit - other_x_limit, 0, 0)
		
		if is_perfect_stack and other.test_wall_collision(-other_rel_vec):
			_reposition_move(-other_rel_vec)
		elif other.test_wall_collision(Vector3.RIGHT * flip / 10):
			_reposition_move(other_rel_vec)
		elif other._reposition_move(other_rel_vec * 1.5):
			_reposition_move(-other_rel_vec)
		move_and_collide(Vector3.DOWN)

	if is_side_collision:
		var my_x_speed: float = velocity.x
		var my_remaining_motion := Vector3(collision.remainder.x, 0, 0)
		var other_x_speed: float = other.velocity.x
		var other_new_x_speed: float = 0
		var collision_type := sign(my_x_speed) + sign(other_x_speed)
		
		if collision_type != _OPPOSITE_COLLISION:
			other_new_x_speed = collision.remainder.x / _get_delta()
		elif abs(my_x_speed) > abs(other_x_speed):
			other_new_x_speed = velocity.x + other_x_speed
		else:
			other_new_x_speed = 0
			my_remaining_motion = Vector3.ZERO
			
		other.velocity.x = other_new_x_speed
		other.move_and_push()
		other.force_update_transform()
		move_and_collide(my_remaining_motion)


func _repositioned_impl(_prev: Vector3) -> void:
	pass


func _reposition_move(rel_vec: Vector3) -> KinematicCollision:
	var previous_position := global_translation
	var c := move_and_collide(rel_vec)
	_repositioned_impl(previous_position)
	return c

