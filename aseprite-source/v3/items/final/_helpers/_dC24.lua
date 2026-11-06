-- _dC24 helper (first-draft chunk C24). Thin layer over batch2/_b2.lua; shared files are not edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = { B = B, H = H, HP = HP, X = X }
function D.new(name) return B.new(name) end
function D.fin() B.fin() end
function D.R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
function D.ramp(r) return H.ramp(r) end
-- polyline stem w px wide, 2-tone (base + lit edge pixels)
function D.stem(c, pts, w, base, lit)
  local m = c:line(pts, w)
  c:fillMask(m, base)
  if lit then m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then c:px(x, y, lit) end end) end
  return m
end
-- elliptic leaf along axis, midrib + n side veins
function D.leafE(c, cx, cy, rx, ry, ang, ramp, nv)
  local r = H.ramp(ramp)
  local m = B.ell(cx, cy, rx, ry, ang)
  B.lit(c, m, r, min(rx, ry) + .8)
  local ca, sa = cos(ang), sin(ang)
  B.ln(c, cx - ca * (rx - 1), cy - sa * (rx - 1), cx + ca * (rx - 2), cy + sa * (rx - 2), r[6], m)
  nv = nv or 0
  for i = 1, nv do
    local u = -0.5 + (i - 1) / max(1, nv) * 1.1
    local px, py = cx + ca * rx * u, cy + sa * rx * u
    for sgn = -1, 1, 2 do
      local ex, ey = px + (ca * 0.8 - sgn * sa * 0.9) * ry * .85, py + (sa * 0.8 + sgn * ca * 0.9) * ry * .85
      B.ln(c, px, py, ex, ey, sgn < 0 and r[5] or r[2], m)
    end
  end
  return m
end
-- heart leaf (two lobes + pointed tip) pointing along ang
function D.heart(c, cx, cy, r, ang, ramp, ribs)
  local rp = H.ramp(ramp)
  local ca, sa = cos(ang), sin(ang)
  local m = HP.mask()
  m:add(B.ell(cx - ca * r * .1 - sa * r * .45, cy - sa * r * .1 + ca * r * .45, r * .62, r * .62, 0))
  m:add(B.ell(cx - ca * r * .1 + sa * r * .45, cy - sa * r * .1 - ca * r * .45, r * .62, r * .62, 0))
  m:add(B.ell(cx + ca * r * .45, cy + sa * r * .45, r * .62, r * .42, ang))
  B.lit(c, m, rp, r * .7)
  B.ln(c, cx - ca * r * .5, cy - sa * r * .5, cx + ca * r * 1.0, cy + sa * r * 1.0, rp[6], m)
  if ribs then
    for sgn = -1, 1, 2 do
      B.ln(c, cx, cy, cx + (ca * .5 - sgn * sa * .8) * r, cy + (sa * .5 + sgn * ca * .8) * r, rp[2], m)
    end
  end
  return m
end
-- leaf scrap: slim blade with veins, returns mask
function D.scrap(c, o)
  o = o or {}
  local x0, y0, x1, y1 = o.x0 or 6, o.y0 or 55, o.x1 or 56, o.y1 or 51
  return B.blade(c, x0, y0, x1, y1, o.w or 6.5, o.ramp or "moss", { veins = o.veins or { 8, 14, 20, 26, 32, 38, 44 }, slant = o.slant or 2 })
end
-- scatter specks inside mask
function D.speck(c, m, hex, seed, thr)
  m:each(function(x, y) if X.hash(x, y, seed or 5) > (thr or 0.9) then c:px(x, y, hex) end end)
end
function D.dot(c, x, y, hex) c:px(x, y, hex) end
return D
