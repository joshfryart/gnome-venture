-- puddle-hat (D10 final, Sonnet high). A yellow oilskin sou'wester seen side-on: domed crown with panel seams and two
-- brass grommets, a short front brim and a long back brim that droops like a duck tail, ribbed with parallel stitch rows,
-- a red band round the crown and a chin strap hanging into the puddle it sits in. Oilskin sheen: bright streak on the crown,
-- darker underside on the drooping tail. Puddle: sea ramp with ripple rings and a dark reflection under the hat.
-- quirk: a single raindrop is still hanging off the front brim, with one ripple already spreading below it.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aD10_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("puddle-hat")

local YEL = { "#7a3d1a", "#b5601c", "#e08a1c", "#f7b52a", "#ffd84e", "#fff3a0" }
local EMB = { "#4a1a30", "#7d2438", "#b52e3f", "#e8493b", "#ff7a55", "#ffb08a" }
local SEA = { "#2a4a7a", "#3a6ea6", "#5fa4c8", "#8ed0e0", "#b6f0e0", "#e4fbf4" }
local BRASS = { "#6a4a1c", "#9a7424", "#c89a34", "#f0c860", "#fff0a8" }

-- puddle
local pud = c:ellipse(33, 52, 25, 6)
local pn = {}
pud:each(function(x, y) pn[K(x, y)] = { 0.0, 0.0, 1.0 } end)
local ptok = { r = { name = "puddle" } }
pud:each(function(x, y)
  local d = ((x - 33) / 25.5) ^ 2 + ((y - 52) / 6.5) ^ 2
  local i = 3
  if d > 0.72 then i = 2 end
  if d > 0.9 then i = 1 end
  if y < 49 and d < 0.7 then i = 4 end
  c:put(x, y, SEA[i], ptok)
end)
-- ripple rings (hard 1px lines)
local function ring(cx, cy, rx, ry, col)
  for a = 0, 63 do
    local t = a / 64 * 2 * pi
    local x, y = floor(cx + cos(t) * rx + 0.5), floor(cy + sin(t) * ry + 0.5)
    if pud:has(x, y) then c:put(x, y, col, ptok) end
  end
end
ring(11, 54, 4, 1.4, SEA[5]) ring(11, 54, 7, 2.3, SEA[4])
ring(56, 53, 3.6, 1.3, SEA[5])
-- dark reflection of the hat under it
local refl = c:ellipse(33, 53, 19, 3)
refl:clip(pud):each(function(x, y) c:put(x, y, ((x + y) % 2 == 0 and y > 52) and SEA[2] or SEA[1], ptok) end)
for _, p in ipairs{ { 20, 51 }, { 36, 50 }, { 44, 52 } } do c:put(p[1], p[2], SEA[5], ptok) c:put(p[1] + 1, p[2], SEA[5], ptok) end

-- brim: front tip left, long back tail droops to the right
local brim = c:poly{ { 8, 36 }, { 12, 35 }, { 15, 34 }, { 39, 34 }, { 46, 38 }, { 53, 43 }, { 58, 49 }, { 57, 53 }, { 52, 52 }, { 44, 49 }, { 34, 46 }, { 22, 45 }, { 13, 43 }, { 9, 40 } }
local bn = X.pillow(brim, 3.0)
-- tilt: the tail faces down-right, darker
local tail = {}
brim:each(function(x, y) local k = K(x, y)
  local tt = max(0, (x - 38) / 20)
  local v = bn[k]
  bn[k] = { A.norm(v[1] + tt * 0.35, v[2] + tt * 0.5, v[3]) }
end)
local btok = { r = { name = "brim" } }
local bi = A.shade(c, brim, bn, YEL, { amb = 0.1, wrap = 0.28, tok = btok, cuts = { 0.24, 0.42, 0.58, 0.74, 0.88 } })
-- ribbed stitch rows parallel to the brim edge
local dd = X.dist(brim)
brim:each(function(x, y) local k = K(x, y)
  local d = dd[k]
  local i = bi[k] or 3
  if (abs(d - 2.2) < 0.5 or abs(d - 4.6) < 0.5 or abs(d - 7.0) < 0.5) and d > 1.6 then c:put(x, y, YEL[max(1, i - 2)], btok)
  elseif (abs(d - 3.0) < 0.5 or abs(d - 5.4) < 0.5) and d > 2.5 and i >= 3 then c:put(x, y, YEL[min(6, i + 1)], btok) end
end)
-- seam where the tail folds
for t = 0, 1, 0.04 do local x, y = floor(40 + 15 * t + 0.5), floor(35 + 12 * t * 0.9 + 0.5) if brim:has(x, y) then c:put(x, y, YEL[2], btok) end end

