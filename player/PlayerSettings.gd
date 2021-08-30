tool
extends Resource
class_name PlayerSettings

export(float) var ride_height = 1.3
export(float) var crouch_ride_height = .8

export(float) var ride_spring_strength = 800
export(float) var ride_spring_damper = 100

export(float) var max_speed = 4
export(float) var max_speed_sprint = 6
export(float) var max_speed_crouch = 1.75

export(float) var acceleration = 8
export(float) var acceleration_air = .2
export(float) var acceleration_sprint = 10
export(float) var max_acceleration_force = 10
export(Curve) var acceleration_factor_from_dot

export(float) var fall_stun_height = .75
export(float) var fall_stun_length = .25

export(float) var mouse_sensitivity := .25
export(bool) var invert_mouse := false

export(bool) var head_bob_enabled := true
