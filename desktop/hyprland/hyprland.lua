-- Hyprland 0.55 Lua config. Ported from modules/*.conf (now inert on 0.55 with
-- a .lua present). The conf files are kept in modules/ as the historical record.
--
-- Load-bearing workarounds for the Intel UHD 770 + Hyprland 0.55 stack
-- (see ~/.claude/projects/-home-cush-projects-drift/memory/ for the full
-- archaeology):
--   * render.cm_enabled = false + misc.disable_hyprland_logo = true
--       Hyprland 0.55 color-management bug: getConvertedColor black-screens
--       the compositor. Both flags required; cm_enabled alone is not enough
--       because the BGTex (splash/logo) path also calls getConvertedColor.
--   * AQ_NO_ATOMIC = 1
--       Hyprland 0.55 implicit-pre-apply double-modeset trips the kernel's
--       page-flip-awaiting check. Under atomic mode this wedges the pipe
--       unrecoverably; under legacy mode the errors are cosmetic and the
--       compositor renders normally.
--   * no_hardware_cursors = true
--       i915 hardware cursor plane thrashes between buffers (~30Hz),
--       bleeding ~30% CPU on Hyprland's main thread.
--   * AQ_DRM_DEVICES = /dev/dri/card1
--       Intel iGPU. Today card1 because initramfs loads nvidia before i915.
--       If that order ever flips this becomes wrong silently.
--   * Explicit per-output hl.monitor rules (no empty-output catch-all)
--       Workaround for the double-modeset; pinning every output narrows
--       the race window. Catch-alls also matched named outputs, doubling
--       rule application.

------------------
---- MONITORS ----
------------------

hl.monitor({
	output = "HDMI-A-1",
	mode = "preferred",
	position = "0x0",
	scale = 1.25,
})

-- LG SDQHD 2560x2880 portrait-tall panel, to the right of HDMI-A-1's
-- 3072-wide logical desktop (4K @ 1.25 scale). Flip to "-2048x0" if it
-- physically moves left.
hl.monitor({
	output = "DP-1",
	mode = "preferred",
	position = "3072x0",
	scale = 1.25,
})

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Intel iGPU compositor backend. Aquamarine splits AQ_DRM_DEVICES on ':'
-- with no escape, so by-path symlinks are unusable. Use the cardN node.
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")
hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("AQ_NO_ATOMIC", "1")

-- Toolkit backends
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- XDG specs
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	-- Wallpaper: awww-daemon handles it. The daemon backgrounds itself and
	-- exits, then `awww img` sets the actual wallpaper. The retry loop covers
	-- monitors that come online after the first img call (otherwise they stay
	-- on the default black).
	hl.exec_cmd(
		"awww-daemon && (for i in 1 2 3 4 5; do awww img ~/media/wallpapers/boat-painting.jpg; sleep 1; done) &"
	)

	-- Quickshell surfaces (bar, notifications, settings).
	hl.exec_cmd("quickshell -p ~/dotfiles/desktop/quickshell/bar/shell.qml")
	hl.exec_cmd("quickshell -p ~/dotfiles/desktop/quickshell/notifications/shell.qml")
	hl.exec_cmd("quickshell -p ~/dotfiles/desktop/quickshell/settings/shell.qml")

	-- Drift overlay (standalone, lives in ~/projects/drift-shell, symlinked at
	-- ~/dotfiles/desktop/quickshell/overlay). Persistent process, hidden until
	-- IPC toggle. SUPER+O shows/hides it.
	hl.exec_cmd("quickshell -p ~/dotfiles/desktop/quickshell/overlay/OverviewOnly.qml")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 20,
		gaps_out = 50,
		border_size = 2,
		col = {
			active_border = "rgb(665c54)",
			inactive_border = "rgb(282828)",
		},
		resize_on_border = true,
		allow_tearing = false,
		layout = "scrolling",
	},

	decoration = {
		rounding = 8,
		rounding_power = 16,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 20,
			render_power = 3,
			color = "rgb(282828)",
		},
		-- Blur disabled. No transparent surfaces right now, so the 4-pass
		-- Gaussian was full-screen GPU work for nothing. Parameters kept so
		-- flipping enabled back to true is a one-line change.
		blur = {
			enabled = false,
			size = 1,
			passes = 4,
			ignore_opacity = true,
			noise = 0.08,
			contrast = 1.5,
			xray = false,
			new_optimizations = true,
			vibrancy = 0.1696,
		},
	},

	cursor = {
		no_warps = true,
		no_hardware_cursors = true,
	},

	animations = {
		enabled = true,
	},

	render = {
		cm_enabled = false,
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		vrr = 0,
	},

	debug = {
		disable_logs = false,
		enable_stdout_logs = true,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	-- Niri-style scrollable tiling. Each workspace is an infinite horizontal
	-- strip of columns; the viewport scrolls to keep the focused column
	-- visible. column_widths is the set cycled through with `colresize
	-- +conf`/`-conf` (default keybind below).
	scrolling = {
		column_width = 0.5,
		follow_focus = true,
		follow_min_visible = 0.4,
		focus_fit_method = 1,
		fullscreen_on_one_column = true,
		explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
		direction = "right",
		wrap_focus = false,
		wrap_swapcol = false,
	},

	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 0,
		sensitivity = 0,
		touchpad = {
			natural_scroll = false,
		},
	},
})

-- "Ja" animation set ported from animations.conf.
hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.5, 0 }, { 0.99, 0.99 } } })
hl.curve("smoothIn", { type = "bezier", points = { { 0.5, -0.5 }, { 0.68, 1.5 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "liner", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "smoothOut" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "overshot" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 5, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "default", style = "popin" })
-- layersOut overrides the parent style to fade rather than reverse-popin.
-- Reverse-popin (the default inherited from "layers") snapshots the
-- layer at full size and scales it to a point at screen center when the
-- surface destructs, which we never want for the overlays we build —
-- our own internal close animation handles the transition. Fade just
-- ramps alpha, so the surface vanishes cleanly.
hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "default", style = "fade" })

----------------
---- INPUT  ----
----------------

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"
local terminal = "ghostty"
local fileManager = "dolphin"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("quickshell -p ~/dotfiles/desktop/quickshell/launcher/shell.qml"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.config/waybar/scripts/launch.sh"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("quickshell -p ~/projects/HyprQuickFrame -n"))
hl.bind(
	mainMod .. " + SHIFT + B",
	hl.dsp.exec_cmd([[pkill -f "^quickshell .*bar/shell"; quickshell -p ~/dotfiles/desktop/quickshell/bar/shell.qml]])
)
hl.bind(
	mainMod .. " + SHIFT + N",
	hl.dsp.exec_cmd(
		[[pkill -f "^quickshell .*notifications/shell"; quickshell -p ~/dotfiles/desktop/quickshell/notifications/shell.qml]]
	)
)
hl.bind(
	mainMod .. " + I",
	hl.dsp.exec_cmd("quickshell -p ~/dotfiles/desktop/quickshell/settings/shell.qml ipc call settings toggle")
)
hl.bind(
	mainMod .. " + O",
	hl.dsp.exec_cmd("quickshell -p ~/dotfiles/desktop/quickshell/overlay/OverviewOnly.qml ipc call overview toggle")
)
hl.bind(
	mainMod .. " + SHIFT + I",
	hl.dsp.exec_cmd(
		[[pkill -f "^quickshell .*settings/shell"; quickshell -p ~/dotfiles/desktop/quickshell/settings/shell.qml]]
	)
)
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))

-- Screenshots (A for "area"; mod-only = region, +SHIFT = whole monitor,
-- +CTRL = active window). Default goes to the clipboard; +ALT writes a PNG
-- to ~/media/screenshots/ instead. Implemented via scripts/screenshot.sh.
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("~/dotfiles/desktop/hyprland/scripts/screenshot.sh region"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("~/dotfiles/desktop/hyprland/scripts/screenshot.sh output"))
hl.bind(mainMod .. " + CTRL + A", hl.dsp.exec_cmd("~/dotfiles/desktop/hyprland/scripts/screenshot.sh window"))
hl.bind(mainMod .. " + ALT + A", hl.dsp.exec_cmd("~/dotfiles/desktop/hyprland/scripts/screenshot.sh region file"))
hl.bind(mainMod .. " + SHIFT + ALT + A", hl.dsp.exec_cmd("~/dotfiles/desktop/hyprland/scripts/screenshot.sh output file"))

-- Focus movement (vim keys)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Toggle the focused column between full viewport width (1.0) and the
-- default (0.5). The bars stay visible (the layout respects exclusive
-- zones). Script does the detection via hyprctl activewindow + monitors.
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-column-fullwidth.sh"))

-- True Hyprland fullscreen (hides bars, takes the whole screen). Different
-- intent than SUPER+F; reach for this only when you genuinely want a clean
-- canvas (video, presentation).
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())

-- Other scrolling-layout binds. Cycle column width, swap column position,
-- toggle column grouping (consume_or_expel = put the focused window into
-- the previous column / pull it back out).
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + G", hl.dsp.layout("consume_or_expel"))

-- Workspace switch + move-to-workspace 1..10 (0 = workspace 10)
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize with mainMod + LMB/RMB
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Drift-compositor-only bindings. hl.dsp.drift is registered by
-- drift-compositor/src/drift/LuaBindings.cpp and is nil under stock
-- Hyprland, so this whole block is gated. Without the guard, an LSP
-- syntax pass and a stock-Hyprland load both error on "attempt to
-- index nil value (field 'drift')". Layout switching uses the same
-- table because drift:layout-* dispatchers are top-level (not
-- layoutmsg routes); routing through hl.dsp.layout would forward to
-- the active layout's onMessage and bounce with "no such layoutmsg
-- for scrolling".
if hl.dsp.drift then
	hl.bind(mainMod .. " + CTRL + Down", hl.dsp.drift.workspace_down())
	hl.bind(mainMod .. " + CTRL + Up", hl.dsp.drift.workspace_up())
	hl.bind(mainMod .. " + CTRL + SHIFT + Down", hl.dsp.drift.move_to_workspace_down())
	hl.bind(mainMod .. " + CTRL + SHIFT + Up", hl.dsp.drift.move_to_workspace_up())
	hl.bind(mainMod .. " + CTRL + ALT + Down", hl.dsp.drift.move_to_workspace_silent_down())
	hl.bind(mainMod .. " + CTRL + ALT + Up", hl.dsp.drift.move_to_workspace_silent_up())
	hl.bind(mainMod .. " + Tab", hl.dsp.drift.layout_toggle())
	hl.bind(mainMod .. " + SHIFT + s", hl.dsp.drift.layout_set_scrolling())
	hl.bind(mainMod .. " + SHIFT + d", hl.dsp.drift.layout_set_dwindle())
end

------------------------
---- WINDOW RULES  -----
------------------------

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})

-- Godot: float by default so the tiling layout doesn't squash the editor.
hl.window_rule({
	name = "float-godot",
	match = { class = "^[Gg]odot" },
	float = true,
})

-- Underbloom game preview: open fullscreen.
hl.window_rule({
	name = "fullscreen-underbloom",
	match = { title = "^Underbloom$" },
	fullscreen = true,
})
