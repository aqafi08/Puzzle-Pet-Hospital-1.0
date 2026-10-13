extends Control

const SAVE_PATH := "user://puzzle_pet_save.json"
const BG := Color("eaf7ff")
const NAVY := Color("28465c")
const PINK := Color("ffb8ca")
const MINT := Color("b8f0d5")
const YELLOW := Color("ffe38a")
const LAVENDER := Color("d8c8ff")

var coins: int = 0
var stars: int = 0
var treated: int = 0
var current_pet := "🐱"
var current_pet_name := "Mimi the Cat"
var current_problem := "A little paw needs care!"
var page := "home"
var puzzle_answer := -1
var puzzle_correct := 1
var puzzle_feedback := "Choose the matching shape to help your pet!"
var pets := [
	{"emoji":"🐱", "name":"Mimi the Cat", "problem":"Mimi has a sore paw!", "color":Color("ffd0de")},
	{"emoji":"🐶", "name":"Buddy the Dog", "problem":"Buddy needs a little check-up!", "color":Color("c6e8ff")},
	{"emoji":"🐰", "name":"Coco the Bunny", "problem":"Coco feels a little tired!", "color":Color("e4d8ff")}
]

func _ready() -> void:
	load_game()
	show_home()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

func clear_ui() -> void:
	for child in get_children():
		child.queue_free()

func make_root() -> VBoxContainer:
	clear_ui()
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 16)
	root.add_theme_constant_override("margin_left", 26)
	root.add_theme_constant_override("margin_right", 26)
	root.add_theme_constant_override("margin_top", 30)
	root.add_theme_constant_override("margin_bottom", 26)
	add_child(root)
	return root

func label(text: String, size: int, color: Color = NAVY, centered: bool = true) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func button(text: String, color: Color, callback: Callable, min_h: int = 78) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, min_h)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 25)
	b.add_theme_color_override("font_color", NAVY)
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 24
	normal.corner_radius_top_right = 24
	normal.corner_radius_bottom_left = 24
	normal.corner_radius_bottom_right = 24
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	b.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = color.darkened(0.06)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.pressed.connect(callback)
	return b

func header(root: VBoxContainer, title: String) -> void:
	var top := HBoxContainer.new()
	var title_label := label(title, 32, NAVY, false)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title_label)
	top.add_child(label("🪙 %d   ⭐ %d" % [coins, stars], 20))
	root.add_child(top)

func show_home() -> void:
	page = "home"
	var root := make_root()
	header(root, "Puzzle Pet Hospital")
	root.add_child(label("🏥", 88))
	root.add_child(label("Little paws, big care!", 30))
	root.add_child(label("Help adorable pets feel better with fun little puzzles.", 21))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)
	root.add_child(button("🩺  Help a Pet!", MINT, show_pet_select, 90))
	root.add_child(button("🌼  My Hospital Garden", YELLOW, show_rewards, 78))
	root.add_child(button("👨‍👩‍👧  Grown-up Info", LAVENDER, show_parent, 68))
	root.add_child(label("Made for little helpers • Play offline", 16, Color("668094")))

func show_pet_select() -> void:
	page = "pets"
	var root := make_root()
	header(root, "Choose a Patient")
	root.add_child(label("Who needs your kind care today?", 24))
	for p in pets:
		var pet_data: Dictionary = p
		var card := button("%s\n%s\n%s" % [p.emoji, p.name, p.problem], p.color, func(): choose_pet(pet_data), 170)
		card.add_theme_font_size_override("font_size", 24)
		root.add_child(card)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)
	root.add_child(button("⬅ Back", Color("dceaf3"), show_home, 60))

func choose_pet(p: Dictionary) -> void:
	current_pet = p.emoji
	current_pet_name = p.name
	current_problem = p.problem
	puzzle_answer = -1
	puzzle_feedback = "Tap the shape that matches the paw badge!"
	show_treatment()

