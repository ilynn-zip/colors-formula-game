extends Panel

signal change_color(color, item)

@onready var rng : = RandomNumberGenerator.new()

func _ready() -> void:
	self.self_modulate = get_random_color()
	%Label.text = '0'
	

func get_random_color() -> Color:
	var r : = rng.randf()
	var g : = rng.randf()
	var b : = rng.randf()
	%AudioStreamPlayer.pitch_scale = 0.6 + (r + g + b)
	return Color(r, g, b)
	
func anim_buttons(item, ispressed : bool):
	var nscale : = Vector2.ZERO
	if ispressed: 
		nscale = Vector2(0.95, 0.95)
	else : 
		nscale = Vector2(1, 1)
		
	var tween : = create_tween()
	tween.tween_property(item, "scale", nscale, 0.1).set_trans(Tween.TRANS_SINE)
	
func add_count():
	%Label.text = str(int(%Label.text) + 1)
	
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_released("tap"):
		add_count()
		change_color.emit(self.self_modulate, self)
		anim_buttons(self, false)
		%AudioStreamPlayer.play()
	if event.is_action_pressed("tap"):
		anim_buttons(self, true)
