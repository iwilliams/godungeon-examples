tool
extends Resource
class_name PlayerSettings

export(float) var ride_height = 1.3
export(float) var crouch_ride_height = .8

export(float) var ride_spring_strength = 800
export(float) var ride_spring_damper = 100

export(float) var max_speed = 4
export(float) var crouch_max_speed = 1.75
export(float) var acceleration = 8
export(float) var max_acceleration_force = 150
export(Curve) var acceleration_factor_from_dot

export(float) var mouse_sensitivity := .25
export(bool) var invert_mouse := false
