extends Control

func _process(delta):
    $fps.text = str(Engine.get_frames_per_second())
