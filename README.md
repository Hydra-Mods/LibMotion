# LibMotion

LibMotion is a powerful animation library, providing an easy-to-use API to create dynamic animations and transitions.

## Features

- **Animation Creation**: Create animations for various properties such as position, size, opacity, color, and more.
- **Easing Functions**: Choose from a variety of easing functions to define animation curves and achieve smooth transitions.
- **Animation Grouping**: Group multiple animations together to create complex sequences and coordinate timing.
- **Event System**: Trigger custom actions at specific animation milestones, such as start, completion, or progress points.
- **Lightweight and Efficient**: Built with performance in mind, ensuring smooth animations with minimal impact on system resources.

### Usage

### Creating an Animation
```lua
local animation = LibMotion:CreateAnimation(parent, animType)
```

### Animation Types
LibMotion supports various animation types, including:

- **move**: Movement animation for changing object position.
- **fade**: Fade animation for adjusting object opacity.
- **height**: Height animation for resizing objects vertically.
- **width**: Width animation for resizing objects horizontally.
- **color**: Color animation for changing object colors.
- **progress**: Progress animation for controlling progress bars.
- **scale**: Scale animation for scaling objects.
- **path**: Path animation for animating objects along a predefined path.
- **gif**: GIF animation for creating animated textures.
- **typewriter**: Typewriter animation for simulating typing effect.

### Creating an Animation Group
```lua
local animationGroup = LibMotion:CreateAnimationGroup()
```

## Animation Controls
- **animation:Play()**: Play the animation.
- **animation:IsPlaying()**: Check if the animation is currently playing.
- **animation:Pause()**: Pause the animation.
- **animation:IsPaused()**: Check if the animation is currently paused.
- **animation:Stop(reset)**: Stop the animation. Pass **reset** as **true** to reset the animation to its pre-played state.
- **animation:IsStopped()**: Check if the animation is currently stopped.
- **animation:Reset()**: Reset the animation to its pre-played state.
- **animation:Finish()**: Set the animation to its finished state.
- **animation:SetDuration(duration)**: Set the duration of the animation.
- **animation:GetDuration()**: Get the duration of the animation in seconds.
- **animation:SetStartDelay(delay)**: Set the delay before the animation starts.
- **animation:GetStartDelay()**: Get the delay before the animation starts.
- **animation:SetEndDelay(delay)**: Set the delay after the animation ends.
- **animation:GetEndDelay()**: Get the delay after the animation ends.
- **animation:SetEasing(easing)**: Set the easing type used by the animation.
- **animation:GetEasing()**: Get the easing type used by the animation.
- **animation:SetProgress(progress)**: Set the progress of the animation from 0 to 1.
- **animation:GetProgress()**: Get the progress of the animation from 0 to 1.
- **animation:SetOrder(order)**: Set the play order of the animation if it belongs to a group.
- **animation:GetOrder()**: Get the play order of the animation.
- **animation:SetParent(parent)**: Set the object that the animation controls.
- **animation:GetParent()**: Get the object that the animation controls.
- **animation:SetGroup(group)**: Add the animation to a group or remove it from its current group.
- **animation:GetGroup()**: Get the animation group.
- **animation:SetScript(event, func)**: Set a callback to be fired on an event.
- **animation:GetScript(event)**: Get the callback to be fired on an event.

In addition to these common animation controls, each animation type in LibMotion provides additional controls specific to that type. Here's an overview of the animation types and their additional controls:

## Move
- **animation:SetOffset(x, y)**: Set the x and y offset of a movement animation.
- **animation:GetOffset()**: Get the x and y offset of a movement animation.
- **animation:SetSmoothPath(smooth)**: Set a movement animation to use a smooth path rather than linear.
- **animation:GetSmoothPath()**: Get whether a movement animation will use a smooth path rather than linear.

## Fade
- **animation:SetChange(alpha)**: Set the alpha change of a fade animation.
- **animation:GetChange()**: Get the alpha change of a fade animation.

## Height
- **animation:SetChange(height)**: Set the change of a height animation.
- **animation:GetChange()**: Get the change of a height animation.

## Width
- **animation:SetChange(width)**: Set the change of a width animation.
- **animation:GetChange()**: Get the change of a width animation.

## Color
- **animation:SetChange(r, g, b)**: Set the RGB change of a color animation.
- **animation:GetChange()**: Get the RGB change of a color animation.
- **animation:SetColorType(region)**: Define what a color animation will colorize.
- **animation:GetColorType()**: Get what a color animation will colorize.

The **SetColorType** method allows you to specify the region or element that the color animation will affect. You can choose from the following options for the **region** parameter:

- **backdrop**: Colorize the backdrop of the parent frame.
- **border**: Colorize the border of the parent frame.
- **statusbar**: Colorize the status bar of the parent frame.
- **text**: Colorize the text of the parent fontstring.
- **texture**: Colorize the texture of the parent texture.
- **vertex**: Colorize the vertex color of the parent texture.

