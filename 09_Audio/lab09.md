summary: UI
id: export
categories: Audio, Audio Manager, Audio Bus, Audio Stream, Audio Listener, Tween
status: Published
authors: Ondřej Kyzr
Feedback Link: https://forms.gle/J8eeuQAJ3wMY1Wnq7

# Lab09 - Audio

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
  [Template Project](https://cent.felk.cvut.cz/courses/39HRY/godot/09_Audio/template.zip)
</button>



## Audio Basics
Duration: hh:mm:ss

Let's first go through the basics of **playing audio** in Godot and look at the new folder with files I added.

### Audio Folder
I added a yellow-colored folder `Audio` with all the necessary stuff needed for this codelab. 

- `Ambient` folder - Hosts ambient sounds that will be played in certain areas
- `Music` folder - Hosts the music tracks that will be used in the game
- `SFX` folder - Hosts all the sound effects for the player and enemies
- `audio_manager.tscn` and `audio_manager.gd` - Autoloaded manager, that I made to make playing sounds and music easier, which we will complete in this codelab
- `sfx_settings.gd` - Resource to modify SFX settings which keeps track of the number of actively playing SFX


### Audio Bus
Every audio, that is played in Godot must be played on a **Audio Bus**. The most common use-case for having multiple buses is to play each audio type (music, SFX, ambient, voices...) on a separate audio bus. This allows you to set the volume, solo/mono, etc. for each audio type, as it is done in almost all games.

#### Definition
*An audio bus (also called an audio channel) can be considered a place that audio is channeled through on the way to playback through a device's speakers. Audio data can be modified and re-routed by an audio bus.* - [Godot Documentation](https://docs.godotengine.org/en/latest/tutorials/audio/audio_buses.html)

#### Godot Bus Layout
In Godot, you can find the Audio Bus settings at the bottom of the editor next to the `Debugger` tab. This is how it looks in our template:

![](img/AudioBusDefault.png)

There is a single "Master" audio bus present through which all audio is played by default. You can set many things for each bus such as the **volume**, **audio effects**, or **route bus** though another one (dropdown at the bottom).

#### Our Setup
We will create a very standard audio bus setup. Please **recreate the audio buses** as seen in the following picture:

![](img/AudioBusSetup.png)

> aside negative
> Make sure to **name the buses the same** as I did, since I already connected audio sliders to these bus names, more on that later on.

> aside positive
> **Bus routing** can be used to composite different buses, in our case we will just route all the buses to the `Master Bus`. This way the `Master Bus` will control the volume of all the other buses. 


### Audio Nodes
To play and listen to audio Godot provides several audio nodes. Here is a brief overview:
- <img src="img/AL2D.png" width="25"/> <img src="img/AL3D.png" width="25"/> `AudioListener2D/3D` - Usually not used since the current camera works as a listener by default, **overrides the location** sounds are heard from in 2D/3D, 
- <img src="img/AP.png" width="25"/> `AudioStreamPlayer` - **Plays the audio** equally loud in both speakers
- <img src="img/AP2D.png" width="25"/> <img src="img/AP3D.png" width="25"/> `AudioStreamPlayer2D/3D` - **Plays the audio** in 2D/3D space, that is **attenuated with distance and angle** to the listener, e.g. audio played 10 meters to the left of listener is quieter and heard more from the left speaker


### Debug Audio Sliders
For our convenience, I also created debug audio sliders for each audio bus and placed them on the player HUD, so that we can easily adjust the audio levels during this codelab.

![](img/DebugAudioSliders.png)


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
  [Template Done Project](https://cent.felk.cvut.cz/courses/39HRY/godot/09_Audio/template-done.zip)
</button>
