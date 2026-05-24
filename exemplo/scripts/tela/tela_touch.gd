# [PT-BR] Converte toques e cliques sobre a tela 3D em entrada válida para um SubViewport
# [EN] Converts touches and clicks on the 3D screen into valid input for a SubViewport
extends StaticBody3D

# [PT-BR] Viewport de destino que recebe os eventos de entrada simulados
# [EN] Target viewport that receives the simulated input events
@export var viewport: SubViewport
# [PT-BR] Forma de colisão usada para calcular a posição relativa do toque na superfície
# [EN] Collision shape used to calculate the relative touch position on the surface
@onready var shape = $CollisionShape3D.shape as BoxShape3D

@warning_ignore("unused_parameter")
# [PT-BR] Recebe eventos de interação sobre o corpo estático e os encaminha para o viewport
# [EN] Receives interaction events on the static body and forwards them to the viewport
func _on_input_event(camera: Node, event: InputEvent, hit_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		# [PT-BR] Calcula a posição local exata do ponto tocado dentro da caixa de colisão
		# [EN] Calculates the exact local position of the touched point inside the collision box
		var local_pos = $CollisionShape3D.to_local(hit_position)
		
		# [PT-BR] Obtém o tamanho da caixa física e a resolução do viewport de destino
		# [EN] Reads the physics box size and the target viewport resolution
		var box_size = shape.size
		var vp_size = viewport.size

		# [PT-BR] Mantém o eixo X invertido para compensar o espelhamento da superfície
		# [EN] Keeps the X axis inverted to compensate for the surface mirroring
		var percent_x = 1.0 - ((local_pos.x + (box_size.x / 2.0)) / box_size.x)
		# [PT-BR] Normaliza o eixo Y para mapear corretamente a coordenada visual
		# [EN] Normalizes the Y axis to map the visual coordinate correctly
		var percent_y = ((box_size.y / 2.0) - local_pos.y) / box_size.y

		# [PT-BR] Converte a posição proporcional para coordenadas de pixels do viewport
		# [EN] Converts the proportional position into viewport pixel coordinates
		var vp_pos = Vector2(round(percent_x * vp_size.x), round(percent_y * vp_size.y))

		# [PT-BR] Duplica o evento para evitar mutar o objeto original recebido pela engine
		# [EN] Duplicates the event to avoid mutating the original object received from the engine
		var ev = event.duplicate()
		ev.position = vp_pos
		
		if ev is InputEventMouseButton:
			ev.global_position = vp_pos

		# [PT-BR] Envia o evento já adaptado para a interface renderizada no viewport
		# [EN] Sends the adapted event to the interface rendered inside the viewport
		viewport.push_input(ev)
		
# [PT-BR] Encaminha teclas digitadas para o viewport e evita que a cena principal processe o mesmo evento duas vezes
# [EN] Forwards typed keys to the viewport and prevents the main scene from processing the same event twice
func _input(event):
	if event is InputEventKey:
		viewport.push_input(event)
		# [PT-BR] Marca o evento como tratado para impedir duplicação de processamento pela árvore principal
		# [EN] Marks the event as handled to prevent duplicate processing by the main tree
		get_viewport().set_input_as_handled()
