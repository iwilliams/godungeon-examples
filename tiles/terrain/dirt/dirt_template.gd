tool
extends "res://addons/godungeon/GodungeonSpatialTileTemplate.gd"

func get_collision(am: AdjacencyMap) -> Array:
    return [
        [$CollisionShape, $CollisionShape.transform]
    ]


func get_meshes(am: AdjacencyMap):
    return [
        [$MeshInstance.mesh, $MeshInstance.transform],
        [$ceiling.mesh, $ceiling.transform]
    ]
