extends Control

var main_directory
var save_directory
var save_directory_string: String = r"D:\TestDir2"
var main_directory_string: String = ""

var local_save_path: String = r"res://pdbsave.json"

var author_dict: Dictionary = {}
var project_dict: Dictionary = {}
var tags_dict: Dictionary = {}
var tags_dict_arrayified: Dictionary = {}
var tags_bad_characters: String= r" !@#$%^&*()-+=<>?/\|{}[];':1234567890`~"
var description_dict: Dictionary = {}

#Variables for the saving and changing directory logic:
var saved_directories: Dictionary
var selected_directory_button_string: String

var active_string: String
var active_dictionary: Dictionary

var filter_search_results: Array

@onready var file_button_theme: Theme = preload("res://Themes/file_button.tres")
@onready var filter_button_theme: Theme = preload("res://Themes/new_filter_button.tres")
var file_buttons: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	saved_directories["test2"] = r"D:\TestDir2"
	saved_directories["test1"] = r"D:\TestDir1"
	load_saved_directories()
	main_directory = DirAccess.get_files_at(r"D:\TestDir1")
	save_directory = DirAccess.get_files_at(r"D:\TestDir2") 
	for file in main_directory:
		var new_button = Button.new()
		new_button.set_theme(file_button_theme)
		new_button.text = file
		new_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		new_button.toggle_mode = true
		new_button.button_down.connect(display_editor.bind(new_button.text))
		%FileListContainer.add_child(new_button)
	file_buttons = %FileListContainer.get_children()
	if save_directory:
		var author_file = FileAccess.open(save_directory_string+r"\author.json",FileAccess.READ)
		var author_json = author_file.get_as_text()
		author_dict = JSON.parse_string(author_json)
		var project_file = FileAccess.open(save_directory_string+r"\project.json",FileAccess.READ)
		var project_json = project_file.get_as_text()
		project_dict = JSON.parse_string(project_json)
		var tags_file = FileAccess.open(save_directory_string+r"\tags.json",FileAccess.READ)
		var tags_json = tags_file.get_as_text()
		tags_dict = JSON.parse_string(tags_json)
		var description_file = FileAccess.open(save_directory_string+r"\description.json",FileAccess.READ)
		var description_json = description_file.get_as_text()
		description_dict = JSON.parse_string(description_json)
	else:
		FileAccess.open(save_directory_string+r"\author.json",FileAccess.WRITE)
		FileAccess.open(save_directory_string+r"\project.json",FileAccess.WRITE)
		FileAccess.open(save_directory_string+r"\tags.json",FileAccess.WRITE)
		FileAccess.open(save_directory_string+r"\description.json",FileAccess.WRITE)
		for file in main_directory:
			author_dict[file] = ""
			project_dict[file] = ""
			tags_dict[file] = ""
			description_dict[file] = ""
		save_dictionaries_to_json()
	active_dictionary = tags_dict
	for key in active_dictionary:
		tags_dict_arrayified[key] = active_dictionary[key].split(",")
	active_dictionary = tags_dict_arrayified
	make_filter_buttons(active_dictionary)
	connect_menu_buttons_to_signals()
	print(saved_directories)

func _on_button_search_text_changed() -> void:
	for button in file_buttons:
		if %ButtonSearch.text.to_upper() in button.text.to_upper():
			button.show()
		else: button.hide()
		if %ButtonSearch.text == "":
			button.show()

func display_editor(button_text) -> void:
	active_string = button_text
	for file in file_buttons:
		if file.text != active_string:
			file.button_pressed = false
	%SaveEditContainer.visible = true
	if button_text in author_dict:
		%AuthorTextEdit.text = author_dict[button_text]
		%ProjectTextEdit.text = project_dict[button_text]
		%TagsTextEdit.text = tags_dict[button_text]
		%DescriptionTextEdit.text = description_dict[button_text]
	else:
		author_dict[button_text] = ""
		project_dict[button_text] = ""
		tags_dict[button_text] = ""
		description_dict[button_text] = ""

