summary: 2D Platformer
id: export
categories: 2D, 3D, SubViewport, Area3D, Camera3D
status: Published
authors: Ondřej Kyzr
Feedback Link: https://google.com

# Lab04 - 2D Platformer in 3D

## Overview TODO
Duration: hh:mm:ss

This lab will combine the 2D minigame created in the previous lab with the 3D game we were making before. We will look at how to use `SubViewports` and how to stop and resume a subtree (the 2D game).

Today we will look over:
- See the **changes** I made from the last lab and save the **2D player scene**
- TODO


Here is the template for this lab. Please download it, there are new scenes and folders.
<button>
  [Template Project](link)
</button>




## Project Changes and Saving the Player2D
Duration: hh:mm:ss

### 3D Scene Changes
I cleaned up our 3D scene a bit more by moving all the objects under the node `Obstacles`, which is a child of `Environment`. I also added another node container called `2DPlatforming`, which will hold all the 2D platforming sections. There is already a `Sprite3D` for the first section and we will setup a `SubViewport` in the next section.

![](img/3DChanges.png)


### 2D Changes
I created a 2D platforming template level and a testing level for this codelab. The template will work as a base scene, that can be duplicated to easily create more 2D platforming levels. All the levels can be found in the folder `2DPlatforming/Levels/`.

![](img/2DChanges.png)

> aside positive
> The levels do not have a `Camera2D`, since the `SubViewport` will work as a camera into the 2D world.


### Save the player
Currently, if we wanted to change a property of the 2D player, for example the sprite, we would have to go into every scene with the 2D player and change it manually. This is not **very time efficient** and can produce **many bugs**. Let's save the player as a scene and replace it in all the 2D scenes.

1. **Open** the `debug_2d_scene.tscn` scene (or any one of the three 2D scenes)
2. **Right-click** the `Player2D` node
3. Select **Save Branch as a Scene**
4. **Save it** to a folder `2DPlatforming/Scenes` (needs to be created) and name the file `player_2d.tscn`
5. Now **open** all the other 2D scenes
6. **Delete** the `Player2D` node
7. **Instantiate** the saved `player_2d.tscn` scene using the ![](img/SceneInstantiate.png) icon above the scene hierarchy

> aside negative
> Remember to move to newly instantiated player node to the position where the deleted one was.

The resulting scene hierarchy in `debug_2d_scene.tscn` should look like this:

![](img/2DPlayerSaved.png)

Now if we change something in the `player_2d.tscn` scene, it shows up in all 2D scenes. Try it out!




## Visible 2D Scene in 3D
Duration: hh:mm:ss

Now in order to make the 2D scene visible in 3D, we need a something to show it on. **Open** the `debug_3d_scene.tscn` and look at the **Scene Hierarchy**. There, you can see the node `Enviroment` -> `2DPlatforming` (a container for all the 2D platforming sections), which has a single `Sprite3D` as a child (a single platforming section). `Sprite3D` node is used to display 2D sprites/images in 3D.


### Adding a SubViewport
To look inside the 2D scene and use the image, we need to add a `SubViewport` node, which basically works as a window/camera into the child subtree of the `SubViewport`.

1. **Add** a `SubViewport` node as a child of the `Sprite3D`
2. **Set** the `Texture` property of the `Spite3D` to **New ViewportTexture**
3. In the pop-up window **select** the newly created `SubViewport`

![](img/SubViewport.png)

Now to actually see the 2D scene, let's **instantiate** (![](img/SceneInstantiate.png)) the `level_codelabs.tscn` scene as a child of the `SubViewport`.


### Settings of the SubViewport
If you look at the `Sprite3D` now, there are 3 issues:
1. The whole level is not in view. We need to change **the dimensions** of the `SubViewport`.
2. The level looks blurry up close. We need to change **the sprite filtering** option.
3. The level has a gray background. We need to toggle **transparent background** ON.

To fix them do:
1. In the **Inspector** of the `SubViewport` change the size to `x=448` and `y=640`.
2. In the **Inspector** of the `Sprite3D` change the `Texture Filter` property to `Nearest`.
3. In the **Inspector** of the `SubViewport` switch the `Transparent BG` on. 

The result should look like this:
![](img/2DIn3D.png)

> aside positive
> The size of the `SubViewport` is in multiples of `32px` because the size of a single tile in `32px` by `32px`.




