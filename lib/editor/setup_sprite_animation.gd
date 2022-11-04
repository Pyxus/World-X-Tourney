tool
extends EditorScript

const FPS_60 = 1/12.0

func _run() -> void:
	var interface := get_editor_interface()
	var current_path := interface.get_current_path()
	var editor_selection := interface.get_selection()
	var selected_nodes := editor_selection.get_selected_nodes()
	var sprite: Sprite3D
	var anim_player: AnimationPlayer

	for node in selected_nodes:
		if node is Sprite3D:
			sprite = node
		elif node is AnimationPlayer:
			anim_player = node
	
	if sprite == null:
		push_error("No Sprite3D node selected")
		return
	
	if anim_player == null:
		push_error("No AnimationPlayer selected")
		return

	var dir := Directory.new()
	var regex := RegEx.new()
	regex.compile("^[a-zA-Z][a-zA-Z]\\d\\d\\d")
	
	if dir.open(current_path) == OK:
		dir.list_dir_begin(true)
		var file_name := dir.get_next()
		var result := regex.search(file_name)
		var current_batch := result.get_string()
		var animation := Animation.new()
		var track_id := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(
			track_id, 
			NodePath("%s:texture" % sprite.get_parent().get_path_to(sprite)))
		
		if anim_player.has_animation(current_batch):
			anim_player.remove_animation(current_batch)
		anim_player.add_animation(current_batch, animation)
		
		var i = 0
		while file_name != "":
			var texture := load(dir.get_current_dir() + "/" + file_name)
			result = regex.search(file_name)
			
			if result.get_string() != current_batch:
				animation.length = i * FPS_60
				current_batch = result.get_string()
				animation.step = FPS_60
				animation = Animation.new()
				track_id = animation.add_track(Animation.TYPE_VALUE)
				animation.track_set_path(
					track_id, 
					NodePath("%s:texture" % sprite.get_parent().get_path_to(sprite)))
				if anim_player.has_animation(current_batch):
					anim_player.remove_animation(current_batch)
				anim_player.add_animation(current_batch, animation)
				i = 0
			animation.track_insert_key(track_id, i * FPS_60, texture)
			file_name = dir.get_next()
			i += 1
	else:
		push_error("Failed to open directory")
