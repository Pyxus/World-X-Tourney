tool
extends CollisionShape


func _process(_delta: float) -> void:
	if shape is BoxShape:
		translation.y = shape.extents.y
