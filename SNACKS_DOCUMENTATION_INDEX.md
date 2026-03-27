# Snacks.nvim on_show Callback Analysis - Documentation Index

## Overview

This directory contains comprehensive analysis of the snacks.nvim picker's `on_show` callback timing and execution. The analysis includes complete source code tracing, timing diagrams, and implementation guidance.

---

## Documents Included

### 1. **SNACKS_ANALYSIS_SUMMARY.md** (Start Here!)
**Length**: ~8.7 KB (323 lines)  
**Best For**: Getting a complete overview  
**Contains**:
- Key findings summary
- Complete execution flow with diagrams
- Window state at each callback
- Using on_show for animations
- Common issues and solutions
- Testing verification

**Start with this document to understand the big picture.**

---

### 2. **SNACKS_TIMING_QUICK_REFERENCE.md** (Cheat Sheet)
**Length**: ~4.5 KB (174 lines)  
**Best For**: Quick lookup and reference  
**Contains**:
- TL;DR section
- Critical file locations table
- Simplified execution order
- Window status table
- Code patterns for animation
- Callback comparison table
- Quick troubleshooting

**Use this for quick answers and code patterns.**

---

### 3. **snacks_on_show_analysis.md** (Deep Dive)
**Length**: ~8.2 KB (313 lines)  
**Best For**: Understanding callback internals  
**Contains**:
- Detailed execution timeline (7 steps)
- Key timing facts
- Window creation sequence diagram
- Explorer-specific behavior
- Callback comparison (on_show vs on_win vs on_buf)
- Animation callback execution details
- Timing issues explanation

**Use this for detailed understanding of the callback flow.**

---

### 4. **snacks_callback_reference.md** (Code Reference)
**Length**: ~13 KB (459 lines)  
**Best For**: Looking up specific code locations  
**Contains**:
- Complete call stack with file references
- Exact line numbers for every component
- Full code snippets from source
- Execution order with annotations
- Window state table
- Animation implementation guide
- Testing verification code

**Use this to find exact code locations and see full function implementations.**

---

### 5. **SNACKS_ANIMATION_ANALYSIS.md** (Existing Document)
**Length**: ~5.5 KB (155 lines)  
**Best For**: Animation-specific questions  
**Contains**:
- Animation callback timing
- Window visibility during animation
- Animation scheduling options
- Integration with snacks.nvim

**Use this for animation-specific implementation details.**

---

## How to Use This Documentation

### If you want to...

**Understand when on_show is called:**
→ Start with SNACKS_ANALYSIS_SUMMARY.md section "Key Findings"

**Implement an animation:**
→ Go to SNACKS_TIMING_QUICK_REFERENCE.md "Code Pattern for Animation"

**Find exact code location:**
→ Look in snacks_callback_reference.md for line numbers and file paths

**Troubleshoot animation not working:**
→ Check SNACKS_ANALYSIS_SUMMARY.md "Common Issues & Solutions"

**Get quick callback comparison:**
→ See SNACKS_TIMING_QUICK_REFERENCE.md "Callback Comparison" table

**Understand full execution flow:**
→ Read snacks_on_show_analysis.md "Execution Timeline"

---

## Key Findings Summary

### When is on_show Called?
**After all windows are visible and fully initialized.**

Timeline: `picker:show()` → `layout:show()` → `layout:update()` → `window:show()` → `on_show(picker)`

### Are Windows Visible?
**YES** - Windows are displayed on screen, valid, and ready to use.

### Can You Animate?
**YES** - This is the ideal hook point for animations.

### Is It Synchronous?
**YES** - Runs immediately in normal execution flow, not deferred.

### For Explorer Picker?
**Same as picker** - No special skipping of on_show callback.

---

## File Locations in Snacks.nvim

