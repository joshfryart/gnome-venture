-- wander-deep: Hearth Pop v3 wander banner, 480x64 native. The deep wilds: ancient braided trees,
-- glowing shelf fungus and caps, violet mist and fireflies. Centre third kept calm for the card title.
local ROOT = "/home/user/gnome-venture/aseprite-source/v3/"
local HP = dofile(ROOT .. "lib/hp.lua")
local K = dofile(ROOT .. "here-gate/places/_wander-kit.lua")
local OUT = app.params.out or (ROOT .. "here-gate/places/")
local NAME = "wander-deep"
local floor, sin, cos, abs, max, min = math.floor, math.sin, math.cos, math.abs, math.max, math.min
local hash = K.hash
local W, H = 480, 64
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local S = K.new(W, H)

local INK = "#2b1c26"
local FAR = { "#2a1f3e", "#33264a", "#3e2f58", "#4a3a66" }
local BARK = { "#1a1220", "#2a1e2e", "#3c2c40", "#544056", "#6e5870", "#8a7488" }
local ROOF = { "#140f1e", "#1e1a2e", "#2a2440", "#363254", "#444066", "#55507a" }
local MOSS = { "#1e1628", "#2a1e36", "#382a46", "#4a3858", "#5e4a6c" }
local PATH = { "#2a2234", "#3a3046", "#4c4058", "#62566c", "#786c80" }
local TEAL = { "#1d5a63", "#2b8a8a", "#49c2b0", "#8ef0d0", "#c8f8e4" }
local PINK = { "#5a1e5a", "#8a2e86", "#c24aba", "#ec84e0", "#f8c0f0" }
local function side(x) return x < 160 or x >= 320 end
local glows = {}

S:sky{ { 0, "#1e1430" }, { 10, "#281a3e" }, { 19, "#33224c" }, { 27, "#3e2b5a" }, { 34, "#4a3468" } }

-- distant twisted trunks
for i = 0, 22 do
  local x = 4 + i * 21 + floor(hash(i, 1) * 10)
  local w = side(x) and (4 + hash(i, 2) * 3) or (2.5 + hash(i, 2) * 1.5)
  local a = (hash(i, 3) - 0.5) * 10
  S:tube({ { x, 46 }, { x + a, 32 }, { x - a, 16 }, { x + a * 0.5, -2 } }, function(t) return w * (1.3 - t * 0.5) end, FAR,
    { ol = "#1c1428", grain = 2, seed = i })
end

-- leaf roof
for x = -6, W + 6, 12 do
  local cs = side(x)
  local cy = cs and (0 + hash(x, 4) * 5) or (-5 + hash(x, 4) * 2)
  local rx = cs and (9 + hash(x, 5) * 6) or (6 + hash(x, 5) * 3)
  S:canopy(x, cy, rx * 2, rx * 1.1, x + 90, ROOF, INK, { n = 3 })
end

-- forest floor
local function floorTop(x) return 49 + 1.5 * sin(x / 29 + 1) + sin(x / 8) end
S:terrain(floorTop, MOSS, { ol = INK, base = 0.5, fall = 0.03,
  tex = function(x, y, d, v)
    local hh = hash(x, y, 5)
    if hh > 0.92 then return v + 0.25 elseif hh < 0.08 then return v - 0.25 end
    return v + (hash(floor(x / 3), floor(y / 2), 6) - 0.5) * 0.2
  end })

-- ancient braided trees: two strands twisting round each other
local function ancient(x, w, seed)
  local g = 5000 + seed
  for s = 0, 1 do
    local k = s == 0 and 1 or -1
    S:tube({ { x - k * w * 0.45, 64 }, { x + k * w * 0.55, 42 }, { x - k * w * 0.55, 20 }, { x + k * w * 0.35, -4 } },
      function(t) return w * (0.75 - t * 0.2) + (t < 0.15 and (0.15 - t) * w * 3 or 0) end, BARK,
      { ol = INK, inner = BARK[1], group = g, grain = 4, seed = seed + s, lx = 0.8, ly = 0.15 })
  end
  -- knot hollow (narrow lens)
  local hy = 30 + floor(hash(seed, 9) * 8)
  S:blob(x + 1, hy, w * 0.14, w * 0.3, seed + 7, { "#0f0a14", "#1a1220", "#2a1e2e" }, { ol = BARK[1], amp = 0.05 })
end
ancient(26, 22, 10)
ancient(118, 13, 20)
ancient(362, 14, 30)
ancient(450, 24, 40)
S:canopy(28, 4, 52, 16, 71, ROOF, INK)
S:canopy(452, 3, 56, 16, 72, ROOF, INK)

-- roots
local function root(p, w0, w1, seed)
  S:tube(p, function(t) return w0 + (w1 - w0) * t end, BARK, { ol = INK, grain = 3, seed = seed, lx = 0.3, ly = 0.9 })
