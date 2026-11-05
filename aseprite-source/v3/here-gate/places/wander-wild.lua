-- wander-wild: Hearth Pop v3 wander banner, 480x64 native. A darker tangled wild off the trail:
-- big roots, thorn brambles, shadowed trunks under a leaf roof. Centre third kept calm (a hushed gap).
local ROOT = "/home/user/gnome-venture/aseprite-source/v3/"
local HP = dofile(ROOT .. "lib/hp.lua")
local K = dofile(ROOT .. "here-gate/places/_wander-kit.lua")
local OUT = app.params.out or (ROOT .. "here-gate/places/")
local NAME = "wander-wild"
local floor, sin, abs, max, min = math.floor, math.sin, math.abs, math.max, math.min
local hash = K.hash
local W, H = 480, 64
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local S = K.new(W, H)

local INK = "#2b1c26"
local ROOF = { "#162418", "#1e3220", "#284228", "#34522e", "#446438", "#587a42" }
local FAR = { "#33403e", "#3e4d48", "#4b5a52", "#5a6a5c" }
local BARK = { "#1c1418", "#2a1f22", "#3a2a2a", "#4e3a34", "#654c40", "#7c604c" }
local ROOT_R = { "#2a1f22", "#3a2a2a", "#4e3a34", "#654c40", "#80634e", "#9a7a5c" }
local MOSS = { "#1d2a1c", "#26371f", "#324626", "#415830", "#55703a", "#6c8a44" }
local MUD = { "#3a2a22", "#4e3828", "#664a32", "#80603e", "#9a7a52" }
local function side(x) return x < 160 or x >= 320 end

-- dusky sky glimpses
S:sky{ { 0, "#3b4a4a" }, { 9, "#4a5c56" }, { 17, "#5c6e60" }, { 25, "#6e7c66" }, { 31, "#83906e" } }

-- distant pale trunks (calm everywhere, thin)
for i = 0, 26 do
  local x = 6 + i * 18 + floor(hash(i, 1) * 9)
  local w = side(x) and (3 + hash(i, 2) * 3) or (2 + hash(i, 2) * 1.5)
  local lean = (hash(i, 3) - 0.5) * 6
  S:tube({ { x, 44 }, { x + lean * 0.3, 30 }, { x + lean * 0.7, 14 }, { x + lean, -2 } }, function() return w end, FAR,
    { ol = "#28302f", grain = 2, seed = i })
end

-- far undergrowth
S:terrain(function(x) return 37 + 2.5 * sin(x / 19) + 1.5 * sin(x / 7 + 1) + (side(x) and 0 or 2) end,
  { "#1f2e26", "#283c2c", "#324a32", "#3e5a38" }, { ol = "#1a221c", base = 0.4, fall = 0.03,
  tex = function(x, y, d, v) return v + (hash(floor(x / 2), y, 2) - 0.5) * 0.3 end })

-- leaf roof along the top (thin over the centre)
for x = -6, W + 6, 11 do
  local cs = side(x)
  local cy = cs and (1 + hash(x, 4) * 5) or (-4 + hash(x, 4) * 2)
  local rx = cs and (9 + hash(x, 5) * 6) or (6 + hash(x, 5) * 3)
  S:canopy(x, cy, rx * 2, rx * 1.2, x + 40, ROOF, INK, { n = 3 })
end
-- hanging vines (sides)
S:obj(nil)
for x = 3, W - 3, 5 do
  if side(x) and hash(x, 60) > 0.6 then
    local len = 6 + floor(hash(x, 61) * 14)
    local y0 = 6 + floor(hash(x, 62) * 4)
    for k = 0, len do
      local xx = x + floor(sin(k / 3 + x) * 0.8)
      S:put(xx, y0 + k, k % 4 == 0 and "#446438" or "#26371f")
    end
  end
end

-- big shadowed trunks
local function trunk(x, w, bend, seed)
  S:tube({ { x - bend * 0.3, 62 }, { x + bend * 0.2, 40 }, { x - bend * 0.4, 18 }, { x + bend, -4 } },
    function(t) return w * (1 + 0.6 * max(0, 0.25 - t) * 4) end, BARK, { ol = INK, grain = 4, seed = seed, lx = 0.8, ly = 0.2 })
