-- Compositor settings: general/decoration/blur/dwindle/misc/input/ecosystem.

local C = M.colors

hl.config({
  general = {
    gaps_in     = 5,
    gaps_out    = 15,
    border_size = 1,
    col = {
      active_border   = { colors = { C.primary_fixed, C.primary_fixed_dim }, angle = 45 },
      inactive_border = C.surface_container,
    },
    resize_on_border = false,
    allow_tearing    = false,
    layout           = "dwindle",
  },

  decoration = {
    rounding         = 6,
    rounding_power   = 2,
    active_opacity   = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled      = true,
      range        = 25,
      render_power = 3,
      -- color = surface_container_low @ alpha aa (170/255). Lua takes 0xAARRGGBB.
      color        = "rgba(231919aa)",
    },

    blur = {
      enabled       = true,
      size          = 5,
      passes        = 3,
      popups        = true,
      input_methods = true,
    },
  },

  dwindle = {
    preserve_split = true,
  },

  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo   = false,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms  = true,
  },

  input = {
    kb_layout    = "us",
    kb_variant   = "",
    kb_model     = "",
    kb_options   = "",
    kb_rules     = "",
    follow_mouse = 1,
    sensitivity  = 0,
    touchpad = {
      natural_scroll = false,
    },
  },

  ecosystem = {
    no_update_news  = true,
    no_donation_nag = true,
  },
})

-- 3-finger horizontal swipe = workspace switch.
hl.gesture({
  fingers   = 3,
  direction = "horizontal",
  action    = "workspace",
})
