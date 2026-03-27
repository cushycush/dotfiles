# Snacks.nvim on_show Callback Timing & Execution Analysis

## Summary

The `on_show` callback in snacks.nvim picker is called **AFTER** the layout windows have been shown and are visible. The callback executes synchronously within the normal flow, not in a deferred/scheduled manner.

---

## Execution Timeline

### 1. Picker Creation & Initialization (`M.new()` in picker.lua:81-145)
- Picker object is created and configured
- Layout is initialized via `init_layout()` but with `show = false`
- Windows are created but NOT yet displayed
- `on_win` callbacks are NOT triggered at this point

### 2. Picker Display Trigger (`M:show()` in picker.lua:483-496)
When the picker is ready to display:

```lua
function M:show()
  if self.shown or self.closed then
    return
  end
  self.shown = true
  self.layout:show()                    -- ← STEP 1: Show layout
  if self.opts.focus ~= false and self.opts.enter ~= false then
    self:focus()
  end
  if self.opts.on_show then             -- ← STEP 4: Call on_show
    self.opts.on_show(self)
  end
end
```

### 3. Layout Display (`M:show()` in layout.lua:579-584)
```lua
function M:show()
  if self:valid() then
    return
  end
  self:update()                          -- ← Calls layout update
end
```

### 4. Layout Update (`M:update()` in layout.lua:234-303)
This is where windows actually become visible:

```lua
function M:update()
  if self.closed then return end
  vim.o.lazyredraw = true
  for _, win in pairs(self.wins) do
    win.enabled = false
  end
  local layout = vim.deepcopy(self.opts.layout)
  -- ... calculate dimensions ...
  
  -- CRUCIAL: Windows are shown here
  for _, win in pairs(self:get_wins()) do
    if win:valid() then
      -- Window already exists, just update
      local ei = vim.o.eventignore
      vim.o.eventignore = "all"
      win:update()
      vim.o.eventignore = ei
    else
      -- Window doesn't exist, show it
      win:show()                         -- ← WINDOWS ARE SHOWN
    end
  end
  -- ...
  
  if self.opts.on_update then
    self.opts.on_update(self)
  end
end
```

### 5. Window Display (`M:show()` in win.lua:819-875)
When `win:show()` is called:

```lua
function M:show()
  if self:valid() then
    self:update()
    return self
  end
  
  self.augroup = vim.api.nvim_create_augroup("snacks_win_" .. self.id, { clear = true })
  self:open_buf()
  
  -- ... buffer setup ...
  
  self:open_win()                        -- ← Window is created/opened
  self.closed = false
  
  -- ... window local vars & options ...
  
  Snacks.util.wo(self.win, self.opts.wo)
  if self.opts.on_win then
    self.opts.on_win(self)               -- ← on_win callback fires HERE
  end
  
  -- ... more setup ...
  
  self:map()
  self:drop()
  
  return self
end
```

### 6. on_win Callback Execution
In the list window, `on_win` calls `on_show()`:

```lua
on_win = function()
  self:on_show()                         -- ← For list windows
  lists[self.win.win] = self
end
```

Which executes:
```lua
function M:on_show()
  self.state.scrolloff = vim.wo[self.win.win].scrolloff
  self.state.scroll = vim.wo[self.win.win].scroll
  self.state.height = vim.api.nvim_win_get_height(self.win.win)
  self.state.mousescroll = tonumber(vim.o.mousescroll:match("ver:(%d+)")) or 1
  Snacks.util.wo(self.win.win, { scrolloff = 0 })
  self.dirty = true
  self:update_cursorline()
  self:update({ force = true })          -- ← Updates list content
end
```

### 7. Picker's on_show Callback (`M:show()` line 493-495)
```lua
if self.opts.on_show then
  self.opts.on_show(self)                -- ← USER'S on_show FIRES HERE
end
```

---

## Key Timing Facts

