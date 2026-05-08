-- Side panels with BSP-style stacking. Each gutter (LEFT, RIGHT) holds an
-- ordered list of window addresses; geometry is divided evenly among them
-- vertically. Adding a window to an already-occupied slot tiles a new row
-- below the existing ones.
--
-- Bindings (binds.lua):
--   SUPER+ALT+left  / right  — toggle focused window in/out of slot
--   SUPER+ALT+0              — clear both gutters
--   SUPER+ALT+1..5           — aspect ratio presets
--   SUPER+left/right         — slot-aware directional focus
--
-- State per slot: { x, y, w, h, addrs = {addr1, addr2, ...} }

local SCREEN_W = 3840
local SCREEN_H = 1080

local PRESETS = {
  ["16:9"]  = { gutter = 960,  label = "16:9 (1920)"   },
  ["16:10"] = { gutter = 1056, label = "16:10 (1728)"  },
  ["21:9"]  = { gutter = 660,  label = "21:9 (2520)"   },
  ["full"]  = { gutter = 0,    label = "full ultrawide" },
  ["panel"] = { gutter = 400,  label = "side panels"   },
}

local STACK_GAP_Y = 6  -- vertical gap between stacked windows in a gutter

local M = {
  monitor        = "HDMI-A-2",
  current_aspect = "panel",
  slots = {
    left  = { x = 10,   y = 40, w = 380, h = 1000, addrs = {} },
    right = { x = 3450, y = 40, w = 380, h = 1000, addrs = {} },
  },
}

local function dlog(msg)
  local f = io.open("/tmp/sidepanels.log", "a")
  if f then f:write("[" .. os.date() .. "] " .. msg .. "\n"); f:close() end
end

local function find_window(addr)
  if not addr then return nil end
  for _, w in ipairs(hl.get_windows() or {}) do
    if w and w.address == addr then return w end
  end
  return nil
end

-- Compute the sub-rect for stack index i (1-based) of total n.
local function sub_rect(slot, i, n)
  if n <= 0 then return slot.x, slot.y, slot.w, slot.h end
  local total_gap = STACK_GAP_Y * (n - 1)
  local per_h = math.floor((slot.h - total_gap) / n)
  local y = slot.y + (i - 1) * (per_h + STACK_GAP_Y)
  return slot.x, y, slot.w, per_h
end

-- Place a single window into a specific rect: float, pin, then resize+move.
local function place_at(window, x, y, w, h)
  if not window then return end
  hl.dispatch(hl.dsp.focus({ window = window }))
  if not window.floating then
    hl.dispatch(hl.dsp.window.float({ action = "set" }))
  end
  if not window.pinned then
    hl.dispatch(hl.dsp.window.pin())
  end
  hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
  hl.dispatch(hl.dsp.window.move({ x = x, y = y }))
end

-- Re-stack all windows in a slot into evenly-divided sub-rects. Drops any
-- addresses whose windows have closed.
local function place_stack(slot)
  -- Garbage-collect dead addrs.
  local live = {}
  for _, addr in ipairs(slot.addrs) do
    if find_window(addr) then table.insert(live, addr) end
  end
  slot.addrs = live
  local n = #slot.addrs
  for i, addr in ipairs(slot.addrs) do
    local w = find_window(addr)
    if w then
      local x, y, ww, hh = sub_rect(slot, i, n)
      place_at(w, x, y, ww, hh)
    end
  end
end

-- Release a single window: unpin (toggle off). Caller removes from addrs[].
local function release_from_slot(window)
  if not window then return end
  hl.dispatch(hl.dsp.focus({ window = window }))
  if window.pinned then
    hl.dispatch(hl.dsp.window.pin())
  end
end

-- Helpers for slot membership lookup.
local function slot_of(addr)
  for side, slot in pairs(M.slots) do
    for i, a in ipairs(slot.addrs) do
      if a == addr then return side, slot, i end
    end
  end
  return nil
end

local function remove_from_addrs(slot, addr)
  for i, a in ipairs(slot.addrs) do
    if a == addr then table.remove(slot.addrs, i); return true end
  end
  return false
end

