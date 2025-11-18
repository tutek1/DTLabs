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



## Changes in the Project TODO
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

For testing purposes let's also add an image so that we can see the effect.

1. **Add** a `Sprite2D` node as a child of the `VFXManager`
2. **Set** the `Texture` property to `icon.svg`
3. **Move** the `Sprite2D` to the threshold of the `GrayscaleRect` (similar to the image below)

![](img/GodotKuk.png)


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
The `SCREEN_UV` is a variable that holds the `UV` coordinates of the pixel on the screen.

The last line in the fragment shader sets the `COLOR` variable, which is the final pixel color, to the sampled color. If you save the shader file (`CTRL + S`), you should now see that the `GrayscaleRect` is transparent in the scene.

![](img/TransparentRect.png)

> aside positive
> Colors are stored as `Vector4` since a color is composed of the RGB channels and the alpha channel.

#### Get the Grayscale Color
To make the color grayscale, we can easily average all the RGB channels, create a new vector with this value, and set it as the final color.

```C
...
void fragment() {
    ...
    float avg = (color.r + color.g + color.b) / 3.0f;
    vec4 grayscale = vec4(avg, avg, avg, 1.0f);
    COLOR = grayscale;
}
...
```

> aside positive
> You can index vectors in shaders with any of these `(x, y, z, w)`, `(r, g, b, a)`, or `(s, t, p, q)`, the result is the same.

#### Control the Grayscale
TODO






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

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

```



### Player On-hit Effect


## Hologram Shader - Visual
Duration: hh:mm:ss

### Setup

#### Shader

#### Test Object

### Scan lines

### Fresnel Effect

### Vertex Glitch

### Glow in scene


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