### When on_show is Called:
1. **After** `layout:show()` completes
2. **After** `layout:update()` completes
3. **After** all windows have been shown via `win:show()`
4. **After** all `on_win` callbacks have executed (including list's `on_show()`)
5. **Before** `picker:focus()` is called (if focus is enabled)
6. **Synchronously** - NOT in a vim.schedule/vim.defer_fn block

### Window Visibility:
- Windows ARE visible and valid when `on_show` is called
- The list has been updated with items
- All window options are set
- Layout calculations are complete

---

## Window Creation Sequence

```
picker.new()
  ↓
picker:init_layout(layout)  ← Layout created with show=false
  ↓
layout = Snacks.layout.new() ← Windows CREATED but NOT shown
  ↓
[Later when picker:show() is called]
  ↓
picker:show()
  ↓
layout:show()
  ↓
layout:update()
  ↓
for each win in layout.wins:
  win:show()
    ↓
    win:open_buf()
    win:open_win()  ← Window actually appears on screen
    on_win()        ← Window callbacks fire
    
For list window specifically:
    on_win = function()
      list:on_show()  ← List updates itself
      ...
    end
  ↓
picker:focus() [if enabled]
  ↓
picker.opts.on_show(picker)  ← USER'S CALLBACK HERE
```

---

## Explorer-Specific Behavior

The explorer picker has special handling in `/home/cush/.local/share/nvim/lazy/snacks.nvim/lua/snacks/explorer/init.lua:39`:

```lua
picker:show()
local ref = picker:ref()
-- focus on UIEnter, since focusing before doesn't work
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  group = group,
  callback = function()
    local p = ref()
    if p then
      p:focus()
    end
  end,
})
```

**Note:** The explorer doesn't bypass `on_show()` - it just defers the focus operation to UIEnter.

---

## on_show vs on_win vs on_buf

| Callback | Location | When Called | Use Case |
|----------|----------|-------------|----------|
| `on_buf` | win.lua:839 | After buffer is setup but before window opens | Buffer-level initialization |
| `on_win` | win.lua:872 | **After window is opened and visible** | Window-level operations |
| `on_show` (picker) | picker.lua:493 | **After ALL windows shown and layout:focus() called** | High-level picker initialization |

---

## Animation Callback Execution

If you're using `on_show` for animations:

**The windows ARE visible and ready for animation:**
- Window handles are valid (`win.win` is set)
- Windows are displayed on screen
- Buffer content is populated
- All window options are applied

**What's NOT guaranteed at on_show time:**
- User focus state (focus might happen after on_show)
- The exact screen rendering (might not be drawn to screen yet on very first redraw)

**To animate, you might need:**

```lua
on_show = function(picker)
  -- Option 1: Direct animation (windows are ready)
  local list_win = picker.layout.wins.list
  if list_win and list_win:valid() then
    -- Animate immediately - window is open
    animate_window(list_win.win)
  end
  
  -- Option 2: Schedule to next redraw
  vim.schedule(function()
    if picker.layout and picker.layout.wins.list:valid() then
      animate_window(picker.layout.wins.list.win)
    end
  end)
  
  -- Option 3: Use UIEnter (guaranteed visual render)
  vim.api.nvim_create_autocmd("UIEnter", {
    once = true,
    callback = function()
      if picker.layout and picker.layout.wins.list:valid() then
        animate_window(picker.layout.wins.list.win)
      end
    end,
  })
end
```

---

## Why Your Animation Might Not Be Visible

1. **Wrong timing**: If you're using `on_change` instead of `on_show`, the window might not exist yet
2. **Animation is too fast**: Try adding a slight delay with `vim.schedule()`
3. **Wrong window handle**: Verify you're animating the right window (list, input, preview)
4. **Animation library issue**: Check if the animation library works with floating windows
5. **Colorscheme/highlight issue**: The animation might be setting colors that don't render

---

## How to Verify on_show is Being Called

```lua
on_show = function(picker)
  print("on_show called!")
  print("List window valid:", picker.layout.wins.list:valid())
  print("List window id:", picker.layout.wins.list.win)
  print("List buffer lines:", vim.api.nvim_buf_line_count(picker.layout.wins.list.buf))
end
```

Check `:messages` to see if it prints.

---

## Summary for Animation Implementation

**Best Hook Point**: `on_show` callback  
**Windows Status**: Visible and ready  
**When to Animate**: Inside `on_show` or in `vim.schedule()`  
**Can Access**: `picker.layout.wins.{input,list,preview}` - all are valid  
**Animation Timing**: Immediate (synchronous) or `vim.schedule()` for next frame
