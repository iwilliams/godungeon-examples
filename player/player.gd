extends RigidBody

export(float) var ride_height = .8
export(float) var ride_spring_strength = 300
export(float) var ride_spring_damper = 100

export(float) var max_speed = 2
export(float) var acceleration = 200
export(float) var max_accel_force = 150

var m_goal_vel = Vector3.ZERO
var speed_factor = Vector3(1, 0, 1)

export(Curve) var acceleration_factor_from_dot


func _process(delta):
    if Input.get_action_strength("look_left") > 0:
        $Yaw.rotate_y(1 * delta)

    if Input.get_action_strength("look_right") > 0:
        $Yaw.rotate_y(-1 * delta)
        
        
    var look_x = 50
    if Input.get_action_strength("look_up") > 0:
        $Yaw/Pitch.rotation_degrees.x = clamp($Yaw/Pitch.rotation_degrees.x + (look_x * delta), -90, 90)
        
    if Input.get_action_strength("look_down") > 0:
        $Yaw/Pitch.rotation_degrees.x = clamp($Yaw/Pitch.rotation_degrees.x - (look_x * delta), -90, 90)

func _integrate_forces(state: PhysicsDirectBodyState):
    var delta = state.step
    
    var collision = state.get_space_state().intersect_ray(global_transform.origin, global_transform.origin + Vector3(0, -1.5, 0), [self], collision_mask)

#    var hit = $RayCast.get_collider()
#    if hit != null:
    if not collision.empty():
        var velocity = linear_velocity
        var ray_dir = Vector3.DOWN
        
        var other_velocity = Vector3.ZERO
        
        var ray_dir_velocity = ray_dir.dot(velocity)
        var other_dir_velcoity = ray_dir.dot(other_velocity)
        
        var rel_velocity = ray_dir_velocity - other_dir_velcoity
#        var ride_hit_distance = $RayCast.global_transform.origin.distance_to($RayCast.get_collision_point()) - ride_height
        var ride_hit_distance = $RayCast.global_transform.origin.distance_to(collision.position) - ride_height
        var x = ride_hit_distance
        var spring_force = (x * ride_spring_strength) - (rel_velocity * ride_spring_damper)
        add_central_force(Vector3.DOWN * spring_force)
    
    # desired direction
    var m_unit_goal = Vector3(Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"), 0, Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down"))
    
    m_unit_goal = $Yaw.transform.basis.xform(m_unit_goal)
    
    # current direction
    var unit_vel = m_goal_vel.normalized()
    # difference between desired direction and current direction
    var vel_dot = m_unit_goal.dot(unit_vel)
    var accel = acceleration * ((acceleration_factor_from_dot as Curve).interpolate(vel_dot) + 1 / 2)
    
    var goal_vel = m_unit_goal * max_speed * speed_factor
#    print(goal_vel)
    m_goal_vel = m_goal_vel.move_toward(goal_vel, accel * delta)
#    print(m_goal_vel)
    
    var needed_accel = (m_goal_vel - (state.linear_velocity * Vector3(1, 0, 1))) / delta
    var max_accell = max_accel_force * Vector3(1, 0, 1)

    needed_accel = needed_accel.normalized() * min(needed_accel.length(), max_accell.length())
    add_central_force(needed_accel * mass)
