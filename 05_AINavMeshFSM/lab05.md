summary: Ground Enemy AI (NavMesh, FSM)
id: export
categories: Globals, AI, 3D, FSM, Plugin, Projectile
status: Published
authors: Ondřej Kyzr
Feedback Link: https://google.com

# Lab05 - Ground Enemy AI (NavMesh, FSM)

## Overview
Duration: hh:mm:ss

This lab will focus on creating a Ground Enemy for our game. We will need to create an AI for them, so that they can easily interact with the player and the environment. They will use a NavMesh (more on that in a second) to navigate the space. To handle the enemy behavior we will learn about and use a FSM (Finite-State-Machine).

Today we will look over:
- See 
- How 
- Learn 
- How 
- The 
- Lastly

Here is the template for this lab. Please download it, there are new folders, 3D models/meshes, updates in scenes and scripts.
<button>
  [Template Project](link)
</button>



## Project Changes
Duration: hh:mm:ss

I have made quite a few changes since the last codelab. Most notably, I added comments to most of the code, changed the main 3D scene to accommodate the theme of this lab, and added 3D models for the enemy and projectile. More on that later on.

### global_debug.gd
One of the more important additions is the `global_debug.gd` script. You can make use of it during playtime by pressing these keys:
- `ESC` - unlocks/locks the mouse (no more pressing Windows key)
- `F2` - slows down time by 1/2
- `F3` - speeds up time by 2

Having a script like this in your project is **extremely useful** for fast and easy **debugging**. More over you can easily expand it to solve your project specific debugging issues. I **recommend** copying it into your project if you plan on using Godot. 

However, firstly we need to learn about **Singletons** and **Autoload**!

### Singleton pattern and Autoload
The Singleton pattern is a software design pattern that **restricts a class**, so that there cannot be more than a **singular instance**. In most other game engines you would have to use Singletons for scripts like the `global_debug.gd`.

In **Godot** you could also use Singletons but there is an easier way. Godot allows you to set **scripts** or even **node trees** as **Autoload**. If you add a node/script as **Autoload** it will be automatically created and added above the scene tree upon start. The usual **Godot Lifecycle** functions are still run and you can access the class from anywhere in code.

Let's add the `global_debug.gd` as an **Autoload**:
1. **Open** the `Project Settings`
2. **Navigate** to the `Globals` tab
3. **Go** into the `Autoload` tab
4. **Click** on the folder icon and find the `global_debug.gd` script.
5. **Press** the `Add` button

The result should look like this:
![](img/GlobalsAutoload.png)

> aside negative
> In your own project, you will also need to add the script `Autoload`.


### Globals in remote scene tree view

Now if you **run** the game and **press the keys** outlined above they should do their job. While running the game you can switch the scene hierarchy to `Remote`. This allows you to see the **current state of the scene** as the game runs. Looking at it **while running the game**, we can see that the autoloaded `GlobalDebug` node sits as a sibling to the current 3D scene.

![](img/AutoloadInAction.png)

Autoload/Singletons are very useful for **tracking global values** (max reached level, time played, player stats, number of deaths, highscore...) or to easily **access important nodes** (Managers, UI, Fade In/Out, debugging...).


> aside positive
> One small note: The script **only works in the editor**. When running a build of the game (compiled .exe file), I made it so the node automatically deletes itself (see `_ready()` function of the `global_debug.gd`).



## Theory: NavMesh
Duration: hh:mm:ss

Imagine you have a **NPC** character and you want them to move through a **maze**. We need to know where they **can and cannot walk** and then somehow **plan a path** through the maze. We can solve this problem easily with a **NavMesh** and a **NavigationAgent**:

- **NavMesh** is a simplified representation of the environment using convex polygons, that defines which areas of an environment are traversable by **NavMesh Agents**.
- **NavigationAgent** uses the **NavMesh** and a pathfinding algorithm like `A*` to plan a path from point A to a point B.


Here is an example of a **NavMesh** in Godot. The light-blue areas are walkable by an agent. 
![](img/NavmeshExample.png)

A **NavMesh** is usually "baked" or calculated in the editor, so naturally it is **NOT** suitable for **highly dynamic** environments. If you really need to, you can bake a NavMesh while the **game is running**, but be aware that the computation is quite **costly**.

> aside positive
> Normally, the **NavigationAgent** is called a **NavMesh Agent** and in Godot a **NavMesh** is called **NavigationRegion**. Both version of these terms are correct and I will use them interchangeably.




