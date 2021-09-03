tool
extends Spatial


export(bool) var is_on = false
export(bool) var is_mirror = false

var thickness = .007
#onready var ig: ImmediateGeometry = find_node("ImmediateGeometry")


func draw_face(ig: ImmediateGeometry, top_left: Vector3, bottom_right: Vector3):
    ig.set_uv(Vector2(0, 0))
    ig.add_vertex(top_left) # top left
    ig.set_uv(Vector2(1, 0))
    ig.add_vertex(Vector3(bottom_right.x, top_left.y, top_left.z)) # top right
    ig.set_uv(Vector2(1, 1))
    ig.add_vertex(bottom_right) # bottom right
    
    ig.set_uv(Vector2(0, 0))
    ig.add_vertex(top_left) # top left
    ig.set_uv(Vector2(1, 1))
    ig.add_vertex(bottom_right) # bottom right
    ig.set_uv(Vector2(0, 1))
    ig.add_vertex(Vector3(top_left.x, bottom_right.y, bottom_right.z)) # bottom left
    

func _process(delta):
    var ig = find_node("ImmediateGeometry")
#    var ray: RayCast = find_node("RayCast")
#    var end = ray.get_collision_point()
    
    var end = Vector3.INF
    var colliding_body
    for ray in [$NRaycast, $ERaycast, $SRaycast, $WRaycast]:
        var end_point = to_local((ray as RayCast).get_collision_point())
        if end_point.z < end.z:
            end = end_point
            colliding_body = (ray as RayCast).get_collider()
    
    end.x = 0
    end.y = 0

    if end.z == INF || end.z == 0:
        end.z = 10
    
    ig.clear()
#    if end && is_on:
    if is_on:
        ig.begin(Mesh.PRIMITIVE_LINES)
        ig.set_color(Color.red)
        ig.add_vertex(Vector3.ZERO)
        ig.add_vertex(end)
        ig.end()
        
#        ig.begin(Mesh.PRIMITIVE_TRIANGLES)
#        ig.set_color(Color.red)
#        draw_face(ig, Vector3(0, thickness, 0), Vector3(end.x, 0, thickness))
#        draw_face(ig, Vector3(0, 0, thickness), Vector3(end.x, -thickness, 0))
#        draw_face(ig, Vector3(end.x, thickness, 0), Vector3(0, 0, -thickness))
#        draw_face(ig, Vector3(end.x, 0, -thickness), Vector3(0, -thickness, 0))
#        draw_face(ig, Vector3(-thickness * .5, 0, 0), Vector3(thickness * .5, 0, end.z))
#        draw_face(ig, Vector3(0, thickness, 0), Vector3(thickness, 0, end.z))
#        draw_face(ig, Vector3(thickness, 0, 0), Vector3(0, -thickness, end.z))
#        draw_face(ig, Vector3(0, thickness, end.z), Vector3(-thickness, 0, 0))
#        draw_face(ig, Vector3(-thickness, 0, end.z), Vector3(0, -thickness, 0))
#        ig.end()

        
        $OmniLight.visible = true
        $OmniLight.transform.origin = end
    else:
        $OmniLight.visible = false
