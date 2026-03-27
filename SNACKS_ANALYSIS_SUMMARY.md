# Snacks.nvim on_show Callback Analysis - Complete Summary

## Overview

This analysis covers the complete execution flow of the `on_show` callback in snacks.nvim picker, including exact timing, window visibility state, and implementation guidance for animations and other callbacks.

---

## Key Findings

### 1. on_show Callback Timing

**The `on_show` callback is called AFTER all windows are visible and fully initialized.**

Timeline:
```
1. picker:show() is called
2. layout:show() is called
3. layout:update() calculates dimensions
4. Each window calls win:show()
   - Window is created on screen
   - on_win callbacks execute
   - List updates its content via on_show()
5. picker:focus() is called (if enabled)
6. on_show(picker) is CALLED ← USER'S CALLBACK
```

### 2. Window State at on_show Callback

**Windows ARE visible and ready to use:**
- ✓ Windows are displayed on screen
- ✓ Window IDs are valid: `picker.layout.wins.{input,list,preview}.win`
- ✓ All buffers have content
- ✓ All window options have been applied
- ✓ Layout is complete and finalized

### 3. Execution is Synchronous

The callback is NOT deferred or scheduled:
- It runs in the normal Lua execution flow
- No `vim.schedule()` or `vim.defer_fn()` wrapping
- Executes immediately after `layout:show()` completes

### 4. Explorer-Specific Behavior

The explorer picker does NOT have special behavior that skips `on_show`:
- It uses the picker infrastructure under the hood
- `on_show` will be called normally
- The only special thing is focus is deferred to UIEnter event

---

## Detailed Execution Flow

### Step 1: Picker Creation (picker.lua lines 81-145)
```lua
function M.new(opts)
  -- Picker is created
  -- init_layout() is called with show=false
  -- Windows are created but NOT shown
  -- on_win callbacks NOT triggered here
end
```

### Step 2: Picker Display (picker.lua lines 484-496)
```lua
function M:show()
  self.shown = true
  self.layout:show()           -- ← Step 1: Show layout
  if self.opts.focus ~= false then
    self:focus()               -- ← Step 2: Focus (optional)
  end
  if self.opts.on_show then
    self.opts.on_show(self)    -- ← Step 3: USER'S CALLBACK
  end
end
```

### Step 3: Layout Display (layout.lua lines 579-584)
```lua
function M:show()
  if self:valid() then
    return
  end
  self:update()                -- ← Calls M:update()
end
```

### Step 4: Layout Update - Where Windows Appear (layout.lua lines 234-303)
```lua
function M:update()
  -- ... dimension calculations ...
  
  -- CRUCIAL: Windows are shown here (lines 282-292)
  for _, win in pairs(self:get_wins()) do
    if win:valid() then
      win:update()
    else
      win:show()              -- ← WINDOWS DISPLAYED HERE
    end
  end
end
```

### Step 5: Window Display (win.lua lines 819-902)
```lua
function M:show()
  -- ... setup ...
  self:open_win()             -- ← Line 862: Window appears
  -- ... apply options ...
  if self.opts.on_win then
    self.opts.on_win(self)    -- ← Line 872: on_win fires
  end
end
```

### Step 6: List's on_show Method (list.lua)
```lua
-- In list's on_win callback:
on_win = function()
  self:on_show()              -- ← Calls list's on_show()
end

-- List's on_show():
function M:on_show()
  -- ... state initialization ...
  self:update({ force = true }) -- ← Updates with items
end
```

---

## File Locations

| Component | File | Lines |
|-----------|------|-------|
| Picker's show() | `lua/snacks/picker/core/picker.lua` | 483-496 |
| Layout's show() | `lua/snacks/layout.lua` | 579-584 |
| Layout's update() | `lua/snacks/layout.lua` | 234-303 |
| Window's show() | `lua/snacks/win.lua` | 819-902 |
| Window's on_win | `lua/snacks/win.lua` | 872-873 |
| List's on_win setup | `lua/snacks/picker/core/list.lua` | ~95 |
| List's on_show() | `lua/snacks/picker/core/list.lua` | ~380 |
| Explorer handling | `lua/snacks/explorer/init.lua` | 39 |

---

## Using on_show for Animations

### Best Practice Pattern

