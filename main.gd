extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	print("帝国：博弈 - 卡牌游戏界面已加载")
	
	# 连接卡牌的点击信号（如果需要交互）
	var card1 = $CardContainer/Card1
	var card2 = $CardContainer/Card2
	var card3 = $CardContainer/Card3
	
	# 为卡牌添加简单的交互效果
	card1.gui_input.connect(_on_card_gui_input.bind("维多利亚女王"))
	card2.gui_input.connect(_on_card_gui_input.bind("俾斯麦"))
	card3.gui_input.connect(_on_card_gui_input.bind("谷物法废除"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# 卡牌交互处理函数
func _on_card_gui_input(event, card_name):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("选择了卡牌: ", card_name)
		# 在这里可以添加卡牌使用逻辑
