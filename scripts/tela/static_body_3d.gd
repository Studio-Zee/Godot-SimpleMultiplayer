extends StaticBody3D

@export var viewport: SubViewport
@onready var shape = $CollisionShape3D.shape as BoxShape3D

@warning_ignore("unused_parameter")
func _input_event(camera, event, hit_position, normal, shape_idx):
	# Verifica se foi um clique do mouse ou toque na tela do celular
	if event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag:
		
		# 1. Converte a posição do raio 3D para o centro da nossa caixa de colisão
		var local_pos = to_local(hit_position)
		var box_size = shape.size
		var vp_size = viewport.size

		# 2. Transforma o X e Y da caixa 3D em porcentagem (0.0 até 1.0)
		var percent_x = (local_pos.x + (box_size.x / 2.0)) / box_size.x
		# No 3D o Y cresce para cima, no 2D cresce para baixo, então invertemos a conta:
		var percent_y = ((box_size.y / 2.0) - local_pos.y) / box_size.y

		# 3. Descobre o pixel exato da interface 2D
		var vp_pos = Vector2(percent_x * vp_size.x, percent_y * vp_size.y)

		# 4. Cria um "clone" do clique original e altera a posição dele para o Viewport
		var ev = event.duplicate()
		ev.position = vp_pos

		# 5. Manda a Godot apertar o botão invisível na tela 2D!
		viewport.push_input(ev)
