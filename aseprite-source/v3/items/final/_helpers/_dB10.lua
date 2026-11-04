-- _dB10 helper (first-draft items, chunk B10). Thin layer over batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X, K = B.H, B.HP, B.X, B.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local D = { B = B, H = H, HP = HP, X = X, K = K, P = H.P }
function D.new(name) return B.new(name) end
function D.fin() B.fin() end
D.ell, D.ln, D.lit, D.seed, D.blade, D.sprout, D.seam = B.ell, B.ln, B.lit, B.seed, B.blade, B.sprout, B.seam
-- speckle tone variation on a lit part: idx from lit()
function D.speck(c, m, idx, ramp, seed, dens)
  local r = H.ramp(ramp)
  m:each(function(x, y)
    local i = idx[K(x, y)]
    if not i then return end
    local h = X.hash(x, y, seed or 7)
    if h > 1 - (dens or .12) and i >= 2 then c:px(x, y, r[i - 1])
    elseif h < (dens or .12) * .7 and i <= 5 and i >= 2 then c:px(x, y, r[i + 1]) end
  end)
end
D.LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
D.HEDGE = { "#183c32", "#256440", "#348048", "#4a9e50", "#72bb5c", "#a3d670" }
D.HEDGE2 = { "#12302c", "#1c4c38", "#286a40", "#3a8847", "#58a853", "#80c564" }
D.WOOD = { "#3d2420", "#5e3a2c", "#8a5638", "#b57850", "#d9a070", "#f0c698" }
D.STEEL = { "#3c3e57", "#555973", "#72778f", "#9296ab", "#b7bacb", "#e4e6ee" }
D.COPPER = { "#5c2a1e", "#8a3c20", "#b8582a", "#d98038", "#f0a850", "#ffd58a" }
D.CREAM = { "#9c8f86", "#c9bba0", "#e6dbbf", "#f6ecd2", "#fff4d6", "#fff4d6" }
-- oblique hedge block(s): rects = footprint {x0,y0,x1,y1}; h = front height
function D.hedge(c, rects, h, o)
  o = o or {}
  local full, tp = HP.mask(), HP.mask()
  for _, r in ipairs(rects) do
    full:add(c:rrect(r[1], r[2], r[3], r[4] + h, o.r or 3))
    tp:add(c:rrect(r[1], r[2], r[3], r[4], o.r or 3))
  end
  c:groundShadow(32, 56, 24, 2)
  local fi = D.lit(c, full, o.front or D.HEDGE2, 2.4, { wrap = .15 })
  D.speck(c, full, fi, o.front or D.HEDGE2, 3, .16)
  -- soil strip
  for _, p in ipairs{} do end
  local ti = D.lit(c, tp, o.top or D.HEDGE, 4, {})
  D.speck(c, tp, ti, o.top or D.HEDGE, 11, .16)
  -- crease between top and front
  full:copy():cut(tp):each(function(x, y) if tp:has(x, y - 1) then c:px(x, y, (o.front or D.HEDGE2)[1]) end end)
  -- soil/trunk row at base
  full:each(function(x, y) if not full:has(x, y + 1) then c:px(x, y, D.WOOD[1]) end end)
  return full, tp
end
-- tiny helper to draw a small ball with lighting
function D.ball(c, cx, cy, r, ramp)
  return H.disc(c, cx, cy, r, ramp)
end
-- gauze/leaf scrap with veins
function D.scrap(c, ax, ay, bx, by, w, ramp, veins)
  return B.blade(c, ax, ay, bx, by, w, ramp or D.LEAF, { veins = veins or { 6, 11, 16, 21, 26, 31, 36 }, slant = 2.2 })
end
return D
