extends Camera2D

func _ready():
	self.limit_left = $Node/TopLeft.global_position.x
	self.limit_top = $Node/TopLeft.global_position.y + 80
	self.limit_right = $Node/BottomRight.global_position.x
	self.limit_bottom = $Node/BottomRight.global_position.y + 80
