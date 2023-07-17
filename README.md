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
- **animation:Stop(reset)**: Stop the animation. Pass `reset` as `true` to reset the animation to its pre-played state.
- **animation:IsStopped()**: Check if the animation is currently stopped.
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

These easing types can be used with the SetEasing() method to customize the animation's movement.

## Animation Callbacks
LibMotion provides callback functions that can be set to execute at specific animation milestones. These callbacks allow you to perform custom actions during the animation. Here are the available animation callbacks:

**OnPlay**: Executed when the animation starts playing.
**OnPause**: Executed when the animation is paused.
**OnStop**: Executed when the animation is stopped.
**OnResume**: Executed when the animation is resumed from a paused state.
**OnReset**: Executed when the animation is reset.
**OnFinished**: Executed when the animation completes its full duration.

To set a callback, use the following method:

```lua
animation:SetCallback(event, func)
```

Where `*event*` is the animation milestone event (e.g., "OnPlay") and `*func*` is the callback function.

## Animation Group Callbacks
Similar to animation callbacks, animation groups in LibMotion also support callbacks that can be set to execute at specific group milestones. These callbacks allow you to perform actions when the animation group reaches a certain state. Here are the available animation group callbacks:

**OnPlay**: Executed when the animation group starts playing.
**OnPause**: Executed when the animation group is paused.
**OnStop**: Executed when the animation group is stopped.
**OnFinished**: Executed when the animation group completes its full duration.
**OnLoop**: Executed each time the animation group loops (if looping is enabled).

To set a callback for an animation group, use the following method:

```lua
animationGroup:SetCallback(event, func)
```

Where `*event*` is the animation group milestone event (e.g., "OnPlay") and `*func*` is the callback function.

## Example Usage
Here's an example that demonstrates how to create an animation and use easing functions:
```lua
local animation = LibMotion:CreateAnimation(frame, "fade")
animation:SetDuration(2.5) -- Set the duration of the animation to 2.5 seconds
animation:SetScript("OnFinished", function(self)
    print("Animation complete!")
end)
animation:Play()
```

In this example, an animation is created to fade a frame using the "fade" animation type. The OnFinished callback is registered to print a message when the animation completes.