## Practice: NavMesh
Duration: hh:mm:ss

Now that we know what a **NavMesh** is, we can try and use it in our project. Open the project and our `debug_3d_scene.tscn` scene.

1. **Add** a `NavigationRegion3D` node as a child of the root
2. In the **Inspector** of the new node **add** a new `NavigationMesh`
3. **Open** the created `NavigationMesh`

There are many settings that you can change here and I will not go through all of them. I will show you the basics and you can look up the rest. 

First, we need to specify, which meshes/colliders should be considered during the calculation. We can do that in the `Geometry` category. This can be set in the `Source Geometry Mode` property. I find the most manageable to be the `Group With Children` setting, so please set it. Also set the property `Source Group Name` to `NavMeshSource`.


### Groups
Now we have set a **Group Name** but what are groups? Each node can be a part of any number of **Groups**. They can be used to easily **tag** nodes. For example you can tag **boxes and barrels** in your game as **"Destructible"** and then when the player attacks an object, you can **check** if the object is in the group "Destructible", if yes then you can **delete** the box/barrel.

This code is used to check a node's group: 
```GDScript
# {var} is in place of a real value 
{node}.is_in_group({string_name})
```


### Back to NavigationRegion3D
With the `Source Group Name` set the NavigationRegion will **only consider** nodes (and their children) that are in the group `NavMeshSource`. Let's set the **group** to the correct nodes.

1. In the **Inspector** of the `Ground` node, **select** the **Node** tab
2. **Click** on the **Groups** button next to Signals
3. **Press** the `+` button and in the popup **set** the name to `NavMeshSource` and **check** the `Global` toggle

![](img/GroupsMenu.png) 
![](img/GlobalGroup.png)

Now the node `Ground` is in the group `NavMeshSource`.

Please also add the node `Obstacles` to the same group. Now, since the group is already created, you can just **select** the `Obstacles` node and toggle the `NavMeshSource` group in the **Groups** tab.


### Baking the NavMesh
To bake the NavMesh in the editor:
1. **Select** the `NavigationRegion3D` node
2. **Press** the `Bake NavigationMesh` button in the context menu

![](img/NavMeshContextMenu.png)

The result should look like this:

![](img/NavMeshBaked.png)


> aside positive
> Godot has 3D and 2D `NavigationRegions` and `NavigationAgents`.



## Prepare the enemy for NavMesh
Duration: hh:mm:ss

I have prepared a **testing enemy** with a basic script and node setup. However, there are a few things that need to be **adjusted** first.

**Open** the `ground_enemy_fsm.tscn` scene located in the folder `3D/Enemies/GroundEnemy/FSM`.

### Import settings of Assets

#### Enemy Model
Looking at the scene in **3D view**, we can see that the enemy is **misplaced** and is not inside the area of the **collision shape**. However, the position of the enemy is **not changed**, it is at `(0,0,0)`. That means that the person, who created the model (me), must have placed **the origin of the object** in the wrong place.

![](img/GroundEnemyPosition.png)

To fix this we will learn about the **Import** tab.

1. **Select** the `GORODITH_ground_enemy_corrupted.obj` in the folder `3D/Enemies/GroundEnemy`
2. **Switch** to the **Import** tab at the top of the **Scene Hierarchy**
3. **Set** the `Offset Mesh` property to `(-1.05, -2, 1.1)`
4. **Press** the `Reimport` button

![](img/GroundEnemyReimported.png)

Now the enemy should be correctly centered like in the picture above. 

> aside positive
> I created this 3D Voxel model in a free program called **MagicaVoxel**. It is very easy to use and I recommend it if you want to use a similar aesthetic.


#### Enemy Texture
There is a one more import issue. When I modelled the enemy it had very **different colors**. See these images for reference (first one is from the modelling software, second one from Godot):

<img src="img/GroundEnemyMagicaVoxel.png" width="300"/>
<img src="img/GroundEnemyGodot.png" width="290"/>

This problem comes from how the modelling program uses textures. It is exported as a small **strip of colors** from the color palette.

<img src="img/GORODITH_ground_enemy_corrupted.png" width="1800"/>

However, by default Godot **compresses a texture** upon importing to save **memory and computational power**. Our textures are so small (256x1 px) that we so not need to compress them.

1. **Select** the `GORODITH_ground_enemy_corrupted.png` in the folder `3D/Enemies/GroundEnemy`
2. **Switch** to the **Import** tab at the top of the **Scene Hierarchy**
3. **Change** the in the `Compress` category the `Mode` to **Lossless** 
4. **Press** the `Reimport` button

