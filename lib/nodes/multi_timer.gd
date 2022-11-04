extends Node

signal timeout(name)

export(int, "Physics", "Idle") var process_mode: int

## Type: Dictionary<String, TimerData>
var _timers: Dictionary

func _process(delta: float) -> void:
	_tick(delta)


func _physics_process(delta: float) -> void:
	_tick(delta)


func create_timer(timer_name: String, time_sec: float, one_shot: bool = true) -> void:
	if _timers.has(timer_name):
		push_warning("Failed to create timer. Timer with name '%s' already exists." % timer_name)
		return

	var timer := TimerData.new()
	timer.init(time_sec, one_shot)
	_timers[timer_name] = timer
	

func _tick(delta: float) -> void:
	for timer_name in _timers:
		var timer: TimerData = _timers[timer_name]
		
		if not timer.paused:
			timer.time_left -= delta
			
			if timer.time_left <= 0:
				if timer.one_shot:
					_timers.erase(timer_name)
					emit_signal("timeout", timer_name)
				else:
					timer.reset()


class TimerData:
	extends Reference
	
	var wait_time: float
	var time_left: float
	var one_shot: bool
	var paused: bool
	
	func init(time_sec: float, is_one_shot: bool) -> void:
		wait_time = time_sec
		time_left = time_sec
		one_shot = is_one_shot
	
	
	func reset() -> void:
		time_left = wait_time
