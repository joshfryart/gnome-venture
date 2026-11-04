-- dC35 helper: thin layer over batch2/_b2.lua. Not editing shared files.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = { B = B, H = H, HP = HP, X = X, K = B.K, P = H.P, INK = "#2b1c26", CREAM = "#fff4d6" }
D.new = B.new
D.lit = B.lit
D.ell = B.ell
D.ln = B.ln
D.ramp = H.ramp
D.fin = function() H.fin(B.c) end
D.MOSS  = { "#1f4a3a", "#2f6b45", "#3f9150", "#5fae52", "#8fcb64", "#c4e07a" }
D.PLUM  = { "#1f1442", "#35255f", "#4f3b8c", "#6b53ad", "#8d78cb", "#b5a3e6" }
D.PLUOT = { "#1f4a3a", "#2f6b45", "#4c8e4e", "#74b055", "#a2cf66", "#d2e88c" }
D.STONE = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }
D.WOOD  = { "#3a2420", "#51302b", "#864c33", "#b97a4a", "#d49a62", "#e8b982" }
D.GLASS = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8adbd6", "#b6f0e0", "#e4fbf4" }
-- lit ellipse with glint; returns mask
function D.ball(c, cx, cy, rx, ry, ramp, o)
  o = o or {}
  local m = B.ell(cx, cy, rx, ry, o.ang or 0)
  B.lit(c, m, ramp, o.R or (min(rx, ry) + .6), o.lo)
  if o.glint ~= false then c:px(floor(cx - rx * .4), floor(cy - ry * .45), o.gh or D.CREAM) end
  return m
end
-- lit rounded rect
function D.box(c, x0, y0, x1, y1, r, ramp, R)
  local m = c:rrect(x0, y0, x1, y1, r)
  B.lit(c, m, ramp, R or 3)
  return m
end
-- vertical cylinder rrect
function D.vc(c, x0, y0, x1, y1, r, ramp)
  local m = c:rrect(x0, y0, x1, y1, r)
  H.vcyl(c, m, ramp, x0 - 1, x1 + 1)
  return m
end
-- hashed speckles over a mask
function D.speck(c, m, hexes, dens, seed)
  m:each(function(x, y)
    local h = X.hash(x, y, seed or 3)
    if h < dens then c:px(x, y, hexes[1 + floor(X.hash(y, x, 9) * #hexes) % #hexes]) end
  end)
end
-- small leaf (ellipse + midrib)
function D.lf(c, cx, cy, rx, ry, ang, ramp)
  local m = B.ell(cx, cy, rx, ry, ang)
  B.lit(c, m, ramp, 1.8)
  local ca, sa = cos(ang), sin(ang)
  B.ln(c, cx - ca * (rx - 1), cy - sa * (rx - 1), cx + ca * (rx - 1), cy + sa * (rx - 1), ramp[2], m)
  return m
end
-- glass sheen over a jar body mask
function D.sheen(c, x0, x1, y0, y1)
  for y = y0, y1 do c:px(x0 + 1, y, D.GLASS[5]) end
  c:px(x0 + 2, y0, D.GLASS[6]) c:px(x0 + 2, y0 + 1, D.GLASS[6])
  for y = y0 + 3, y1 - 2 do c:px(x1 - 1, y, D.GLASS[2]) end
end
return D
