-- _wm.lua: private helpers for watermelon + watermelon-seed (batch2, Opus pass). Wraps batch1/_g1.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../batch1/_g1.lua")
local HP, X, K = G.HP, G.X, G.K
local W = setmetatable({}, { __index = G })
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi

-- watermelon leaf ramps (shared so crop leaf and seed scrap match)
W.LEAF = { "#173c36", "#1f5540", "#2c7047", "#438e4d", "#68ad57", "#9acb6c" }
W.VEIN, W.COOL = "#c2e28e", "#3a6e72"

-- one lobe: curved blade from (ax,ay) via (cx,cy) to (bx,by), half width w, wavy margin.
-- paints into c, returns mask, T, S, len
function W.lobe(c, ax, ay, cx, cy, bx, by, w, o)
  o = o or {}
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.95 + 0.05)
    local b = w * sin(pi * u ^ (o.pow or 1.1)) ^ 0.75
    if o.lob then b = b * (1 - (o.lamp or 0.32) * max(0, sin(t * pi * o.lob))) end   -- secondary lobing
    return max(0.45, b)
  end, { fold = o.fold or 0.45 })
  -- small serration nibble on the margin
  m:edge():each(function(x, y) local k = K(x, y)
    if T[k] > 0.15 and T[k] < 0.9 and sin(T[k] * len / 1.6 + (S[k] > 0 and 1 or 0)) > 0.7 then m.s[k] = nil end end)
  local tok = o.tok or { r = { name = "leaf" } }
  G.toneN(c, m, n, o.ramp or W.LEAF, { bias = o.bias, tok = tok, cuts = o.cuts or { 0.24, 0.42, 0.58, 0.74, 0.92 }, amb = 0.1, wrap = 0.22 })
  local R = o.ramp or W.LEAF
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if o.bias and o.bias[k] then return end
    if abs(s) < 0.13 and t < 0.92 then c:put(x, y, s <= 0 and (o.vein or W.VEIN) or R[3], tok) return end
    for _, vt in ipairs(o.veins or {}) do
      local d = t * len - (vt + abs(s) * 3.2)
      if d > -0.5 and d < 0.5 and abs(s) > 0.2 and abs(s) < 0.72 then c:put(x, y, s < 0 and (o.vein or W.VEIN) or R[2], tok) return end
    end
  end)
  if not o.nocool then
    m:edge():each(function(x, y) local k = K(x, y)
      if not (o.bias and o.bias[k]) and S[k] > 0.55 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, W.COOL, tok) end end)
  end
  return m, T, S, len
end

-- flat teardrop seed: round end at -u, point at +u. returns mask, normals
function W.drop(cx, cy, rl, rw, ang, tip)
  local ca, sa = cos(ang), sin(ang)
  local m = HP.mask()
  local R = rl + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rl + 0.4)
    local v = (-dx * sa + dy * ca)
    if abs(u) <= 1 then
      local hw = (rw + 0.4) * sqrt(1 - u * u) * (1 - (tip or 0.35) * (u + 1) / 2)
      if abs(v) <= hw then m:set(x, y) end
    end
  end end
  return m
end

-- 1px polyline of pixels (no mask), colour list per segment index or single colour
function W.path(c, pts, col, tok)
  local out = {}
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]), 1)
    for s = 0, n do
      local x, y = floor(a[1] + (b[1] - a[1]) * s / n + .5), floor(a[2] + (b[2] - a[2]) * s / n + .5)
      c:put(x, y, type(col) == "table" and col[min(#col, i)] or col, tok)
      out[#out + 1] = { x, y }
    end
  end
  return out
end
return W
