# LibMotion

LibMotion is a powerful animation library for Lua, providing developers with an easy-to-use API to create dynamic animations and transitions in Lua projects.

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
local animationGroup = LibMotion:CreateAnimationGroup(parent)
```