## PlatformingManager2D and ProcessMode
Duration: hh:mm:ss

Try to play the game now. You can see that you can control **both** the 2D and 3D player at the same time. This is not how the game is supposed to work. Let's make a script called `PlatformingManager2D`, which will control the winning, losing, starting, and ending the 2D platforming level.

1. **Create** a new script `platforming_manager_2d.gd` it the folder `2DPlatforming/Scripts`
2. **Add** a function `turn_on()` and `turn_off()` with no parameters and return type of `void`
3. **Add** the script to the `LevelCodelabs` node in `level_codelabs.tscn`
3. **Add** the script to the `LevelTemplate` node in `_level_template.tscn`


What to put into the new functions? 🤔


### ProcessMode
We want the 2D level to be inactive until we "enter" it, how do we do that? Each node that inherits from `Node` (which is basically every node there is) has a property of `Mode` in the `Process` category. This determines if the node runs the `_process()` and `_physics_process()` function every frame. For example, when you disable a `CharacterBody2D` it will stop moving and processing all collisions.

Here you can see all the modes, that can be set:

![](img/ProcessMode.png)

- **Inherit** - uses the same mode as the parent node
- **Pausable** - the node will not process when `get_tree().paused = true` is set
- **WhenPaused** - the node will process ONLY when `get_tree().paused = true` is set
- **Always** - the node will process no matter what
- **Disabled** - the node will not process at all



### Back to the PlatformingManager2D
So let's fill in the `turn_on()` function with:
```GDScript
process_mode = Node.PROCESS_MODE_INHERIT
```

and the `turn_off()` function with:
```GDScript
process_mode = Node.PROCESS_MODE_DISABLED
```

For now, the script doesn't do much. We will fix it in the next section, where we will add another script.




## Area3D, PlatformingSection, and Signals
Duration: hh:mm:ss

Let's setup the rest of the platforming section so that the player enters the 2D platforming once they touch an enter area in space. That is where the `Area3D` (and `Area2D` for 2D) node comes in.

1. **Add** an `Area3D` node as a child of the `Sprite3D`
2. As the `Area3D` warning suggests, **add** a `CollisionShape3D` as a child of the `Area3D`
3. **Fill in** the `Shape` property of the `CollisionShape3D` with a `BoxShape3D`
4. **Move** the `Area3D` to the bottom left corner of the `BigResistor` object
5. **Adjust** the collision **layer** of the `Area3D` like this:

![](img/Area3DLayer.png)

6. **Adjust** the collision **mask** of the `Area3D` like this:

![](img/Area3DMask.png)

7. Optional: **Add** a `MeshInstance3D` as a child of the `Area3D` and **create** an interesting mesh

Here is what the resulting scene should look like.

![](img/Area3D.png)

> aside positive
> I chose a text mesh to show you, that you can easily create 3D text meshes from any fonts.



### Create PlatformingSection Script
With the setup complete, let's create and add a script to the `Sprite3D`, which will control the entering and exiting the 2D platforming level from the 3D world.

1. **Create** a new script `platforming_section.gd` in the `2DPlatforming/Scripts` folder
2. **Add** the script to the `Sprite3D`, which has the `SubViewport` as a child

Now we would like to be notified, when the player enters the `Area3D`. This can be easily done using Godot **Signals**.

### Godot Signals
They are very similar to events in other programming languages. Any node can **connect** to a signal of another node with a given **Callable** function. Once the signal is fired, all the connected nodes are **notified** and the given functions are **called**. You can also create your own signals, which we will do in this codelab later on. Let's try them out!

### Connecting the signal
If you select the `Area3D`, you can switch the tab at the top of the **inspector** to the **Node** tab.

![](img/Area3DSignals.png)

The `Area3D` has many different signals that can be connected. We are interested in the signal `body_entered(body: Node3D)` since our player is a `CharacterBody3D` -> `body_entered`.

1. **Select** the `body_entered(body: Node3D)` signal
2. **Press** the `Connect...` button on the bottom right
3. In the pop-up window, **select** the `Sprite3D` with the `platforming_section.gd` script
4. Press the `Connect` button

The script should open with a new function `_on_area_3d_body_entered(body)`, let's change it up and test it out with a print like this:
```GDScript
func _on_area_3d_body_entered(body : Node3D) -> void:
    print("Player entered!")
```
Try to play the game and enter/exit the `Area3D`. The console should print `"Player entered!"` every time you enter the area.





