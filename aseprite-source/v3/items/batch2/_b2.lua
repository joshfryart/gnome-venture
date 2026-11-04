-- batch2 helper: thin layer over batch1/_h.lua (not edited)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/../batch1/_h.lua")
local HP, X = H.HP, H.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local B = { H = H, HP = HP, X = X, K = H.K }
function B.new(name) H.out = app.params.out or "./"; local _, _, c, P = H.new(name) B.c = c return c end
-- rotated ellipse mask
function B.ell(cx, cy, rx, ry, ang)
  local m = HP.mask() ang = ang or 0
  local ca, sa = cos(ang), sin(ang)
  local R = math.ceil(max(rx, ry)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx + .0, y - cy + .0
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
function B.lit(c, m, ramp, R, o) o = o or {} o.R = R or 3 return H.lit(c, m, ramp, o) end
-- line of pixels (clip optional)
function B.ln(c, x0, y0, x1, y1, hex, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:px(x, y, hex) end
  end
end
function B.polyline(c, pts, hex, clip) for i = 1, #pts - 1 do B.ln(c, pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], hex, clip) end end
-- pixels of m touching front (4-adj) get hex
function B.seam(c, m, front, hex)
  m:each(function(x, y)
    if front:has(x, y) then return end
    if front:has(x+1, y) or front:has(x-1, y) or front:has(x, y+1) or front:has(x, y-1) then c:px(x, y, hex) end
  end)
end
-- leaf blade from a to b, w = max half width, profile exponent; midrib + veins (veins every vs px)
function B.blade(c, ax, ay, bx, by, w, ramp, o)
  o = o or {}
  local r = H.ramp(ramp)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.97 then return -1 end
    local pr = o.prof and o.prof(t) or sin(pi * min(1, t * 1.02 + 0.06)) ^ 0.7
    return max(0.5, w * pr)
  end)
  X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), r, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  local len = sqrt((bx-ax)^2 + (by-ay)^2)
  m:each(function(x, y)
    local k = B.K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.2 and t > 0.05 and t < 0.9 and not o.norib then c:px(x, y, s <= 0 and r[6] or r[2]) end
    if o.veins then
      for _, vt in ipairs(o.veins) do
        local d = t * len - (vt + abs(s) * (o.slant or 2.2))
        if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.85 then c:px(x, y, s < 0 and r[5] or r[2]) end
      end
    end
  end)
  return m
end
-- sprout: stem from (x,y) up by (dx,dy) with leaves list {x,y,rx,ry,ang}
function B.sprout(c, x, y, tx, ty, stemHex, leaves, ramp)
  B.ln(c, x, y, tx, ty, stemHex)
  for _, L in ipairs(leaves) do
    local m = B.ell(L[1], L[2], L[3], L[4], L[5])
    B.lit(c, m, ramp, 1.6)
  end
end
-- lit seed with contact shadow (offset shadow ellipse first), glint at upper-left
function B.seed(c, cx, cy, rx, ry, ang, ramp, shadow, glint)
  c:fillMask(B.ell(cx + 1, cy + 1.2, rx + .3, ry + .3, ang), shadow or "#1f553f")
  local m = B.ell(cx, cy, rx, ry, ang)
  B.lit(c, m, ramp, min(rx, ry) + .6)
  if glint ~= false then c:px(floor(cx - rx * .35), floor(cy - ry * .45), glint or "#fff4d6") end
  return m
end
function B.fin() H.fin(B.c) end
return B
