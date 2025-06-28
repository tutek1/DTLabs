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

So let's fill in the `turn_on()` function with:
```GDScript
process_mode = Node.PROCESS_MODE_INHERIT
```

and the `turn_off()` function with:
```GDScript
process_mode = Node.PROCESS_MODE_DISABLED
```
















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