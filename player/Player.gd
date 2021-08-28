extends RigidBody

var m_goal_vel = Vector3.ZERO
var speed_factor = Vector3(1, 0, 1)

export(Resource) var settings


func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _integrate_forces(state: PhysicsDirectBodyState):
    var delta = state.step
    
    var collision = state.get_space_state().intersect_ray(global_transform.origin, global_transform.origin + Vector3(0, -1.5, 0), [self], collision_mask)

    if not collision.empty():
        var velocity = linear_velocity
        var ray_dir = Vector3.DOWN
        
        var other_velocity = Vector3.ZERO
        
        var ray_dir_velocity = ray_dir.dot(velocity)
        var other_dir_velcoity = ray_dir.dot(other_velocity)
        
        var rel_velocity = ray_dir_velocity - other_dir_velcoity

        var ride_height = settings.ride_height if not Input.is_action_pressed("crouch") else settings.crouch_ride_height

        var ride_hit_distance = global_transform.origin.distance_to(collision.position) - ride_height
        var x = ride_hit_distance
        var spring_force = (x * settings.ride_spring_strength) - (rel_velocity * settings.ride_spring_damper)
        add_central_force(Vector3.DOWN * spring_force)
    
    # desired direction
    var m_unit_goal = Vector3(Input.get_action_strength("move_left") - Input.get_action_strength("move_right"), 0, Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
    m_unit_goal = m_unit_goal.normalized()
    m_unit_goal = $Yaw.transform.basis.xform(m_unit_goal)
    
    # current direction
    var unit_vel = m_goal_vel.normalized()
    # difference between desired direction and current direction
    var vel_dot = m_unit_goal.dot(unit_vel)
    var accel = settings.acceleration * ((settings.acceleration_factor_from_dot as Curve).interpolate(vel_dot) + 1 / 2)
    
    var max_speed = settings.max_speed if not Input.is_action_pressed("crouch") else settings.crouch_max_speed
    var goal_vel = m_unit_goal * max_speed * speed_factor
    m_goal_vel = m_goal_vel.move_toward(goal_vel, accel * delta)
    
    var needed_accel = (m_goal_vel - (state.linear_velocity * Vector3(1, 0, 1))) / delta
    var max_accell = settings.max_acceleration_force * Vector3(1, 0, 1)

    needed_accel = needed_accel.normalized() * min(needed_accel.length(), max_accell.length())
    add_central_force(needed_accel * mass)


func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        $Yaw.rotation_degrees.y -= settings.mouse_sensitivity * event.relative.x
        var x_delta = settings.mouse_sensitivity * event.relative.y
        if !settings.invert_mouse:
            x_delta *= -1
        $Yaw/Pitch.rotation_degrees.x -= x_delta
        $Yaw/Pitch.rotation_degrees.x = clamp($Yaw/Pitch.rotation_degrees.x, -90, 90)
