extends Node2D

@export_group("Dialog Data")
@export var dialog_display: DialogDisplay
@export var start_wait_time: float = 2.0
@export var load_level_after: String = "res://maps/game_world.tscn"
@export var animation_player: AnimationPlayer
@export_file("*.json") var dialog_text_file
# @export_multiline var dialog_text: String = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Fusce consectetuer risus a nunc."

@onready var timer = $Timer

var dialogs_data: Array = []
var dialog_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parse_json()
	timer.wait_time = start_wait_time
	dialog_display.message_displayed.connect(next_message)
	# .message_displayed.connect(next_message)

	if animation_player == null:
		push_error("Animation player not set")

	if dialogs_data.size() > 0:
		timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func parse_json() -> void:

	var file_content = load_dialog_text()
	var json = JSON.new()
	var error = json.parse(file_content)
	var dialog_data_json : Dictionary

	if error != OK:
		push_error("Error parsing JSON")
	else:
		dialog_data_json = json.get_data()
		dialogs_data = dialog_data_json["dialogs"]


func load_dialog_text() -> String:
	var file = FileAccess.open(dialog_text_file, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return content

func next_message() -> void:
	print("Dialog Player - Next message called")
	print("Dialog Player - Dialog index: " + str(dialog_index), " dialog data size: " + str(dialogs_data.size()))
	if dialog_index < dialogs_data.size():
		dialog_display.display_next_message(dialogs_data[dialog_index])
		if dialogs_data[dialog_index].has("animation"):
			animation_player.play(dialogs_data[dialog_index]["animation"])
		dialog_index += 1
	else:
		print("No dialog data to display")
		Global.goto_scene(load_level_after)

func _on_timer_timeout() -> void:
	print("Timer timeout")
	next_message()