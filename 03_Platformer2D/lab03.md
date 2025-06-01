summary: 2D Platformer
id: export
categories: 2D,, Compilation
status: Published
authors: Ondřej Kyzr
Feedback Link: https://google.com

# Lab03 - 2D Platformer

## Overview
Duration: hh:mm:ss

This lab will move away a bit from the previous one. We will look at how to make a basic 2D platformer. We will use this 2D platformer in our 3D game in the next lab.

Today we will look over:
- What is a **sprite atlas/sheet**
- What are and how to use **tile maps**
- Setting up a **tile set** for tile maps with collisions
- Create (or mostly copy from 3D) a **2D player controller**
- Use exported **bit masks** for physics layers/masks
- Create **spikes** by manually **processing collision**
- Learn how to **reset** the scene
- Learn about scaling 2D objects in the **viewport**

Here is the template for this lab. Please download it, there are new assets, scenes, and folders.
<button>
  [Template Project](link)
</button>




## Project Orientation
Duration: hh:mm:ss

Let's have a look in the template project, that I provided. If you look in the **FileSystem** you can see the folder **2DPlatforming**. Inside it you can find the debug scene, in which we will work in in this codelab, and a sprite sheet.

### Folder management
One important thing is the way you structure the folders in your project. Many people have folders based on file type (`Scripts`, `Art`, `Scenes`, `Sounds` etc.). This can be quick and useful to find something in smaller projects or folders. I will use this approach in the `2DPlatforming` part of the project, since it will be a small minigame in the final `3D` game.

The other approach, which you can see in the `3D` folder, is to split everything based on the type of the game object. I personally like this approach better, since it is more **logical** and **scalable**.

### Folder colors
Another important thing is to stay organized. I recommend setting colors to the main folders (3D and 2DPlatforming) in the **FileSystem**. You can do it like this with a `right-click`:

![](img/FolderColor.png)

Personally, in this project it would be nice to color the **3D** folder red and **2D** folder blueish, since 3D nodes are red and 2D nodes are blue. Like this:

![](img/FolderColorDone.png)


Now open the `debug_2d_scene.tscn` and switch to the **2D tab**




## Sprite Sheet Theory and TileSet
Duration: hh:mm:ss

### Sprite Sheets/Atlases
**Sprite sheets** or **sprite atlases** are a way of storing 2D drawn images. In games, where the environment can be built in a **grid** (Super Mario, Terraria, Core Keeper, etc.) it is a useful way to save memory and draw calls to the GPU.

 The main rules for sprite sheets are:
- One sprite sheet is a **one image**
- Each tile in the sheet has the **same size**
- Tiles are spread out equally next to each other

![](img/spritesheet.png)

This is an example of a sprite sheet from our game. The first tile is the **wall tile**. Next to it there is a **platform tile**. Then there are 4 sprites with the electric cable animation and one sprite for a jump pad. The second line features the test player character from the 3D game.

> aside positive
> Sprite sheets are ideal for frame-by-frame animations.


### TileSet










## Recap
Duration: hh:mm:ss

Let's look at what we did in this lab.
-s
-s
-s
-s
-s