## Progress
- **animation:SetChange(value)**: Set the change of a progress animation.
- **animation:GetChange()**: Get the change of a progress animation.

## Number
- **animation:SetChange(value)**: Set the change of a number animation.
- **animation:GetChange()**: Get the change of a number animation.
- **animation:SetStart(value)**: Set the start value of a number animation.
- **animation:GetStart()**: Get the start value of a number animation.
- **animation:SetPrefix(text)**: Set the prefix text of a number animation.
- **animation:GetPrefix()**: Get the prefix text of a number animation.
- **animation:SetPostfix(text)**: Set the postfix text of a number animation.
- **animation:GetPostfix()**: Get the postfix text of a number animation.

## Scale
- **animation:SetChange(scale)**: Set the change of a scale animation.
- **animation:GetChange()**: Get the change of a scale animation.

## Path
- **animation:SetPath(path)**: Set the path for a path animation.
- **animation:SetSmoothPath(smooth)**: Set whether a path animation should use a smooth path.

## GIF
- **animation:SetFrameDuration(duration)**: Set the frame duration for a GIF animation.
- **animation:GetFrameDuration()**: Get the frame duration for a GIF animation.
- **animation:SetFrames(list)**: Set the frames for a GIF animation.
- **animation:GetFrames()**: Get the frames for a GIF animation.

## Group Controls
- **animationGroup:Play()**: Play the animation group.
- **animationGroup:IsPlaying()**: Check if the animation group is currently playing.
- **animationGroup:Pause()**: Pause the animation group.
- **animationGroup:IsPaused()**: Check if the animation group is currently paused.
- **animationGroup:Stop()**: Stop the animation group.
- **animationGroup:IsStopped()**: Check if the animation group is currently stopped.
- **animationGroup:SetLooping(loop)**: Set whether the animation group should loop.
- **animationGroup:GetLooping()**: Get whether the animation group should loop.
- **animationGroup:SetParent(parent)**: Set the object that the animation group controls.
- **animationGroup:GetParent()**: Get the object that the animation group controls.
- **animationGroup:SetScript(event, func)**: Set a callback to be fired on an event.
- **animationGroup:GetScript(event)**: Get the callback to be fired on an event.

## Easing Types
- **linear**
- **inquadratic**
- **outquadratic**
- **inoutquadratic**
- **incubic**
- **outcubic**
- **inoutcubic**
- **inquartic**
- **outquartic**
- **inoutquartic**
- **inquintic**
- **outquintic**
- **inoutquintic**
- **insinusoidal**
- **outsinusoidal**
- **inoutsinusoidal**
- **inexponential**
- **outexponential**
- **inoutexponential**
- **incircular**
- **outcircular**
- **inoutcircular**
- **outbounce**
- **inbounce**
- **inoutbounce**
- **inelastic**
- **outelastic**
- **inoutelastic**
- **in** (alias for inquadratic)
- **out** (alias for outquadratic)
- **inout** (alias for inoutquadratic)

These easing types can be used with the animation:SetEasing() method to customize the animation's movement.

## Animation Callbacks
LibMotion provides callback functions that can be set to execute at specific animation milestones. These callbacks allow you to perform custom actions during the animation. Here are the available animation callbacks:

- **OnPlay**: Executed when the animation starts playing.
- **OnPause**: Executed when the animation is paused.
- **OnStop**: Executed when the animation is stopped.
- **OnResume**: Executed when the animation is resumed from a paused state.
- **OnReset**: Executed when the animation is reset.
- **OnFinished**: Executed when the animation completes its full duration.

To set a callback, use the following method:

```lua
animation:SetScript(event, func)
```

Where **event** is the animation milestone event (e.g., "OnPlay") and **func** is the callback function.

## Animation Group Callbacks
Similar to animation callbacks, animation groups in LibMotion also support callbacks that can be set to execute at specific group milestones. These callbacks allow you to perform actions when the animation group reaches a certain state. Here are the available animation group callbacks:

- **OnPlay**: Executed when the animation group starts playing.
- **OnPause**: Executed when the animation group is paused.
- **OnStop**: Executed when the animation group is stopped.
- **OnFinished**: Executed when the animation group completes its full duration.
- **OnLoop**: Executed each time the animation group loops (if looping is enabled).

To set a callback for an animation group, use the following method:

```lua
animationGroup:SetScript(event, func)
```

Where **event** is the animation group milestone event (e.g., "OnPlay") and **func** is the callback function.

## Example Usage
Here's an example that demonstrates how to use SetScript:
```lua
local animation = LibMotion:CreateAnimation(frame, "fade")
animation:SetScript("OnFinished", function(self)
    print("Animation complete!")
end)
animation:Play()
```

In this example, an animation is created to fade a frame using the "fade" animation type. The OnFinished callback is registered to print a message when the animation completes.