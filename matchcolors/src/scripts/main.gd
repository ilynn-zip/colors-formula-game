extends Control

signal match_color(percent : float, color1 : Color, color2 : Color)

const SINGLE_COLOR : = preload("res://src/scenes/single_color.tscn")
const Mixbox = preload("res://src/addons/mixbox/mixbox.gd")

@onready var palette : = %ColorsHBoxContainer
@onready var orgn : = %OrgnColorPanel.get_child(0)
@onready var color_pick : = %ColorPanel.get_child(0)
@onready var first_color : bool = true
@onready var rng : = RandomNumberGenerator.new()
@onready var color_undo : Array[Color] = []
@onready var cur_color : Color
@onready var palette_undo : Array[Control] = []
@onready var hint : bool = false

func _ready() -> void:
	set_palette()
	cur_color = color_pick.modulate
	
func reload_colors():
	#for p in palette.get_children():
	#	p.queue_free()
	set_palette_colors()
	orgn.modulate = set_orgn_color()
	reset_colors()

func set_palette():
	var count : int = 5
	for c in count:
		var color_instance : = SINGLE_COLOR.instantiate()
		color_instance.connect("change_color", _on_change_color_signal)
		palette.add_child(color_instance)

func set_palette_colors():
	for p in palette.get_children():
		p._ready()
		p.get_child(1).visible = hint
		
func set_orgn_color() -> Color:
	var count : int = randi_range(3, 12)
	var orgn_color : Color = Color.WHITE
	
	var color_array : Array[Color] = []
	var colors : = palette.get_children()
	var color_count : = palette.get_child_count()
	print(color_count)
	for c in count:
		var pos : = rng.randi_range(0, color_count - 1)
		color_array.append(colors[pos].self_modulate)
		#print(pos)
	
	var first : bool = true
	for ca in color_array:
		if first:
			first = false
			orgn_color = ca
		else:
			orgn_color = mix_color(orgn_color, ca)
	
	orgn.get_parent().get_child(2).text = str(count)
	return orgn_color

func mix_color(color1 : Color, color2 : Color, t : float = 0.5 ) -> Color:
	return Mixbox.lerp(color1, color2, t)

func change_color(color):
	color_pick.get_parent().get_child(2).text = str(int(color_pick.get_parent().get_child(2).text) + 1)
	if first_color:
		cur_color = color
		first_color = false
	else:
		cur_color = mix_color(cur_color, color)

	anim_color_change()

func update_color_undo(item):
	%undo_button.modulate = cur_color
	color_undo.append(cur_color)
	palette_undo.append(item)

func _on_change_color_signal(color, item):
	update_color_undo(item)
	change_color(color)

func get_undo():
	if color_undo.is_empty():
		#print('there\'s nothing to undo')
		pass
	else:
		cur_color = color_undo.pop_back()
		var item : Control = palette_undo.pop_back()
		var text : String = color_pick.get_parent().get_child(2).text
		item.get_child(1).text = str(int(item.get_child(1).text) - 1)
		
		if text != '0':
			color_pick.get_parent().get_child(2).text = str(int(text) - 1)
		anim_color_change()
		#color_pick.modulate = cur_color
		if not color_undo.is_empty():
			%undo_button.modulate = color_undo.back()
		else:
			first_color = true

		
func get_match() -> float:
	var orgnc : Color = orgn.modulate
	var color : Color = cur_color
	
	var r : float = absf(orgnc.r - color.r)
	var g : float = absf(orgnc.g - color.g)
	var b : float = absf(orgnc.b - color.b)
	#var a : float = absf(orgnc.a - color.a)
	
	var res : float = (3.0 - (r + g + b)) / 3 * 100
	
	res = (1.0 - color_distance_rgb(orgnc, cur_color)) * 100
	print(res)
	return res
	
func color_distance_rgb(a: Color, b: Color) -> float:
	var PERCEPTUAL_RGB_WEIGHTS := Vector3(0.774529, 1.520822, 0.295305)
	return (Vector3(a.r, a.g, a.b) * PERCEPTUAL_RGB_WEIGHTS) \
			.distance_to(Vector3(b.r, b.g, b.b) * PERCEPTUAL_RGB_WEIGHTS)
	
func reset_colors():
	cur_color = Color.WHITE
	color_pick.modulate = cur_color
	first_color = true
	color_undo.clear()
	palette_undo.clear()
	%undo_button.modulate = cur_color
	color_pick.get_parent().get_child(2).text = '0'
	for p in palette.get_children():
		p.get_child(1).text = '0'
	

func anim_color_change():
	var tween : = create_tween()
	tween.tween_property(color_pick, "modulate", cur_color, 0.1).set_trans(Tween.TRANS_SINE)
	
func anim_buttons(item, ispressed : bool, small : Vector2 = Vector2.ZERO):
	var nscale : = Vector2(0.7, 0.7) - small
	if not ispressed: 
		nscale = Vector2(0.75, 0.75) - small
		
	var tween : = create_tween()
	tween.tween_property(item, "scale", nscale, 0.1).set_trans(Tween.TRANS_SINE)

func show_hint(showing : bool):
	orgn.get_parent().get_child(2).visible = showing
	color_pick.get_parent().get_child(2).visible = showing
	for p in palette.get_children():
		p.get_child(1).visible = showing

func _on_undo_button_gui_input(event: InputEvent) -> void:
	if event.is_action_released("tap"):
		get_undo()
		anim_buttons(%undo_button, false)
		%undo_audio.play()
	if event.is_action_pressed("tap"):
		anim_buttons(%undo_button, true)

func _on_match_button_gui_input(event: InputEvent) -> void:
	if event.is_action_released("tap"):
		match_color.emit(get_match(), orgn.modulate, color_pick.modulate)
		anim_buttons(%match_button, false)
		%match_audio.play()
	if event.is_action_pressed("tap"):
		anim_buttons(%match_button, true)

func _on_clear_button_gui_input(event: InputEvent) -> void:
	if event.is_action_released("tap"):
		reset_colors()
		anim_buttons(%clear_button, false)
		%clear_audio.play()
	if event.is_action_pressed("tap"):
		anim_buttons(%clear_button, true)
		
func _on_hint_botton_gui_input(event: InputEvent) -> void:
	if event.is_action_released("tap"):
		hint = !hint
		show_hint(hint)
		anim_buttons(%hint_button, false)
		if hint:
			anim_buttons(%hint_button, true)
		
	if event.is_action_pressed("tap"):
		#if hint:
		#	anim_buttons(%hint_button, true, Vector2(0.05, 0.05))
		#else:
		anim_buttons(%hint_button, true)
		%hint_audio.play()
