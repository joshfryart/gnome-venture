-- _dB33.lua: private helpers for the garden/garlic/gathering chunk (first draft, Sonnet). Read-only use of batch2/_b2.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local HP, X, K, H = B.HP, B.X, B.K, B.H
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local D = setmetatable({ B = B, HP = HP, X = X, K = K, H = H }, { __index = B })
D.INK, D.CREAM = "#2b1c26", "#fff4d6"
D.WOOD  = { "#3c2326", "#5d382e", "#864c33", "#b97a4a", "#d49a62", "#ecc48e" }
D.WOOD2 = { "#4a2a2a", "#6e4034", "#97593a", "#c48858", "#e0aa72", "#f4d3a0" }  -- paler pine
D.DARKW = { "#2c1a22", "#45281f", "#63392b", "#84503a", "#a46a46", "#c89062" }
D.IRON  = { "#2f3248", "#454a66", "#626b88", "#8590aa", "#b3bfd0", "#e2eaf2" }
D.LEAF  = { "#173f33", "#225a3d", "#2f7744", "#46954b", "#68b452", "#98d06a" }
D.STONE = { "#33344f", "#4f5170", "#74758c", "#9391a8", "#bdbccb", "#e6e4ea" }
D.GOLD  = { "#6b3a1c", "#8f4a1f", "#d98322", "#f5b82e", "#ffd35e", "#fff0a8" }
D.EMBER = { "#4e1a30", "#6e2038", "#b52e3f", "#e8493b", "#ff7a52", "#ffb48a" }
D.CREAMR= { "#7a5a4a", "#a88468", "#d4b48a", "#ecd6a8", "#f8e8c4", "#fffbe8" }
D.GLASS = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8ee0d6", "#c4f2ea", "#f0fffa" }

function D.new(name) D.name = name return B.new(name) end
function D.save(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i in pairs(c.pix) do local x, y = i % c.w, i // c.w x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx, dy = floor((c.w - W) / 2) - (x0 - 1), floor((c.h - Hh) / 2 + .5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("size %dx%d", W, Hh))
  B.fin()
end
-- lit part on any mask
function D.lit(c, m, ramp, R, o) return B.lit(c, m, ramp, R or 2, o) end
-- tapered/straight rod with lighting
function D.rod(c, ax, ay, bx, by, hw, ramp, hw2)
  local m = H.cyl(c, ax, ay, bx, by, function(t) return hw + ((hw2 or hw) - hw) * t end, ramp)
  return m
end
-- hash speckle inside mask
function D.speck(c, m, hex, thr, seed)
  m:each(function(x, y) if X.hash(x, y, seed or 5) < thr then c:px(x, y, hex) end end)
end
-- plank with grain; dir "v" or "h"
function D.plank(c, x0, y0, x1, y1, ramp, dir, R)
  local m = c:rect(x0, y0, x1, y1)
  B.lit(c, m, ramp, R or 1.8)
  local r = H.ramp(ramp)
  local seed = x0 * 7 + y0
  for y = y0 + 1, y1 - 1 do for x = x0 + 1, x1 - 1 do
    if dir == "v" then if x - x0 == 1 and X.hash(1, floor(y / 3), seed) < 0.5 and (x1 - x0) > 3 then c:px(x, y, r[2]) end
    else if y - y0 == 1 and X.hash(floor(x / 3), 1, seed) < 0.5 then c:px(x, y, r[2]) end end
  end end
  return m
end
-- picket: top "point" | "round" | "flat"
function D.picket(c, x, yb, w, h, ramp, top, dark)
  local m = c:rect(x, yb - h + 1, x + w - 1, yb)
  if top == "point" then
    m:cut(c:rect(x, yb - h + 1, x, yb - h + 2)) m:cut(c:rect(x + w - 1, yb - h + 1, x + w - 1, yb - h + 2))
    if w >= 4 then m:cut(c:rect(x + 1, yb - h + 1, x + w - 2, yb - h + 1)) end
  elseif top == "round" then
    m:cut(c:rect(x, yb - h + 1, x, yb - h + 1)) m:cut(c:rect(x + w - 1, yb - h + 1, x + w - 1, yb - h + 1))
  end
  B.lit(c, m, ramp, 1.6)
  local r = H.ramp(ramp)
  c:px(x + 1, yb - floor(h / 2), r[2])  -- nail / grain knot
  c:px(x + 1, yb - h + 4, dark or r[2])
  return m
end
-- post with cap "ball" | "pyramid" | "flat"
function D.post(c, x, yb, w, h, ramp, cap)
  local m = c:rect(x, yb - h + 1, x + w - 1, yb)
  B.lit(c, m, ramp, 2)
  local r = H.ramp(ramp)
  for y = yb - h + 3, yb - 2, 3 do c:px(x + 1, y, r[2]) end
  local cm
  if cap == "ball" then cm = B.ell(x + (w - 1) / 2, yb - h - 1, 2.6, 2.6) B.lit(c, cm, ramp, 2.4)
  elseif cap == "pyramid" then cm = c:poly{ { x - 1, yb - h }, { x + w, yb - h }, { x + w - 1, yb - h - 2 }, { x + w - 2, yb - h - 3 }, { x + 1, yb - h - 3 }, { x, yb - h - 2 } } B.lit(c, cm, ramp, 1.5)
  else cm = c:rect(x - 1, yb - h - 1, x + w, yb - h + 1) B.lit(c, cm, ramp, 1.3) end
  return m, cm
end
-- rail along a slope (drawn as lit rod)
function D.rail(c, ax, ay, bx, by, ramp) return D.rod(c, ax, ay, bx, by, 1.3, ramp) end
-- fence run from base point (x0,y0) to (x1,y1) with n pickets of width w, height h
function D.fence(c, x0, y0, x1, y1, n, w, h, ramp, top, rails)
  local rr = rails or D.DARKW
  local dx, dy = (x1 - x0) / (n - 1), (y1 - y0) / (n - 1)
  D.rail(c, x0 + 1, y0 - h * 0.28, x1 + 1, y1 - h * 0.28, rr)
  D.rail(c, x0 + 1, y0 - h * 0.74, x1 + 1, y1 - h * 0.74, rr)
  for i = 0, n - 1 do
    D.picket(c, floor(x0 + dx * i + .5), floor(y0 + dy * i + .5), w, h, ramp, top)
  end
end
-- small leaf (ellipse leaf with midrib) 
function D.tleaf(c, cx, cy, rx, ry, ang, ramp)
  local m = B.ell(cx, cy, rx, ry, ang)
  B.lit(c, m, ramp, min(rx, ry) + .6)
  local ca, sa = cos(ang), sin(ang)
  local r = H.ramp(ramp)
  for t = -rx + 1, rx - 1, 1 do c:px(floor(cx + ca * t + .5), floor(cy + sa * t + .5), r[2]) end
  return m
end
return D