-- Public: assign focused (or given) window to slot. If already in this slot,
-- toggle off. If in the OTHER slot, move it. Otherwise append to stack.
function M.assign(side, window)
  local slot = M.slots[side]
  if not slot then dlog("assign: bad side " .. tostring(side)); return end
  window = window or hl.get_active_window()
  if not window then dlog("assign: no window"); return end
  local addr = window.address
  dlog(string.format("assign: side=%s addr=%s", side, tostring(addr)))
  -- Already in this slot → release + remove.
  for _, a in ipairs(slot.addrs) do
    if a == addr then
      release_from_slot(window)
      remove_from_addrs(slot, addr)
      place_stack(slot)
      return
    end
  end
  -- In other slot → remove there.
  for other_side, other_slot in pairs(M.slots) do
    if other_side ~= side then remove_from_addrs(other_slot, addr) end
  end
  table.insert(slot.addrs, addr)
  place_stack(slot)
end

M.assign_window = M.assign

-- Public: clear all slots (release all pinned occupants).
function M.clear_all()
  for _, slot in pairs(M.slots) do
    for _, addr in ipairs(slot.addrs) do
      local w = find_window(addr)
      if w then release_from_slot(w) end
    end
    slot.addrs = {}
  end
end

-- On workspace switch: re-stack all slots, focus bottom-left middle window.
hl.on("workspace.active", function(ws)
  for _, slot in pairs(M.slots) do place_stack(slot) end
  local slotted = {}
  for _, slot in pairs(M.slots) do
    for _, a in ipairs(slot.addrs) do slotted[a] = true end
  end
  local middles = {}
  for _, w in ipairs(hl.get_windows() or {}) do
    if w.workspace and ws and w.workspace.id == ws.id and not slotted[w.address] then
      table.insert(middles, w)
    end
  end
  if #middles == 0 then return end
  table.sort(middles, function(a, b)
    local ax = (a.at or {})[1] or (a.at or {}).x or 0
    local bx = (b.at or {})[1] or (b.at or {}).x or 0
    if ax ~= bx then return ax < bx end
    local ay = (a.at or {})[2] or (a.at or {}).y or 0
    local by = (b.at or {})[2] or (b.at or {}).y or 0
    return ay > by
  end)
  hl.dispatch(hl.dsp.focus({ window = middles[1] }))
end)

-- On window close: remove from any slot it occupied + restack.
hl.on("window.close", function(w)
  if not w then return end
  for _, slot in pairs(M.slots) do
    if remove_from_addrs(slot, w.address) then place_stack(slot) end
  end
end)

-- Public: snap focused window to gutter under cursor on SUPER+LMB release.
function M.snap_active()
  local active = hl.get_active_window()
  if not active then return end
  local cur = hl.get_cursor_pos() or {}
  local cx = math.floor((cur[1] or cur.x or 0) + 0.5)
  local g = (PRESETS[M.current_aspect] or PRESETS.panel).gutter
  if g < 100 then return end
  local side = nil
  if cx < g then
    side = "left"
  elseif cx > SCREEN_W - g then
    side = "right"
  end

  -- Cursor in middle: untile if currently slotted.
  if not side then
    local cur_side, cur_slot = slot_of(active.address)
    if cur_side then
      release_from_slot(active)
      remove_from_addrs(cur_slot, active.address)
      hl.dispatch(hl.dsp.focus({ window = active }))
      hl.dispatch(hl.dsp.window.float({ action = "unset" }))
      place_stack(cur_slot)
    end
    return
  end

  -- Cursor in gutter: append to that slot's stack (or move from other).
  local slot = M.slots[side]
  for _, a in ipairs(slot.addrs) do
    if a == active.address then
      place_stack(slot)  -- already in this slot; just re-anchor
      return
    end
  end
  for other_side, other_slot in pairs(M.slots) do
    if other_side ~= side then remove_from_addrs(other_slot, active.address) end
  end
  table.insert(slot.addrs, active.address)
  place_stack(slot)
end