![](img/GroundEnemyTextureLossless.png)


> aside positive
> Another option for bigger textures would be to keep the `VRAM Compress` mode but toggle on the `High Quality` setting.



### Navigation Agent Node
Now we need the enemy/agent to **interface** with the `NavigationRegion3D`. We can just add the `NavigationAgent3D` node to our enemy and then **use it in the script**. We **do not** need a reference to the `NavigationRegion3D` since all **navigation communication** happens through the `NavigationServer3D`, so our job is a bit easier. Think of it as a **magical black box**, that just **transmits** all the necessary information between `NavMeshes` and `Agents`.

Please **add** the `NavigationAgent3D` node as a child of the `GroundEnemyFSM`.

#### Agent reference
We will also need a **reference** to the `NavigationAgent3D` node in the script, so **open the script** on the enemy and add the reference to the top of the script using one of the **two following methods**:

You can either **drag the node**, then **press CTRL**, and **drop it** in the code (don't forget to add the type) or just **copy the code** below:
```GDScript
@onready var navigation_agent_3d : NavigationAgent3D = $NavigationAgent3D
```

### Move the Enemy in Scene
Now let's **open** our favorite `debug_3d_scene.tscn`. We can see that the enemy is already **instantiated** in the scene. **Playing** the game, you can see that the enemy just **moves forward** into the wall. Let's look at **code** controlling the enemy.

Most of the code is very similar to the player's movement code. To test out the `NavMesh` we just need to change 2 lines of code. First, we would like to set the target of the agent to where we click with the mouse. 

#### Set target
I have already prepared all the raycasting math needed, so you can just go into the `_input()` function and **change** the last `if` statement to this:
```GDScript
if result:
    navigation_agent_3d.target_position = result.position
```

This sets the **target** of the `NavigationAgent` to the **clicked position** and the agent finds the **closest path** to the point.

#### Move to the target
The second change is at the top of the `_movement()` function. We need to change the `target_pos` to the next point on the path generated by the `NavigationAgent`. There is just the function for it in the `NavigationAgent`. Change the line to this:
```GDScript
var target_pos : Vector3 = navigation_agent_3d.get_next_path_position()
```

Try to play the game and click somewhere. If the position was on the `NavMesh` the enemy should go to it.




## NavMesh and Enemy Fixes 
Duration: hh:mm:ss

If you played around with our current setup enough you might have noticed, that the enemy can get **stuck on walls**, cannot **climb** the steps, etc. We will go through these issues and fix them.

### Debug View
For easier debugging, let's open the enemy scene and and look in the `NavigationAgent3D`'s **Inspector**.

There in the **Debug** category turn on the `Enabled` property.

![](img/NavAgentDebug.png)

Now if you **play** the game and **click** somewhere, you can see the **path** (red line) the agent is taking.

![](img/AgentPath.png)


> aside negative
> Don't forget to save the enemy scene every time we change something!


### Stuck on walls
The reason the enemy is getting **stuck on walls** is because they are **wider** than the `radius` property that the `NavMesh` was baked with. Our enemy has a `SphereShape` with radius of `1m` as the collider. Let's go into the `NavigationMesh` settings and **change** the `radius` property:

![](img/NavMeshRadius.png)

Every time you change something in the `NavigationMesh` you need to bake it again. So press the `Bake NavigationMesh` button again from the **context menu**.

> aside positive
> There are many more settings in `NavigationMesh`, that completely change how it is created. I suggest you try out different setting but in the end almost **every enemy** needs slightly **different settings**.



### Stuck on the stairs
This problem is a bit different since it does not originate from the any of the **Navigation** nodes, but from the `CharacterBody3D` itself. The `CharacterBody3D` considers the steps as a **wall**, so it does not allow movement up the steps. The **solution** I found (there may be other and even better) is to set the `Max Angle` property in the `Floor` category of the `CharacterBody3D` to `60`. So please **set** it:

![](img/FloorAngle.png)


> aside positive
> If your game needs to have different `NavMeshes` for different enemies, you can add more `NavigationRegion` nodes and toggle, which enemy can use which `NavMeshes` with the `Navigation Layers` property.





## Extra NavMesh Nodes
Duration: hh:mm:ss

There are **2 extra nodes** related to `NavMeshes`/`NavigationRegions`, that can be used. This chapter is a bit **optional** but I recommend at least looking through it, so that you know that these nodes exist.


### NavigationObstacle3D
This node is useful when you want to have an **area** to be **removed** from the `NavMesh`. We will use it to get rid of these **small patches** on top of the resistors.

![](img/SmallAreas.png)

To do this:
1. **Open** the `resistor.tscn` scene
2. **Add** a `NavigationObstacle3D` as a child of the root
3. **Open** the `verticies` property and **add** 4 vertices
4. **Set** the **coordinates** of vertices so it matches the bounds of the grey square
5. **Set** the `height` property to `1.5m` (needed so that the top of the object is unwalkable)
6. **Toggle** the property `Affect Navigation Mesh` ON in the `Navigation Mesh` category

The resulting `Resistor` should look like this:
![](img/NavObstacle.png)

Now, the last thing we need to do is to **bake** the `NavMesh` again. The `NavMesh` in the scene should now be without the small patches:

![](img/NavObstacleMainScene.png)



### NavigationLink3D
The second node is useful when you want to add connections to the `NavMesh` manually. For example, you can add a link to a **ledge** and the agent can now **jump** down, or the agent can **jump over** a gap add a link so that they can jump over. 

To **add** a link, simply add the `NavigationLink3D` node to the scene. I like to keep them as a **child** of the `NavigationRegion3D`. The link has several interesting properties:
- `Bidirectional` - control whether the agent can traverse the link **both ways**
- `Start Position` - the **coordinates** of the start position (it is easier to set it using the **red dot** gizmo in scene view)
- `End Position` - the **coordinates** of the end position (it is easier to set it using the **red dot** gizmo in scene view)
- `Travel Cost` - length **multiplier** for the pathfinding, higher values makes the links more costly, it has an effect only when more there are **multiple ways** to the target

As an example I created this link setup:

![](img/NavMeshLinks.png)

You can try to **make** a similar one and see how the enemy handles it.





## Theory: Finite-State Machines (FSM)
Duration: hh:mm:ss

I would like the enemy to work like this:
- When the player is **not spotted** -> **Patrol**
- When **patrolling** -> move between a **sequence of points**
- When the player is **spotted** -> **Chase** the player
- When **chasing** the player -> Periodically **shoot** a projectile at them

This behavior can be expressed as the **graph** below. Where each **box** is a **state** in which the enemy can be in and each **arrow** is a transition from one state to another when the **conditions** (red squares) are met.

![](img/FiniteStateMachinePlan.png)

This makes our **enemy AI** very readable and easy to understand. We will now recreate this structure in our project, so that the enemy will behave exactly like that.

### Definitions
Let's first make a few definitions, that will hold true for our implementation (and most implementations of FSMs):
- The enemy can be **only in one state** at a time.
- The enemy **starts in one** defined state.
- States can be **changed** (transitioned from one to another) only upon **meeting set conditions**.
- When a state is **entered**, its `state_enter()` **function is called**.
- When the enemy is **in a state**, each **process tick**, it
s `state_process()` **function is called**.
- When a state is **exited**, its `state_exit()` **function is called**.


### What we have so far?
If you look in the folder `3D/Enemies/GroundEnemy/FSM` you can see a **script** called `abstract_fsm_state.gd`. Here is the full script, just in case:
```GDScript
class_name AbstractFSMState
extends Resource

# Called upon transition into the state
func state_enter(_enemy : GroundEnemyFSM) -> void:
    assert(false, "Do not use this abstract class!")

# Called every physics process frame
func state_physics_process(_enemy : GroundEnemyFSM, _delta : float) -> void:
    assert(false, "Do not use this abstract class!")

# Called upon transition from the state
func state_exit(_enemy : GroundEnemyFSM) -> void:
    assert(false, "Do not use this abstract class!")

```

This will be our **parent class**, meeting our definitions, for **all the states** that we will create.


> aside positive
> The `AbstractFSMState` class `extends Resource`. This is all that we need, because the state just **holds data** and **the behavior**. Keeping the states to a resource will enable us to:
> - Easily **create** them in the **Inspector** window, without needing more nodes.
> - Have the **possibility** to **save and Reuse** states (looping patrol vs. back-and-forth patrol)












































## Recap
Duration: hh:mm:ss

Let's look at what we did in this lab.
- We looked at the **changes I made** between the last codelab and this one
- Then, 
- We 
- Next, 
- Then, 
- We 
- Next, 
- Lastly, 


If you want to see how the finished template looks like after this lab, you can download it here:
<button>
  [Template Done Project](link)
</button>