end
root({ { 30, 56 }, { 52, 45 }, { 70, 52 }, { 94, 64 } }, 9, 3, 11)
root({ { 18, 57 }, { 8, 50 }, { 2, 57 }, { -6, 63 } }, 8, 4, 12)
root({ { 120, 58 }, { 136, 52 }, { 146, 57 }, { 158, 64 } }, 5, 2, 13)
root({ { 360, 58 }, { 346, 52 }, { 336, 57 }, { 326, 64 } }, 5, 2, 14)
root({ { 444, 55 }, { 422, 42 }, { 404, 50 }, { 386, 64 } }, 10, 3, 15)
root({ { 460, 57 }, { 472, 50 }, { 480, 55 }, { 488, 61 } }, 8, 4, 16)

-- shelf fungus on trunks
local function shelf(x, y, w, flip)
  local cx = x + (flip and -w * 0.4 or w * 0.4)
  S:blob(cx, y, w * 0.55, w * 0.32, floor(x * 3 + y), TEAL, { ol = "#123038", ycut = y, amp = 0.08 })
  S:obj(nil)
  for xx = floor(cx - w * 0.45), floor(cx + w * 0.45) do S:put(xx, y + 1, "#123038") end
  glows[#glows + 1] = { floor(cx), y - 1, 5, "#49c2b0", 0.22 }
end
shelf(36, 22, 9) shelf(38, 28, 7) shelf(16, 40, 8, true)
shelf(124, 26, 6) shelf(112, 36, 5, true)
shelf(356, 30, 6, true) shelf(370, 20, 5)
shelf(440, 24, 9, true) shelf(462, 34, 8) shelf(458, 40, 6)

-- glowing caps on the floor
local function cap(x, y, h, w, ramp, glow)
  S:obj(INK)
  for k = 1, h do S:put(x, y - k, "#c8c0d0"); if w > 4 then S:put(x + 1, y - k, "#9a90a8") end end
  S:blob(x + (w > 4 and 1 or 0.5), y - h, w * 0.5, w * 0.36, x * 7 + y, ramp, { ol = INK, ycut = floor(y - h), amp = 0.06 })
  glows[#glows + 1] = { x, y - h - 1, 6, glow, 0.2 }
end
cap(58, 58, 3, 6, PINK, "#ec84e0") cap(66, 59, 2, 4, PINK, "#ec84e0") cap(140, 56, 2, 4, TEAL, "#8ef0d0")
cap(8, 60, 3, 5, TEAL, "#8ef0d0") cap(340, 57, 3, 5, PINK, "#ec84e0") cap(412, 58, 3, 7, TEAL, "#8ef0d0")
cap(420, 59, 2, 4, TEAL, "#8ef0d0") cap(472, 60, 2, 5, PINK, "#ec84e0") cap(98, 60, 2, 4, PINK, "#ec84e0")

-- faint path at the bottom
local function trailTop(x) return 60 + 0.8 * sin(x / 21) + (hash(floor(x / 6), 1) > 0.7 and 1 or 0) end
S:terrain(trailTop, PATH, { ol = INK, base = 0.4, fall = 0,
  tex = function(x, y, d, v)
    local hh = hash(x, y, 9)
    if hh > 0.94 then return v + 0.3 elseif hh < 0.06 then return v - 0.25 end
    return v
  end })

S:edges()

-- glowing moss specks
for x = 0, W - 1 do
  if hash(x, 80) > (side(x) and 0.9 or 0.97) then
    local y = floor(floorTop(x)) + 2 + floor(hash(x, 81) * 6)
    if y < 59 then S.col[y * W + x] = "#49c2b0" end
  end
end
-- fungus glow
for _, g in ipairs(glows) do S:glow(g[1], g[2], g[3], g[4], g[5]) end
-- violet mist, two wispy bands (hard steps)
S:tint(0, 30, W - 1, 48, function(x, y)
  local cy = 39 + 3 * sin(x / 37) + 1.5 * sin(x / 13 + 2)
  local th = 3.5 + 1.5 * sin(x / 23 + 1)
  local d = abs(y - cy)
  if d < th * 0.5 then return 0.3 elseif d < th then return 0.16 end
end, "#a58ad8")
S:tint(0, 50, W - 1, 63, function(x, y)
  local cy = 56 + 2 * sin(x / 29 + 3)
  local d = abs(y - cy)
  if d < 1.5 then return 0.22 elseif d < 3 then return 0.1 end
end, "#a58ad8")

-- fireflies
for i = 1, 34 do
  local x = floor(hash(i, 90) * (W - 8)) + 4
  if side(x) or hash(i, 93) > 0.6 then
    local y = 8 + floor(hash(i, 91) * 44)
    S:glow(x, y, 3, "#e8f0a0", 0.16)
    S.col[y * W + x] = "#f6f0a0"
    if hash(i, 92) > 0.5 then
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local xx, yy = x + d[1], y + d[2]
        if xx >= 0 and xx < W and yy >= 0 and yy < H then S.col[yy * W + xx] = "#b8c860" end
      end
    end
  end
end

S:flush(c)
c:finish{ outline = false }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }
