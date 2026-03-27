# Snacks.nvim on_show Callback - Detailed Code Reference

## Complete Call Stack with File References

### File 1: `/home/cush/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/core/picker.lua`

#### Line 81-145: Picker Creation
```lua
function M.new(opts)
  -- ... initialization ...
  self:init_layout(layout)  -- Creates layout with show=false
  -- ... more setup ...
  return self
end
```

**Key Point**: Windows exist but are NOT shown at this point.

#### Line 225-272: Layout Initialization
```lua
function M:init_layout(layout)
  layout = layout or Snacks.picker.config.layout(self.opts)
  self.resolved_layout = vim.deepcopy(layout)
  self.resolved_layout.cycle = self.resolved_layout.cycle == true
  self.preview:update(self)
  local opts = layout
  local backdrop = nil
  if self.preview.main then
    backdrop = false
  end
  self.layout = Snacks.layout.new(vim.tbl_deep_extend("force", opts, {
    show = false,              -- ← Windows NOT shown yet
    win = {
      wo = {
        winhighlight = Snacks.picker.highlight.winhl("SnacksPicker"),
      },
    },
    wins = {
      input = self.input.win,
      list = self.list.win,
      preview = self.preview.win,
    },
    hidden = layout.hidden,
    on_close = function()
      self:close()
    end,
    on_update = function()
      self.preview:refresh(self)
      self.input:update()
      self.list:update({ force = true })
      self:update_titles()
    end,
    on_update_pre = function()
      self:update_titles()
    end,
    layout = {
      backdrop = backdrop,
    },
  }))
  self:attach()
  return layout
end
```

#### Line 483-496: THE CRITICAL SHOW METHOD
```lua
function M:show()
  if self.shown or self.closed then
    return
  end
  self.shown = true
  self.layout:show()              -- ← STEP 1: Call layout:show()
  if self.opts.focus ~= false and self.opts.enter ~= false then
    self:focus()                  -- ← STEP 2: Focus (optional)
  end
  if self.opts.on_show then       -- ← STEP 3: Check for callback
    self.opts.on_show(self)       -- ← STEP 4: FIRE USER'S on_show
  end
end
```

**Timeline at this point**:
1. `layout:show()` has completed → all windows are visible
2. All `on_win` callbacks have fired
3. List window has called its `on_show()` method
4. Windows are fully initialized and displayed
5. NOW the user's `on_show(picker)` callback is called

---

### File 2: `/home/cush/.local/share/nvim/lazy/snacks.nvim/lua/snacks/layout.lua`

#### Line 579-584: Layout Show Method
```lua
function M:show()
  if self:valid() then
    return
  end
  self:update()                   -- ← Calls M:update() below
end
```

#### Line 234-303: Layout Update (Where Windows Actually Display)
```lua
function M:update()
  if self.closed then
    return
  end
  vim.o.lazyredraw = true
  for _, win in pairs(self.wins) do
    win.enabled = false
  end
  local layout = vim.deepcopy(self.opts.layout)
  if self.opts.fullscreen then
    layout.width = 0
    layout.height = 0
    layout.col = 0
    layout.row = 0
  end
  if not self.root:valid() then
    self.root:show()
    self.screenpos = vim.fn.screenpos(self.root.win, 1, 1)
  end

  -- ... dimension calculations ...

  local parent_width = layout.relative == "win" and vim.api.nvim_win_get_width(self.root.opts.win or 0) or vim.o.columns
  local parent_height = layout.relative == "win" and vim.api.nvim_win_get_height(self.root.opts.win or 0)
    or vim.o.lines - top - bottom

  self:update_box(layout, {
    col = 0,
    row = self.opts.fullscreen and self.split and top or 0,
    width = parent_width,
    height = parent_height,
  })

  -- ... fix fullscreen layouts ...

  if self.opts.on_update_pre then
    self.opts.on_update_pre(self)
  end

  -- ← THIS IS WHERE WINDOWS GET SHOWN
  for _, win in pairs(self:get_wins()) do
    if win:valid() then
      local ei = vim.o.eventignore
      vim.o.eventignore = "all"
      win:update()
      vim.o.eventignore = ei
    else
      win:show()                  -- ← WINDOWS DISPLAYED HERE
    end
  end
  
  for w, win in pairs(self.wins) do
    if not self:is_enabled(w) and win:win_valid() then
      win:close()
    end
  end
  vim.o.lazyredraw = false
  if self.opts.on_update then
    self.opts.on_update(self)
  end
end
```

**Key Point**: Line 282-292 is where `win:show()` is called for each window.

---

### File 3: `/home/cush/.local/share/nvim/lazy/snacks.nvim/lua/snacks/win.lua`

#### Line 819-902: Window Show Method
```lua
function M:show()
  if self:valid() then
    self:update()
    return self
  end

  self.augroup = vim.api.nvim_create_augroup("snacks_win_" .. self.id, { clear = true })

  self:open_buf()

  -- buffer local variables
  for k, v in pairs(self.opts.b or {}) do
    vim.b[self.buf][k] = v
  end

  -- OPTIM: prevent treesitter or syntax highlighting to attach on FileType if it's not already enabled
  local optim_hl = not vim.b[self.buf].ts_highlight and vim.bo[self.buf].syntax == ""
  vim.b[self.buf].ts_highlight = optim_hl or vim.b[self.buf].ts_highlight
  Snacks.util.bo(self.buf, self.opts.bo)
  vim.b[self.buf].ts_highlight = not optim_hl and vim.b[self.buf].ts_highlight or nil

  if self.opts.on_buf then
    self.opts.on_buf(self)
  end

  -- ... footer setup ...

  self:open_win()                 -- ← Line 862: Window actually opens on screen
  self.closed = false
  
  -- window local variables
  for k, v in pairs(self.opts.w or {}) do
    vim.w[self.win][k] = v
  end
  if Snacks.util.is_transparent() then
    self.opts.wo.winblend = 0
  end
  Snacks.util.wo(self.win, self.opts.wo)
  
  if self.opts.on_win then       -- ← Line 872: on_win callback fired
    self.opts.on_win(self)       -- ← WINDOWS NOW VISIBLE
  end

  -- syntax highlighting
  local ft = self.opts.ft or vim.bo[self.buf].filetype
  if ft and not ft:find("^snacks_") and not vim.b[self.buf].ts_highlight and vim.bo[self.buf].syntax == "" then
    local lang = vim.treesitter.language.get_lang(ft)
    if not (lang and pcall(vim.treesitter.start, self.buf, lang)) then
      vim.bo[self.buf].syntax = ft
    end
  end

  for _, event in ipairs(self.events) do
    self:_on(event.event, event)
  end

  -- swap buffers when opening a new buffer in the same window
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = self.augroup,
    nested = true,
    callback = function()
      return self:fixbuf()
    end,
  })

  self:map()
  self:drop()

  return self
end
```

#### Line 724-778: open_win Method
```lua
function M:open_win()
  local relative = self.opts.relative or "editor"
  local position = self.opts.position or "float"
  local enter = self.opts.enter == nil or self.opts.enter or false
  if self.opts.focusable == false then
    enter = false
  end
  local opts = self:win_opts()
  if position == "float" then
    self.win = vim.api.nvim_open_win(self.buf, enter, opts)  -- ← Float window opens
  elseif position == "current" then
    self.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(self.win, self.buf)
  else --split
    -- ... split window handling ...
  end
  vim.w[self.win].snacks_win = {
    id = self.id,
    position = self.opts.position,
    relative = self.opts.relative,
    stack = self.opts.stack,
  }
end
```

---

### File 4: `/home/cush/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/core/list.lua`

#### List Window Creation - on_win Callback
The exact location where list sets up its on_win callback:

```lua
function M.new(picker)
  local self = setmetatable({}, M)
  self.reverse = picker.resolved_layout.reverse
  self.picker = picker
  self.selected = {}
  self.selected_map = {}
  self.matcher = require("snacks.picker.core.matcher").new(picker.opts.matcher)
  self.matcher_regex = require("snacks.picker.core.matcher").new({ regex = true })
  local win_opts = Snacks.win.resolve(picker.opts.win.list, {
    show = false,
    enter = false,
    on_win = function()          -- ← LIST'S on_win CALLBACK
      self:on_show()             -- ← Calls list's on_show() method
      lists[
        self.win.win --[[@as number]]
      ] = self
    end,
    -- ... other options ...
  })
  self.visible = {}
  self.win = Snacks.win(win_opts)
  -- ... more initialization ...
end
```

