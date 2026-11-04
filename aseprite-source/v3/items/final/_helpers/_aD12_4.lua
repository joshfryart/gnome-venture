-- _aD12_4.lua: private helper for artist aD12_4 (rice-and-peas, rice-seed, rich-loam, river-clay).
-- Thin layer over batch2/_b2g1.lua (not edited): one HP instance, tube / blade / oval / cast / toneN / recentre.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local A = { G = G, HP = HP, X = X, K = K }
function A.new(name) return G.new2(name) end
function A.save(c, name) G.save2(c, name) end
function A.rng(seed)
  local s = seed or 7
  return function() s = (s * 1103515245 + 12345) % 2147483648 return s / 2147483648 end
end
-- rotated ellipse mask
function A.ell(cx, cy, rx, ry, ang)
  local m = HP.mask() ang = ang or 0
  local ca, sa = cos(ang), sin(ang)
  local R = math.ceil(max(rx, ry)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
function A.ln(c, x0, y0, x1, y1, hex, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:px(x, y, hex) end
  end
end
function A.pl(c, pts, hex, clip) for i = 1, #pts - 1 do A.ln(c, pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], hex, clip) end end
-- polygon mask from rows: f(y) -> x0, x1
function A.rows(y0, y1, f)
  local m = HP.mask()
  for y = y0, y1 do local a, b = f(y) if a then for x = floor(a + .5), floor(b + .5) do m:set(x, y) end end end
  return m
end
-- pillow-lit mask (rounded bevel R)
function A.pill(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R or 2.5)
  return G.toneN(c, m, n, ramp, o), n
end
-- sphere-lit mask
function A.sph(c, m, cx, cy, r, ramp, o)
  o = o or {}
  local n = X.sphere(cx, cy, r, m)
  return G.toneN(c, m, n, ramp, o), n
end
-- spindle (pointed grain) mask along angle; L half length, W half width. base round at -u, tip pointed at +u
function A.spind(cx, cy, L, W, ang)
  local m = HP.mask()
  local ca, sa = cos(ang), sin(ang)
  local R = math.ceil(L) + 2
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    local s = (u + L) / (2 * L)
    if s > 0 and s < 1 then
      local p = sin(pi * s ^ 0.72) ^ 0.8
      if abs(v) <= W * p + 0.15 then m:set(x, y) end
    end
  end end
  return m
end
-- blade along quadratic bezier with midrib and optional parallel veins (S offsets)
function A.blade(c, ax, ay, cx, cy, bx, by, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.4 })
  if o.cut then o.cut(m, T, S, len) end
  if o.bias then end
  local idx = G.toneN(c, m, n, ramp, { bias = o.bias, tok = o.tok, cuts = o.cuts or { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  return m, n, T, S, len, idx
end
return A
