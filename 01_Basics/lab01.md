summary: Basics of Godot and 3D
id: export
categories: Installation, Basics, Engine UI, 3D
status: Published
authors: Ondřej Kyzr
Feedback Link: https://google.com

# Basics of Godot and 3D

## Getting Godot Engine 
Duration: hh:mm:ss

### Programming Language
First we need to download the Godot Engine itself. Each Godot release has two versions:
- Standard (supports GDScript language)
- .NET (supports GDScript and C# language)

This tutorial will use the standard version using GDScript, which is a python-like scripting language made specifically for Godot. You can use C# and GDScript interchangeably in one project (with some minor restrictions) but this tutorial will be done entirely in GDScript for simplicity.

<aside class="positive">
To maximaze performance of a project you would ideally use C# for complex algorithms (such as pathfinding or other complex calculations) and GDScript for interfacing with the engine and calling engine functions.  
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
4. Click one the import button and find the folder, where you downloaded the template project. There select the `project.godot` file and press open. ![](img/ProjectImport.png)
5. In the popup window select `Import`.

