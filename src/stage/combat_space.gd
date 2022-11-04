extends Spatial

var _max_fighter_dist: float = 15

onready var _fighter1: Fighter = $Fighter1
onready var _fighter2: Fighter = $Fighter2
onready var _left_wall: StaticBody = $"%LeftWall"
onready var _right_wall: StaticBody = $"%RightWall"
onready var _ground: StaticBody = $"%Ground"
onready var _gimbal: CameraGimbal = $Gimbal

func _ready() -> void:
	_fighter2.set_ai(FighterAI.new())
	

func _process(_delta: float) -> void:
	var f1_pos := _fighter1.global_translation
	var f2_pos := _fighter2.global_translation
	var center_of_fighters := f1_pos.linear_interpolate(f2_pos, .5)
	var dist_between_fighters := f1_pos.distance_to(f2_pos)
	var cam := _gimbal.get_camera()
	
	#TODO: Improve wall placement method
	if center_of_fighters.x < 8 and center_of_fighters.x > -8:
		_left_wall.global_translation.x = cam.project_position(Vector2.ZERO, _max_fighter_dist).x
		_right_wall.global_translation.x = cam.project_position(get_viewport().size, _max_fighter_dist).x
	_fighter1.opponent_global_pos = f2_pos
	_fighter2.opponent_global_pos = f1_pos
	_gimbal.zoom = clamp(dist_between_fighters, 11,  _max_fighter_dist)
	_gimbal.manual_position.x = center_of_fighters.x
	_gimbal.manual_position.y = (
		max(_fighter1.global_translation.y, _fighter2.global_translation.y) 
		if center_of_fighters.y > 0.1
		else 0.0)
	_ground.update(center_of_fighters)
	_gimbal.update_camera()
