extends StaticBody


onready var _left_shape: CollisionShape = $CollisionShape
onready var _center_shape: CollisionShape = $CollisionShape1
onready var _right_shape: CollisionShape = $CollisionShape2

func update(fighter_center: Vector3) -> void:
	if _in_bounds_of(_center_shape, fighter_center):
		return
	
	var is_shift_successful := _attempt_shift(fighter_center)
	if not is_shift_successful:
		_center_shape.global_translation.x = fighter_center.x
		_left_shape.global_translation.x = fighter_center.x - 60
		_right_shape.global_translation.x = fighter_center.x + 60


func _attempt_shift(fighter_center: Vector3) -> bool:
	for shape in [_left_shape, _right_shape]:
		if _in_bounds_of(shape, fighter_center):
			var prev_center := _center_shape
			_center_shape = shape
			
			if prev_center.global_translation.x < _center_shape.global_translation.x:
				_right_shape = _left_shape
				_left_shape = prev_center
				_right_shape.global_translation.x = _center_shape.global_translation.x + 60
				pass
			else:
				_left_shape = _right_shape
				_right_shape = prev_center
				_left_shape.global_translation.x = _center_shape.global_translation.x - 60
				pass
			return true
	return false
	

func _in_bounds_of(shape: CollisionShape, point: Vector3) -> bool:
	return point.x < shape.global_translation.x + 30 and point.x > shape.global_translation.x - 30
