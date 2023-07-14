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
- **sleep**: Animation for adding delays in animation sequences.
- **number**: Number animation for animating numerical values.
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
- **animation:Stop(reset)**: Stop the animation. Pass reset as true to reset the animation to its pre-played state.
- **animation:IsStopped()**: Check if the animation is currently stopped.
- **animation:SetEasing(easing)**: Set the easing type used by the animation.
- **animation:GetEasing()**: Get the easing type used by the animation.
- **animation:SetDuration(duration)**: Set the duration of the animation.
- **animation:GetDuration()**: Get the duration of the animation in seconds.
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

## Group Methods
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