func update_dictionaries(key) -> void:
	author_dict[key] = %AuthorTextEdit.text
	project_dict[key] = %ProjectTextEdit.text
	tags_dict[key] = %TagsTextEdit.text
	description_dict[key] = %DescriptionTextEdit.text
	tags_dict_arrayified[key] = tags_dict[key].split(",")

func save_dictionaries_to_json() -> void:
	var author_file = FileAccess.open(r"D:\TestDir2\author.json",FileAccess.WRITE)
	var author_json = JSON.stringify(author_dict)
	author_file.store_string(author_json)
	author_file.close()
	var project_file = FileAccess.open(r"D:\TestDir2\project.json",FileAccess.WRITE)
	var project_json = JSON.stringify(project_dict)
	project_file.store_string(project_json)
	project_file.close()
	var tags_file = FileAccess.open(r"D:\TestDir2\tags.json", FileAccess.WRITE)
	var tags_json = JSON.stringify(tags_dict)
	tags_file.store_string(tags_json)
	tags_file.close()
	var description_file = FileAccess.open(r"D:\TestDir2\description.json", FileAccess.WRITE)
	var description_json = JSON.stringify(description_dict)
	description_file.store_string(description_json)
	description_file.close()

func _on_save_to_json_pressed() -> void:
	update_dictionaries(active_string)
	save_dictionaries_to_json()

func _on_filter_type_option_button_item_selected(index: int) -> void:
	if index == 0: active_dictionary = tags_dict_arrayified
	if index == 1: active_dictionary = project_dict
	if index == 2: active_dictionary = author_dict
	#print(active_dictionary)
	make_filter_buttons(active_dictionary)

func _on_filter_search_text_edit_text_changed() -> void:
	var caret_position = %FilterSearchTextEdit.get_caret_column()
	if active_dictionary == tags_dict_arrayified:
		%FilterSearchTextEdit.text = restrict_characters(%FilterSearchTextEdit,tags_bad_characters)
		%FilterSearchTextEdit.set_caret_column(caret_position)
	var array_of_tag_buttons: Array[Node] = %FilterButtonContainer.get_children()
	for button in array_of_tag_buttons:
		if %FilterSearchTextEdit.text in button.text:
			button.show()
		else:
			button.hide()
		if %FilterSearchTextEdit.text == "":
			button.show()

func restrict_characters(TextEditNode: TextEdit, RestrictedCharacters: String) -> String:
	return TextEditNode.text.rstrip(RestrictedCharacters)

func _on_tags_text_edit_text_changed() -> void:
	var caret_position = %TagsTextEdit.get_caret_column()
	%TagsTextEdit.text = restrict_characters(%TagsTextEdit, tags_bad_characters)
	%TagsTextEdit.set_caret_column(caret_position)

func make_filter_buttons(dictionary:Dictionary):
	var old_buttons = %FilterButtonContainer.get_children()
	for button in old_buttons:
		button.queue_free()
	var array_of_filters: Array
	for key in dictionary:
		var new_filter = dictionary[key]
		if new_filter in array_of_filters:
			pass
		else:
			array_of_filters.append(new_filter)
	if dictionary == tags_dict_arrayified:
		array_of_filters = make_filter_buttons_tags(array_of_filters)
	for item in array_of_filters:
		if item == "":
			array_of_filters.erase(item)
	for item in array_of_filters:
		var new_button = Button.new()
		new_button.text = item
		new_button.custom_minimum_size.x = 130
		new_button.custom_minimum_size.y = 60
		new_button.toggle_mode = true
		new_button.pressed.connect(filter_file_buttons_by_tag_buttons)
		new_button.set_theme(filter_button_theme)
		
		%FilterButtonContainer.add_child(new_button)
		
func make_filter_buttons_tags(entries:Array) -> Array:
	var output_array: Array
	for entry in entries:
		for item in entry:
			var new_item = item
			if new_item in output_array:
				pass
			else:
				output_array.append(new_item)
		if entry not in output_array:
			output_array.append(entry)
	for item in output_array:
		if item is PackedStringArray:
			output_array.erase(item)
	return output_array

func make_array_of_selected_tags() -> Array:
	var output_array = []
	var button_array = %FilterButtonContainer.get_children()
	for button in button_array:
		if button.is_pressed():
			output_array.append(button.text)
	return output_array

