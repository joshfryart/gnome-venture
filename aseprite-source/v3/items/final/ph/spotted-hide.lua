-- spotted-hide (lean P1b_O20)
-- A cream cow-style pelt draped over a wooden rail: four dangling legs and a tail, big irregular chestnut-black patches, fur-tuft edge, one patch mended with blue cross-stitches (quirk).
local NAME = "spotted-hide"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, vf, nm, adj)
  local tok = { r = { name = nm } }
  local nr = #ramp
  m:each(function(x, y)
    local v = vf(x, y)
    local i = 1 + floor(max(0, min(0.999, v)) * nr)
    if adj then i = adj(x, y, i, v) or i end
    c:put(x, y, ramp[max(1, min(nr, i))], tok)
  end)
end
local function T(nm) return { r = { name = nm } } end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local CREAM = { "#6e4a48", "#a47c68", "#d0a882", "#ecd0a2", "#f9e6bc", "#fff6dc" }
local DARK = { "#1e1018", "#3c2220", "#5e3a2a", "#85553a" }
local WOOD = { "#2e1a14", "#573320", "#80522c", "#a97a42", "#cfa062" }
c:groundShadow(32, 58, 20, 2)
local hide = HP.mask()
hide:add(c:poly{ {10,13},{54,13},{58,21},{53,28},{56,38},{53,47},{47,46},{44,39},{39,41},{38,49},{35,57},{30,57},{28,49},{25,41},{20,42},{19,49},{13,48},{10,39},{13,31},{7,23} })
local n = X.pillow(hide, 9)
local v = X.light(n, { amb = 0.12, wrap = 0.3 })
-- spots
local spots = HP.mask()
local function spot(cx, cy, rx, ry, seed)
  local m = HP.mask()
  for y = floor(cy - ry - 2), floor(cy + ry + 2) do for x = floor(cx - rx - 2), floor(cx + rx + 2) do
    local a = math.atan2(y - cy, x - cx)
    local wob = 1 + 0.28 * sin(a * 3 + seed) + 0.15 * sin(a * 5 + seed * 2)
    local q = ((x - cx) / (rx * wob)) ^ 2 + ((y - cy) / (ry * wob)) ^ 2
    if q <= 1 then m:set(x, y) end
  end end
  return m:clip(hide:copy():shrink(1))
end
local S = { spot(22, 22, 7, 6, 1), spot(42, 20, 6, 5, 2.5), spot(33, 34, 5, 6, 4), spot(16, 38, 3, 4, 5.5), spot(48, 38, 3, 5, 7), spot(37, 49, 2, 3, 8) }
for _, s in ipairs(S) do spots:add(s) end
paint(c, hide, CREAM, function(x, y) return v[K(x, y)] + 0.1 * sin(x * 0.55) end, "hide", function(x, y, i)
  if X.hash(x, y, 3) > 0.93 then return i + 1 end
end)
for _, s in ipairs(S) do
  paint(c, s, DARK, function(x, y) return v[K(x, y)] * 0.9 + 0.05 end, "spot")
end
-- fur tufts on the edge
hide:edge():each(function(x, y) if X.hash(x, y, 9) > 0.6 and y > 14 then c:put(x, y, CREAM[5], T"hide") end end)
-- rail on top
local rail = c:rect(4, 7, 60, 11)
paint(c, rail, WOOD, function(x, y) return (y == 7 and 0.9) or (y == 8 and 0.65) or (y == 9 and 0.45) or (y == 10 and 0.25) or 0.05 end, "wood", function(x, y, i) if (x * 7 + y) % 11 == 0 then return i - 1 end end)
c:fillMask(c:rect(4, 7, 5, 11), WOOD[2]) c:put(4, 8, WOOD[5], T"wood")
c:fillMask(c:rect(8, 12, 9, 12), WOOD[1]) c:fillMask(c:rect(54, 12, 55, 12), WOOD[1])
-- AO under rail
for x = 10, 53 do c:put(x, 14, CREAM[1], T"hide") end
-- blue cross-stitch mend on the left spot
local st = "#4aa8d8"
for _, p in ipairs{ {19,19},{19,24},{22,19},{22,24},{25,19},{25,24} } do c:put(p[1], p[2], st, T"st") end
for _, p in ipairs{ {20,21},{20,22},{23,21},{23,22} } do c:put(p[1], p[2], "#2a6a9c", T"st") end
-- gloss spec on creamy shoulder
c:put(13, 18, CREAM[6], T"hide") c:put(14, 18, CREAM[6], T"hide")
G.save(c, NAME)
