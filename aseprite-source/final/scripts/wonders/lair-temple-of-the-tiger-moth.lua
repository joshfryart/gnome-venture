-- lair-temple-of-the-tiger-moth.lua : Boss lair (CSA, zone 3). Stepped Andean temple, a giant tiger moth drawn to its torches. Night. Params out= ase=
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
L.sky(c, "night", 96)
L.stars(c, 46, 60, 11)
-- big moon behind the moth
c:fill(c:ellipse(120, 46, 30, 30), "#6a5fa8"); c:fill(c:ellipse(120, 46, 27, 27), "#9a8ed4"); c:fill(c:ellipse(120, 46, 23, 23), "#c3b8ec")
for _, p in ipairs({ {106,34,4,3},{132,56,5,3},{112,58,3,2} }) do c:fill(c:ellipse(p[1], p[2], p[3], p[4]), "#9a8ed4") end
-- Andean peaks with snow
local function peak(x, top, hw, col, snow)
  local m = c:poly({ {x - hw, 104}, {x, top}, {x + hw, 104} })
  c:fill(m, col)
  if snow then c:fill(m:copy():clip(c:rect(0, 0, W, top + 10)), snow) end
end
peak(30, 56, 44, "#3e3680", "#8c84c8"); peak(204, 50, 50, "#3e3680", "#8c84c8"); peak(88, 76, 34, "#322c6c"); peak(160, 72, 36, "#322c6c")
-- cloud forest mist band
c:fill(c:rect(0, 94, W, 99), "#4a428e"); c:fill(c:rect(0, 100, W, 102), "#5a52a0")
-- jungle hills both sides
c:part(L.below(c, function(x) return 96 + math.sin(x * 0.08) * 4 + math.max(0, (60 - x) * 0.2) end), GV.ramp("#2f5a2a"), { outline = false, gloss = false, cres = 3, deep = 4 })
-- ground plaza
c:part(c:rect(0, 118, W - 1, H - 1), GV.ramp("#5b6470"), { outline = false, gloss = false, cres = 2, deep = 3 })

-- the stepped temple
local tiers = { {44,112,196,128}, {62,98,178,112}, {80,86,160,98}, {98,76,142,86} }
for _, t in ipairs(tiers) do c:part(c:rect(t[1], t[2], t[3], t[4]), GV.ramp("#a89a82"), { cres = 4, deep = 6, gloss = false }) end
-- gold fret band on each tier
for _, t in ipairs(tiers) do c:seam({ {t[1] + 3, t[2] + 4}, {t[3] - 3, t[2] + 4} }, { on = 4, off = 2 }) end
-- central stair
for i, y in ipairs({ 76, 80, 84, 88, 92, 96, 100, 104, 108, 112, 116, 120, 124 }) do
  c:fill(c:rect(110, y, 130, y + 2), (i % 2 == 0) and "#c9c0a8" or "#8a7e68")
end
c:fill(c:rect(110, 76, 110, 126), "#4a3a2a"); c:fill(c:rect(130, 76, 130, 126), "#4a3a2a")
-- shrine on top with a glowing door
c:part(c:rect(106, 62, 134, 76), GV.ramp("#a89a82"), { cres = 4, deep = 5, gloss = false })
c:part(c:poly({ {102,63},{120,52},{138,63} }), GV.ramp("#8a4f2a"), { cres = 3, deep = 5, gloss = false })
c:part(c:rrect(114, 66, 126, 76, 3), GV.ramp("#f5b860"), { outline = false, gloss = false, contour = "#2a1a10", flat = true })
c:fill(c:rect(118, 70, 122, 76), "#fbe0a8")
-- torches on tier corners
local function torch(x, y)
  c:fill(c:rect(x, y - 8, x + 1, y), "#4a2c1a")
  c:fill(c:ellipse(x + 0.5, y - 12, 3.5, 4.5), "#e0501f"); c:fill(c:ellipse(x + 0.5, y - 11, 2, 3), "#f5b838"); c:px(x, y - 11, "#fff1c8")
end
torch(50, 112); torch(190, 112); torch(68, 98); torch(172, 98); torch(86, 86); torch(154, 86)

-- the Tiger Moth, wings spread in front of the moon
local function wing(pts, base, stripes)
  local m = c:poly(pts)
  c:part(m, GV.ramp(base), { cres = 5, deep = 7, gloss = false })
  return m
end
local function mirror(pts) local r = {}; for i, p in ipairs(pts) do r[i] = { 240 - p[1], p[2] } end; return r end
local hind = { {118,56},{86,66},{66,88},{70,98},{98,92},{116,76} }
local fore = { {118,50},{80,20},{46,26},{34,46},{54,64},{96,62} }
for _, side in ipairs({ 1, -1 }) do
  local hp, fp = hind, fore
  if side == -1 then hp, fp = mirror(hind), mirror(fore) end
  local hm = wing(hp, "#e0501f")
  c:fill(hm:copy():clip(c:ellipse(side == 1 and 84 or 156, 80, 14, 12):cut(c:ellipse(side == 1 and 84 or 156, 80, 8, 6))), "#2a1a10")
  c:part(c:ellipse(side == 1 and 82 or 158, 80, 3, 3), GV.ramp("#f5cf6a"), { flat = true, outline = false, gloss = false })
  local fm = wing(fp, "#f5a838")
  -- black tiger stripes clipped to the wing
  for _, st in ipairs({ { {60,28},{74,58} }, { {76,22},{90,56} }, { {92,34},{104,54} }, { {48,36},{66,62} } }) do
    local a = { side == 1 and st[1][1] or 240 - st[1][1], st[1][2] }; local b = { side == 1 and st[2][1] or 240 - st[2][1], st[2][2] }
    c:fill(fm:copy():clip(c:line({ a, b }, 3)), "#2a1a10")
  end
  c:px(side == 1 and 46 or 193, 40, "#fff1c8")
end
-- fluffy cream body and head
c:part(c:ellipse(120, 68, 7, 18), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 5, gloss = false })
for _, y in ipairs({ 64, 70, 76 }) do c:fill(c:rect(115, y, 125, y), "#d8c496") end
c:part(c:ellipse(120, 46, 10, 9), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 5 })
c:eye(111, 42); c:eye(124, 42)
-- feathery antennae
c:fill(c:line({ {115,38},{108,26},{100,18} }, 2), "#2a1a10"); c:fill(c:line({ {125,38},{132,26},{140,18} }, 2), "#2a1a10")
for k = 0, 3 do c:px(106 - k, 26 - k * 2 - 1, "#c3b8ec"); c:px(134 + k, 26 - k * 2 - 1, "#c3b8ec") end
c:part(c:ellipse(99, 17, 2.5, 2.5), GV.ramp("#f5cf6a"), { flat = true }); c:part(c:ellipse(141, 17, 2.5, 2.5), GV.ramp("#f5cf6a"), { flat = true })
-- fireflies and ferns
for _, p in ipairs({ {20,70},{30,84},{214,80},{224,66},{10,100},{232,100},{60,106} }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2], "#c8d77a") end
local function fern(x, y, s)
  for _, d in ipairs({ -10, -5, 0, 5, 10 }) do c:part(c:line({ {x, y}, {x + d * s * 0.5, y - 8 * s + math.abs(d) * 0.3}, {x + d * s, y - 4 * s + math.abs(d) * 0.4} }, 2), GV.ramp("#4a8a3e"), { flat = true, gloss = false }) end
end
fern(16, 130, 1.4); fern(32, 132, 1); fern(212, 130, 1.4); fern(228, 132, 1)
L.finish(c, "lair-temple-of-the-tiger-moth")