| Component | File | Lines |
|-----------|------|-------|
| Picker's show() | `lua/snacks/picker/core/picker.lua` | 483-496 |
| Layout's show() | `lua/snacks/layout.lua` | 579-584 |
| Layout's update() | `lua/snacks/layout.lua` | 234-303 |
| Window's show() | `lua/snacks/win.lua` | 819-902 |
| Window's on_win | `lua/snacks/win.lua` | 872-873 |
| List's on_show() | `lua/snacks/picker/core/list.lua` | ~380 |

---

## Quick Code Pattern

For animations in picker/explorer:

```lua
Snacks.picker.explorer {
  on_show = function(picker)
    local list_win = picker.layout.wins.list
    if list_win and list_win:valid() then
      -- Windows are visible, safe to animate
      vim.schedule(function()
        -- Animation code here
      end)
    end
  end
}
```

---

## Document Statistics

| Document | Type | Size | Lines | Focus |
|----------|------|------|-------|-------|
| SNACKS_ANALYSIS_SUMMARY.md | Overview | 8.7 KB | 323 | Complete guide |
| SNACKS_TIMING_QUICK_REFERENCE.md | Reference | 4.5 KB | 174 | Quick lookup |
| snacks_on_show_analysis.md | Analysis | 8.2 KB | 313 | Deep dive |
| snacks_callback_reference.md | Reference | 13 KB | 459 | Code locations |
| SNACKS_ANIMATION_ANALYSIS.md | Specific | 5.5 KB | 155 | Animations |
| **TOTAL** | | **40 KB** | **1,424** | Full analysis |

---

## Key Insights

1. **Windows ARE visible at on_show** - Not a timing issue or limitation
2. **Synchronous execution** - Runs immediately, no deferred scheduling needed
3. **Complete layout** - All windows shown, layout finalized
4. **Best hook for animations** - Ideal point for visual modifications
5. **Explorer uses picker** - Same behavior, no special cases

---

## Troubleshooting Guide

### Animation not visible?
1. Check that on_show is called: add `print("on_show called")`
2. Verify window is valid: `picker.layout.wins.list:valid()`
3. Try scheduling: wrap in `vim.schedule()`
4. Check animation library compatibility

### Wrong callback used?
- Use `on_show` for initialization/animations
- Don't use `on_change` for window setup
- Use `on_buf` only for buffer-level setup

### Window reference issues?
- Access windows via `picker.layout.wins.{input,list,preview}`
- Always check validity with `:valid()` before use
- Window IDs are `.win`, buffer IDs are `.buf`

---

## Analysis Methodology

This analysis was created by:
1. Tracing snacks.nvim picker source code
2. Following the execution flow from picker creation to on_show callback
3. Examining each component (picker, layout, window)
4. Documenting file locations and line numbers
5. Creating visual diagrams of execution order
6. Providing code examples and patterns

**Source**: `/home/cush/.local/share/nvim/lazy/snacks.nvim/`  
**Analysis Date**: 2026-03-22  
**Coverage**: Complete execution flow from picker creation to on_show callback

---

## Navigation Guide

```
Start Reading
    ↓
SNACKS_ANALYSIS_SUMMARY.md (overview + everything)
    ↓
    ├─→ Need quick lookup? → SNACKS_TIMING_QUICK_REFERENCE.md
    ├─→ Need code patterns? → Both above documents
    ├─→ Need exact code? → snacks_callback_reference.md
    ├─→ Need deep understanding? → snacks_on_show_analysis.md
    └─→ Need animation details? → SNACKS_ANIMATION_ANALYSIS.md
```

---

## Questions Answered by This Documentation

✓ When exactly is on_show called?  
✓ Are windows visible at that point?  
✓ Can I use on_show for animations?  
✓ What windows can I access?  
✓ Is the callback synchronous or async?  
✓ Why might my animation not be working?  
✓ How does explorer picker differ?  
✓ What's the complete execution flow?  
✓ Which callback should I use?  
✓ How do I access window handles?  

---

**All questions are answered in these documents.**

Start with SNACKS_ANALYSIS_SUMMARY.md for complete understanding.

