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

Then we will learn about **Steering Behaviors** as a less robust but more interesting alternative for **Navigational Meshes** (NavMesh). We will use the new enemy **Air Enemy** to try out the Steering Behaviors, while implementing some of them.

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


## Changes Made in the Project
Duration: hh:mm:ss

Since the last template I have added and changed quite a few things in our game.

### 2D Puzzle
Quite a large addition is the 2D puzzle section. It works similarly as the **platforming section** except you use the mouse to play it. You can have a look at the code and node setup if you are interested in how games that are controlled with a mouse work.

![](img/Puzzle2D.png)

### Player Stats
Some player parameters (`speed`, `jump_force`, `health`, `can_double_jump`, etc.) will change during the gameplay though the upgrade system. To easily handle changes, saving, and loading of these parameters I created a `Resource` class called **PlayerStats** that has all of these parameters. This way the stats of the player can be changed on the go.

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


## Player Model
Duration: hh:mm:ss

Let's open the `player.tscn` scene and set up the player model.

### Put player in place
As you can see, the player is not in the right place. The capsule collider is way off and the `InteractArea`, which signalizes the front of the player is on the side.

Please **rotate** and **move** the `Mesh` node to match the collider. This is the before and after image:

<img src="img/PlayerWrongPlace.png" width="332"/>
<img src="img/PlayerRightPlace.png" width="380"/>

> aside positive
> I moved the `Mesh` node to `y = -1.0` and rotated to `y = -90`, which closely matches the player collider.

### Blurry Textures
You may have noticed, that the textures on the player model are a bit blurry, and they start to clear up, when you get really close to the player. Let's fix this.

1. **Open** the file `3D/Player/GORODITH_Player_anim.fbx` in the **FileSystem**.
2. Now in the **Advanced Import Settings** disable the `Generate LODs` option in the menu on the right side.
3. **Press** the `Reimport` button.

Now the texture should be crystal-clear:

<img src="img/NonBlurryPlayerTexture.png" width="200"/>

> aside positive
> The `Generate LODs` option is almost necessary for high-poly models and environments, since it improves performance. However, our model is low-poly and only suffers from this option.

### <img src="img/AnimationPlayerIcon.png" width="20"/> **`AnimationPlayer`** Node
Importing a `.fbx` model with animations will automatically create a `AnimationPlayer` node. This node can play a single animation at a time and has parameters such as `Speed Scale`. You can use the `Current Animation` property to tryout and **play animations** of the player model.

In our case, we need to disable the animation `Optimizer` since it breaks (skipping some frames) a few of the animations.
1. Again, **open** the **Advanced Import Settings** of the player model.
2. **Select** the `AnimationPlayer` node in the left menu.
2. **Disable** the `Optimizer` in the right menu.

> aside positive
> More complex behaviors, such as **blending animations**, **changing them** based on current circumstances/parameters, etc. needs to be done either by **`AnimationTree`** node (covered in later section) or **your own implementation** for switching animations.

### Animation Import
While we are messing around with the importing, let's set some properties of the animations of the player. We want some animations to loop since they will be continuously playing. To do this we need to change the import settings of the animation.

1. Again, **open** the **Advanced Import Settings** of the player model.
2. **Select** the `Armature|Fall` animation in the left menu.
3. **Change** the `Loop Mode` property to `Linear`.
4. **Repeat** the process for these animations:
    1. `Armature|Idle`
    2. `Armature|WalkForward`
    3. `Armature|WalkBackwards`
    4. `Armature|WalkLeft`
    5. `Armature|WalkRight`


## Theory: Skeletal Animations
Duration: hh:mm:ss

In this section I would like to tell you the theory behind **Skeletal Animations**, how they work, and how they are created. We will look at the process of creating a proper **Rig** for our player model. Feel free to look over this section if you are interested, or you can skip it and comeback later, if some part of **Skeletal Animation** is unclear.

**Skeletal Animation** is a technique of using connected **bones** to simulate movement and bend vertices of the model in natural ways. **Animations** are then created by only moving the bones of the model, since the vertices follow the bones.

### Step 1: Skeleton
First, the bones of the model need to be created and connected. The skeleton does not need to the match all the real joints and bones that the model has. For example here you can see the **Skeleton** of our player model, which only has one bone for the whole right arm, since I do not want the elbow to bend in any of the animations:

![](img/PlayerBones.png)

