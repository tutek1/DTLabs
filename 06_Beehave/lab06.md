summary: Ground Enemy AI (Behavior Tree)
id: export
categories: AI, Behavior Trees, Beehave, NavMesh, 3D, Plugin
status: Published
authors: Ondřej Kyzr
Feedback Link: https://google.com

# Lab06 - Ground Enemy AI (Behavior Tree)

## Overview
Duration: hh:mm:ss
TODO
This lab will focus on learning about **Behavior Trees**. We will recreate the behavior of the **Ground Enemy Finite-State Machine** from the last lab using a Behavior Tree.

Today we will look over:
- Changes made in the project between the codelabs. 
- The 
- Learn 
- Creating 
- 

Here is the template for this lab. Please download it, there are scripts needed for the Behavior tree implementation.
<button>
  [Template Project](link)
</button>



## Behavior Trees 
Duration: hh:mm:ss

When it comes to creating an AI character in a videogame, there are many known ways/architectures that you can use. For example:
- easy but restrictive **Simple reactive planning** (bunch of if-else statements, that only react to the current environment)
- more complex **Finite-State Machine** (becoming less and less clear the more states and transitions you add)
- easily modifiable **Behavior Tree** (forcing you to learn to think about AI in a different way)
- and many more...

The choice of the architecture always depends on the complexity of the character you are making. However, most of the more complex characters are usually made with **FSMs** or **Behavior Trees**, that is why I wanted to cover them in this tutorial series.

> aside positive
> Behavior Trees are **very powerful** once you know how to use them. The ability to represent them visually makes them easy to debug. Most popular games use them, here are a few notable examples:
> - **GTA V** - pedestrian NPCs reacting to players actions
> - **The Sims** - each Sim manages their needs and interacts with objects
> - **Kingdom Come: Deliverance** - with their life-like NPC behavior
> - Nearly all modern AAA games using the Unity Engine of the Unreal Engine use Behavior Trees



### What are ![](img/TreeIcon.png) Behavior Trees?
Behavior trees are and alternative way to of creating AI for videogames. The whole behavior of the AI is divided into a **tree structure with many nodes**, that can have various types and purposes. The tree is run from **the root** and when there are sibling nodes, they are run left -> right, or top -> bottom (depends on the orientation of the tree).

When a node is run, it **must return the state** that it is in. A node can be in one of these three states:
- `SUCCESS` - Signals to the parent that the node has executed the action successfully.
- `FAILURE` - Signals to the parent that the node failed to execute the action.
- `RUNNING` - Signals to the parent that the node is still performing the execution. This pauses the tree traversal and the node will be run again next frame/tick. This is used for actions that take some time to complete.

There are 3 base node types:
- **Composite** - has more than one children and the state return value depends on the children
- **Leaf** - has no children, usually performs an action or checks a condition ("go to patrol point", "is player seen?" etc.)
- **Decorator** - has exactly one child node, that is a leaf and performs operation on the state return (invert state, always SUCCESS, etc.)


### ![](img/CategoryComposite.png) Composite
Let's look how the two most basic composite nodes work.

#### ![](img/Sequence.png) SequenceComposite
Sequence node runs all child nodes one by one until **one has failed or all have succeeded**:
- Child node return `SUCCESS` -> run the next child node -> no more child nodes to run -> return `SUCCESS`
- Child node return `FAILURE` -> return `FAILURE`
- Child node return `RUNNING` -> return `RUNNING` (next frame/tick the child node is run again)

#### ![](img/Selector.png) SelectorComposite
Similar to sequence, the selector node runs all child nodes one by one until **one has succeeded or all have failed**:
- Child node return `FAILURE` -> run the next child node -> no more child nodes to run -> return `FAILURE`
- Child node return `SUCCESS` -> return `SUCCESS`
- Child node return `RUNNING` -> return `RUNNING` (next frame/tick the child node is run again)


