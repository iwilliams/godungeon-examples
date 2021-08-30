extends RigidBody

var m_goal_vel = Vector3.ZERO
var speed_factor = Vector3(1, 0, 1)

export(Resource) var settings
export(bool) var movement_locked = false

export(float) var max_bob_height = .25
export(Curve) var bob_curve
export(float, 0, 1) var bob_offset = 0
export var stick_sens := 100.0

var is_on_floor = false
var fall_start = 0
var fall_stunned = false

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _integrate_forces(state: PhysicsDirectBodyState):
    var delta = state.step
    
    var collision = state.get_space_state().intersect_ray(global_transform.origin, global_transform.origin + Vector3(0, -1.5, 0), [self], collision_mask)
    
    var was_on_floor = is_on_floor
    is_on_floor = not collision.empty()
    if is_on_floor:
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
    
    if not is_on_floor and was_on_floor:
        fall_start = global_transform.origin.y    
    
    
    # desired direction
    var m_unit_goal = Vector3(Input.get_action_strength("move_left") - Input.get_action_strength("move_right"), 0, Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
    m_unit_goal = m_unit_goal.normalized()
    m_unit_goal = $Yaw.transform.basis.xform(m_unit_goal)
    
    if movement_locked or fall_stunned:
        m_unit_goal = Vector3(0, 0, 0)
    
    # current direction
    var unit_vel = m_goal_vel.normalized()
    # difference between desired direction and current direction
    var vel_dot = m_unit_goal.dot(unit_vel)
    
    var acceleration = settings.acceleration
    
    # Air acceleration
    if not is_on_floor:
        acceleration = settings.acceleration_air
    
    var max_speed = settings.max_speed
    
    if Input.is_action_pressed("crouch"):
        max_speed = settings.max_speed_crouch
    elif Input.is_action_pressed("sprint"):
        acceleration = settings.acceleration_sprint
        max_speed = settings.max_speed_sprint
        
    var accel = acceleration * ((settings.acceleration_factor_from_dot as Curve).interpolate(vel_dot) + 1 / 2)
    var goal_vel = m_unit_goal * max_speed * speed_factor

    m_goal_vel = m_goal_vel.move_toward(goal_vel, accel * delta)
    
    var needed_accel = (m_goal_vel - (state.linear_velocity * Vector3(1, 0, 1))) / delta
    var max_accell = settings.max_acceleration_force * Vector3(1, 0, 1)

    needed_accel = needed_accel.normalized() * min(needed_accel.length(), max_accell.length())
    add_central_force(needed_accel * mass)
    
    # Head bob
    var h_linear_velocity = (linear_velocity.abs() * Vector3(1, 0, 1)).length()
    if h_linear_velocity and is_on_floor and m_unit_goal.abs().length():
        var base_timescale = 1.6
        $Yaw/AnimationTree["parameters/TimeScale/scale"] = range_lerp(
            h_linear_velocity, 
            settings.max_speed, 
            settings.max_speed_sprint, 
            base_timescale, 
            base_timescale * (settings.max_speed_sprint/settings.max_speed)
        )

        $Yaw/AnimationTree.advance(delta)
        $Yaw.transform.origin.y = 0.147 + (bob_curve.interpolate(bob_offset) * max_bob_height)
        
    # View tilt
    var velocity_relative_to_look_direction = $Yaw.transform.basis.xform_inv(linear_velocity)
    var tilt_vector = Vector3(velocity_relative_to_look_direction.z * .5, 0, velocity_relative_to_look_direction.x * -.75)
    if not is_on_floor:
        tilt_vector.x += velocity_relative_to_look_direction.y * -4
    $Yaw/Pitch/Tilt.rotation_degrees = $Yaw/Pitch/Tilt.rotation_degrees.move_toward(tilt_vector, delta * 40)
    
    # Splash
    if not was_on_floor and is_on_floor:
        var fall_delta = fall_start - global_transform.origin.y
        if fall_delta > settings.fall_stun_height:
            if settings.fall_stun_length:
                fall_stunned = true
                $FallStun.start(settings.fall_stun_length)
                var _signal_connection = $FallStun.connect("timeout", self, "set", ["fall_stunned", false], CONNECT_ONESHOT)
            $AudioStreamPlayer.play()
        
    # Non mouse look
    if not movement_locked and (Input.is_action_pressed("look_left") or Input.is_action_pressed("look_right")):
        $Yaw.rotation_degrees.y += (Input.get_action_strength("look_left") - Input.get_action_strength("look_right")) * stick_sens * delta
    
    if not movement_locked and (Input.is_action_pressed("look_up") or Input.is_action_pressed("look_down")):
        var x_delta = (Input.get_action_strength("look_up") - Input.get_action_strength("look_down")) * stick_sens * delta * -1
        if not settings.invert_mouse:
            x_delta *= -1
        $Yaw/Pitch.rotation_degrees.x -= x_delta
        $Yaw/Pitch.rotation_degrees.x = clamp($Yaw/Pitch.rotation_degrees.x, -90, 90)


func _input(event):
    if not movement_locked and event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        $Yaw.rotation_degrees.y -= settings.mouse_sensitivity * event.relative.x
        var x_delta = settings.mouse_sensitivity * event.relative.y
        if not settings.invert_mouse:
            x_delta *= -1
        $Yaw/Pitch.rotation_degrees.x -= x_delta
        $Yaw/Pitch.rotation_degrees.x = clamp($Yaw/Pitch.rotation_degrees.x, -90, 90)
        