-- crown dome
local crown = HP.mask()
local cx, cy, rx, ry = 27, 33, 13.5, 15.5
for y = 17, 36 do for x = 12, 42 do
  local dx, dy = (x - cx) / rx, (y - cy) / ry
  if dx * dx + dy * dy <= 1 and y <= 36 then crown:set(x, y) end
end end
local cn = {}
crown:each(function(x, y) local k = K(x, y)
  local dx, dy = (x - cx + 0.5) / (rx + 0.6), (y - cy + 0.5) / (ry + 0.6)
  local q = max(0.03, 1 - dx * dx - dy * dy)
  cn[k] = { A.norm(dx * 1.0, dy * 0.9, sqrt(q)) }
end)
local ctok = { r = { name = "crown" } }
local cb = {}
X.ao(cb, crown, c:rect(0, 36, 63, 40), 1, 0)
A.shade(c, crown, cn, YEL, { amb = 0.1, wrap = 0.28, tok = ctok, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
local ci = X.tone(c, crown, X.light(cn, { amb = 0.1, wrap = 0.28 }), YEL, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 }, tok = ctok })
-- panel seams (curved, follow the dome)
for _, k in ipairs{ -0.42, 0.38 } do
  for y = 19, 31 do
    local dy = (y - cy) / ry
    local x = floor(cx + k * rx * sqrt(max(0, 1 - dy * dy)) + 0.5)
    if crown:has(x, y) then
      local i = ci[K(x, y)] or 3
      c:put(x, y, YEL[max(1, i - 2)], ctok)
      if crown:has(x - 1, y) and k < 0.5 then c:put(x - 1, y, YEL[min(6, i + 1)], ctok) end
    end
  end
end
-- band round the base (red), with a shade row
local band = HP.mask()
crown:each(function(x, y) if y >= 31 then band:set(x, y) end end)
local bandi = X.tone(c, band, X.light(cn, { amb = 0.1, wrap = 0.28 }), EMB, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 }, tok = { r = { name = "band" } } })
band:each(function(x, y) if y == 31 then c:put(x, y, EMB[1], { r = { name = "band" } }) end end)
-- brass grommets on the crown
for _, g in ipairs{ { 19, 26 }, { 19, 22 } } do
  c:put(g[1], g[2], BRASS[3], ctok) c:put(g[1] + 1, g[2], BRASS[2], ctok) c:put(g[1], g[2] - 1, BRASS[5], ctok) c:put(g[1] + 1, g[2] - 1, BRASS[4], ctok)
  c:put(g[1], g[2] + 1, BRASS[1], ctok) c:put(g[1] + 1, g[2] + 1, BRASS[1], ctok)
end
-- oilskin sheen streak + specular
for _, p in ipairs{ { 22, 20 }, { 21, 21 }, { 21, 22 }, { 20, 23 } } do c:put(p[1], p[2], YEL[6], ctok) end
c:put(24, 19, YEL[6], ctok) c:put(25, 19, YEL[5], ctok)
-- a darker lower-right panel crease on the dome
for y = 22, 29 do local x = floor(cx + 0.7 * rx * sqrt(max(0, 1 - ((y - cy) / ry) ^ 2)) + 0.5) if crown:has(x, y) then c:put(x, y, YEL[1], ctok) end end

-- chin strap: red, hangs from the band at the front into the puddle, brass buckle
local strap = { { 15, 36 }, { 12, 41 }, { 11, 46 }, { 12, 51 } }
local tm, tn = A.tube(strap, function(t) return 1.2 end)
tm:cut(brim)
X.tone(c, tm, X.light(tn, { amb = 0.1, wrap = 0.25 }), EMB, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 }, tok = { r = { name = "strap" } } })
local bk = c:rect(10, 48, 14, 50)
c:fillMask(bk, BRASS[3]) c:fillMask(c:rect(11, 49, 13, 49), BRASS[1]) c:px(10, 48, BRASS[5]) c:px(11, 48, BRASS[4])
-- ambient darkening where the front brim meets the crown
for x = 13, 17 do if brim:has(x, 35) and not crown:has(x, 35) then c:put(x, 35, YEL[1], btok) end end

-- quirk: hanging raindrop under the front brim tip
c:fillMask(c:rect(8, 41, 9, 42), SEA[4]) c:px(8, 43, SEA[3]) c:px(9, 43, SEA[3]) c:px(8, 41, SEA[6]) c:px(9, 44, SEA[2])
A.save(c, "puddle-hat")
