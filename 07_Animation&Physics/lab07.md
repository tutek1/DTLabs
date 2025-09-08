summary: Animation & Physics
id: export
categories: Animation, Physics, 3D, Models, Joints, Animation Tree
status: Published
authors: Ondřej Kyzr
Feedback Link: https://google.com

# Lab07 - Animation & Physics

## Overview TODO
Duration: hh:mm:ss

This lab will focus on learning about **Behavior Trees** as an alternative for **Finite-State Machines**. We will recreate the behavior of the **Ground Enemy Finite-State Machine** from the last lab using a Behavior Tree.

Then we will learn about **Steering Behaviors** as an less robust but more interesting alternative for **Navigational Meshes** (NavMesh). We will use the new enemy **Air Enemy** to try out the Steering Behaviors, while implementing some of them.

In a bullet point format, we will:
- Learn the theory behind **Behavior Trees**. 
- Install the **`Beehave`** plugin** and set it up.
- Reimplement the **`Ground Enemy` behavior** using Behavior Trees.
- Learn the theory behind **Steering Behaviors**. 
- Implement **`Seek`** and **`Pursue`** behavior.
- Try out all the other **steering behaviors** I prepared.

Here is the template for this lab. Please download it, there are scripts, models, and scenes needed for the Behavior Trees and Steering Behaviors.
<button>
  [Template Project](link)
</button>



## Changes Made in the Project TODO
Duration: hh:mm:ss

Since the last template I have added and changed quite a few things in our game.

### 2D Puzzle
Quite a large addition is the 2D puzzle section. It works in a similar way to the **platforming section** except you use the mouse to play it. You can have a look at the code and node setup if you are interested in how games that are controlled with a mouse work.

![](img/Puzzle2D.png)


### Player Stats
Some of the player parameters (`speed`, `jump_force`, `health`, `can_double_jump`, etc.) will change during the gameplay though the upgrade system. To easily handle changes, saving, and loading of these parameters I created a `Resource` class called **PlayerStats** that has all of these parameters. This way the stats of the player can be changed on the go.

> aside negative
> Some parameters, that do not change (`rotation_speed`, `gravity`, `acceleration`, etc.), are still present as `@export` parameters of the player class.

### Player, Broken pin, Cylinder, and Cube models
I made the model for the **Player** in **MagicaVoxel** and then rigged, weight-painted, and animated the model in **Blender**. We will use the model in the first part of the codelab focusing on animation.

<img src="img/Player.png" width="300"/>


Next, I created several models for us to play around with in **MagicaVoxel**. We will use them in the **Physics** part of this codelab for `Rigidbodies`, `Joints`, etc.

<img src="img/Cylinder.png" width="200"/>
<img src="img/Cube.png" width="300"/>
<img src="img/BrokenPin.png" width="300"/>


### Environment
The main `debug_3d_scene.tscn` was also expanded. I made the floor much bigger, created a playground for the **Physics** part of the codelab, and added the new models.

![](img/Environment.png)


## Player model import TODO
Duration: hh:mm:ss
TODO

### Blurry Textures

### Animation Import

### Put player in place



## Animation Tree (Premade Animations) TODO
Duration: hh:mm:ss

### State machine

### Blend tree

### fall and jump parameters

### Connect to puzzle (fill out function)



## Skeleton Modifiers (Procedural Animations) TODO
Duration: hh:mm:ss

### Light in eyes BoneAttachment

### LookAt for gun

### Player projectiles

### SkeletonIK showcase



## Moving Platform (In-engine animations) TODO
Duration: hh:mm:ss

### Animation Player

### Animation

### Why it works?



## Physics TODO?
Duration: hh:mm:ss



## Rigidbodies TODO
Duration: hh:mm:ss

### Make player interact - mask layer process

### Physics material and mass


## Hinge Joint - Seesaw
Duration: hh:mm:ss



## Other Joints TODO
Duration: hh:mm:ss

### Types

### My implementation

### Button - Spring joint 


## Recap TODO
Duration: hh:mm:ss

Let's look at what we did in this lab.
- We learned about **Behavior Trees** and installed the plugin `Beehave`.
- Then, we **implemented the `Patrol`** behavior of the `GroundEnemy` to match the `FSM` variant.
- Next, we **implemented the `Chase`** behavior of the `GroundEnemy` to match the `FSM` variant.
- In order to do the two steps above we learned about **composite, decorator,** and **leaf nodes**.
- Lastly, we **added the shooting and tweens**, that the `FSM` variant of the enemy also does.
- With Behavior Trees covered we looked into the **theory** of **Steering Behaviors**
- Then, we looked at the `AirEnemy` and how is **Steering** implemented in the code
- We got our hands dirty by programming the **`Seek & Pursue`** behaviors.
- Lastly we looked at other **Steering Behaviors**:
    - **Arrive**
    - **Collision Avoidance**
    - My own: **Hover**

### Note on AI in games
As we saw, you can create an AI for your game in about a **million different ways**. In the end it all depends on the behavior that you are trying to achieve with your game. Each game can have **different restrictions**, that you need to take into account, whether it be the visual style/theme of the game, performance, or ease of use by the designers.

### A better plugin
If you are interested in a more robust plugin for your game, I recommend **LimboAI** ([GitHub](https://github.com/limbonaut/limboai)). It implements `FSM` and `Behavior Trees` in a very efficient way with interesting visual tools for debugging.

### Project Download
If you want to see how the finished template looks like after this lab, you can download it here:
<button>
  [Template Done Project](link)
</button>
