extends PanelContainer

# Paths to the levels
@export_category("Paths to levels")
@export var level_paths: Array[String] = [
	"res://maps/level_prototype.tscn",
	"res://maps/mask_test.tscn",
	"res://maps/test_scene.tscn",
	"res://maps/game_world.tscn",
]

@onready var version_label: Label = get_node("%VersionLabel")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var settings_box: VBoxContainer = get_node("MarginContainer/HBoxContainer/VBoxSettingsMenu")
@onready var credits_box: VBoxContainer = get_node("MarginContainer/HBoxContainer/VBoxCredits")
@onready var controls_setting: GridContainer = get_node("MarginContainer/HBoxContainer/VBoxSettingsMenu/ControlSettingsGrid")
@onready var controls_gamepad_setting: GridContainer = get_node("MarginContainer/HBoxContainer/VBoxSettingsMenu/ControlGamepadSettingsGrid")
@onready var particles: CPUParticles2D = get_node("CPUParticles2D")
@onready var sound_toggle: CheckButton = get_node("MarginContainer/HBoxContainer/VBoxSettingsMenu/SoundSettingsGrid/SoundsEnabledCheckButton")
@onready var debug_menu: VBoxContainer = get_node("MarginContainer/HBoxContainer/VBoxDebugMenu")

var level_selected = ""
var hide_credits = false
var hide_settings = false

var input_actions = {
	"left": " Move Left",
	"right": "Move Right",
	"jump": "Jump",
	"interact": "Interact",
	"pause_game": "Pause Game",
	"skip_dialog_text": "Skip Dialog Text"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()
	Global.map_changed.connect(_on_map_changed)
	sound_toggle.button_pressed = AudioManager.audio_enabled

	if OS.is_debug_build():
		debug_menu.visible = true
	else:
		debug_menu.visible = false

func initialize() -> void:
	hide_all_settings()
	version_label.text = "Version: " + ProjectSettings.get_setting("application/config/version")
	
	if level_paths.size() > 0:
		level_selected = level_paths[0]
	else:
		push_error("No levels found in the level_paths array")
	
	animation_player.play("logo_blood")
	create_action_list()

	particles.emitting = true

func _on_start_game_button_pressed() -> void:
	AudioManager.play_button_sound()
	Global.goto_scene("res://maps/intro_scene.tscn")


func _on_quit_button_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().quit()


func _on_item_list_item_selected(index: int) -> void:
	# Select the level based on the index
	if index < level_paths.size():
		level_selected = level_paths[index]
	else:
		push_error("Index out of bounds, index: " + str(index) + " level_paths.size(): " + str(level_paths.size()))
		level_selected = level_paths[0]

func _on_start_selected_level_button_pressed() -> void:
		AudioManager.play_button_sound()
		Global.goto_scene(level_selected)

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "logo_blood":
		animation_player.play("blood_pulse")
	
	if anim_name == "show_credits" and hide_credits:
		credits_box.hide()
	
	if anim_name == "show_settings" and hide_settings:
		settings_box.hide()

func _on_options_button_pressed() -> void:
	AudioManager.play_button_sound()
	if settings_box.is_visible():
		animation_player.play("show_settings", -1, -2.0, true)
		hide_settings = true
	else:
		hide_all_settings()
		settings_box.show()
		hide_settings = false
		animation_player.play("show_settings")


func _on_credits_button_pressed() -> void:
	AudioManager.play_button_sound()
	if credits_box.is_visible():
		animation_player.play("show_credits", -1, -4.0, true)
		hide_credits = true
		#play(name: StringName = &"", custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false)
	else:
		hide_all_settings()
		credits_box.show()
		hide_credits = false
		animation_player.play("show_credits")

func _on_sounds_enabled_check_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		AudioManager.set_sound_enabled(true)
	else:
		AudioManager.set_sound_enabled(false)

func _on_map_changed(new_map: String) -> void:
	print("Map changed signal received: " + new_map)
	# if new_map == get_tree().current_scene.scene_file_path:
	# 	print("Map changed to the main menu")
	# 	initialize()


func hide_all_settings() -> void:
	settings_box.hide()
	credits_box.hide()

func create_action_list() -> void:
	InputMap.load_from_project_settings()
	clear_action_list()

	for action in input_actions:
		var action_label: Label = Label.new()
		action_label.text = input_actions[action]
		action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var input_label: Label = Label.new()
		input_label.size_flags_horizontal = Control.SIZE_SHRINK_END & Control.SIZE_EXPAND_FILL		
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			for event in events:
				if event is InputEventKey:
					input_label.text += event.as_text().trim_suffix(" (Physical)") + " / "
			input_label.text = input_label.text.trim_suffix(" / ")
		else:
			input_label.text = "Not set"
		
		controls_setting.add_child(action_label)
		controls_setting.add_child(input_label)


	for action in input_actions:
		var action_label: Label = Label.new()
		action_label.text = input_actions[action]
		action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var input_label: Label = Label.new()
		input_label.size_flags_horizontal = Control.SIZE_SHRINK_END & Control.SIZE_EXPAND_FILL
		input_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		input_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			for event in events:
				if event is InputEventJoypadButton or event is InputEventJoypadMotion:
					input_label.text += get_short_event_name(event) + " / "
			input_label.text = input_label.text.trim_suffix(" / ")
		else:
			input_label.text = "Not set"
		
		controls_gamepad_setting.add_child(action_label)
		controls_gamepad_setting.add_child(input_label)


func get_short_event_name(event: InputEvent) -> String:
	if event is InputEventJoypadButton:
		return "Button " + str(event.button_index)
	elif event is InputEventJoypadMotion:
		return "Axis " + str(event.axis)
	return ""


func clear_action_list() -> void:
	for item in controls_setting.get_children():
		item.queue_free()
	
	for item in controls_gamepad_setting.get_children():
		item.queue_free()