### Example Behavior Tree
I think Behavior Trees are best shown on an example. This modified example was taken from [gamedeveloper.com](https://www.gamedeveloper.com/programming/behavior-trees-for-ai-how-they-work) and I will walk you through it.

![](img/BTExampleModified.jpg)

Here, the goal of the tree is to perform actions so that the character **goes through a door**. The execution starts in the **root of the tree**, in the top-most composite `RootSequence` node. Let's take a scenario, where the door is locked.

1. **`RootSequence`** runs **`Walk to Door`** -> `SUCCESS`
2. **`RootSequence`** runs the **`DoorSelector`**, which runs the **`Open Door`** node -> `FAILURE` (door is locked)
3. **`DoorSelector`** runs **`UnlockSequence`**, which runs **`Unlock Door`** -> `SUCCESS` (worked since the door was locked) then run **`Open Door`** -> `SUCCESS` 
4. This makes the **`UnlockSequence`** -> `SUCCESS`, making the **`DoorSelector`** -> `SUCCESS`
5. **`RootSequence`** runs **`Walk through Door`** -> `SUCCESS`, then runs **`Close Door`** -> `SUCCESS`
6. **`RootSequence`** -> `SUCCESS`, which means that the tree executed successfully

> aside positive
> If a node returned **`RUNNING`** in the example above, the tree would be **"stuck" and continuously run** the node until it would return `SUCCESS` or `FAILURE`

Try to walk through the tree with **other scenarios** (door is only closed or it has a broken lock). You should find that the tree adapts to the situation and if something were to go wrong, you would be able to see, which node/action had failed -> easy debugging.

> aside negative
> **Small but important note:** "node -> SUCCESS" means that "node returns SUCCESS"

### ![](img/Blackboard.png) Blackboard
The last thing you should know about Behavior Trees for now is how to handle dynamic information. In the example above the dynamic information could be:
- Position of the door
- Does the AI have a key to the door?
- etc.

Behavior Trees use a **Blackboard** to store this information. Every node can **access, read, and write** into the Blackboard. In most frameworks it is implemented as a set of `{key} = {value}` pairs, the same way that the data structure `Dictionary` works.




## Beehave Installation, Project Setup 
Duration: hh:mm:ss

The Godot Engine does not support Behavior Trees out of the box. To use them you either need to code them yourself or use a plugin. I have chosen the **Beehave** plugin, that implements Behavior Trees. The plugin is not perfect and has a few quirks and visual glitches. However, having the live visual debugging is perfect for our educational purposes.


![](img/BeehaveLogo.png)

### Beehave Installation
I have already installed the plugin to save time. However, some more complex plugins, such as this one, need to be enabled in the **Project Settings**. Please do so:

![](img/BeehavePluginEnable.png)


### GroundEnemyBH script
I have created a copy of the `GroundEnemyFSM` called `GroundEnemyBH` and replaced them in the `debug_3d_scene.tscn` scene. All relevant scripts and scenes can be found in the `3D/Enemies/GroundEnemy/Beehave/` folder. Please **open** the `ground_enemy_bh.gd` script and let's go through it:
- At the top, there are all the **`@export` variables** from the `GroundEnemyFSM` and all of the FSM states. These variables are declared here in the enemy, because they are not dynamic data (during play time they do not change).
- Then, there are several `enums`:
    - **`BB_VAR`** - These are all the keys for the **Blackboard variables**, that we will need. Normally, you would use strings as keys but I feel like that leads to many bugs due to typos.
    - **`ROTATE_MODE`** - You might have noticed that in the FSM version our enemy rotated differently in each state. For simplicity I decided to delegate the job back to the main enemy script and the Behavior Tree will only switch, which mode is currently running.
    - **`ACTIONS`** - This will be used to easily detect what action (Patrol, Chase) the enemy is currently in. We will use it to detect that we started chasing the player and play the "pop up" tween animation. 
- The `_ready()` function sets the **default values** of all the Blackboard variables.
- Rest of the script is pretty much the same as the FSM variant, except for **storing and loading dynamic variables**, where the Blackboard is used.

> aside positive
> **Setting** and **Getting** the values of the Blackboard can be easily done with `blackboard.set_value(key, value)` and `blackboard.get_value(key)`


### `bh_...` scripts
You might have noticed that there quite a few `bh_...` scripts in the `GroundEnemy/Beehave/` folder. These are the **custom actions and decorators** that we will use as nodes in the Behavior Tree. Coding all of them from the ground up would take far too much time and this codelab would be very long. We will at least go through some of them and **create 2 actions** on our own later on.


### GroundEnemyBH scene
Now **open** the `ground_enemy_bh.tscn`. The scene is pretty much the same as the `ground_enemy_fsm.tscn` except for the missing `Timer` node. We will supplement its functionality by a Decorator node in the Behavior Tree.

Let's create a basic Beehave setup, so that in the next section, we can start making the behavior already.
1. **Add** a `Blackboard` node as a child of the `GroundEnemyBeehave`
2. **Add** a `BeehaveTree` node as a child of the `GroundEnemyBeehave`
3. **Set** the property of `Blackboard` in the `BeehaveTree` node the the `Blackboard` node

<img src="img/GroundEnemyBHSetup.png" width="350"/>
<img src="img/BeehaveTreeNodeSetup.png" width="400"/>





## Patrolling Behavior
Duration: hh:mm:ss

Let's start by creating the **Patrolling behavior** of the enemy, since that is an easy place to start. In **Beehave** the Behavior Tree is build with nodes in the **Scene Hierarchy**. This works because the **Scene Hierarchy** is a tree-like structure with nodes and children. Don't worry about how adding the Chase behavior will work for now.

### ![](img/Sequence.png) Patrol Sequence
If you think about the behavior of **Patrolling** it is a **Sequence** of actions (Go to point -> Wait until there -> Update index -> Go to next point -> ...) by that logic, we should use a `SequenceComposite` node as the root of the tree. The `BeehaveTree` in `ground_enemy_bh.tscn` will be the **parent of the root of the tree**.

1. **Add** a ![](img/SequenceSmall.png) `SequenceComposite` node as a child of the ![](img/TreeIconSmall.png) `BeehaveTree`
2. **Rename** it to `PatrolSequence`

Now what should the patrol sequence look like? Let's first set the action (Patrol/Chase) that we are in.

1. **Add** a ![](img/Action.png) `ActionLeaf` node as a child of the ![](img/SequenceSmall.png) `PatrolSequence`
2. **Rename** it to `SetAgentAction`
3. **Add** the `bh_set_agent_action.gd` script from folder `GroundEnemy/Beehave/` to it

Ok, next let's set the rotation mode of the enemy, so that it rotates based on velocity (looks the way it is walking).

1. **Add** a ![](img/Action.png) `ActionLeaf` node as a child of the ![](img/SequenceSmall.png) `PatrolSequence`
2. **Rename** it to `SetRotateModeVelocity`
3. **Add** the `bh_set_rotation_mode.gd` script from folder `GroundEnemy/Beehave/` to it
4. In the **Inspector** of the node **set** the property `Rotate Mode` to `Velocity` 

Next, let's set the target of the `NavigationAgent` using another action node. The process will be basically the same as the nodes above, so I will shorten it:

- **Node** ![](img/Action.png) `ActionLeaf` child of ![](img/SequenceSmall.png) `PatrolSequence` -> **Name** `SetNextPatrolPoint` -> **Script** `bh_set_next_patrol_point.gd`

For **reference** the tree should look like this now, with custom scripts on all the action nodes:

![](img/TreeBeforeUntilFail.png)



#### ![](img/UntilFail.png) UntilFail decorator
Now the interesting part come in. The sequence to this point sets the **agent action**, sets the **rotate mode**, and sets a **new target to walk to** for the enemy. If you remember how the `PatrolState` in the FSM worked, we want to wait now until the enemy reaches the patrol point. In Beehave we can do that using the Decorator `UntilFail`.

Looking at the **Beehave [documentation](https://bitbra.in/beehave/#/manual/decorators)**, we can see that the decorator:
- Executes its child and returns `RUNNING` as long as it returns either `RUNNING` or `SUCCESS`.
- Once the child returns `FAILURE` it returns `SUCCESS`

So if we add a **condition node** that checks if the enemy is NOT on the patrol point, the tree execution would be stuck here until then. Meaning we can effectively **wait** with the rest of the sequence (index update, next point set, etc.) until the enemy is at the currently set patrol point.

1. **Node** ![](img/UntilFailSmall.png) `UntilFailDecorator` child of ![](img/SequenceSmall.png) `PatrolSequence` -> **Name** `UntilNotOnPatrolPoint` -> **Script** default
2. **Node** ![](img/InverterSmall.png) `InverterDecorator` child of ![](img/UntilFailSmall.png) `UntilNotOnPatrolPoint` -> **Name** `NotOnPatrolPoint` -> **Script** default








## Notes TODO
Duration: hh:mm:ss

Do on your own `bh_set_next_patrol_point.gd`, `bh_is_player_close_enough.gd`
use user guide: [text](https://bitbra.in/beehave/#/manual/)
`logan/login/lungo` something AI plugin



## Recap
Duration: hh:mm:ss
TODO
Let's look at what we did in this lab.
- We looked at the **changes I made** between the last codelab
- In 
- Then, 
- In order to 
- Next, we 
- Then, we 
- After that 
- Next, we
    - 
    - 
    - 
- Lastly


If you want to see how the finished template looks like after this lab, you can download it here:
<button>
  [Template Done Project](link)
</button>


> aside positive
> All custom icons used in headers taken from the free Godot plugin [Beehave](https://github.com/bitbrain/beehave).
