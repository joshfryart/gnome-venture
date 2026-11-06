-- dB20 helper: thin layer over batch2/_b2.lua. Not editing shared files.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X, P = B.H, B.HP, B.X, H and B.H.P or nil
P = H.P
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = { B = B, H = H, HP = HP, X = X, K = B.K, P = P, INK = "#2b1c26", CREAM = "#fff4d6" }
D.new, D.lit, D.ell, D.ln, D.polyline, D.blade, D.seed, D.sprout = B.new, B.lit, B.ell, B.ln, B.polyline, B.blade, B.seed, B.sprout
D.ramp, D.cyl, D.disc, D.leaf, D.mix, D.sweep = H.ramp, H.cyl, H.disc, H.leaf, H.mix, H.sweep
function D.fin() H.fin(B.c) end
-- vertical-axis cylinder body: mask m, shaded between x0..x1
function D.body(c, m, ramp, x0, x1, o) return H.vcyl(c, m, ramp, x0, x1, o) end
-- leaf scrap (long blade) under seeds; returns mask
function D.scrap(c, ramp, ax, ay, bx, by, w, veins)
  return B.blade(c, ax, ay, bx, by, w, ramp, { veins = veins or { 5, 10, 15, 20, 25, 30, 35, 40 } })
end
-- glossy drop / bead
function D.bead(c, cx, cy, r, ramp)
  local m = H.disc(c, cx, cy, r, ramp)
  c:px(floor(cx - r * .45), floor(cy - r * .5), D.CREAM)
  return m
end
-- steam curl, 1px cream-ish S going up
function D.steam(c, x, y, hex, n)
  for i = 0, (n or 8) do c:px(x + floor(sin(i * .9) * 1.6 + .5), y - i, hex or "#f3ecf2") end
end
-- little hatch marks along a mask
function D.hatch(c, m, hex, step, ox)
  m:each(function(x, y) if (x + y * 2 + (ox or 0)) % step == 0 then c:px(x, y, hex) end end)
end
return D