The bones work in the same way as the nodes in a **hierarchy**. By transforming the parent bone all the child bones are also transformed in the same way. An example can be seen in the GIF below, where rotating the `LegBone` also rotates the `FootBone`. 

### Step 2: Weight Painting
Next, you need to define, which vertices react to, which bones of the model and how strongly they react to them. This is done with the process of **Weight Painting**, where you automatically or manually paint each vertex ranging from **blue** (no influence) to **red** (maximum influence) for each bone.

Here you can see the weight painting of the right leg and foot of the player:

<img src="img/WeightPaintingRightLeg.png" width="350"/>
<img src="img/Divider278x10.png" width="10"/>
<img src="img/WeightPaintingRightFoot.png" width="349"/>

> aside positive
> Note that in the "knee" area, the both bones have the same influence. You could say that the influence of the bones "cross-fades".

### Step 3: Posing
The last step is the transform the bones into poses. You can see in the GIF below how the model reacts to moving the bones.

<img src="img/SkeletonAnim.gif" width="450"/>

### Step 4: Animation
Animations are made by capturing these poses in **keyframes** at set times. You can think of keyframes as the desired **transforms of the bones** of the model. The final animation is then only a sequence of theses keyframes. The animation is then played by interpolating from one keyframe to another, creating a seamless motion, while storing only a fraction of the data.

Here you can see the keyframes (gray and yellow dots) of all the bones for the player during the `WalkForward` animation:

![](img/KeyframesWalk.png)

### Final Note
**Skeletal Animation** is a very useful technique to create natural moving models and are a much deeper topic. If you are interested in 3D modelling or procedural animation, I recommend looking up more sources. This brief overview will be sufficient for us to use them in this codelab.


## Animation Tree (Premade Animations) TODO
Duration: hh:mm:ss

Creating more complex animation behavior, than just playing one animation, can be done in Godot with the use of the `AnimationTree` node. It can be used to create very complex animation switching and blending trees.

The tree has a property of `Tree Root`, which can be set to create the behavior. There are several options but only some of them are useful (✔️) to be chosen as the root of the animation tree. 

![](img/AnimationTreeRoot.png)

- ❌ **`AnimationRootNode`** is just an abstract class that all other animation node classes inherit from.
- ✔️ **`AnimationNodeBlendTree`** is a canvas in which you can connect nodes to blend animations.
- 🟡 **`AnimationNodeBlendSpace1D`** is a 1D axis that interpolates between several animations based on a value `[0.0 - 1.0]`. It can be used but it is very limited.
- 🟡 **`AnimationNodeBlendSpace2D`** is the same as the 1D version, however you blend/interpolate in 2D space. Again, it can be used, but it is very limited.
- ✔️ **`AnimationNodeStateMachine`** a visual state machine, similar to the one we created in one of the previous codelabs, but specialized for animation.
- ❌ **`AnimationNodeAnimation`** a single animation. Useless as the root since you can achieve this behavior by setting a fixed animation in the `AnimationPlayer`.


### `AnimationTree` setup
Let's open the `player.tscn` scene and set up an `AnimationTree`.

1. **Add** a `AnimationTree` node as a child of the `Mesh` node.
2. **Set** the property of `Anim Player` of the new node to the `AnimationPlayer` node.
3. **Set** the property of `Tree Root` to a new `AnimationNodeStateMachine`.

Now with the setup complete, we can view the state machine by pressing the `AnimationTree` button on the bottom panel:

![](img/AnimationStateMachine.png)

### State machine
With the state machine open we can see the `Start` node, which is initial state, and the `End` node. The state machine can be used as such:

<img src="img/StateMachineUsage.gif" width="500"/>

> aside positive
> Selecting a transition, many things can be set in the **Inspector** such as `Priority`, `Switch Mode`, `Transition Conditions`, etc. More on that later.

### Blend tree
If you followed the steps in the GIF above, please **clear the state machine** and let's fill it out.

1. **Add** a `BlendTree` node.
2. **Rename** the node to `FreeMoveBlend`.
3. **Connect** a transition from the `Start` node to the `FreeMoveBlend`.
4. **Click** the **pencil icon** in the `FreeMoveBlend` node. 


### fall and jump parameters

### Connect to puzzle (fill out function)



## Skeleton Modifiers (Procedural Animations) TODO
Duration: hh:mm:ss

### Light in eyes BoneAttachment

### LookAtModifier for gun

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
