summary: VFX
id: export
categories: VFX, Shader, Visual Shader, GLSL, Fullscreen Effect, Hologram, Noise, Particles, Tween
status: Published
authors: Ondřej Kyzr
Feedback Link: https://forms.gle/J8eeuQAJ3wMY1Wnq7

# Lab10 - VFX (Visual Effects)

## Overview
Duration: hh:mm:ss

This lab will focus on learning about 

In a bullet point format, we will:
- Look at the 
- Learn about 
- **Play a simple** 
- Look at the 
- Use the 
- Learn about 2 methods 
- Lastly, we will make

Here is the template for this lab. Please download it, there are scripts, shaders, sprites, and scenes needed for the implementation of the audio playing.
<button>
  [Template Project](https://cent.felk.cvut.cz/courses/39HRY/godot/10_VFX/template.zip)
</button>



## Changes in the Project
Duration: hh:mm:ss

Since the last codelab, I have added and changed a few things in our game, which we will use today.

### Object Hologram Shader
We will create the hologram shader for our player. However, the "hologramable" objects need to use a different shader, which we will not create in this codelab and is already prepared in the template.

![](img/HologramWallPreview.png)

### Secret Box for Hologram
I prepared a testing object for the hologram shader. It's a white box, where one of the walls can be passed through when using the hologram ability.

![](img/HologramBoxPreview.png)

### VFX Manager
The manager handles playing fullscreen VFX. We will add it to `Autoload` and use it to add the fullscreen grayscale effect to the game. Now it just has a tweening function to pulse the grayscale effect, which is not yet implemented.

### Particle Sprites
The last thing I added are the sprites that will be used for the particle effects, which we will create in the second part of the codelab.

<img src="img/AirEnemyParticles.png" width="60"/> <img src="img/BoltParticles.png" width="120"/> <img src="img/CloudParticles.png" width="60"/> <img src="img/FootParticles.png" width="60"/> 


## Shaders
Duration: hh:mm:ss

Let's quickly look at how shaders work and what they can be used for. I recommend at least reading the **vertex**, **rasterization**, and **fragment** stages.

### The Graphic Pipeline
This image ([Source](https://docs.vulkan.org/tutorial/latest/03_Drawing_a_triangle/02_Graphics_pipeline_basics/00_Introduction.html)) shows the stages of the **graphics pipeline**. We will briefly go over them.

<img src="img/VulkanPipeline.svg" width="300"/>

### Input Assembler
The **input assembler** collects the raw vertex data.

❌ Non-programmable part of the pipeline.

### Vertex Shader
The **vertex shader** is run for every vertex and generally applies transformations to turn vertex positions from model space to screen space. It is the first programmable stage, where you can adjust the properties of vertices (position, normal, UV, etc.).

✔️ Programmable part of the pipeline. 

### Tessellation
The **tessellation shaders** allow you to divide geometry into smaller parts to increase the mesh quality. This is often used to make surfaces like brick walls and cobblestone floor look less flat.

🟡 Tessellation shaders are a programmable part of the pipeline, but a bit too complex and out-of-scope for our course.

### Geometry Shader
The **geometry shader** is run on every primitive (triangle, line, point) and it can discard the primitive or output more primitives than came in. This is similar to the tessellation shader but much more flexible. However, it is not used very often in today’s applications because the performance overhead.

🟡 Geometry shaders are also programmable and also too complex and out-of-scope for our course.

### Rasterization
The **rasterization stage** breaks the primitives into fragments (pixel elements). Any fragments that fall outside the screen are discarded, and the attributes outputted by the vertex shader are interpolated across the fragments (color, normals, etc.). Usually, the fragments that are behind other primitive fragments are also discarded here because of depth testing.

❌ Non-programmable part of the pipeline.

### Fragment Shader
The **fragment shader** is invoked for every fragment (usually fragment == pixel) that survives. It can do this using the interpolated data from the vertex shader, which can include things like texture coordinates and normals for lighting. The **final color of the pixel** is the output of this stage.

✔️ Programmable part of the pipeline.

### Color Blending
The **color blending** stage applies operations to mix different fragments that fall on the to the same pixel in the framebuffer. Fragments can simply overwrite each other, add up or be mixed based upon transparency.

❌ Non-programmable part of the pipeline.


> aside positive
> The pipeline image and descriptions are taken from the Vulkan rendering API, but all rendering APIs implement the important stages.

## Fullscreen Effect
Duration: hh:mm:ss

Creating fullscreen effects in Godot is very simple. I created the `VFXManager` to handle playing and composing them. However, this setup is not necessary and a simple `Canvas` and `ColorRect` setup is enough (will be looked at in this section).

> aside positive
> The `VFXManager` could also be part of the UI/HUD. It depends on the game that you are making.

### VFX Manager
Let's look at the `VFXManager` and **add** it as `Autoload`.

1. **Open** the `VFX/vfx_manager.tscn` scene
2. **Open** the `Project Settings`
3. **Select** the `Globals` tab
4. **Set** the `Path` to `res://VFX/vfx_manager.tscn` (or use the folder icon to find the manager)
5. **Set** the `Node Name` to `VFXManager`
6. **Press** the `+Add` button

![](img/Autoloads.png)

### `CanvasLayer` and `ColorRect`
Now we will add a `CanvasLayer` node, which will make all its 2D children display to the screen, and a `ColorRect` node, which will hold the shader effect.

1. **Add** a `CanvasLayer` node as a child of the `VFXManager`
2. **Add** a `ColorRect` node as a child of the `CanvasLayer`
3. **Set** the `Layout/Anchor Preset` property to `Full Rect`
4. **Rename** the `ColorRect` to `GrayscaleRect`
5. **Right-click** the `GrayscaleRect` and **Select** the `Access as Unique Name`

> aside negative
> Be sure to set the correct name `GrayscaleRect` or else the underlying code in `vfx_manager.gd` will not work.


### Debug sprite
For testing purposes let's also add an image so that we can see the effect.

1. **Add** a `Sprite2D` node as a child of the `VFXManager`
2. **Set** the `Texture` property to `icon.svg`
3. **Move** the `Sprite2D` to the threshold of the `GrayscaleRect` (similar to the image below)

![](img/GodotKuk.png)

> aside positive
> If you want the fullscreen effect to also work on the `PlayerHUD`, you need to set the `Layer` variable of the effects `CanvasLayer` to a **higher** number that the `Layer` of the `PlayerHUD` canvas.

### Grayscale Shader - Setup
Let's now create the grayscale shader.

1. **Right-click** the `VFX/Shaders/Grayscale` folder
2. **Press** the `Create New` ⇾ `Resource` option
3. **Choose** the `Shader` resource
4. **Set** the `Mode` to `Canvas Item` and **name** the file as `grayscale_shader.gdshader`

With the shader created, let's use it on the `GrayscaleRect`.

1. **Select** the `GrayscaleRect` node
2. In the `Material` property **create** a `New ShaderMaterial`
3. **Set** the `Shader` property of the `ShaderMaterial` to the `grayscale_shader.gdshader`

### Grayscale Shader - Programming Language
Godot uses a similar shading programming language to **GLSL**. If you have never heard of it, don't worry, the syntax is very similar to the `C` programming language. I recommend briefly going over the **shader reference** in the [Godot Documentation](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html) to get the basic idea.

**Open** the newly created `grayscale_shader.gdshader` shader. You should see this:

![](img/FreshlyCreatedShader.png)

### Grayscale Shader - Implementation
Let's start actually implementing the shader.

#### Screen texture
First, we will need to get the current rendered screen. We can get that by adding this line above the `vertex()` function:

```C
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
...
```
- `uniform` - tells the engine that this variable is settable from the editor/code (similar to `@export`) and is not interpolated between the stages of the pipeline
- `sampler2D` - represents a 2D texture, which in our case is the rendered screen image
- `hint_screen_texture` - tells the engine to fill this variable with the rendered screen image

> aside positive
> The `repeat_disable` hint makes the texture not repeat when sampling out of range. The `filter_nearest` hint makes the texture not pixel-perfect (no pixel interpolation).


#### Color of the Current Pixel
Let's go into the `fragment()` function since we only want the change the final pixels. To sample a texture we can use the `texture()` function.

```C
...
void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);
    COLOR = color;
}
...
```
- `SCREEN_UV` is a automatically set variable that holds the `UV` coordinates of the pixel on the screen.

The last line in the fragment shader sets the `COLOR` variable, which is the final pixel color, to the sampled color. If you save the shader file (`CTRL + S`), you should now see that the `GrayscaleRect` is transparent in the scene.

![](img/TransparentRect.png)

> aside positive
> Colors are stored as `Vector4` since a color is composed of the RGB channels and the alpha channel.

#### Get the Grayscale Color
To make the color grayscale, we can easily average all the RGB channels, create a new vector with this value, and set it as the final color.

```C
...
void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);
    float avg = (color.r + color.g + color.b) / 3.0f;
    vec4 grayscale = vec4(avg, avg, avg, 1.0f);
    COLOR = grayscale;
}
...
```

> aside positive
> You can index vectors in shaders with any of these `(x, y, z, w)`, `(r, g, b, a)`, or `(s, t, p, q)`, the result is the same.

#### Control the Grayscale
I would like to control the grayscale effect with a variable, that can be set from the CPU-side (for example activate it when getting hit).

```C
shader_type canvas_item;

uniform float amount : hint_range(0.0, 1.0, 0.01);
...

void fragment() {
    ...
    COLOR = mix(color, grayscale, amount);  // Change the previous COLOR = ... line
}
```
- `hint_range(start, end, step)` changes the way the variable is shown in the editor to a slider
- `mix()` function is the same as `lerp()` in GDScript

Now, if you navigate to `GrayscaleRect` in the **scene view** and look at the **inspector**, you can change the `amount` variable:

![](img/ShaderParam.gif)

#### The whole shader code
Here is the whole shader code:

```C
shader_type canvas_item;

uniform float amount : hint_range(0.0, 1.0, 0.01);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	float avg = (color.x + color.y + color.z) / 3.0f;
	vec4 grayscale = vec4(avg, avg, avg, 1.0f);
	COLOR = mix(color, grayscale, amount);
}
```

### Player On-hit Effect
Let's play the effect when the player gets hit. I have already prepared a handy function for us to use in the `vfx_manager.gd` script.

#### Clean-up
First, we need to clean up the `vfx_manager.tscn` scene.

1. **Select** the `GrayscaleRect` node in the **scene hierarchy**
1. **Set** the `amount` property of the **grayscale shader** to `0`
2. **Delete** the `Sprite2D` node with the Godot icon

#### Pulse the grayscale effect
Let's now navigate to the `player_controller_3d.gd` script and play the grayscale effect when the player gets hit. I have already prepared the function that will interact with the shader and the variables (prefix `OHG`) of the effect in the player.

**Navigate** to the `receive_damage()` function and **add** the following line above the `AudioManager.play...` line:

```GDScript
VFXManager.pulse_grayscale(OHG_amount, OHG_fade_in, OHG_wait_time, OHG_fade_out)
```

#### The result
Playing the game now, you should see the grayscale effect working, when you get hit.

![](img/GrayscaleInEffect.gif)


#### Override
An interesting effect emerges when you set the `OHG_amount` parameter of the player to a higher number than `1`. **Open** the `player.tscn` scene and **change** the `OHG_amount` parameter to `1.5`.

![](img/OHGAmount.png)

You should see this effect:

![](img/GrayscaleOverride.gif)


> aside positive
> Making shaders is a bit of an **artistic process**. If you had asked me to make this shader effect (override variant), I would not know how to do that. However, through **experimentation** and **tinkering** with the grayscale shader making this effect was easy.




## Hologram Shader - Visual
Duration: hh:mm:ss

Creating shaders using code is efficient and performant but for more artistic people a bit too complex and unintuitive, that is why **Visual Shaders** exist. They are a node-based system in which you can easily create shaders. While **not as performant** (in very large graphs) and a **little less capable** than "code" shaders, they can be used for **quick and easy prototyping** or **making simple effects**.

![](img/VisualShader.png)

Let's learn how to use the **visual shaders** and create a hologram effect for the player.

### Setup
First, we will need to set up a few things.

#### Test Object
We will create a **testing object** with the shader applied, so that we can see the current state of the shader during the creation.
1. **Go** to the `debug_scene_3d.tscn` scene
2. **Add** a new `MeshInstance3D` node as child of the **root**
3. **Set** the `Mesh` property as a `New CapsuleMesh`
4. **Move** the `MeshInstance3D` out of the ground

![](img/TestingCapsule.png)

#### Material and Shader
Let's set a material of the `MeshInstance3D` and create the shader.
1. **Select** the `MeshInstance3D`
2. **Click** the `Mesh` property in the **Inspector** to open it
3. **Set** the `Material` to a `New ShaderMaterial`
4. **Click** the `Material` property to open it
5. **Set** the `Shader` property to a `New Shader`
6. **Set up** the dialog window as such:
    ![](img/CreateVisualShader.png)
7. **Double-click** the created shader in `VFX/Hologram/hologram_shader.tres`

### Scanlines
The hologram effect is composed of several effects. We will start off with making the scanlines, that are present on holographic objects.

#### Basic lines
Copy this setup:

![](img/BaseScanLines.png)
- `Input` (`vertex`) - position of the vertex in camera space
- `Vector Decompose` - allows you to use only parts of a vector, in our case `y` since we want the lines on the `Y-axis`
- `FloatOp` (`Remainder`) - works as the `%` modulo operator, making the transparency periodically fade
- `Output ` (`Alpha`) - adjusts the transparency of the object

The setup creates this effect:

<img src="img/BaseScanLinesResult.png" width="300"/>

#### World Space
You might have noticed, that the effect "stays" with the camera. That is because we use `Vertex` input, which is in the **Camera space**.

<img src="img/BaseScanMoveCamera.gif" width="300"/>

Let's move the effect to **World space** by getting the correct coordinates from the `Vertex Shader`. We will do this by using a `Varying`, which is a variable type that gets **interpolated** from the `Vertex stage` to the `Fragment stage` similarly to the normal vector, position, color, etc.

1. **Switch** to the `Vertex` shader in the **top left** of the **Shader Editor**
2. **Press** the `Manage Varyings` button and **Press** the `Add Varying` button 
    <img src="img/ManageVaryings.png" width="500"/>
3. **Set** the `Type` to `Vector3`, **name** to `WorldPos`, and **Press** the `Create` button
4. **Recreate** this setup in the `Vertex Shader`:
    <img src="img/VaryingSetter.png" width="500"/>
5. **Change** the `Input` (`vertex`) node in the **Fragment Shader** to a `VaryingGetter`
    <img src="img/VaryingGetter.png" width="500"/>

Now the effect is correctly positioned in **World space** and does not warp under weird angles. It also "stays in place" meaning, that moving/rotating the object moves the effect as such:

<img src="img/WorldSpaceHolo.gif" width="600"/>

#### Scanlines adjustment
Let's make the size of the scanline size settable from **outside the shader** and make the effect more **pronounced**. In the `Fragment Shader`:

1. **Add** a `FloatParameter` node and **set it up** like this:
    <img src="img/Parameter.png" width="400"/>

2. **Add** a `Remap` node and **set it up** it like this:
    <img src="img/Remap.png" width="600"/>

    - This takes the input value from `[0.0 - 0.075]` range to `[0.0 - 1.0]`, basically normalizing it.
3. **Add** a `FloatOp` (`Pow`) node and **set it up** like this:
    <img src="img/PowNode.png" width="600"/>

    - This makes the transparent and nontransparent parts more equal.

This should be the resulting look:

<img src="img/ScanlinesDone.png" width="300"/>

#### Moving scanlines
Right now, the scanlines are static and look a bit boring. Let's make the scanlines move with the `Input` (`time`) node and controllable with a parameter from outside the shader.

**Adjust** the scanline setup in the `Fragment Shader` like this:

![](img/ScanLineMoveSetup.png)

> aside positive
> The highlighted nodes are the new ones added.

This makes the hologram effect move on the `Y-axis` based on the `FloatParameter`:

<img src="img/ScanLinesMoveResult.gif" width="300"/>


### Hologram Color
Let's take a short break from more complex nodes and create the **color of the hologram**.

**Recreate** this setup:

<img src="img/HologramColor.png" width="800"/>

> aside positive
> You can use the `Reroute` node to **arrange** the lines in a more clear way like I did.

This node setup interpolates from the `Input` (`color`) to the `HologramColor` using the `Mix` node. The interpolation is done with the `alpha` channel of the `HologramColor`.

### Fresnel Effect
We will enhance the hologram with one more effect. The **Fresnel effect** is the strongest on edges of objects, where the angle between the `view vector` (camera forward) and the `normal vector` of the surface. Here is an example, where the **whiter** the color is, the stronger the effect is:

<img src="img/Fresnel.png" width="200"/>


#### Fresnel Hologram
Let's use the Fresnel effect to make the hologram more interesting. **Add** the **highlighted** nodes to the setup:

<img src="img/FresnelSetup.png" width="800"/>

This is the resulting look. In my opinion, the addition of Fresnel makes the hologram feel more enclosed.

<img src="img/FresnelResult.png" width="200"/>


> aside positive
> The **Fresnel effect** is normally used to add specular highlights on the edges of objects. However, as you can see, it can be used for many other uses.

### Vertex Glitch
The last effect of the hologram is **Vertex glitch**. We will move the vertices of the model in "random" ways to simulate the instability of holograms.

#### Basic noise texture setup
To offset the vertices "randomly", we will use a noise texture, which is essentially a controlled randomness. We will only offset the `y` coordinate to make this tutorial a bit easier to digest. The effect will still look good.

1. **Switch** to the `Vertex shader` in the **Shader Editor**
2. **Add** a `Texture2D` node
3. **Set** the middle parameter of the `Texture2D` node to a `New NoiseTexture2D`

    <img src="img/NoiseTexture.png" width="200"/>

4. **Set** the `Noise` parameter in the **Inspector** to a `New FastNoiseLite`
5. **Replicate** the following setup to adjust the position of the vertices (highlighted nodes are new):
<img src="img/BaseVertexGlitch.png" width="500"/>

> aside negative
> We need to use the `Input` (`vertex`) from the `Varying` setup so that we force the compiled code to send the **unchanged** vertex to the `Varying`. If we had used another `Input` (`vertex`) node it would have used the displaced vertex position and the glitch effect would not have been visible.

This basic setup moves the vertices up. 

<img src="img/BaseDisplace.png" width="250"/>


#### Controlled noise texture
This does not look so good. Let's first `remap` the noise from `[0.0 - 1.0]` to `[-1.0 - 1.0]` so that we don't just move the vertices **up** but also **down**. We will also add a `FloatParameter` to **control the amount** of vertex glitch.

**Add/Change** these highlighted nodes to the `Vertex shader`:

<img src="img/StaticComplexVertexGlitch.png" width="700"/>

#### Moving noise texture
This looks a bit better, but it would be nice if the **vertex glitch effect** moved. We can do that by adjusting the `uv` input of the `Texture2D` node, which controls which pixel of the texture is sampled.

**Add** these highlighted nodes to the `Vertex shader`:

<img src="img/MovingNoiseTexture.png" width="700"/>

> aside positive
> We use the `Input` (`vertex`) instead of the `Input` (`uv`) because of the special way the player model is made (duplicate vertices). To fit the `vertex` position (`Vector3`) to the `uv` input of the `Texture2D` I decided to just add all the parts together with the `z-axis` being added to both `x` and `y`.

### Glow in scene
Let's make our hologram **glow** to add a bit more juice.

1. **Go** into the `WorldEnvironment` node in the `debug_scene_3d.tscn`
2. **Change** the `Glow` property to `On`
3. **Change** the `Hologram Color` property of the testing object (`MeshInstance3D`) using the **RAW** tab, to a value over the standard range, for example: `(0, 1.2, 0)`

The color exaggeration makes the hologram glow more.

### Shader Flags
You can also change the `Shader Flags` and `Modes` to adjust the rendering behavior of the object. For example toggling `Depth Prepass Alpha` will make the hologram **cast shadows** (needed for shadows due to the transparency).

<img src="img/FlagsAndModes.png" width="300"/>

### Do not Receive Shadows
The last thing I want to change is that currently the hologram receives shadows, which doesn't really make sense. We can either toggle `On` the `Unshaded` flag, but this would **remove the glow** effect, or we can **set** the `emission` property in the `Fragment Shader`. If we set it to the same value as the `albedo` it will override the shadows.

Simply **connect** to last node that goes to `albedo` to also go into `emission` like this:

<img src="img/Emission.png" width="600"/>

### The Result

Here is the final shader **visual**:

<img src="img/HologramVisualDone.gif" width="400"/>

Here is the `Vertex Shader` **setup**:

<img src="img/FullVertexShader.png" width="4000"/>

Here is the `Fragment Shader` **setup**:

<img src="img/FullFragmentShader.png" width="4000"/>

> aside positive
> If the image is too small, since the codelab framework downscales the image, **Right-click** and **Select** the `Open Image in a New Tab` option.

## Hologram Shader - Logic
Duration: hh:mm:ss

input done

### Hologram in `GlobalState`

### Hologram Player Function

### Hologram Wall Setup

### Secret Box Setup

### Set up `LevelManager`



## Particles
Duration: hh:mm:ss

### Double Jump Particles

### Walking Particles

### Damage Particles

### Enemy Flying Particles




## Recap
Duration: hh:mm:ss

### Feedback
I would be very grateful if you could take a moment to fill out a **very short feedback form** (it takes less than a minute). Your feedback will prove very useful for my master thesis, where I will use it to evaluate the work I have done.
<button>
  [Google Forms](https://forms.gle/xcsTDRJH2sjiuCjP7)
</button>

> aside positive
> This whole course and the game we are making are a part of my master thesis.

### Recap
Let's look at what we did in this lab.
- First, we looked at 
- Next, we learned what 
- We created the 
- Then, we learned about all the 
- After the intro, we made 
- Next, we looked at the 
- Then, we implemented the 
- With that complete, we used these methods 
- Lastly, we learned how to 


### Note on X


### Project Download
If you want to see what the finished template looks like after this lab, you can download it here:
<button>
  [Template Done Project](https://cent.felk.cvut.cz/courses/39HRY/godot/10_VFX/template-done.zip)
</button>
