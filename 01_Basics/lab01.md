summary: Basics of Godot and 3D
id: export
categories: Installation, Basics, Engine UI, 3D
status: Published
authors: Ondřej Kyzr
Feedback Link: https://google.com

# Lab01 - Basics of Godot and 3D

## Getting Godot Engine 
Duration: hh:mm:ss

### Programming Language
First we need to download the Godot Engine itself. Each Godot release has two versions:
- Standard (supports GDScript language)
- .NET (supports GDScript and C# language)

This tutorial will use the standard version using GDScript, which is a python-like scripting language made specifically for Godot. You can use C# and GDScript interchangeably in one project (with some minor restrictions) but this tutorial will be done entirely in GDScript for simplicity.

<aside class="positive">
To maximize performance of a project you would ideally use C# for complex algorithms (such as pathfinding or other complex calculations) and GDScript for interfacing with the engine and calling engine functions.  
</aside>

### Engine Version
This tutorial will be done using the engine version `4.4.1` and I suggest you do the same, but any newer version can be used.

Please download the Godot engine using the following link and place it into a folder of your liking:
<button>
  [Godot 4.4.1](https://godotengine.org/download/archive/4.4.1-stable/)
</button>

<aside class="negative">
Beware that the differences in major Godot versions may be significant. So if you plan on using a newer version not all things said in this tutorial might be completely correct.  
</aside>


## The Project
Duration: hh:mm:ss

In this tutorial we will be making a game about a robot that goes inside a computer to fight off a malware that has infected the computer. It will mainly be a 3D platformer with seamless 2D platforming and puzzle sections. The complete Game Design Document (perhaps to inspire your own GDD) can be found here: [TODO]("https://google.com")

### Getting and running the template
Each lab will have a template project that we will fill out together. This lab's template can be downloaded here:
<button>
  [Template Project](link)
</button>

1. Download the template using the link above
2. Place it into a folder of your choosing, where you will have all other Godot projects.
3. Launch the Godot Engine `Godot_v4.4.1-stable_win64.exe` (or an alternative for your operating system)
4. Click one of the `Import` buttons and find the folder, where you downloaded the template project. There select the `project.godot` file and press open. ![](img/ProjectImport.png)
5. In the popup window select `Import`.
6. The project should be open now.



## Godot UI
Duration: hh:mm:ss

Now with the project open it might a bit overwhelming to orient yourself in the Godot UI so let's look at it. (Each part will be explained in greater detail later on)
![](img/GodotUI.png)
1. This is the Scene hierarchy. Here you will see all the Nodes (basic building blocks) in the current scene and how they are composed in the scene tree. There is also a second tab for import settings of assets.
2. This is the scene view. It is visible because in 6. the 3D tab is selected. This is the main way you can look around and preview the scene you are making.
3. This is the FileSystem. It shows you all the files, folders, and assets that are present in the projects folder.
4. This is a window with multiple functionalities. 
    - It has the output console, where you will see all messages printed during play.
    - The debugger, where you can find all the information about the performance, errors, networking etc.
    - Audio bus settings, animation window, shader editor and much more.
5. This is the Inspector. Here you can change all the exposed parameters of nodes such as the position, rotation, scale, visibility, etc.
6. This is where you can change the tabs, which influence what you can see in the scene view (2.). 
    - The 2D/3D tabs shows you the current scene from that perspective
    - The Script tab hosts the in engine IDE for writing scripts.
    - The Game tab has the game window, where you can try the game once you run it.
    <aside class="negative">
    Note that 3D scenes cannot be viewed in 2D using these tabs and vice versa.
    </aside>
7. This is the Play panel. We will be mainly interested in the first button, which starts the full game (a set main scene), then the next 2 buttons for control, and the fifth button for playing the current scene.

Don't worry if you feel lost. We will go though all these parts in much more detail later. This is just an overview.



## 3D Navigation
Duration: hh:mm:ss

<aside class="negative">
If you don't see the testing scene in the scene view (the one in the video below) let's open it. In the FileSystem open the folder "3D" -> "Debug" and double click the "debug_3d_scene.tscn" file. 
</aside>

In this section we will learn several ways how to move in the 3D scene view (for 2D it is very similar). Now there are 2 main ways to move in the scene view:

### Middle Mouse Button (MMB)
You can hold the middle mouse button to move in different ways in the scene and can be seen in this video:
<video id=wXRXxe11oss></video>

- `MMB` - Rotate around a point
- `SHIFT + MMB` - Pan
- `CTRL + MMB` - Zoom in/out

Please try to move in the scene using this method.

### Flying camera
The second way, and in my opinion the best way, to move is using the flying camera. It is active while holding the `Right Mouse Button` and pressing these buttons:
<video id=FSjuFlvCc8U></video>

- `W,A,S,D` to move forwards/backwards and right/left
- `Q,E` to move up/down
- `SHIFT` to move faster
- `MMB scroll` to control the speed

Please try to move around in the scene using this method.



## Scene manipulation
Duration: hh:mm:ss

Let's learn how you can manipulate objects (nodes) in the scene. Find and Select the `Resistor` node in the scene hierarchy on the left.

<aside class="positive">
If the resistor is out of view or you are far away you can press F to focus on it. 
</aside>

Now with the `Resistor` selected and in view you can move it, rotate it or scale it. You can do that using several ways.

![](img/ResistorManipulation.png)
1. Select a tool from the tool panel (1.) and then hold left click and drag in the scene view (`Q` select, `W` move, `E` rotate, `R` scale).
2. Grab the colorful parts of the "Gizmo" seen in the image (2.), then hold left mouse button and drag.
3. Directly change the coordinates/degrees/scale of the object in the inspector

<aside class="positive">
You can hold CTRL and SHIFT while manipulating with objects to snap them to a grid.
</aside>

### Object duplication
Our scene is looking a little sad so let's add a big more resistors. Select the `Resistor` node and press `CTRL+D` to duplicate. Now repeat this step and move, scale, and rotate it to make the scene look nicer.

Try to use all three ways to manipulate the objects.

<aside class="positive">
You can select multiple resistors and duplicate them all. So that you don't have to duplicate them one by one.
</aside>

If you played with the scale of objects you might have noticed that they are no longer placed precisely on the ground. They are either a above/below ground or partway in the ground. You can use:
- `PAGEDOWN` key to snap an object to the ground.
- `SHIFT+G` and then click to place it on any surface.

After you are happy with the scene you can continue. Mine looks like this:

![](img/DebugScenePopulated.png)

### World Environment
The visual look of a game is very important. Let's change the World Environment node and play around with the visual style of the scene.

![](img/WorldEnvironment.png)

1. Select the `World Environment` node.
2. Click on the Environment Resource box
3. Change the settings of the world to your liking. There are many settings that can be changed, try to play around with it.

You can look up what each setting does in the [documentation](https://docs.godotengine.org/en/stable/classes/class_environment.html#class-environment). If you feel lost or confused don't dwell on it too much and move to the next section.



## Node Hierarchy
Duration: hh:mm:ss

Let's now dive a bit into the theory behind nodes, trees, and scene hierarchy.

### Nodes
You can think of a node as ingredients in a recipe having a singular purpose. One node might handle showing the Mesh/Sprite of the player, one might handle the collision shape etc. There are many types of nodes with different functionalities.

Each node can only have one script attached, which supports the theory of each node having one functionality. 

### Scene Hierarchy
In the image below you can see that some nodes are "inside" others. This structure follows the logical ordering of the nodes and their functionalities. For example:
- `Player` node (type CharacterBody2D) handles all player movement and controls
    - `AnimatedSprite2D` handles the animations of the player sprite
    - `CollisionShape2D` handles the physics shape the player should have
    - `AudioStreamPlayer2D` handles playing sounds the player makes
    - `Camera2D` handles showing view from the scene to the monitor

![](img/GD_nodes_and_scenes_nodes.webp)

This hierarchy also keeps many properties consistent.
- **Transform** - if `Player` node is moved/rotated/scaled the transformation is applied to all the nodes inside it (children).
- **Visibility** - if `Player` is hidden all children nodes are also hidden (eye icon next to the node)
- and many others ...



## Add your own object
Duration: hh:mm:ss

One of the last things I would like to cover in this lab is how to create your own object with collisions (will come in handy later). So let's make a bigger version of the resistor.

### StaticBody3D
Since the resistor will not move let's add a `StaticBody3D` node.
![](img/AddNode.png)

1. Right click the Environment node (container for all the objects)
2. Press the `Add a child` button
3. Since we want to add a mesh (3D model),search for `StaticBody3D` and press `Create`

Now we have a new node in the scene. Let's add a cube mesh to it.

### MeshInstance3D
Using the same process as before add a `MeshInstance3D` node as a child of the `StaticBody3D`. Now let's configure the mesh.

![](img/Mesh.png)
1. In the inspector with the new node selected, press the empty mesh resource box
2. Press `New BoxMesh` to create a new cube.

Now there is a white cube placed in the ground. Let's make it big and change it's color.

![](img/MeshManipulation.png)
1. Click the cube mesh in the inspector
2. Change the size (I changed it to 10x10x10 meters)
3. Add a `StandardMaterial3D` which defines how the surface of objects will look like
4. Change the albedo color to black
5. You can see the resulting mesh

### CollisionShape3D
After this we can see that the `StaticBody3D` has a warning next to it.
![](img/StaticBodyWarning.png)

The warning tells us that it needs a collision shape. Let's add one so that later on our player cannot go through the object and collides with it.

![](img/CollisionShape.png)
1. Let's start by adding a new node as a child of the `StaticBody3D` of type ` CollisionObject3D`
2. Click the empty shape resource box
3. Choose the `BoxShape3D` since our mesh is a box
4. Now click on the BoxShape3D and set the size to the same as the mesh

Now you have a cube object with collision. 

### Bonus
If you are up to the challenge you can add the yellow cables to the sides in the same way as the cube. Although keep to a single StaticBody3D node. Here is how my solution looks like.

![](img/FinalBox.png)


## Recap
Duration: hh:mm:ss

Let's look at what we did in this lab.
- First we downloaded the Godot Engine and setup the template project
- Next up we looked at the Godot UI and got ourselves familiar with it.
- We also learned how to move in the 3D scene and how to manipulate objects in a scene.
- Then we learned a bit of theory about nodes, the hierarchy of nodes and how changes of a parent propagate to children
- Lastly we tried adding our own bigger `Resistor` object, where we learned about `StaticBody3D` node, `MeshInstance3D` node, and `CollisionShape3D` node.

In the next lab, we will create a player character a third person camera and finally play the game we are making.