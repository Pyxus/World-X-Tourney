extends Reference

const StateNodeAnimation = preload("state_node_animation.gd")


static func load_node(path: String) -> StateNodeAnimation:
	var node = load(path) as AnimationNode
	
	if node == null:
		push_error("Invalid path or resource is not of type AnimationNode")
		return null
	
	return StateNodeAnimation.new(node)


static func new_animation_node(animation: String) -> StateNodeAnimation:
	var node := AnimationNodeAnimation.new()
	node.animation = animation
	return StateNodeAnimation.new(node)
