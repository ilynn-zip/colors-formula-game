extends TextureRect

#@onready var pressed : bool = false

func anim(pressed : bool):
	var rot : float = 0
	if pressed:
		rot = 540
	var tween : = create_tween()
	tween.tween_property(self.get_child(0), "rotation_degrees", rot, 0.3).set_trans(Tween.TRANS_SINE)
