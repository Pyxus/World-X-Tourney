extends Node

const CIF := Fray.Input.CompositeInputFactory

func _ready() -> void:
	FrayInputMap.add_bind_fray_action("left", [
		Fray.Input.InputBindJoyButton.new(JOY_DPAD_LEFT),
		Fray.Input.InputBindJoyAxis.new(JOY_AXIS_0, false),
		Fray.Input.InputBindKey.new(KEY_A),
	])
	FrayInputMap.add_bind_fray_action("right", [
		Fray.Input.InputBindJoyButton.new(JOY_DPAD_RIGHT),
		Fray.Input.InputBindJoyAxis.new(JOY_AXIS_0, true),
		Fray.Input.InputBindKey.new(KEY_D),
	])
	FrayInputMap.add_bind_fray_action("up", [
		Fray.Input.InputBindJoyButton.new(JOY_DPAD_UP),
		Fray.Input.InputBindJoyAxis.new(JOY_AXIS_1, false),
		Fray.Input.InputBindKey.new(KEY_W),
	])
	FrayInputMap.add_bind_fray_action("down", [
		Fray.Input.InputBindJoyButton.new(JOY_DPAD_DOWN),
		Fray.Input.InputBindJoyAxis.new(JOY_AXIS_1, true),
		Fray.Input.InputBindKey.new(KEY_S),
	])
	FrayInputMap.add_bind_fray_action("light", [
		Fray.Input.InputBindJoyButton.new(JOY_SONY_SQUARE)
	])
	FrayInputMap.add_bind_fray_action("medium", [
		Fray.Input.InputBindJoyButton.new(JOY_SONY_TRIANGLE)
	])
	FrayInputMap.add_bind_fray_action("heavy", [
		Fray.Input.InputBindJoyButton.new(JOY_SONY_CIRCLE)
	])
	FrayInputMap.add_bind_fray_action("special", [
		Fray.Input.InputBindJoyButton.new(JOY_SONY_X)
	])
	
	
	FrayInputMap.add_composite_input("forward", CIF.new_conditional()\
		.add_component("", CIF.new_simple(["right"]))\
		.add_component("on_right", CIF.new_simple(["left"]))\
		.build())

	FrayInputMap.add_composite_input("backward", CIF.new_conditional()\
		.add_component("", CIF.new_simple(["left"]))\
		.add_component("on_right", CIF.new_simple(["right"]))\
		.build())
	
	FrayInputMap.add_composite_input("forward_up", CIF.new_conditional()\
		.add_component("", CIF.new_combination_async()\
			.add_component(CIF.new_simple(["up"]))\
			.add_component(CIF.new_simple(["right"]))\
			.virtual())\
		.add_component("on_right", CIF.new_combination_async()\
			.add_component(CIF.new_simple(["up"]))\
			.add_component(CIF.new_simple(["left"]))\
			.virtual())\
		.virtual()\
		.build())
		
	FrayInputMap.add_composite_input("forward_down", CIF.new_conditional()\
		.add_component("", CIF.new_combination_async()\
			.add_component(CIF.new_simple(["down"]))\
			.add_component(CIF.new_simple(["right"]))\
			.virtual())\
		.add_component("on_right", CIF.new_combination_async()\
			.add_component(CIF.new_simple(["down"]))\
			.add_component(CIF.new_simple(["left"]))\
			.virtual())\
		.virtual()\
		.build())
		
	FrayInputMap.add_composite_input("backward_up", CIF.new_conditional()\
		.add_component("", CIF.new_combination_async()\
			.add_component(CIF.new_simple(["up"]))\
			.add_component(CIF.new_simple(["left"]))\
			.virtual())\
		.add_component("on_right", CIF.new_combination_async()\
			.add_component(CIF.new_simple(["up"]))\
			.add_component(CIF.new_simple(["right"]))\
			.virtual())\
		.virtual()\
		.build())
		
	FrayInputMap.add_composite_input("backward_down", CIF.new_conditional()\
		.add_component("", CIF.new_combination_async()\
			.add_component(CIF.new_simple(["down"]))\
			.add_component(CIF.new_simple(["left"]))\
			.virtual())\
		.add_component("on_right", CIF.new_combination_async()\
			.add_component(CIF.new_simple(["down"]))\
			.add_component(CIF.new_simple(["right"]))\
			.virtual())\
		.virtual()\
		.build())
