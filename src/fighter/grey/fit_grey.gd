extends Fighter

const Condition = Fray.State.Condition

const FitDir = "res://src/fighter/grey/"

onready var _anim_tree: AnimationTree = $AnimationTree

func _ready() -> void:
	var builder := Fray.State.CombatSituationBuilder.new()
	
	_combat_sm.add_situation("on_ground", builder\
		.add_state("root", AnimationNodeFactory.load_node(FitDir + "anim_sm/asm_ground.tres"))\
		.start_at("root")\
		.build()
		)
	
	_combat_sm.add_situation("in_air", builder\
		.add_state("root", AnimationNodeFactory.load_node(FitDir + "anim_sm/asm_air.tres"))\
		.start_at("root")\
		.build()
		)

func _process(delta: float) -> void:
	var debug_text := ""

	debug_text += "Current Situation: %s\n" % _combat_sm.current_situation
	debug_text += "Current State: %s\n" % _combat_sm.root.current_node
	debug_text += "Current Animation: %s\n" % _animation_player.current_animation
	debug_text += "Is On Ground: %s\n" % is_on_ground()

	$DebugLabel.text = debug_text
	pass


func _motion_impl() -> void:
	var current_node := _combat_sm.root.get_node_current()
	if current_node is StateNodeAnimation:
		if _anim_tree.tree_root != current_node.anim_node:
			_anim_tree.active = false
			_anim_tree.tree_root = current_node.anim_node
			_anim_tree.active = true

	match _combat_sm.current_situation:
		"on_ground":
			var move_dir := _controller.get_axis("left", "right")
			move(sign(move_dir), 8.0)

			if _controller.is_pressed("up"):
				if _controller.is_pressed("forward"):
					jump(Vector2(5, 5), false)
				elif _controller.is_pressed("backward"):
					jump(Vector2(-5, 5), false)
				else:
					jump(Vector2(0, 5))

			if not is_on_ground():
				_combat_sm.change_situation("in_air")
			
			_anim_tree["parameters/conditions/is_sprinting"] = _controller.is_pressed("special")
			_anim_tree["parameters/conditions/not_sprinting"] = not _controller.is_pressed("special")
			_anim_tree["parameters/conditions/is_walking_forward"] = move_dir != 0
			_anim_tree["parameters/conditions/not_walking_forward"] = move_dir == 0
			_anim_tree["parameters/conditions/is_crouching"] = _controller.is_pressed("down")
			_anim_tree["parameters/conditions/not_crouching"] = not _controller.is_pressed("down")
		"in_air":
			if is_on_ground():
				_combat_sm.change_situation("on_ground")
			
			_anim_tree["parameters/conditions/is_falling"] = velocity.y > 0
			_anim_tree["parameters/conditions/not_falling"] = velocity.y <= 0

#func _ready() -> void:
#	var builder := Fray.State.CombatSituationBuilder.new()
#	var anim_builder := Fray.State.AnimationStateMachineBuilder.new()
#	_combat_sm.add_situation("on_ground", builder\
#		.add_state("idle", anim_builder\
#			.transition("idle", "walk_forward", {
#				advance_conditions = [Condition.new("is_walking_forward")],
#				auto_advance = true
#				})\
#			.transition("walk_forward", "idle", {
#				advance_conditions = [Condition.new("is_walking_forward", true)],
#				auto_advance = true
#				})\
#			.transition("idle", "walk_backward", {
#				advance_conditions = [Condition.new("is_walking_backward")],
#				auto_advance = true
#				})\
#			.transition("walk_backward", "idle", {
#				advance_conditions = [Condition.new("is_walking_backward", true)],
#				auto_advance = true
#				})\
#			.transition("idle", "crouch_t", {
#				advance_conditions = [Condition.new("is_crouching")],
#				auto_advance = true
#				})\
#			.transition("crouch_t", "idle", {
#				advance_conditions = [Condition.new("is_crouching", true)],
#				auto_advance = true
#				})\
#			.transition("crouch_t", "crouch", {
#				advance_conditions = [Condition.new("is_crouching")],
#				auto_advance = true,
#				switch_mode = Fray.State.StateMachineTransition.SwitchMode.AT_END
#				})\
#			.add_animation_state("walk_backward", "walk_forward", true)\
#			.add_animation_state("idle", "idle")\
#			.add_animation_state("walk_forward", "walk_forward")\
#			.set_player(_animation_player)\
#			.build()
#			)\
#		.build()
#		)
#	_combat_sm.add_situation("in_air", builder\
#		.add_state("idle", anim_builder\
#			.transition("air_fall", "air_rise", {
#				advance_conditions = [Condition.new("is_falling", true)],
#				auto_advance = true
#			})\
#			.transition("air_rise", "air_fall", {
#				advance_conditions = [Condition.new("is_falling")],
#				auto_advance = true
#			})\
#			.add_animation_state("air_fall", "air_fall")\
#			.add_animation_state("air_rise", "air_rise")\
#			.set_player(_animation_player)\
#			.build()
#			)\
#		.build()
#		)
#	_combat_sm.root.get_node_current().set_condition("is_walking_forward", true)
#

