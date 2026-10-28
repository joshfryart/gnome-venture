-- icons.lua: animated stat icons (6 frames, 6 fps). Run:
--   "C:\Program Files\Aseprite\Aseprite.exe" -b --script aseprite-source/anim/scripts/icons.lua
-- Reads game/assets/img/ico/ico-<name>.png (frame 1 == static), writes
--   game/assets/img/ico/ico-<name>-anim.png  (horizontal strip, 6 x 64x64)
--   aseprite-source/anim/ico-<name>-anim.aseprite
local D = "C:/Users/hello/OneDrive/Desktop/claude/Gnome Venture/gnome-venture/aseprite-source/anim/scripts/"
local A = dofile(D .. "animlib.lua")
local R = A.REPO
local N = 6
local GOLD, CREAM = "#f5cf6a", "#fff3c8"          -- style-guide thread gold / enamel gloss
local EXTRA = { GOLD, CREAM }

-- 3x3-ish twinkle: centre cream, arms gold (1px accents, as the scene sparkles do)
local function sparkle(f, x, y, big)
  f:put(x, y, A.hex(CREAM))
  for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do f:put(x + d[1], y + d[2], A.hex(GOLD)) end
  if big then
    for _, d in ipairs({ { 2, 0 }, { -2, 0 }, { 0, 2 }, { 0, -2 } }) do f:put(x + d[1], y + d[2], A.hex(GOLD)) end
  end
end

local function build(name, make)
  local st = A.load(R .. "game/assets/img/ico/ico-" .. name .. ".png", 1)
  local frames = {}
  for i = 1, N do
    local f = (i == 1) and st:copy() or make(st, i)
    frames[i] = f
  end
  A.offPalette(st, frames, EXTRA)
  A.export(name, frames, R .. "game/assets/img/ico/ico-" .. name .. "-anim.png",
    R .. "aseprite-source/anim/ico-" .. name .. "-anim.aseprite")
end

-- STRENGTH (grit): flex pump = squash and stretch about the base, with a sparkle on the peak.
build("strength", function(st, i)
  local ky = ({ 1, 1.05, 1.09, 1.05, 0.97, 1 })[i]
  local kx = ({ 1, 0.98, 0.96, 0.98, 1.02, 1 })[i]
  local f = st:scaled(32, 52, kx, ky)
  if i == 3 then sparkle(f, 53, 12, true) elseif i == 2 then sparkle(f, 53, 12) elseif i == 4 then sparkle(f, 55, 17) end
  return f
end)

-- NIMBLE (running figure): run bounce with a head/arm lean.
build("activity", function(st, i)
  local dy = ({ 0, -1, -2, -1, 0, 0 })[i]
  local lean = ({ 0, 1, 1, 0, -1, -1 })[i]
  local f = st:copy()
  f:shearRows(5, 26, function(y) return lean end)   -- head + arms lean
  return f:shifted(0, dy)
end)

-- HARDINESS (shield): a gleam sweeps diagonally over the steel rim, with a 1px settle.
build("shield", function(st, i)
  local f = st:copy()
  local k = ({ 0, 30, 44, 58, 72, 0 })[i]
  if k > 0 then
    f:recolor({ 1, 1, 63, 63 }, { ["#8b8f96"] = "#b3b9bb", ["#a0a7a9"] = "#d0d5d5", ["#686b73"] = "#8b8f96", ["#b3b9bb"] = "#d0d5d5" },
      function(x, y) return math.abs((x + y) - k) <= 2 end)
  end
  return f:shifted(0, (i == 3 or i == 4) and -1 or 0)
end)

-- LORE (books): the stack wobbles, each book sliding a pixel on its own beat.
build("books", function(st, i)
  local t = ({ { 0, 0, 0 }, { 1, 0, 0 }, { 1, -1, 0 }, { 0, -1, 1 }, { 0, 0, 1 }, { 0, 0, 0 } })[i]
  local f = st:copy()
  f:band(40, 59, t[3], 0)
  f:band(24, 39, t[2], 0)
  f:band(6, 23, t[1], 0)
  if i == 3 then sparkle(f, 58, 8) elseif i == 4 then sparkle(f, 6, 22) end
  return f
end)

-- SENSE (eyes): glance right, glance back, then blink (squash about the eye line).
build("eyes", function(st, i)
  local E = A.hex("#f8eed2")
  local f = st:copy()
  local look = ({ 0, 2, 2, 0, 0, 0 })[i]
  local blink = ({ 1, 1, 1, 1, 0.62, 0.34 })[i]
  if look > 0 then
    for _, bx in ipairs({ { 17, 30 }, { 35, 50 } }) do
      f:move({ box = { bx[1], 32, bx[2], 37 }, pred = { "#2a1a10", "#fff3c8" }, bg = E, dx = look })
      f:move({ box = { bx[1], 38, bx[2], 41 }, pred = { "#2a1a10", "#fff3c8" }, bg = E, dx = look // 2 })
    end
  end
  if blink < 1 then f = f:scaled(32, 33, 1, blink) end
  return f
end)

-- CHARM (daisy): petals breathe with a glint on the gold centre.
build("daisy", function(st, i)
  local k = ({ 1, 1.04, 1.07, 1.04, 1, 1 })[i]
  local f = st:scaled(32, 33, k, k)
  if i == 3 or i == 4 then
    f:recolor({ 1, 1, 63, 63 }, { ["#f4cd56"] = "#fdda72", ["#f2b830"] = "#f4cd56" }, function(x, y) return (x + y) % 3 ~= 0 end)
    sparkle(f, 53, 11)
  end
  if i == 2 then sparkle(f, 12, 49) end
  return f
end)

-- LUCK (four-leaf clover): sways from its stem.
build("four-leaf-clover", function(st, i)
  local amp = ({ 0, 1, 2, 1, 0, -1 })[i]
  local f = st:copy()
  f:shearRows(6, 61, function(y) return math.floor(amp * (61 - y) / 55 + 0.5 + (amp < 0 and -0.01 or 0)) end)
  if i == 3 then sparkle(f, 50, 10) end
  return f
end)
