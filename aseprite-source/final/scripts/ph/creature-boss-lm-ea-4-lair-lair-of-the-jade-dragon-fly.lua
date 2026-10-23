-- ph/creature-boss-lm-ea-4-lair-lair-of-the-jade-dragon-fly : Jade Dragon-fly, legendary lair boss
-- front view, four glassy jade wings raised in display, carved-jade head with compound-eye domes,
-- gold crest of spikes, long banded tail curling to the right with a gold stinger tip.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-ea-4-lair-lair-of-the-jade-dragon-fly"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- rotated ellipse mask (angle in degrees, y down)
local function rot(cx, cy, rx, ry, deg)
  local m = c:mask()
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function mirror(m)
  local r = c:mask()
  m:each(function(x, y) r:set(63 - x, y) end)
  return r
end

-- wings: fore pair swept up, hind pair swept out and down (raised display pose)
local fwL = rot(16.5, 26, 10.5, 4.5, 30)
local hwL = rot(16.5, 38, 10, 4, -18)
local fwR, hwR = mirror(fwL), mirror(hwL)

-- tail: chain of shrinking discs from the thorax, curling to the right
local path = { {31.5, 40}, {31.5, 45}, {32.5, 49.5}, {35.5, 52.5}, {40, 53.5}, {44.5, 52.5}, {47.5, 50}, {49, 47} }
local rad  = { 3.6, 3.4, 3.2, 3.0, 2.9, 2.7, 2.5, 2.3 }
local tail = c:mask()
for i = 1, #path - 1 do
  local a, b = path[i], path[i + 1]
  for k = 0, 6 do
    local f = k / 6
    tail:add(c:ellipse(a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f, rad[i] + (rad[i + 1] - rad[i]) * f))
  end
end
local sting = c:poly({ {47, 47}, {52, 47}, {52, 42} })

local thorax = c:ellipse(31.5, 36, 6.5, 5.5)
local head   = c:ellipse(31.5, 22, 12.5, 9)
local domeL  = c:ellipse(23.5, 21.5, 5.5, 5.5)
local domeR  = c:ellipse(39.5, 21.5, 5.5, 5.5)
-- crest: three gold spikes on the brow (boss crown)
local crest = c:poly({ {24, 16}, {24, 7}, {30, 14} })
  :add(c:poly({ {28, 14}, {32, 6}, {36, 14} }))
  :add(c:poly({ {34, 14}, {40, 7}, {40, 16} }))
  :add(c:rrect(24, 12, 39, 15, 1))

local jade  = GV.R.moss
local deepJ = GV.R.leaf
local wing  = GV.ramp("#a8dcc8", { gloss = "#eef8f2", dot = "#f8fcf4", rim = "#d8f0e4", pale = false })

local p = c:build{
  { "fwL", fwL, wing, { gloss = { 9, 21 } } },
  { "fwR", fwR, wing, { gloss = false } },
  { "hwL", hwL, wing, { gloss = false } },
  { "hwR", hwR, wing, { gloss = false } },
  { "sting", sting, "gold", { flat = true } },
  { "tail", tail, jade, { gloss = { 30, 43 } } },
  { "thorax", thorax, jade, { gloss = { 27, 32 } } },
  { "crest", crest, "gold" },
  { "head", head, jade, { gloss = { 29, 15 } } },
  { "domeL", domeL, "water", { gloss = false } },
  { "domeR", domeR, "water", { gloss = false } },
}

-- wing veins: 1 px glass-shade lines fanning from the root
local vein = wing.shade
local function v(pts, w) c:fill(c:line(pts, 1):clip(w:shrink(1)), vein) end
v({ {24, 30}, {16, 25}, {7, 21} }, fwL)
v({ {24, 32}, {14, 29}, {8, 25} }, fwL)
v({ {24, 34}, {15, 36}, {7, 40} }, hwL)
v({ {39, 30}, {47, 25}, {56, 20} }, fwR)
v({ {39, 32}, {49, 29}, {55, 25} }, fwR)
v({ {39, 34}, {48, 36}, {56, 40} }, hwR)
-- pterostigma: a small jade cell near each fore-wing tip
c:fill(c:rect(9, 21, 10, 22), jade.shade); c:fill(c:rect(53, 21, 54, 22), jade.shade)

-- tail bands: dark jade rings across the path every 5 px of arc length
local segs, total = {}, 0
for i = 1, #path - 1 do
  local a, b = path[i], path[i + 1]
  local L = math.sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
  segs[i] = { a = a, b = b, L = L, s0 = total }; total = total + L
end
local inner = tail:shrink(1)
inner:each(function(x, y)
  local best, bs = 1e9, 0
  for _, s in ipairs(segs) do
    local dx, dy = s.b[1] - s.a[1], s.b[2] - s.a[2]
    local t = ((x + 0.5 - s.a[1]) * dx + (y + 0.5 - s.a[2]) * dy) / (s.L * s.L)
    t = math.max(0, math.min(1, t))
    local px, py = s.a[1] + dx * t, s.a[2] + dy * t
    local d = (x + 0.5 - px) ^ 2 + (y + 0.5 - py) ^ 2
    if d < best then best, bs = d, s.s0 + t * s.L end
  end
  if bs > 4 and (bs % 5) < 2 then c:px(x, y, deepJ.deep) end
end)

-- carved-jade diamonds on the thorax
c:paint({ ".d.", "ddd", ".d." }, 30, 37, { d = jade.deep })
-- collar seam between head and thorax, button at its head
c:seam({ {26, 32}, {37, 32} })
c:button(36, 31)
-- face: locked eyes in the compound domes, gold mandibles
c:eye(21, 19); c:eye(37, 19)
c:paint({ ".uuuuu.", "gg...gg", ".g...g." }, 28, 27, { g = GV.R.gold.base, u = "umber" })
-- crest jewel
c:spot(c:ellipse(31.5, 12, 1.5, 1.5), "#3f8fb0", "#c8ecdc")

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