end
trunk(20, 16, 4, 1)
trunk(98, 10, -3, 2)
trunk(384, 11, 3, 3)
trunk(452, 18, -4, 4)
-- leafy masses hugging the trunk tops
S:canopy(30, 6, 46, 16, 71, ROOF, INK)
S:canopy(458, 5, 50, 16, 72, ROOF, INK)

-- forest floor
local function floorTop(x) return 50 + 1.5 * sin(x / 27 + 2) + sin(x / 9) end
S:terrain(floorTop, MOSS, { ol = INK, base = 0.5, fall = 0.03,
  tex = function(x, y, d, v)
    local hh = hash(x, y, 5)
    if hh > 0.92 then return v + 0.25 elseif hh < 0.08 then return v - 0.25 end
    return v + (hash(floor(x / 3), floor(y / 2), 6) - 0.5) * 0.2
  end })

-- thorn brambles (behind the roots)
local function bramble(x0, y0, x1, y1, up, seed)
  S:bramble({ { x0, y0 }, { x0 + (x1 - x0) * 0.3, y0 - up }, { x0 + (x1 - x0) * 0.7, y1 - up }, { x1, y1 } },
    "#4a2234", "#a07070", seed, { berry = "#c23a3a", berry2 = "#e8584a" })
end
bramble(40, 52, 92, 46, 10, 1)
bramble(52, 56, 130, 50, 12, 2)
bramble(110, 54, 150, 44, 8, 3)
bramble(330, 50, 372, 56, 9, 4)
bramble(350, 55, 430, 48, 13, 5)
bramble(400, 44, 470, 54, 7, 6)
bramble(0, 46, 30, 40, 6, 7)

-- big roots
local function root(p, w0, w1, seed)
  S:tube(p, function(t) return w0 + (w1 - w0) * t end, ROOT_R, { ol = INK, grain = 3, seed = seed, lx = 0.3, ly = 0.9 })
end
root({ { 24, 54 }, { 42, 44 }, { 58, 50 }, { 82, 63 } }, 8, 3, 11)
root({ { 14, 56 }, { 6, 52 }, { 2, 58 }, { -4, 63 } }, 7, 4, 12)
root({ { 30, 58 }, { 48, 56 }, { 60, 60 }, { 70, 65 } }, 5, 2, 13)
root({ { 100, 57 }, { 114, 52 }, { 124, 56 }, { 140, 63 } }, 5, 2, 14)
root({ { 380, 57 }, { 366, 52 }, { 356, 57 }, { 344, 64 } }, 5, 2, 15)
root({ { 446, 54 }, { 428, 43 }, { 410, 50 }, { 392, 63 } }, 9, 3, 16)
root({ { 458, 56 }, { 470, 50 }, { 478, 54 }, { 486, 60 } }, 7, 4, 17)
-- thorns over the roots in front
bramble(56, 60, 104, 57, 9, 8)
bramble(400, 58, 452, 60, 8, 9)

-- muddy trail at the bottom
local function trailTop(x) return 59 + 0.8 * sin(x / 21) + (hash(floor(x / 6), 1) > 0.7 and 1 or 0) end
S:terrain(trailTop, MUD, { ol = INK, base = 0.45, fall = 0,
  tex = function(x, y, d, v)
    local hh = hash(x, y, 9)
    if hh > 0.94 then return v + 0.3 elseif hh < 0.06 then return v - 0.25 end
    return v
  end })
-- ferns / dark grass nibbling the trail
S:obj(nil)
for x = 1, W - 2 do
  if hash(x, 50) > (side(x) and 0.72 or 0.9) then
    local t = floor(trailTop(x))
    local hgt = 2 + floor(hash(x, 51) * 4)
    for k = 0, hgt - 1 do S:put(x + (k > 1 and (hash(x, 53) > 0.5 and 1 or -1) or 0), t + 1 - k, k == hgt - 1 and "#55703a" or "#26371f") end
  end
end

S:edges()
-- a hushed paler gap at the centre, deep shade at the edges (hard steps)
S:tint(150, 18, 330, 48, function(x, y)
  local d = abs(x - 240) / 90 + abs(y - 34) / 16
  if d < 0.6 then return 0.22 elseif d < 1.0 then return 0.11 end
end, "#a8b48a")
S:tint(0, 0, W - 1, H - 1, function(x, y)
  local e = min(x, W - 1 - x)
  if e < 14 then return 0.3 elseif e < 34 then return 0.15 end
end, "#140e18")
S:flush(c)
c:finish{ outline = false }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }
