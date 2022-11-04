extends Fray.Collision.HitboxAttributes

var AttackAttributes = load("res://src/fighter/base/hitbox_attributes/attack_attributes.gd")

func _allows_detection_of_impl(attributes: Resource) -> bool:
	return attributes is AttackAttributes


func _get_color_impl() -> Color:
	return Color.aqua
