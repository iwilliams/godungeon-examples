tool # Needed so it runs in the editor.
extends EditorScenePostImport


func post_import(scene):
    for mesh_instance in scene.get_children():
        var mi := mesh_instance as MeshInstance
        if mi == null:
            continue
        
        for i in range(0, mi.mesh.get_surface_count()):
            mi.mesh.surface_set_material(i, preload("res://tiles/terrain/bridge/wood_tmp.tres"))
    return scene # remember to return the imported scene