#### List's on_show() Method
```lua
function M:on_show()
  self.state.scrolloff = vim.wo[self.win.win].scrolloff
  self.state.scroll = vim.wo[self.win.win].scroll
  self.state.height = vim.api.nvim_win_get_height(self.win.win)
  self.state.mousescroll = tonumber(vim.o.mousescroll:match("ver:(%d+)")) or 1
  Snacks.util.wo(self.win.win, { scrolloff = 0 })
  self.dirty = true
  self:update_cursorline()
  self:update({ force = true })  -- ← Updates list with items
end
```

---

## Complete Execution Order

```
1. picker.new(opts)
   └─ Creates picker object
   └─ Calls init_layout() with show=false
      └─ Creates layout and windows
      └─ Windows are NOT shown
      └─ on_win callbacks are NOT called

[Time passes, picker waits to be shown...]

2. picker:show()  ← USER CALLS THIS
   ├─ self.shown = true
   ├─ self.layout:show()
   │  └─ layout:update()
   │     ├─ vim.o.lazyredraw = true
   │     ├─ Calculates dimensions
   │     ├─ For each window:
   │     │  └─ win:show()
   │     │     ├─ win:open_buf()
   │     │     ├─ win:open_win()        ← Window actually appears
   │     │     ├─ on_buf() if set
   │     │     ├─ Snacks.util.wo()      ← Apply window options
   │     │     └─ on_win() if set       ← For list: calls list:on_show()
   │     │        └─ For list window:
   │     │           └─ list:on_show()
   │     │              └─ Updates list with items
   │     └─ on_update() if set
   │
   ├─ picker:focus()  ← Focus window (if enabled)
   │
   └─ on_show(self)   ← FIRE USER'S CALLBACK
                         Windows are now fully visible and initialized
```

---

## Why This Matters

### Window State at Each Callback

| Stage | on_buf | on_win | on_show (picker) |
|-------|--------|--------|------------------|
| Buffer created | ✓ | ✓ | ✓ |
| Buffer populated | ✗ | ✓ | ✓ |
| Window opened | ✗ | ✓ | ✓ |
| Window visible | ✗ | ✓ | ✓ |
| Window options set | ✗ | ✓ | ✓ |
| Layout complete | ✗ | ✗ | ✓ |
| All windows shown | ✗ | ✗ | ✓ |

### For Animation Implementation

**The `on_show` callback is the BEST place to animate because:**
- All windows are visible and valid
- You can access all windows: `picker.layout.wins.{input,list,preview}`
- Window IDs are set: `win.win`
- You can call animation functions immediately or schedule them

**Example:**
```lua
on_show = function(picker)
  local list_win = picker.layout.wins.list
  if list_win and list_win:valid() then
    -- Window is ready to animate
    local win_id = list_win.win
    -- Apply animation to win_id
  end
end
```

---

## Key Differences from Other Callbacks

### on_buf (win.lua:839)
- Called before window opens
- Can't animate window yet
- Best for buffer setup (syntax, keymaps, autocommands)

### on_win (win.lua:872)
- Called after window opens
- Window is visible
- Can access window ID
- Called for each window separately
- For list: delegates to list:on_show()

### on_show (picker.lua:493)
- Called after ALL windows shown
- Layout is complete
- Can see interaction between windows
- Good for cross-window operations
- Perfect for animations

### on_change (only with picker, not standard)
- Called when selected item changes
- Window might not be visible yet if called during initialization

---

## Testing Verification

To verify the callback is being executed:

```lua
on_show = function(picker)
  -- Test 1: Check callback is called
  print("✓ on_show called")
  
  -- Test 2: Verify window is valid
  if picker.layout.wins.list:valid() then
    print("✓ List window is valid")
  end
  
  -- Test 3: Check window ID
  local win_id = picker.layout.wins.list.win
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    print("✓ Window ID is valid:", win_id)
  end
  
  -- Test 4: Verify buffer has content
  local buf_lines = vim.api.nvim_buf_line_count(picker.layout.wins.list.buf)
  if buf_lines > 0 then
    print("✓ Buffer has", buf_lines, "lines")
  end
  
  -- Test 5: Check animation library
  if your_animation_function then
    print("✓ Animation function available")
  end
end
```

Run this and check `:messages` output.

