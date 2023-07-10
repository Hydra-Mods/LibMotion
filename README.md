# LibMotion

LibMotion is a powerful animation library for Lua, providing developers with an easy-to-use API to create dynamic animations and transitions in Lua projects.

## Features

- **Animation Creation**: Create animations for various properties such as position, size, opacity, color, and more.
- **Easing Functions**: Choose from a variety of easing functions to define animation curves and achieve smooth transitions.
- **Animation Grouping**: Group multiple animations together to create complex sequences and coordinate timing.
- **Event System**: Trigger custom actions at specific animation milestones, such as start, completion, or progress points.
- **Lightweight and Efficient**: Built with performance in mind, ensuring smooth animations with minimal impact on system resources.

### Usage

To create an animation:
```lua
local animation = LibMotion:CreateAnimation(parent, animType)
```
To create an animation group:
```lua
local animationGroup = LibMotion:CreateAnimationGroup(parent)
```