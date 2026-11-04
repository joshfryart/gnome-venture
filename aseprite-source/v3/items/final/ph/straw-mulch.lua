-- straw-mulch (lean D2o_15)
-- A fanned sheaf of golden straw stalks bound at the waist by red-brown twine with a knot and two tails;
-- cut flat at the base, a few loose strands on the ground. quirk: a tiny ladybird rests on one stalk.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "straw-mulch" }
local STRAW = { "#8a5a1e", "#b07a2a", "#d49e3c", "#ecc45a", "#f8e08a", "#fff1b8" }
c:groundShadow(32, 55, 15, 2)
for i = -9, 9 do
  local h = X.hash(i + 20, 3, 5)
  local topx = 32 + i * 1.9 + (h - 0.5) * 2
  local topy = 8 + abs(i) * 0.9 + h * 4
  local pts = { {32 + i * 0.95, 53}, {32 + i * 0.8, 44}, {32 + i * 0.75, 36}, {32 + i * 1.3, 24}, {topx, topy} }
  local base = 3 + floor(h * 2.4)
  local ox = 0
  for seg = 1, #pts - 1 do
    local a, b = pts[seg], pts[seg + 1]
    local steps = 20
    for s = 0, steps do
      local x = floor(a[1] + (b[1] - a[1]) * s / steps + 0.5)
      local y = floor(a[2] + (b[2] - a[2]) * s / steps + 0.5)
      local tone = base + (i < -2 and 1 or (i > 3 and -1 or 0))
      if (x + y) % 7 == 0 then tone = tone - 1 end
      c:px(x, y, STRAW[max(1, min(6, tone))])
      if (i + 9) % 3 == 0 then c:px(x + 1, y, STRAW[max(1, min(6, tone - 2))]) end
    end
  end
  c:px(floor(topx + 0.5), floor(topy + 0.5), STRAW[6])
end
-- flat base cut: pale end grain row
for x = 22, 42 do c:px(x, 53, STRAW[5]) end
-- twine band, twisted
local TW = { "#4a1f1a", "#7a2f26", "#a8473a", "#d27a62" }
for y = 34, 38 do for x = 23, 41 do c:px(x, y, TW[((x + y * 2) % 4 < 2) and 3 or 2]) end end
for x = 23, 41 do c:px(x, 34, TW[4]) c:px(x, 38, TW[1]) end
-- knot + tails
local kn = c:ellipse(40, 36, 2.5, 3) c:fillMask(kn, TW[3])
c:px(39, 35, TW[4]) c:px(41, 38, TW[1])
G.line(c, { {41, 38}, {44, 42}, {43, 46} }, TW[2])
G.line(c, { {42, 38}, {47, 40}, {49, 44} }, TW[3])
-- loose strands on the ground
G.line(c, { {13, 54}, {20, 52}, {26, 55} }, STRAW[3])
G.line(c, { {38, 55}, {46, 53}, {52, 55} }, STRAW[4])
-- ladybird
c:fillMask(c:ellipse(25, 26, 2, 1.6), "#c8281f")
c:px(24, 25, "#fff1c0") c:px(26, 27, "#2b1c26") c:px(25, 26, "#2b1c26") c:px(23, 26, "#2b1c26")
G.fin(c, "straw-mulch")
