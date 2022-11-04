tool
class_name CameraGimbal
extends Spatial

export var target: NodePath
export var orientation: Vector3
export var pan: Vector2
export var zoom: float = 10
export var enable_tweening: bool = true
export var rotation_tween_duration: float = .15
export var pan_tween_duration: float = .15
export var zoom_tween_duration: float = .15
export var position_tween_duration: float = .15

var _target: Spatial
var manual_position: Vector3 setget set_manual_position
var manual_rotation: Vector3 setget set_manual_rotation

onready var _camera: Camera = _find_camera()
onready var _pitch_axis := Position3D.new()
onready var _yaw_axis := Position3D.new()
onready var _roll_axis := Position3D.new()
onready var _camera_position := Position3D.new()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	set_target(target)
	add_child(_pitch_axis)
	_pitch_axis.add_child(_yaw_axis)
	_yaw_axis.add_child(_roll_axis)
	_roll_axis.add_child(_camera_position)
	
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
		
func _get_configuration_warning() -> String:
	var warning := ""
	if _find_camera() == null:
		warning += "No camera added as child."

	return warning
	

func set_manual_position(pos: Vector3) -> void:
	manual_position = pos
	
	if _target != null:
		push_warning("Gimbal has a target so manual position will be ignored.")


func set_manual_rotation(rot: Vector3) -> void:
	manual_rotation = rot
	
	if _target != null:
		push_warning("Gimbal has a target so manual rotation will be ignored.")


func update_camera() -> void:
	if _camera != null:
		_camera.set_as_toplevel(true)
		_camera.global_transform = _camera_position.global_transform
	
	var target_rotation := _target.rotation if _target else manual_rotation
	var target_position := _target.global_translation if _target else manual_position
	var rotation_diff := target_rotation - orientation
	var current_orient := _get_orientation()
	var final_orient := Vector3(
		lerp_angle(current_orient.x, rotation_diff.x, 1),
		lerp_angle(current_orient.y, rotation_diff.y, 1),
		lerp_angle(current_orient.z, rotation_diff.z, 1)
	)
	
	if enable_tweening:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_method(self, "_set_orientation", current_orient, final_orient, rotation_tween_duration)
		tween.tween_method(self,"_set_zoom", _get_zoom(), zoom, zoom_tween_duration)
		tween.tween_method(self, "_set_pan", _get_pan(), pan, pan_tween_duration)
		tween.tween_property(self, "global_translation", target_position, position_tween_duration)
	else:
		_set_orientation(final_orient)
		_set_zoom(zoom)
		_set_pan(pan)
		global_translation = target_position
	
	
func set_target(value: NodePath) -> void:
	var node := get_node_or_null(value)
	
	if not node is Spatial and is_instance_valid(node):
		push_error("Failed to set target. Target must be of type Spatial.")
		target = ""
		return
		
	set_target_obj(node)


func set_target_obj(node: Spatial) -> void:
	target = ""
	_target = node
	
	if node != null:
		target = node.get_path()
	

func get_camera() -> Camera:
	return _camera
	

func _get_orientation() -> Vector3:
	return Vector3(
		_yaw_axis.rotation.x, 
		_pitch_axis.rotation.y, 
		_roll_axis.rotation.z)
	

func _set_orientation(orient: Vector3) -> void:
	_yaw_axis.rotation.x = orient.x
	_pitch_axis.rotation.y = orient.y
	_roll_axis.rotation.z = orient.z


func _get_zoom() -> float:
	return _camera_position.translation.z


func _set_zoom(camera_zoom: float) -> void:
	_camera_position.translation.z = camera_zoom


func _get_pan() -> Vector2:
	var camera_pos := _camera_position.translation
	return Vector2(camera_pos.x, camera_pos.y)


func _set_pan(camera_pan: Vector2) -> void:
	_camera_position.translation.x = camera_pan.x
	_camera_position.translation.y = camera_pan.y
	
	
func _find_camera() -> Camera:
	for child in get_children():
		if child is Camera:
			return child
	return null
