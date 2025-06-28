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



## SubViewport Setup
Duration: hh:mm:ss



































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