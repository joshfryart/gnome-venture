-- _dC21: helper for ph/lm..mackerel chunk (wraps batch2/_b2.lua, not edited)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local D = { B = B, H = B.H, HP = B.HP, X = B.X, K = B.K, P = B.H.P }
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
D.LEAF = { "#123a3c", "#1a5a4b", "#247b55", "#3a9c5f", "#64be6c", "#a2dc86" }
D.WOOD = { "#3a1f22", "#5c3426", "#7f4c2e", "#a5693a", "#c88d52", "#e8b878" }
D.CREAM = "#fff2d8"
function D.new(name) return B.new(name) end
function D.fin() B.fin() end
-- elliptical leaflet with midrib; ang as B.ell
function D.leaflet(c, cx, cy, rx, ry, ang, ramp, rib)
  local m = B.ell(cx, cy, rx, ry, ang)
  B.lit(c, m, ramp, min(rx, ry) + .8)
  local r = B.H.ramp(ramp)
  local ca, sa = cos(ang), sin(ang)
  for i = -floor(rx), floor(rx) - 1 do
    local x, y = floor(cx + ca * i + .5), floor(cy + sa * i + .5)
    if m:has(x, y) then c:px(x, y, rib or r[6]) end
  end
  return m
end
-- leaf scrap: blade a->b with veins; returns mask
function D.scrap(c, ax, ay, bx, by, w, ramp, o)
  o = o or {}
  o.veins = o.veins or { 4, 9, 14, 19, 24, 29 }
  return B.blade(c, ax, ay, bx, by, w, ramp or D.LEAF, o)
end
-- small round dewdrop
function D.dew(c, x, y)
  c:px(x, y, "#7fd0d8") c:px(x + 1, y, "#4aa6bc") c:px(x, y + 1, "#4aa6bc") c:px(x + 1, y + 1, "#2c7c98") c:px(x, y, "#e8fbff")
end
return D
