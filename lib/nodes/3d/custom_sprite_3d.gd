tool
extends Sprite3D

export var h_centered: bool = true setget set_h_centered
export var x_offset: float

func _process(_delta: float) -> void:
	if h_centered and texture != null:
		offset.x = (-texture.get_width() / 2.0) + x_offset
		pass


func set_h_centered(value: bool) -> void:
	h_centered = value
	
	if h_centered:
		centered = false
	else:
		offset.x = 0
