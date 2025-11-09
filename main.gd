extends Node2D

# 卡牌数据
var card_data = []
var card_nodes = []

# 节点引用
@onready var card_container = $CardScrollContainer/CardContainer
@onready var card_info_label = $CardInfo

# Called when the node enters the scene tree for the first time.
func _ready():
	print("帝国：博弈 - 卡牌游戏界面已加载")
	
	# 加载卡牌数据
	load_card_data()
	
	# 创建所有领袖卡
	create_leader_cards()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# 加载卡牌数据
func load_card_data():
	var file = FileAccess.open("res://Data/cards.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		
		if parse_result == OK:
			card_data = json.data
			print("成功加载卡牌数据，共找到 ", card_data.size(), " 张卡牌")
		else:
			print("解析JSON失败: ", json.get_error_message())
	else:
		print("无法打开卡牌数据文件")

# 创建所有领袖卡
func create_leader_cards():
	# 清除现有卡牌
	for child in card_container.get_children():
		child.queue_free()
	
	card_nodes.clear()
	
	# 为每张领袖卡创建UI
	for current_card_info in card_data:
		var card_node = create_card_ui(current_card_info)
		if card_node:
			card_container.add_child(card_node)
			card_nodes.append(card_node)

# 创建单个卡牌UI
func create_card_ui(card_info):
	# 创建卡牌面板
	var card_panel = Panel.new()
	card_panel.custom_minimum_size = Vector2(200, 300)
	card_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	card_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# 应用样式
	if ResourceLoader.exists("res://card_style.tres"):
		var style = load("res://card_style.tres")
		card_panel.add_theme_stylebox_override("panel", style)
	
	# 创建卡牌内容标签
	var card_label = Label.new()
	card_label.name = "CardLabel"
	# 设置布局模式为锚点模式
	card_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_label.anchors_preset = Control.PRESET_FULL_RECT
	card_label.offset_left = 10
	card_label.offset_top = 10
	card_label.offset_right = -10
	card_label.offset_bottom = -10
	card_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	card_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	# 构建卡牌文本
	var card_text = card_info.cardName + "\n"
	card_text += "影响力: " + str(card_info.influence) + "\n"
	card_text += "时代: " + str(card_info.era) + "\n\n"
	
	if card_info.skills and card_info.skills.size() > 0:
		card_text += "技能: " + card_info.skills[0].name + "\n"
		card_text += card_info.skills[0].description
	
	card_label.text = card_text
	card_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_label.add_theme_font_size_override("font_size", 14)
	
	# 添加到卡牌面板
	card_panel.add_child(card_label)
	
	# 添加交互
	card_panel.gui_input.connect(_on_card_gui_input.bind(card_info))
	card_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 添加悬停效果
	card_panel.mouse_entered.connect(_on_card_mouse_entered.bind(card_info))
	card_panel.mouse_exited.connect(_on_card_mouse_exited.bind(card_info))
	
	return card_panel

# 卡牌交互处理函数
func _on_card_gui_input(event, card_info):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("选择了卡牌: ", card_info.cardName)
		update_card_info(card_info)

# 鼠标悬停效果
func _on_card_mouse_entered(card_info):
	update_card_info(card_info)

func _on_card_mouse_exited(card_info):
	card_info_label.text = "点击卡牌查看详细信息"

# 更新卡牌信息显示
func update_card_info(card_info):
	var info_text = "【" + card_info.cardName + "】\n"
	info_text += "影响力: " + str(card_info.influence) + "  |  时代: " + str(card_info.era) + "\n"
	
	if card_info.skills and card_info.skills.size() > 0:
		info_text += "技能: " + card_info.skills[0].name + "\n"
		info_text += card_info.skills[0].description
	
	card_info_label.text = info_text