func show_treatment() -> void:
	page = "treatment"
	var root := make_root()
	header(root, "Time to Help!")
	root.add_child(label(current_pet, 90))
	root.add_child(label(current_pet_name, 28))
	root.add_child(label(current_problem, 22))
	root.add_child(label("Find the matching shape:", 24))
	var target := PanelContainer.new()
	target.custom_minimum_size = Vector2(0, 110)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("fff4c9")
	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_left = 28
	style.corner_radius_bottom_right = 28
	target.add_theme_stylebox_override("panel", style)
	target.add_child(label("🐾     ●", 44))
	root.add_child(target)
	var choices := GridContainer.new()
	choices.columns = 2
	choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choices.size_flags_vertical = Control.SIZE_EXPAND_FILL
	choices.add_theme_constant_override("h_separation", 14)
	choices.add_theme_constant_override("v_separation", 14)
	var options := ["●", "▲", "■", "♥"]
	for i in range(options.size()):
		var c := button(options[i], [PINK, MINT, YELLOW, LAVENDER][i], func(): answer_puzzle(i), 125)
		c.add_theme_font_size_override("font_size", 52)
		choices.add_child(c)
	root.add_child(choices)
	root.add_child(label(puzzle_feedback, 20))
	root.add_child(button("💡 Hint", Color("dceaf3"), func(): hint_puzzle(), 58))
	root.add_child(button("⬅ Choose another pet", Color("dceaf3"), show_pet_select, 58))

func answer_puzzle(choice: int) -> void:
	if choice == 0:
		puzzle_answer = choice
		coins += 10
		stars += 1
		treated += 1
		save_game()
		show_success()
	else:
		puzzle_feedback = "Almost! Try again. You can do it! 💛"
		show_treatment()

func hint_puzzle() -> void:
	puzzle_feedback = "Hint: look for the round circle! ●"
	show_treatment()

func show_success() -> void:
	page = "success"
	var root := make_root()
	header(root, "Wonderful Work!")
	root.add_child(label("✨   💖   ✨", 46))
	root.add_child(label(current_pet, 100))
	root.add_child(label("Feeling better!", 34))
	root.add_child(label("You helped %s feel happy." % current_pet_name, 22))
	root.add_child(label("+10 coins     +1 star", 27, Color("b47a12")))
	root.add_child(label("Kindness makes every pet stronger!", 20))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)
	root.add_child(button("🐾 Help Another Pet", MINT, show_pet_select, 86))
	root.add_child(button("🌷 Visit My Garden", YELLOW, show_rewards, 76))
	root.add_child(button("🏠 Home", LAVENDER, show_home, 68))

func show_rewards() -> void:
	page = "garden"
	var root := make_root()
	header(root, "My Hospital Garden")
	root.add_child(label("🌷  🌼  🌻", 68))
	root.add_child(label("A happy place for recovering pets", 24))
	root.add_child(label("Pets helped: %d" % treated, 28))
	root.add_child(label("Coins collected: %d" % coins, 25))
	root.add_child(label("Stars earned: %d" % stars, 25))
	root.add_child(label("Keep helping pets to fill your garden with joy!", 21))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)
	root.add_child(button("🩺 Help another pet", MINT, show_pet_select, 82))
	root.add_child(button("⬅ Home", Color("dceaf3"), show_home, 64))

func show_parent() -> void:
	page = "parent"
	var root := make_root()
	header(root, "Grown-up Info")
	root.add_child(label("💗", 60))
	root.add_child(label("A gentle game about kindness and problem-solving.", 24))
	root.add_child(label("• No chat or social features\n• No purchases in Phase 1\n• No ads in Phase 1\n• Core gameplay works offline\n• Progress is saved on this device", 21, NAVY, false))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)
	root.add_child(button("⬅ Home", Color("dceaf3"), show_home, 68))

func save_game() -> void:
	var data := {"coins": coins, "stars": stars, "treated": treated}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		coins = int(parsed.get("coins", 0))
		stars = int(parsed.get("stars", 0))
		treated = int(parsed.get("treated", 0))
