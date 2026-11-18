extends SpotLight3D

@export var spot_light_3d: SpotLight3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("light"):
		if spot_light_3d.visible == true:
			spot_light_3d.visible = false
		else:
			spot_light_3d.visible = true