```lua
Snacks.picker.explorer {
  on_show = function(picker)
    -- Windows are visible here
    local list_win = picker.layout.wins.list
    if list_win and list_win:valid() then
      -- Animate the list window
      local win_id = list_win.win
      -- Option 1: Animate immediately (synchronous)
      animate_window(win_id)
      
      -- Option 2: Schedule for next frame
      vim.schedule(function()
        animate_window(win_id)
      end)
    end
  end
}
```

### Animation Callback Availability

The `on_show` callback can access:
- `picker.layout.wins.input` - Input window
- `picker.layout.wins.list` - List window
- `picker.layout.wins.preview` - Preview window (if enabled)
- Window IDs via `.win` property
- Buffer IDs via `.buf` property

All are valid and safe to use.

---

## Callback Comparison

| Callback | Location | When Called | Window State | Best For |
|----------|----------|------------|--------------|----------|
| `on_buf` | win.lua:839 | Before window opens | Buffer created only | Buffer setup |
| `on_win` | win.lua:872 | After window opens | Window visible, per-window | Window initialization |
| `on_show` (picker) | picker.lua:493 | After all shown | All windows visible | Animations, cross-window |
| `on_change` | N/A | When item selected | May not be visible | Reactive updates |

---

## Why on_show is the Right Choice

1. **Windows are guaranteed to exist and be visible**
   - Not like `on_buf` or early `on_change`

2. **All windows are shown**
   - Can animate the entire layout, not just one window
   - Can access relationships between windows

3. **Layout calculations are complete**
   - Window dimensions are final
   - Positions are known

4. **Synchronous execution**
   - Runs immediately, no timing uncertainty
   - Can chain operations without additional scheduling

5. **Access to full picker context**
   - Can query current state
   - Can access other picker methods

---

## Common Issues & Solutions

### Issue 1: Animation Not Visible
**Cause**: Animation running before screen redraw  
**Solution**: Use `vim.schedule()`:
```lua
on_show = function(picker)
  vim.schedule(function()
    -- Animation code here
  end)
end
```

### Issue 2: Using on_change Instead of on_show
**Cause**: Window might not be visible yet  
**Solution**: Use `on_show` for initialization/animations

### Issue 3: Wrong Window Handle
**Cause**: Accessing non-existent window property  
**Solution**: Check window validity:
```lua
local win = picker.layout.wins.list
if win and win:valid() then
  -- Safe to use win.win
end
```

### Issue 4: Animation Library Incompatible
**Cause**: Library doesn't work with floating windows  
**Solution**: Try alternative animation approach or library

---

## Testing Verification

Quick test to verify on_show is being called:

```lua
on_show = function(picker)
  -- Test 1: Print message
  print("✓ on_show called!")
  
  -- Test 2: Check window validity
  if picker.layout.wins.list:valid() then
    print("✓ List window valid")
  end
  
  -- Test 3: Check window ID
  if vim.api.nvim_win_is_valid(picker.layout.wins.list.win) then
    print("✓ Window ID valid:", picker.layout.wins.list.win)
  end
  
  -- Test 4: Check buffer content
  local lines = vim.api.nvim_buf_line_count(picker.layout.wins.list.buf)
  if lines > 0 then
    print("✓ Buffer has", lines, "lines")
  end
end
```

Then check `:messages` output.

---

## Implementation Checklist

When implementing animations or other on_show operations:

- [ ] Using `on_show` callback (not `on_change` or other)
- [ ] Checking window validity with `:valid()` before use
- [ ] Accessing windows via `picker.layout.wins.{input,list,preview}`
- [ ] Testing with `print()` to verify callback is called
- [ ] Using `vim.schedule()` if animation needs frame timing
- [ ] Handling case where layout might be cleared
- [ ] Testing both immediate and scheduled animations
- [ ] Verifying animation library works with floating windows

---

## Document References

Three detailed analysis documents are included:

1. **snacks_on_show_analysis.md** - High-level overview and timing facts
2. **snacks_callback_reference.md** - Complete code reference with line numbers
3. **SNACKS_TIMING_QUICK_REFERENCE.md** - Quick lookup table and patterns

---

## Summary

The `on_show` callback in snacks.nvim is called **after all windows are visible and fully initialized**. It is the ideal hook point for animations and cross-window operations because:

1. Windows exist and are displayed
2. Window IDs are valid
3. Buffers are populated
4. Layout is complete
5. Execution is synchronous

Use this callback for animations, highlight changes, or other visual modifications that require the windows to be present and visible.

---

Generated: 2026-03-22  
Source: Snacks.nvim lazy plugin at `/home/cush/.local/share/nvim/lazy/snacks.nvim/`