-- Public: switch aspect preset.
function M.set_aspect(name)
  local p = PRESETS[name]; if not p then return end
  M.current_aspect = name
  local g = p.gutter

  hl.monitor({
    output        = M.monitor,
    mode          = "7680x2160@120",
    position      = "0x0",
    scale         = 2,
    reserved_area = { top = 0, bottom = 0, left = g, right = g },
  })

  if g < 100 then
    -- Full mode: untile everything in slots so dwindle re-tiles into middle.
    for _, slot in pairs(M.slots) do
      for _, addr in ipairs(slot.addrs) do
        local w = find_window(addr)
        if w then
          hl.dispatch(hl.dsp.focus({ window = w }))
          if w.pinned   then hl.dispatch(hl.dsp.window.pin()) end
          local w2 = find_window(addr)
          if w2 and w2.floating then
            hl.dispatch(hl.dsp.focus({ window = w2 }))
            hl.dispatch(hl.dsp.window.float({ action = "unset" }))
          end
        end
      end
      slot.addrs = {}
    end
  else
    M.slots.left.x  = 10
    M.slots.left.w  = g - 20
    M.slots.right.x = SCREEN_W - g + 10
    M.slots.right.w = g - 20
    for _, slot in pairs(M.slots) do place_stack(slot) end
  end
end

-- Continuous auto-snap: any FLOATING+UNPINNED window whose center is over a
-- gutter gets pulled in. Pinned windows are already managed.
local function poll_auto_snap()
  local g = (PRESETS[M.current_aspect] or PRESETS.panel).gutter
  if g < 100 then return end
  for _, w in ipairs(hl.get_windows() or {}) do
    if w.floating and not w.pinned then
      local at, sz = w.at or {}, w.size or {}
      local ax = at[1] or at.x or 0
      local sw = sz[1] or sz.x or 0
      local cx = ax + sw / 2
      local side = nil
      if cx > 0 and cx < g then side = "left"
      elseif cx > SCREEN_W - g and cx < SCREEN_W then side = "right"
      end
      if side then
        local slot = M.slots[side]
        local already = false
        for _, a in ipairs(slot.addrs) do
          if a == w.address then already = true; break end
        end
        if not already then
          dlog("autosnap: " .. w.address .. " -> " .. side)
          for other_side, other_slot in pairs(M.slots) do
            if other_side ~= side then remove_from_addrs(other_slot, w.address) end
          end
          table.insert(slot.addrs, w.address)
          place_stack(slot)
        end
      end
    end
  end
end

hl.timer(poll_auto_snap, { timeout = 1500, type = "repeat" })

-- Slot-aware directional focus.
function M.focus_dir(direction)
  local active = hl.get_active_window()
  if not active then
    hl.dispatch(hl.dsp.focus({ direction = direction }))
    return
  end

  local function ccx(w)
    local at = w.at or {}; local sz = w.size or {}
    local x = at[1] or at.x or 0
    local w_ = sz[1] or sz.x or 0
    return x + w_ / 2
  end
  local function zone_of(w)
    local s = slot_of(w.address)
    if s == "left"  then return "left"  end
    if s == "right" then return "right" end
    return "middle"
  end

  local active_zone = zone_of(active)
  local active_cx = ccx(active)
  local ws_id = active.workspace and active.workspace.id

  local middles = {}
  for _, w in ipairs(hl.get_windows() or {}) do
    if w.workspace and w.workspace.id == ws_id and zone_of(w) == "middle" then
      table.insert(middles, w)
    end
  end
  table.sort(middles, function(a, b) return ccx(a) < ccx(b) end)

  local function focus(w) hl.dispatch(hl.dsp.focus({ window = w })) end
  local function first_addr(side)
    local addr = M.slots[side].addrs[1]
    if not addr then return nil end
    return find_window(addr)
  end

  if direction == "right" then
    if active_zone == "left" then
      if #middles > 0 then focus(middles[1]); return end
      local rs = first_addr("right"); if rs then focus(rs); return end
    elseif active_zone == "middle" then
      for _, w in ipairs(middles) do
        if ccx(w) > active_cx + 1 then focus(w); return end
      end
      local rs = first_addr("right"); if rs then focus(rs); return end
    elseif active_zone == "right" then
      return
    end
  elseif direction == "left" then
    if active_zone == "right" then
      if #middles > 0 then focus(middles[#middles]); return end
      local ls = first_addr("left"); if ls then focus(ls); return end
    elseif active_zone == "middle" then
      for i = #middles, 1, -1 do
        if ccx(middles[i]) < active_cx - 1 then focus(middles[i]); return end
      end
      local ls = first_addr("left"); if ls then focus(ls); return end
    elseif active_zone == "left" then
      return
    end
  end
  hl.dispatch(hl.dsp.focus({ direction = direction }))
end

return M