## Entering 2D
Duration: hh:mm:ss

### Reference to the 2D scene
Our 2D platforming scene has the script with the `turn_off()` and `turn_on()` function. To call it from the `platforming_section.gd` we need a reference to the script. To have a reference to a script we need to set the name of the script class.

1. **Open** the `platforming_manager_2d.gd` script
2. **Add** the line `class_name PlatformingManager2D` as the first line of the script

Now in the `platforming_section.gd` let's get the reference to the 2D level and turn the level off in the `_ready()` function. This will make the 2D player stop moving with the 3D one.

Place this in the script:
```GDScript
@onready var platforming_manager : PlatformingManager2D = $SubViewport/LevelCodelabs

func _ready() -> void:
    platforming_manager.turn_off()
```

Running the game now, the 2D player no longer moves, which was our goal.


### Function `_enter2D()` 
Let's add a function in the `platforming_section.gd`, which will prepare everything needed to transport us into the 2D level.

Add this function to the script:
```GDScript
func _enter2D() -> void:
    platforming_manager.turn_on()
```

This just turns on the 2D level, when we enter the `Area3D` for now.


#### Player 3D reference
Once in the 2D level, we want to **turn off** the 3D player, so we need a reference to it. We could add a `export` reference to the player, but we would have to set all the references **manually**, which would be quite cumbersome if we had a lot of 2D platforming sections. In this case, we can easily get the reference to the 3D player once it **collides** with the `Area3D`.

In the `player_controller_3d.gd` script:
1. **Add** the line `class_name PlayerController3D` as the first line of the script

In the `platforming_section.gd` script:
1. **Add** the variable `_player_3d` of type `PlayerController3D`
2. **Rewrite** the `body_entered` function as such:
```GDScript
func _on_area_3d_body_entered(body : Node3D) -> void:
    if body is PlayerController3D:
        _player_3d = body
        _enter2D()
```

> aside positive
> The keyword `is` is used to check the class type.

#### Turn off the Player
Now the next step is to **turn off** the 3D player. We will do this the same way as we did the for the 2D player.

Add this line to the `_enter2D()` function:
```GDScript
_player_3d.process_mode = Node.PROCESS_MODE_DISABLED
```

It would also be nice, if the player 2D was not **visible** until we enter the 2D world and if the player 3D was invisible until we exit the 2D world. There are several ways to do it and each has a pro and con, we will stick with the simplest and just set the **scale** of the player to `0`.

For the 3D player, add this line to the `_enter2D()` function:
```GDScript
_player_3d.scale = Vector3.ZERO
```

For the 2D player in the script `platforming_manager_2d.gd` we need to add the reference to the player with `export` and add the correct lines to the `turn_on()` and `turn_off()` functions. The script should look like this:
```GDScript
class_name PlatformingManager2D
extends Node

@export var player : Node2D

func turn_on() -> void:
    process_mode = Node.PROCESS_MODE_INHERIT
    player.scale = Vector2.ONE


func turn_off() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED
    player.scale = Vector2.ZERO
```

Remember to set the `export` variable in the **inspector** in all the 2D platforming scenes!




## Camera Follow 2D Player
Duration: hh:mm:ss

Playing the game in seems as if the player enters the 2D world, which is nice. One problem is that the camera stays on the position of the 3D Player. We would like it to follow the 2D player.


### Dummy target
So that we can easily see and debug the position translation from 2D to 3D, let's add a `Node3D` with a mesh, which will act as our new camera target.

**Recreate** this setup:
![](img/TestCube.png)


### Player2D position
How do we get the 2D player position in the `platforming_section.gd` script? Well we have a reference to the `PlatformingManager2D` and the manager has a reference to the player. Let's add a function to the manager to get the reference to the player 2D.

```GDScript
func get_player2D() -> Node2D:
	return player
```


### How to translate 2D position to 3D?
The 2D world has the **origin** in the top left corner with the `Y-axis` going down and `X-axis` going right. So if we get the **player position**, we know how the player is translated in relation to the top left corner of the sprite.

However, the `Sprite3D` is centered, so we also need to **offset** the position by half of the width and half of the height.

