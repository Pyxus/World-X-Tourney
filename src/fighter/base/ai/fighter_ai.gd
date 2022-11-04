class_name FighterAI
extends Reference

var fighter: KinematicBody

var _virtual_device: Fray.Input.VirtualDevice


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_virtual_device.request_disconnect()


func initialize(fighter_ref: KinematicBody) -> void:
	_virtual_device = FrayInput.create_virtual_device()
	fighter = fighter_ref
	fighter.device = _virtual_device.get_id()


func has_virtual_device(id: int) -> bool:
	return _virtual_device.get_id() == id


func get_virtual_device_id() -> int:
	return _virtual_device.get_id()


func physics_update(_delta: float) -> void:
	_physics_update_impl(_delta)


func _physics_update_impl(_delta: float) -> void:
	pass