func filter_file_buttons_by_tag_buttons() -> void:
	var selected_tags = make_array_of_selected_tags()
	if selected_tags == []:
		for file in file_buttons:
			file.show()
	for file in file_buttons:
		for tag in selected_tags:
			if tag in active_dictionary[file.text]:
				file.show()
			else:
				file.hide()
				break
	#The idea here is to look at an array made of the selected tab_buttons.text
	#and compare that to the active dictionary for each key.  If the key has
	#every value in that array-> file_button.show() else-> file_button.hide()

func _on_new_directory_window_close_requested() -> void:
	%NewDirectoryLineEdit.text = ""
	%NewDirectoryWindow.hide()

func make_new_directory_window_visible() -> void:
	%NewDirectoryWindow.show()

func make_saved_directories_window_visible() -> void:
	%SavedDirectoriesWindow.show()

func set_selected_directory(button_text) -> void:
	var buttons_array = %NicknameButtonsVBoxContainer.get_children()
	for button in buttons_array:
		if button.text == button_text:
			continue
		else:
			button.set_pressed(false)
	selected_directory_button_string = saved_directories[button_text]
	print(selected_directory_button_string)

func populate_saved_directory_window() -> void:
	for key in saved_directories:
		var button = Button.new()
		button.text = str(key)
		button.set_theme(file_button_theme)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.toggle_mode = true
		button.button_down.connect(set_selected_directory.bind(button.text))
		var label = Label.new()
		label.text = saved_directories[key] 
		%NicknameButtonsVBoxContainer.add_child(button)
		%FilePathLabelsVBoxContainer.add_child(label)

func file_menu(id):
	match(id):
		0:
			make_new_directory_window_visible()
		1:
			make_saved_directories_window_visible()
			populate_saved_directory_window()

func connect_menu_buttons_to_signals() -> void:
	var popup = %FileButton.get_popup()
	popup.id_pressed.connect(file_menu)

func _on_new_directory_save_button_pressed() -> void:
	if %NewDirectoryLineEdit.text in saved_directories:
		%NewDirectoryErrorLabel.text = "This directory has already been saved to this program.  Try opening it from 'File > Change Directory"
		return
	update_saved_directories()

func update_saved_directories():
	var key: String
	if %NewDirectoryNicknameLineEdit.text == "":
		key = %NewDirectoryLineEdit.text
	else:
		key = %NewDirectoryNicknameLineEdit.text
	if key == "":
		%NewDirectoryErrorLabel.text = "ERROR: required fields left blank"
		return
	if key in saved_directories:
		%NewDirectoryErrorLabel.text = "ERROR: the entered nickname is not unique"
		return
	saved_directories[key] = %NewDirectoryLineEdit.text
	print(saved_directories)
	#var file = FileAccess.open(local_save_path, FileAccess.WRITE)
	#file.store_var(saved_directories)
	#file.close()
	#save_directory_string = %NewDirectoryLineEdit.text
	#DirAccess.make_dir_recursive_absolute(save_directory_string+r"\data")
	#FileAccess.open(save_directory_string+r"\data\author.json",FileAccess.WRITE)
	#FileAccess.open(save_directory_string+r"\data\project.json",FileAccess.WRITE)
	#FileAccess.open(save_directory_string+r"\data\tags.json",FileAccess.WRITE)
	#FileAccess.open(save_directory_string+r"\data\description.json",FileAccess.WRITE)

func load_saved_directories():
	# Need to reformat this for JSONs.
	pass
	#var file = FileAccess.open(local_save_path, FileAccess.READ)
	#saved_directories = file.get_var()
	#file.close()

func _on_saved_directories_window_close_requested() -> void:
	%SavedDirectoriesWindow.hide()
	selected_directory_button_string = ""
	print(selected_directory_button_string)
	var buttons = %NicknameButtonsVBoxContainer.get_children()
	for button in buttons:
		button.queue_free()
	var labels = %FilePathLabelsVBoxContainer.get_children()
	for label in labels:
		label.queue_free()


func _on_open_saved_directory_button_pressed() -> void:
	if selected_directory_button_string == "":
		print("no directory selected")
		return
	main_directory = selected_directory_button_string
	print(main_directory)
