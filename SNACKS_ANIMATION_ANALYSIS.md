# Snacks.nvim Animation Configuration Analysis

## Summary

**Animations are NOT available for the explorer picker or other pickers in snacks.nvim.** The animation system (`Snacks.animate`) is a **general-purpose animation library**, not a picker feature.

## What I Found

### 1. Animation Library Location
- **Path**: `/lua/snacks/animate/init.lua`
- **Purpose**: General-purpose animation utility used by snacks modules (scroll, indent, dim, etc.)
- **NOT part of picker system**

### 2. Modules Using Animations
The animation system is currently used by:
1. **`scroll`** - Smooth scrolling animations with configurable easing
2. **`indent`** - Indentation scope animations
3. **`dim`** - Window dimming animations

These are **global snacks features**, not picker-specific features.

### 3. Explorer/Picker Configuration
**File**: `/lua/snacks/picker/config/sources.lua` (lines 39-111)

The explorer source configuration shows:
```lua
M.explorer = {
  finder = "explorer",
  sort = { fields = { "sort" } },
  supports_live = true,
  tree = true,
  watch = true,
  diagnostics = true,
  -- ... other fields ...
  layout = { preset = "sidebar", preview = false },
  formatters = { ... },
  matcher = { sort_empty = false, fuzzy = false },
  win = {
    list = {
      keys = { ... },
    },
  },
}
```

**There is NO `animate` field in the explorer or any picker source configuration.**

### 4. Window Configuration
**File**: `/lua/snacks/win.lua` (1352 lines)

Window configuration supports:
- Floating windows
- Split windows  
- Borders, backdrops, dimensions
- Window options, buffer options, keymaps

**No animation configuration for window positioning or appearance changes.**

### 5. Picker Types and Configuration
**Files**:
- `/lua/snacks/picker/config/defaults.lua` - Default picker options
- `/lua/snacks/picker/config/sources.lua` - Source-specific configs
- `/lua/snacks/picker/source/explorer.lua` - Explorer source implementation

**Analyzed sources**: explorer, files, buffers, grep, git_status, diagnostics, lsp_*, etc.
**Result**: NONE have animation configuration.

## Why No Picker Animations?

1. **Pickers are for searching/navigation** - Not visual animations
2. **Animation system is for value transitions** - Like scroll position, opacity, etc.
3. **Pickers could theoretically use animations for**:
   - Expanding/collapsing tree items (explorer)
   - Smooth list scrolling within picker
   - Window entrance/exit effects
   - BUT: These are not implemented in current snacks.nvim

## How to Check if Animation Config Should Exist

### Pattern Found in scroll.lua:
```lua
---@class snacks.scroll.Config
---@field animate snacks.animate.Config|{}
---@field animate_repeat snacks.animate.Config|{}|{delay:number}
local defaults = {
  animate = {
    duration = { step = 10, total = 200 },
    easing = "linear",
  },
  animate_repeat = {
    delay = 100,
    duration = { step = 5, total = 50 },
    easing = "linear",
  },
  filter = function(buf) ... end,
}
```

This pattern would be how to add animation to a feature, but:
- **Explorer source does NOT follow this pattern**
- **No other picker sources have this pattern**
- **Picker defaults do NOT reference animation**

## Animation API Structure

If animations were to be added to pickers, they would use:

```lua
Snacks.animate(from, to, callback, {
  duration = 20,              -- ms per step
  easing = "linear",          -- or other easing function
  fps = 120,                  -- global FPS setting
  int = true,                 -- interpolate to integer
  id = "unique_id",           -- animation ID
  buf = nil,                  -- optional buffer check
})
```

**Animation can be disabled**:
- `vim.g.snacks_animate = false` (globally)
- `vim.b.snacks_animate = false` (buffer-locally)

## Conclusion

### Question 1: How does explorer picker animate config work?
**Answer**: There is no animation configuration for the explorer picker. The `animate` field at the picker source level **does not exist and is not valid**.

### Question 2: Is animation a built-in feature for pickers?
**Answer**: No. Animations are NOT a built-in picker feature. The animation system is a general utility used by other snacks modules (scroll, indent, dim).

### Question 3: Correct configuration for picker animations?
**Answer**: There is no official configuration because animations are not implemented for pickers. If you want animations:
1. You'd need to implement them manually using `Snacks.animate()`
2. This would require custom code in a picker action/hook
3. The explorer picker source would need to be extended

### Question 4: Where should animate config be placed?
**Answer**: 
- NOT in picker sources (it's not supported)
- NOT in `picker.win.list`
- NOT in `picker.layout`
- **If implemented, it would be at the module level** (like `scroll`, `indent`, `dim`) with its own config object

## Files Examined

1. ✅ `/lua/snacks/picker/source/explorer.lua` - Explorer source (375 lines)
2. ✅ `/lua/snacks/picker/config/sources.lua` - All source configurations (1093 lines)
3. ✅ `/lua/snacks/picker/config/defaults.lua` - Picker defaults (460 lines)
4. ✅ `/lua/snacks/picker/core/list.lua` - List rendering (645 lines)
5. ✅ `/lua/snacks/animate/init.lua` - Animation library (208 lines)
6. ✅ `/lua/snacks/scroll.lua` - Example of animation usage (402 lines)
7. ✅ `/lua/snacks/win.lua` - Window management (1352 lines)
8. ✅ `/docs/picker.md` - Picker documentation (3360 lines)
9. ✅ `/docs/animate.md` - Animation documentation (133 lines)
10. ✅ `/docs/explorer.md` - Explorer documentation (192 lines)
