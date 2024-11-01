extends ColorRect

@onready var first : bool = true

func _ready() -> void:
	self.visible = true
	%ProgressBar.visible = false
	%Label.visible = false
	
func anim_prgress(percent : float):
	var tween : = create_tween()
	tween.tween_property(%ProgressBar, "value", percent, 0.7).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func anim_screen(isvisble):
	var alpha : float
	if isvisble:
		alpha = 1
	else:
		alpha = 0
		
	var ncolor : Color = self.modulate
	ncolor.a = alpha
	var tween : = create_tween()
	tween.tween_property(self, "modulate", ncolor, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	self.visible = isvisble
	%ProgressBar.value = 0.0

func update_screen(percent: float, color1: Color, color2: Color):
	anim_prgress(percent)
	%orgncolor.modulate = color1
	%colorpick.modulate = color2
	
func anim_buttons(ispressed : bool):
	var nscale : = Vector2(0.95, 0.95)
	if not ispressed: 
		nscale = Vector2(1.0, 1.0)
		
	var tween : = create_tween()
	tween.tween_property(%Button, "scale", nscale, 0.1).set_trans(Tween.TRANS_SINE)
		

func answ_colors():
	pass

func _on_mainscene_match_color(percent: float, color1: Color, color2: Color) -> void:
	%NameLabel.visible = false
	%ProgressBar.visible = true
	%Label.visible = true
	self.visible = true
	anim_screen(true)
	update_screen(percent, color1, color2)
	

func _on_button_button_down() -> void:
	anim_buttons(true)

func _on_button_button_up() -> void:
	anim_buttons(false)
	anim_screen(false)
	get_parent().reload_colors()
	%AudioStreamPlayer.play()
