-- _dB23.lua: helpers for first-draft items cucumber-kimchi .. desert-sage (reads batch2/_b2.lua, edits nothing shared)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = setmetatable({}, { __index = B })
D.INK, D.CREAM = "#2b1c26", "#fff4d6"
function D.new(name) return B.new(name) end
-- 6-tone ramp from dark, mid, light hex
function D.rp(dk, md, lt)
  return { dk, H.mix(dk, md, .5), md, H.mix(md, lt, .4), H.mix(md, lt, .75), lt }
end
D.LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
D.SAGE = D.rp("#2f4a46", "#7f9f78", "#dfe9c4")
-- mask lit as ramp, returns mask
function D.blob(m, ramp, R, o) B.lit(B.c, m, ramp, R or 3, o) return m end
function D.el(cx, cy, rx, ry, ang, ramp, R) local m = B.ell(cx, cy, rx, ry, ang) B.lit(B.c, m, ramp, R or min(rx, ry) + .6) return m end
-- leaf: ellipse-ish lit with midrib. ang radians (0 = pointing +x)
function D.leaf(cx, cy, rx, ry, ang, ramp, rib)
  local c = B.c
  local m = B.ell(cx, cy, rx, ry, ang)
  B.lit(c, m, ramp or D.LEAF, 1.6)
  local r = H.ramp(ramp or D.LEAF)
  if rib ~= false then
    local ca, sa = cos(ang), sin(ang)
    B.ln(c, cx - ca * (rx - 1), cy - sa * (rx - 1), cx + ca * (rx - 1.5), cy + sa * (rx - 1.5), r[6], m)
  end
  return m
end
-- stem polyline w px wide (1 or 2): light left, dark right
function D.stem(pts, lt, dk, w)
  local c = B.c
  B.polyline(c, pts, dk)
  local sh = {}
  for i, p in ipairs(pts) do sh[i] = { p[1] - 1, p[2] } end
  if w and w > 1 then B.polyline(c, sh, lt) else B.polyline(c, pts, lt) end
end
-- leaf scrap on a diagonal: returns mask
function D.scrap(o)
  o = o or {}
  local c = B.c
  local ax, ay, bx, by = o.ax or 6, o.ay or 56, o.bx or 53, o.by or 49
  local m = B.blade(c, ax, ay, bx, by, o.w or 8, o.ramp or D.LEAF, { veins = o.veins or { 8, 15, 22, 29, 36 }, slant = 1.8 })
  return m
end
-- seed with contact shadow
function D.seed(cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  return B.seed(B.c, cx, cy, rx, ry, ang, ramp, o.shadow or "#1f553f", o.glint)
end
function D.bee(x, y)
  local c = B.c
  c:px(x, y, "#f5b82e") c:px(x+1, y, D.INK) c:px(x+2, y, "#f5b82e") c:px(x+3, y, D.INK)
  c:px(x, y+1, "#f5b82e") c:px(x+1, y+1, "#f5b82e") c:px(x+2, y+1, "#d98322") c:px(x+3, y+1, "#d98322")
  c:px(x+1, y-1, "#e4f6ff") c:px(x+2, y-1, "#b9e2f5")
end
function D.fin() B.fin() end
return D
