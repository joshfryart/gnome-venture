-- dB13 helper: thin layer over batch2/_b2.lua (not edited)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local HP, X, H = B.HP, B.X, B.H
local D = { B = B, HP = HP, X = X, H = H }
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
function D.new(name) local c = B.new(name) D.c = c return c end
function D.fin() B.fin() end
-- tapered rod with lighting; hw0 at a, hw1 at b
function D.rod(c, ax, ay, bx, by, hw0, hw1, ramp, o)
  local m, T, S = H.cyl(c, ax, ay, bx, by, function(t) return hw0 + (hw1 - hw0) * t end, ramp, o)
  return m, T, S
end
function D.ball(c, cx, cy, rx, ry, ramp, ang, R)
  local m = B.ell(cx, cy, rx, ry, ang or 0)
  B.lit(c, m, ramp, R or min(rx, ry) + .5)
  return m
end
-- chip: small floating fragment
function D.chip(c, x, y, rx, ry, ramp, ang) return D.ball(c, x, y, rx, ry, ramp, ang, 1.2) end
-- grain lines along a->b offset inside mask
function D.grain(c, m, ax, ay, bx, by, hex, offs)
  for _, o in ipairs(offs) do
    local dx, dy = bx - ax, by - ay local l = sqrt(dx*dx + dy*dy)
    local nx, ny = -dy / l, dx / l
    B.ln(c, ax + nx * o, ay + ny * o, bx + nx * o, by + ny * o, hex, m)
  end
end
-- seed-on-leaf scene
function D.scene(c, o)
  local a, b = o.a or { 6, 53 }, o.b or { 57, 47 }
  local lm = B.blade(c, a[1], a[2], b[1], b[2], o.w or 7, o.leaf, { veins = o.veins or { 8, 14, 20, 26, 32, 38 } })
  for _, s in ipairs(o.seeds) do B.seed(c, s[1], s[2], s[3], s[4], s[5] or 0, s[6], o.shadow, s[7]) end
  if o.stem then
    local s = o.stem
    B.sprout(c, s[1], s[2], s[3], s[4], s.hex or "#4f9f52", s.leaves, s.ramp or o.leaf)
  end
  if o.extra then o.extra(c) end
end
return D