Another thing is that the units of the 2D player position are in **pixels** and the units of the 3D world are in **meters**. Luckily, the `Sprite3D` node has a property of `pixel_size`, which tells us how big in meters a single pixel is.

![](img/2DTranslate.png)


### The code
Since these changes are quite big and the codelab will be quite long already, I won't though the code in great detail. Here is the full `platforming_section.gd` script:

```GDScript
extends Sprite3D

@onready var platforming_manager : PlatformingManager2D = $SubViewport/LevelCodelabs
@onready var camera_target : Node3D = $CameraTarget

var _player_3d : PlayerController3D
var _is_in_2d : bool = false

func _ready() -> void:
    platforming_manager.turn_off()

func _physics_process(delta):
    _update_camera_target()

# When in 2D moves the 3D camera target to be at the same place as the 2D player
func _update_camera_target() -> void:
    if not _is_in_2d: return
	
    # Get the position, offset it, and multiply it by pixel size
    var player2D_position : Vector2 = platforming_manager.get_player2D().position
    camera_target.position.x = (player2D_position.x - texture.get_width()/2) * pixel_size
    camera_target.position.y = (-player2D_position.y + texture.get_height()/2) * pixel_size

# Handles the transition from 3D to 2D platforming
func _enter2D() -> void:
    if _is_in_2d: return
    _is_in_2d = true
	
    # Turn on the 2D level
    platforming_manager.turn_on()
	
    # Disable the 3D Player
    _player_3d.process_mode = Node.PROCESS_MODE_DISABLED
    _player_3d.scale = Vector3.ZERO
	
    # Change the camera target
    _player_3d.camera_pivot.camera_target = camera_target

# Upon body collision, check if it is the player and enter2D
func _on_area_3d_body_entered(body : Node3D) -> void:
    if body is PlayerController3D:
        _player_3d = body
        _enter2D()

```

### PlayerCamera3D changes
Now if you play the game, the camera follows the 2D player with the cube pretty well. However the camera is too **zoomed** in (due to the shapecasting) and we can still **rotate** the camera.

#### Shapecasting problem
The easies way to fix this is to move the camera target a bit out of the wall. We can easily adjust it in the function `_update_camera_target()` by setting:
```GDScript
camera_target.position.z = 0.5
```

> aside positive
> You can put a different number to the `position.z` than `0.5`. I just find this value to work and look well with out setup.


#### Rotation problem
We will fix this by adding a function to switch off and on the ability to rotate the camera with the mouse. 

Let's add this "public" **function** in the `player_camera_3d.gd` script, a **new bool variable** so that we know if we should rotate or not, and a **check**:
```GDScript
...
var _do_rotate_camera : bool = true
...
func _rotate_camera(x : float, y : float) -> void:
	if not _do_rotate_camera: return
    ...

func set_user_rotation_control(value : bool, fixed_rotation : Vector3) -> void:
	_do_rotate_camera = value
	rotation_degrees = fixed_rotation
```
- `value` will determine if we want the rotation to turn on or off
- `fixed_rotation` will determine the rotation, which will be set and present throughout the 2D level

The rotation should be an `export` variable since some 2D platforming levels might be set at an angle in the 3D space. **Add** this to the top of the script:
```GDScript
@export var camera_angle : Vector3 = Vector3.ZERO
```

The last thing to do is to **call** the function at the end of the `_enter2D()` function. **Add** this line there:
```GDScript
_player_3d.camera_pivot.set_user_rotation_control(false, camera_angle)
```

You can of course play around with the angle in the **inspector** but I will keep it at `Vector3.ZERO`









## Bonus: Entering and Exiting 2D Smoothly
Duration: hh:mm:ss

The instant pop-in and pop-out of the players when 











































## Recap TODO
Duration: hh:mm:ss

Let's look at what we did in this lab.
- We looked at **project organization** and folder management
- Then we learned what **sprite sheets** are and how to setup a `TileSet` from one
- We used the created `TileSet` in a `TileMapLayer` and drew an **environment**
- Next I tasked you to create a **2D player controller**
- Then we made the **jump pad** functional using the `Linear Velocity` property in tiles
- We added **electric cables**, which reset the level on touch, while learning about **Custom Data** in tiles and how to get them.
- Lastly, we set up the camera to **correctly scale** with the window size


If you want to see how the finished template after this lab looks like, you can download it here:
<button>
  [Template Done Project](link)
</button>