-- dD1t0 helper: thin layer over batch2/_b2.lua (shared files untouched).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local D = { B = B, H = H, HP = HP, X = X, K = B.K, INK = "#2b1c26", CREAM = "#fff4d6" }
D.new, D.ell, D.lit, D.ln, D.polyline, D.fin = B.new, B.ell, B.lit, B.ln, B.polyline, B.fin
-- leaf scrap: lit blade with midrib + side veins, plus cool under-edge
function D.scrap(c, ax, ay, bx, by, w, ramp, veins)
  return B.blade(c, ax, ay, bx, by, w, ramp, { veins = veins or { 5, 9, 13, 17 }, slant = 2.2 })
end
-- flat seed with contact shadow, ridge line and glint
function D.flatSeed(c, cx, cy, rx, ry, ang, ramp, shadow, ridge)
  local m = B.seed(c, cx, cy, rx, ry, ang, ramp, shadow)
  if ridge then B.ln(c, floor(cx - rx * .5), floor(cy + ry * .2), floor(cx + rx * .5), floor(cy - ry * .2), ridge, m) end
  return m
end
return D
