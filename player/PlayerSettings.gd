tool
extends Resource
class_name PlayerSettings


export(float) var ride_height = 1.3
export(float) var crouch_ride_height = .8

export(float) var ride_spring_strength = 800
export(float) var ride_spring_damper = 100

export(float) var max_speed = 3
export(float) var max_speed_sprint = 5
export(float) var max_speed_crouch = 1.75

export(float) var acceleration = 8
export(float) var acceleration_air = .2
export(float) var acceleration_sprint = 10
export(float) var max_acceleration_force = 10
export(Curve) var acceleration_factor_from_dot = preload("DefaultAccelerationFromDotCurve.tres")

export(float) var fall_stun_height = .75
export(float) var fall_stun_length = .25

export(float) var mouse_sensitivity := .25
export(bool) var invert_mouse := false

export(float) var stick_sensitivity := 100.0
export(bool) var head_bob_enabled := true
export(float) var max_bob_height := .1
export(Curve) var bob_curve = preload("DefaultBobCurve.tres")
export(bool) var head_tilt_enabled := true

enum MOUSE_LOOK_MODE { FIXED, DELAYED }
export(MOUSE_LOOK_MODE) var mouse_look_mode = MOUSE_LOOK_MODE.DELAYED

export(Vector2) var view_box = Vector2(100, 100)
export(Vector2) var view_box_dead_zone = Vector2(.4, .4)
export(float) var view_box_sensitivity = 1.5
export(Curve) var view_box_curve = preload("DefaultViewBoxCurve.tres")
