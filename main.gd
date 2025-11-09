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
	
	print("开始创建卡牌UI，卡牌数量: ", card_data.size())
	print("卡牌容器: ", card_container.name, " 子节点数: ", card_container.get_child_count())
	
	# 设置容器间距
	if card_container.has_method("add_theme_constant_override"):
		card_container.add_theme_constant_override("separation", 20)  # 卡牌间距20像素
	
	# 计算最佳卡牌尺寸以适应窗口
	var scroll_container = get_node("CardScrollContainer")
	var available_width = scroll_container.size.x - 40  # 留出一些边距
	var max_card_width = available_width / card_data.size()
	var target_card_width = min(max_card_width, 160)  # 使用计算值或默认值中的较小者
	
	print("可用宽度: ", available_width, " 最大卡牌宽度: ", max_card_width, " 目标宽度: ", target_card_width)
	
	# 为每张领袖卡创建UI
	for current_card_info in card_data:
		var card_node = create_card_ui(current_card_info, target_card_width)
		if card_node:
			card_container.add_child(card_node)
			card_nodes.append(card_node)
			print("创建卡牌: ", current_card_info.cardName)
	
	print("卡牌创建完成，总卡牌数: ", card_nodes.size())

# 创建单个卡牌UI
func create_card_ui(card_info, card_width = 160):
	# 创建卡牌面板 - 4:5 比例 (宽4高5)
	var card_panel = Panel.new()
	var card_height = card_width * 5.0 / 4.0  # 保持4:5比例
	card_panel.custom_minimum_size = Vector2(card_width, card_height)
	card_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	card_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# 确保卡牌可见
	card_panel.visible = true
	
	print("创建卡牌面板: ", card_info.cardName, " 大小: ", card_panel.custom_minimum_size)
	
	# 应用样式
	if ResourceLoader.exists("res://card_style.tres"):
		var style = load("res://card_style.tres")
		card_panel.add_theme_stylebox_override("panel", style)
	else:
		# 如果没有样式文件，创建默认样式
		var default_style = StyleBoxFlat.new()
		default_style.bg_color = Color(0.2, 0.3, 0.5, 0.8)
		default_style.border_color = Color(0.8, 0.8, 0.9, 1)
		default_style.border_width_top = 2
		default_style.border_width_bottom = 2
		default_style.border_width_left = 2
		default_style.border_width_right = 2
		card_panel.add_theme_stylebox_override("panel", default_style)
	
	# 创建卡牌内容标签
	var card_label = Label.new()
	card_label.name = "CardLabel"
	card_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_label.offset_left = 15
	card_label.offset_top = 15
	card_label.offset_right = -15
	card_label.offset_bottom = -15
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
