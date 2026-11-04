-- wheat (lean D3o_11)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }
local NAME = "wheat"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tone(m, ramp, R, amb, bias) local n = X.pillow(m, R or 4); G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS, bias) end
local GOLD = { "#6a3a14", "#955a1c", "#bf8426", "#dca83a", "#f0c858", "#fce896" }
local STEM = { "#3a5a28", "#587c34", "#7ea442", "#a8c866" }
local TWINE= { "#6e1c2c", "#a02c3c", "#cc4a50", "#ee7c6c" }
c:groundShadow(32, 57, 12, 2)
-- three stalks, splayed at the base, tied together at y=42
local function stalk(x0, y0, x1, y1, bend)
  local m = G.tube({ {x0, y0}, {x0 + (x1 - x0) * 0.2 + bend, y0 + (y1 - y0) * 0.3}, {x0 + (x1 - x0) * 0.7, y0 + (y1 - y0) * 0.7}, {x1, y1} }, function(t) return 1.0 end)
  tone(m, STEM, 1.2, 0.15)
  return m
end
stalk(25, 56, 24, 26, -1)
stalk(39, 56, 41, 26, 1)
stalk(32, 57, 32, 20, 0)
-- long leaf blade
local lm = G.tube({ {32, 54}, {38, 48}, {47, 46}, {53, 49} }, function(t) return 1.6 * sin(min(1, t * 1.05) * pi) + 0.5 end)
tone(lm, { "#1f4a30", "#2f6a3a", "#4a8a44", "#76b058", "#a4d07c", "#cce8a0" }, 1.5, 0.15)
-- ear: kernels in chevrons, awns above
local function ear(cx, ytop, ybot, hw)
  local m = HP.mask()
  for y = ytop, ybot do
    local t = (y - ytop) / (ybot - ytop)
    local h = hw * sin(min(1, t * 1.15 + 0.12) * pi / 2) ^ 0.6 * (1 - 0.35 * t * t)
    for x = floor(cx - h + 0.5), floor(cx + h - 0.5) do m:set(x, y) end
  end
  local n = X.pillow(m, 3)
  local v = X.light(n, { amb = 0.12, wrap = 0.25 })
  G.tone(c, m, v, GOLD, CUTS)
  m:each(function(x, y)
    local s = abs(x - cx + 0.5)
    local ph = (y - ytop + floor(s * 1.5)) % 4
    if ph == 0 and s > 0.4 then c:px(x, y, GOLD[2]) elseif ph == 3 and s < 2.6 and x < cx then c:px(x, y, GOLD[6]) end
  end)
  -- awns
  local top = ytop
  for k = -3, 3 do
    local ax = cx + k * 0.8
    for i = 1, 7 - floor(abs(k) * 1.2) do
      c:px(floor(ax + k * i * 0.28 + 0.5), top - i, (i % 3 == 0) and GOLD[6] or GOLD[5])
    end
  end
  return m
end
ear(24, 21, 34, 3.6)
ear(41, 19, 32, 3.6)
ear(32, 15, 30, 4.2)
-- twine tie, knot and loose ends
c:fillMask(c:rect(23, 42, 41, 44), TWINE[3])
for x = 23, 41 do c:px(x, 42, TWINE[4]) c:px(x, 44, TWINE[1]) if (x % 3) == 0 then c:px(x, 43, TWINE[2]) end end
c:fillMask(c:ellipse(36, 43, 2, 2), TWINE[3]) c:px(35, 42, TWINE[4]) c:px(37, 44, TWINE[1])
G.line(c, { {37, 44}, {39, 47}, {38, 49} }, TWINE[2]) G.line(c, { {35, 44}, {34, 47}, {35, 49} }, TWINE[3])
-- quirk: tiny ladybird on the left stalk
c:fillMask(c:ellipse(24, 36, 1.6, 1.4), "#d8302c") c:px(24, 35, "#2b1c26") c:px(25, 37, "#2b1c26") c:px(23, 34, "#2b1c26") c:px(23, 36, "#ff8a7a")
G.fin(c, NAME)
