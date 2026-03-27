# Snacks.nvim on_show Timing - Quick Reference

## TL;DR

**When is on_show called?** AFTER all windows are visible and initialized.  
**Can you animate?** YES - windows are ready, use `picker.layout.wins.{input,list,preview}`  
**Is it synchronous?** YES - called directly in the normal execution flow  
**Best for?** Cross-window operations, animations, high-level initialization  

---

## Critical File Locations

| What | File | Lines |
|------|------|-------|
| Picker's show() method | `lua/snacks/picker/core/picker.lua` | 483-496 |
| Layout's show() method | `lua/snacks/layout.lua` | 579-584 |
| Layout's update() (where windows display) | `lua/snacks/layout.lua` | 234-303 |
| Window's show() method | `lua/snacks/win.lua` | 819-902 |
| Window's on_win callback | `lua/snacks/win.lua` | 872-873 |
| List's on_show() method | `lua/snacks/picker/core/list.lua` | Line ~380 |

---

## Execution Order (Simplified)

```
picker:show()
  ↓
layout:show()
  ↓
layout:update()
  ↓
for each window:
  window:show()
    ↓
    window is displayed
    on_win() callback fires
  ↓
picker:focus() [optional]
  ↓
on_show(picker) ← USER'S CALLBACK (WINDOWS ARE VISIBLE)
```

---

## Window Status at on_show

| Property | Status |
|----------|--------|
| Windows exist | ✓ Created |
| Windows displayed | ✓ Visible on screen |
| Window IDs valid | ✓ Can use `win.win` |
| Buffers populated | ✓ Have content |
| Window options set | ✓ All applied |
| Layout complete | ✓ Fully calculated |
| All windows shown | ✓ All visible |
| User focus set | May not be (happens after) |

---

## Code Pattern for Animation

```lua
Snacks.picker.explorer {
  on_show = function(picker)
    -- Windows are visible here
    local list_win = picker.layout.wins.list
    if list_win and list_win:valid() then
      local win_id = list_win.win
      -- Animate now or schedule animation
      vim.schedule(function()
        -- Animation code
      end)
    end
  end
}
```

---

## Callback Comparison

| Callback | When | Windows | Use For |
|----------|------|---------|---------|
| `on_buf` | Before window opens | Not yet | Buffer setup |
| `on_win` | After window opens | Per window | Window init |
| `on_show` | After all shown | All visible | Animations, cross-window ops |
| `on_change` | On item change | May not exist | Reactive updates |

---

## Why Animation Might Fail

1. **Using on_change instead of on_show** → Window might not exist yet
2. **Animation library incompatible** → Not compatible with floating windows
3. **Too fast animation** → Not visible before next redraw
4. **Wrong window handle** → Using wrong `win.win` value
5. **Executing before on_show** → Creating picker but not calling `:show()`

---

## How to Verify Callback is Running

```lua
on_show = function(picker)
  print("Called!")
  vim.api.nvim_set_hl(0, "TestHL", { bg = "red" })
end
```

Then check `:messages` for "Called!" and look for red highlight in the picker.

---

## Key Code Snippet

From `/lua/snacks/picker/core/picker.lua` lines 484-496:

```lua
function M:show()
  if self.shown or self.closed then
    return
  end
  self.shown = true
  self.layout:show()              -- ← Windows become visible
  if self.opts.focus ~= false and self.opts.enter ~= false then
    self:focus()
  end
  if self.opts.on_show then
    self.opts.on_show(self)       -- ← Called HERE - windows ARE visible
  end
end
```

---

## Explorer-Specific Notes

Explorer uses picker under the hood. The only special thing:
- Focus is deferred to UIEnter event
- But on_show is NOT skipped

So animations still work with explorer:
```lua
Snacks.explorer.open {
  on_show = function(picker)
    -- This WILL be called
    -- Windows ARE visible
  end
}
```

---

## Next Steps If Animation Doesn't Work

1. Verify on_show is called: Add `print()` statement
2. Verify window is valid: Check `picker.layout.wins.list:valid()`
3. Try scheduling: Wrap in `vim.schedule()`
4. Check animation library: Does it support floating windows?
5. Try simpler animation: Just change a highlight, no complex animation
6. Check for errors: Look at `:messages` and `:checkhealth`

---

## Files Modified in Analysis

- `/home/cush/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/core/picker.lua`
- `/home/cush/.local/share/nvim/lazy/snacks.nvim/lua/snacks/layout.lua`
- `/home/cush/.local/share/nvim/lazy/snacks.nvim/lua/snacks/win.lua`
- `/home/cush/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/core/list.lua`
- `/home/cush/.local/share/nvim/lazy/snacks.nvim/lua/snacks/explorer/init.lua`

