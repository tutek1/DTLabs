summary: UI & Audio
id: export
categories: UI, Canvas, Slider, Label, Alignment, Anchors, Container, Gradient, Progress Bar, Health, Collectibles, Audio, Audio Manager, Audio Bus, Audio Stream, Audio Listener, Tween
status: Published
authors: Ondřej Kyzr
Feedback Link: https://forms.gle/J8eeuQAJ3wMY1Wnq7

# Lab08 - UI & Audio

## Overview TODO
Duration: hh:mm:ss

This lab will focus on learning about 

Then we will learn about 

In a bullet point format, we will:
- Look at the **changes I made** in the project such as.
- **Import** 
- Learn about 
- Look at the 
- Implement 
- Learn how to create 
- Use the 
- Lastly, look at 

Here is the template for this lab. Please download it, there are scripts, models, and scenes needed for the Behavior Trees and Steering Behaviors.
<button>
  [Template Project](https://cent.felk.cvut.cz/courses/39HRY/godot/08_UI&Audio/template.zip)
</button>


## Changes Made in the Project
Duration: hh:mm:ss

Since the last codelab I have added and changed quite a few things in our game.

### Collectibles
I added a 3D model for the malware trace, which will be a collectible item working as currency in this game. I also made the complete scene and script for the collectible, and we will only fill out a small function in the player script.

![](img/Collectible3D.gif)

To remember the amount of traces collected I added a variable for this in the `player_stats.gd` script.


### `player_stats.gd` change
Since we will be adding the **main menu** and a **save and load system** I decided to move the variable of the player `player_stats` to a new autoload script.

This script is called `GlobalState` and is located in the `Global` folder. It will be responsible for loading, saving, and holding the current state (or save) of the game. The script is added as autoload so it can be used from everywhere.

> aside positive
> **Reminder:** `player_stats.gd` resource script holds the current stats of the player (health, jump, speed, damage, etc.) and the player script uses the values from it.

> aside positive
> **Reminder:** autoloaded scenes/scripts are created above the current scene as a child of the root and are accessible from anywhere just by their name.
>
> ![](img/Root.png)
> - `@_DD3D_...` and `@DebugDraw...` are autoloads from the **Debug Draw 3D** plugin (lab05)
> - Both `Beehave...` autoloads are from the **Beehave** plugin (lab06)
> - `GlobalDebug` our helpful script for testing (lab05)
> - `GlobalState` holds the current state of the player and will save and load it


### UI textures
I drew sprites, which we will use in the UI for a **Health Bar**, **Collectible counter**, and a **logo** for the main menu.

<img src="img/HPBar.png" width="300"/>

<img src="img/Collectible.png" width="200"/>

<img src="img/MainMenuLogo.png" width="200"/>



## Health Bar UI TODO
Duration: hh:mm:ss

Let's start by creating a player HUD with a health bar.

### HUD setup
First, we need to somehow draw sprites, text, and buttons to the screen regardless of if we are in 2D or 3D. For these purposes the `CanvasLayer` node exists.

1. **Create** a new scene of type `CanvasLayer` (`CTRL+N` ⇾ `Other node`)
2. **Rename** the root `CanvasLayer` to `HUD`
3. **Save the scene** into the folder `UI/PlayerHUD`
4. **Instantiate** the scene in the `debug_3d_scene.tscn` scene

![](img/UINode.png)
![](img/UIFolder.png)


### `TextureProgressBar`
A health indicator can be done in many different ways. You can use simple text (`Label` or `RichTextLabel` nodes) or make something more complex. We will create a health bar using a `TextureProgressBar` node.

1. **Add** a `TextureProgressBar` node as a child of the `HUD`
2. **Rename** it to `HPBar`
3. **Set** all the textures in the `Textures` category (`Under` → `hp_bar_under.png`, etc.)
4. **Set** the `Texture` ⇾ `Filter` property to `Nearest` (disabling linear interpolation of the textures)
5. **Set** the `Value` to `50` (so that the fill is visible)

If you zoom in, the bar should look like this:

<img src="img/WrongHPBar.png" width="300"/>

We can see that the `Fill` is in the wrong place. **Change** the `Offset Progress` property to `(9, 6)`.

<img src="img/RightHPBar.png" width="300"/>


### HUD Script
Let's now create a script that will set the `Value` of the `TextureProgressBar` based on the amount of HP the player has.

1. **Create** and a script called `hud.gd` in the folder `UI/PlayerHUD`
2. **Make** it `extend` the `CanvasLayer` class
3. **Attach** the script to the `HUD` node

#### Player Signal
Now, we need to be notified every time the players HP changes. We can do that by **adding a signal** to the player script `player_controller_3d.gd`:
```GDScript
class_name PlayerController3D
extends CharacterBody3D

signal hp_change

...
```

Then **add** a call to emit the signal in the `receive_damage()` function **AFTER** the HP change:
```GDScript
func receive_damage(value : float, from : Node3D):
    ...
    hp_change.emit()
    ...
```

#### Connect the signal
Now, let's go back to the `hud.gd` script. **Create** a function for the updating the HP in the HUD:
```GDScript
func _update_hp() -> void:
    pass
```

Then **add a reference** to the player in the HUD script and **connect it** to the `hp_change` signal of the player in the `_ready()` function:
```GDScript
@export var player : PlayerController3D

func _ready() -> void:
    player.hp_change.connect(_update_hp)
```

Don't forget to **SET** the reference node to the player in the `HUD` node in `debug_3d_scene.tscn`.

![](img/UIPlayerRef.png)


#### HP update function
Now, we need a reference to the `HPBar` to set the `Value`. Since we will be moving the node a lot in the subtree later on, we will use the **Access as Unique Name** option.

1. **Right-click** the `HPBar`
2. **Select** the `Access as Unique Name` option

The `HPBar` node should now have a ![](img/UniquePercent.png) icon and can be referenced in code easily. **Add** this line to the top of the HUD script:
```GDScript
@onready var hp_bar : TextureProgressBar = %HPBar
```

The last thing to do, is to set the actual `Value` in the `_update_hp()` function:
```GDScript
func _update_hp() -> void:
    hp_bar.value = GlobalState.player_stats.curr_health / GlobalState.player_stats.health
```

To make the setting of the `Value` correct and automatically adjust for different max HP, let's "normalize" the min and max of the range, so that it is from `0.0 - 1.0` (no HP - max HP).

In the `HPBar` node:
1. **Set** the `Max Value` to `1.0`
2. **Set** the `Step` to `0.01`
3. **Set** the `Value` to `0.5`

The `HPBar` is now functional, but there are still some things that need to be done to make it look nice.

> aside positive
> Referencing nodes with `Access as Unique Name` will no longer break the reference in scripts when changing the structure of the subtree.


### Anchors and Position
One of the most important settings for UI is the ability to anchor it. Anchors basically say how the **UI elements should behave** with respect to **the aspect ratio** of the screen.

#### How to change anchors
To change the anchors you can either:
- Use the **context menu** on the top of the scene view with a node, that inherits from `Control` (green color), selected.

![](img/AnchorContextMenu.png)

- Or set it in the **Inspector** of the node, where it is called `Anchor Preset`:

![](img/AnchorInspector.png)

#### Set the `HPBar`
I want the `HPBar` to sit on the bottom left of the screen and be oriented vertically. Let's set it up:

1. **Set** the `Size` to `(64 ,16)`
2. **Set** the `Anchor Preset` to `Bottom left`
3. **Set** the `rotation` to `-90.0`
4. **Set** the `scale` to `(6, 6)`

Here is the full viewport with the `HPBar`:

![](img/HPBarBigger.png)

> aside positive
> The blue border in the image above is what the viewport sees.


### Gradient and Progress Tint
The last thing I want to do with the `HPBar` is to make the progress bar change color from **green to red** based on the amount of hp.

**Add** a new `@export` variable to `hud.gd`:
```GDScript
@export var hp_gradient : Gradient
```

**Add** a new `Gradient` and **set** it in the inspector like this:

![](img/Gradient.png)

Let's now change the `update_hp()` function to also update the `Tint Progress` property:
```GDScript
func _update_hp() -> void:
    var hp_ratio : float = GlobalState.player_stats.curr_health / GlobalState.player_stats.health
	
    hp_bar.value = hp_ratio
    hp_bar.tint_progress = hp_gradient.sample(hp_ratio)
```

> aside positive
> You can also change the `Tint Progress` in the inspector for a constant value.


### Bug Fix
The current implementation has a one small bug. Until the player takes damage, the `HPBar` keeps displaying as half full. To fix this, simply **add** a call to the `_update_hp()` in the `_ready()` function of the `hud.gd` script.

```GDScript
func _ready() -> void:
    player.hp_change.connect(_update_hp)
    _update_hp()
```

Here is the final `HPBar` in action:

![](img/HPBarChange.gif)


## Collectible UI TODO
Duration: hh:mm:ss

In this section, we will add collectible counter and put it all together with `HPBar` we created in the last section.

### Collectible Texture and Label
I want the texture and label (text with number) to be located one after another in a vertical list. To do this we will use a `VBoxContainer`, which will automatically align the elements.

1. **Add** a `VBoxContainer` node as a child of the `HUD` (rename to `CollectibleVBox`)
2. **Add** a `TextureRect` node as a child of the `VBoxContainer`
3. **Add** a `Label` node as a child of the `VBoxContainer` (rename to `CollectibleCounter`)

![](img/CollectibleCounter.png)

#### `TextureRect` Settings
1. **Set** the `Texture` property to `UI/PlayerHUD/Collectible/collectible.png`
2. **Set** the `Custom Minimum Size` to `(112.0, 112.0)` (to make the sprite larger)
3. **Set** the `Texture` ⇾ `Filter` property to `Nearest`

This makes the `TextureRect` have a **texture**, **bigger**, and render as **pixel art**.

#### `Label` Settings
1. **Set** the `Text` to `0`
2. **Set** the `Label Settings` property to a `new LabelSettings`
    - Font size = `40`
    - Outline size = `20`
    - Outline color = `Black`
3. **Set** the `Horizontal` and `Vertical Alignment` to `Center`
4. **Set** the `Theme Overrides` ⇾ `Constants` ⇾ `Separation` to `-10`

This makes the `Label` **visible**, so that we easily set it, **formats the text** and makes it **closer** to the `TextureRect`


### Put `HPBar` and `CollectibleCounter` Together
I would like to move the **collectible counter** to be on the right of the `HPBar`. We could set the anchor to `Bottom Left` and offset it manually. However, this is very error-prone and could hinder us in the future if we wanted to change some aspects of the UI.

#### The Horizontal Container
Similarly to when we wanted the collectible label and texture to be above each other, we will use a `HBoxContainer` (`H` since we want a horizontal list).

1. **Add** a `HBoxContainer` as a child of the `HUD`
2. **Set** the `Anchor Preset` to `Bottom Left`
3. **Set** the `CollectibleVBox` as a child of the `HBoxContainer`

![](img/HBoxPart1.png)

Now, the problematic part comes in. If we were to set the `HPBar` as a child of the `HBoxContainer`, its scale and rotation would be reset. To circumvent this we need to add a `Control` node and put the `HPBar` as a child of it.

#### Retain Transform
1. **Add** a `Control` node as a child of the `HUD`
2. reset anchor 
3. reparent
4. set min size to (96.0, 384.0) (texture size * 6 since scale)
5. hpbar pivot offset (32, 8)
6. hpbar anchor center
7. put the `Control` as a child of hbox
8. set alignment of CollectibleVBox to end



> aside negative
> I don't blame you if all of these setting of the UI are a bit confusing. For me personally it is always a bit of trial and error to get it right.

`HBoxContainer`
Control nodes for transform retention

## Temporary Audio Sliders TODO
Duration: hh:mm:ss

### `GridContainer`

### Label and Slider

### Slider Signals



## Audio Basics TODO
Duration: hh:mm:ss

### Bus Layout

### Audio Nodes



## Play Simple Audio TODO
Duration: hh:mm:ss

### Sound Import Loop

### `AudioStreamPlayer3D` Setup



## Complex Audio using an `AudioManager` TODO
Duration: hh:mm:ss

### Overview of `AudioManager`

### Play Music

### Fill DEBUG UI Callback


### SFX Settings

### Play SFX Methods



## Play SFX
Duration: hh:mm:ss

### Player Walk
#### physics could work but no
#### bone attachments yes

### Player Jump

### Player Damaged

### Player Shooting

### Collectible Gather

### `GroundEnemy` - Damage

### `GroundEnemy` - Shooting

### `AirEnemy` - Damage



## Recap TODO
Duration: hh:mm:ss

### Feedback
I would be very grateful if you could take a moment to fill out a **very short feedback form** (it takes less than a minute). Your feedback will prove very useful for my diploma thesis, where I will use it to evaluate the work I have done.
<button>
  [Google Forms](https://forms.gle/xcsTDRJH2sjiuCjP7)
</button>

> aside positive
> This whole course and the game we are making are a part of my diploma thesis.

### Recap
Let's look at what we did in this lab.
- We looked at the **changes I made** in the project such as:
    - s
    - s
    - s
- Then, we 
- Next, we looked at 
- We looked at the 3 types 
- The second part of the codelab looked closely 
- We implemented 
- We made a little detour into 
- After that, we used 
- Lastly, we looked at 


### Note on Audacity
X

### Note on Freesound.org
X

### Project Download
If you want to see what the finished template looks like after this lab, you can download it here:
<button>
  [Template Done Project](https://cent.felk.cvut.cz/courses/39HRY/godot/07_Animation&Physics/template-done.zip)
</button>
