class_name Math
extends Object

func _init() -> void:
	assert(true, "Math class is pseudo-static and should not be instanced.")

## Returns the sum of a given set of values
static func sum(values: PoolRealArray) -> float:
	var sum := 0.0
	for value in values:
		sum += value
	return sum

## Returns the average of a given set of values
static func avg(values: PoolRealArray) -> float:
	return 0.0 if values.empty() else sum(values) / values.size()

## Returns a dictionary containing projectile motion data based on input
## t is the flight duration
## y_max is the max height
## d is the distance to travel
static func calc_projectile_motion(t: float, y_max: float, d: float = 0) -> Dictionary:
	assert(t > 0, "t must be greater than 0")
	return {
		gravity = (-2.0 * y_max) / (t * t),
		velocity = calc_launch_velocity(t, y_max, d),
	}

## Returns a velocity
static func calc_launch_velocity(t: float, y_max: float, d: float = 0) -> Vector2:
	assert(t > 0, "t must be greater than 0")
	return Vector2(d / (2.0 * t), (2.0 * y_max) / t)
	

## Returns the result of quadratic interpolation between given points
static func quadratic_interpolate(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	return q0.linear_interpolate(q1, t)


## Returns true if v1 is similar to v2. Range is defined with 'geq' and 'leq'
static func is_vec_facing(v1: Vector3, v2: Vector3, geq: float = .5, leq: float = 1) -> bool:
	var dot := stepify(v1.dot(v2), .001)
	return dot >= geq and dot <= leq

class Physics:
	func _init() -> void:
		assert(true, "Physics class is pseudo-static and should not be instanced.")
	
	###########################################################################
	# Kinematics
	###########################################################################
	
	static func calc_projectile(t: float, y_max: float, d := 0.0, vi := Vector2.ZERO) -> Vector2:
		assert(t > 0, "t must be greater than 0")
		return Vector2(calc_projectile_vx(t, d), calc_projectile_vy(t, y_max)) + vi
	
	# Derived from delta_x = v_0 * t + .5 * a * t^2
	static func calc_projectile_g(t: float, y_max: float, vi := 0.0) -> float:
		assert(t > 0, "t must be greater than 0")
		return (-2.0 * (y_max - vi * t)) / (t * t)
		
	# Derived from delta_x = .5(v_i + v_f) * t
	static func calc_projectile_vy(t: float, d: float, vi := 0.0) -> float:
		return (2.0 * d / t) - vi
		
	# Derived from x = x_i + v_xi * 2t
	static func calc_projectile_vx(t: float, d: float, vi := 0.0) -> float:
		assert(t > 0, "t must be greater than 0")
		return d / (2.0 * t) - vi

	# Derived from v^2 = V_0^2 + 2a * delta_x
	static func calc_v_to_reach(a: float, d: float, vi := 0.0) -> float:
		return sqrt(abs(vi * vi + 2 * (a) * d))
