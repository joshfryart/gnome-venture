-- _aR2_5.lua: private helpers for ph/artichoke, artichoke-fava-stew, artichoke-seed, ashanti-blood-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.CUTS = CUTS
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- blend pillow + sphere normals
function A.body(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 5)
  local ns = X.sphere(cx, cy, r, m)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- lanceolate, finely serrated leaf (peach / almond): blade along A-C-B, midrib + angled veins, saw-tooth margin
function A.leaf(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local teeth = o.teeth or 2.6
  local wfn = o.wfn or function(t)
    if t > 0.985 then return -1 end
    local base = w * sin(pi * min(1, t * 0.97 + 0.05) ^ (o.pk or 1.0)) ^ (o.pw or 0.8)
    return max(0.4, base)
  end
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.45 })
  -- serration: nibble one px off the margin every `teeth` px (offset between sides)
  if o.serrate ~= false then
    local cut = {}
    m:edge():each(function(x, y) local k = K(x, y)
      local ph = (T[k] * len / teeth) + (S[k] > 0 and 0.5 or 0)
      if T[k] > 0.12 and T[k] < 0.9 and (ph - floor(ph)) < 0.34 and abs(S[k]) > 0.5 then cut[#cut + 1] = k end
    end)
    for _, k in ipairs(cut) do m.s[k] = nil end
  end
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "leaf" } }
  local idx = G.toneN(c, m, n, ramp, { amb = o.amb or 0.12, wrap = 0.28, cuts = o.cuts or { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok, bias = o.bias })
  local vs = o.vs or 3.4
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if (o.bias and o.bias[k]) then return end
    if abs(s) < 0.15 and t > 0.03 and t < 0.9 then
      c:put(x, y, s <= 0 and (o.rib or ramp[min(6, (idx[k] or 3) + 2)]) or ramp[max(2, (idx[k] or 3) - 1)], tok)
    elseif t > 0.1 and t < 0.86 and abs(s) > 0.3 and abs(s) < 0.78 then
      local d = (t * len - abs(s) * w * 1.2 + (s > 0 and 1.6 or 0)) % vs
      if d < 0.9 then c:put(x, y, s < 0 and ramp[min(6, (idx[k] or 3) + 1)] or ramp[max(1, (idx[k] or 3) - 1)], tok) end
    end
  end)
  return m, T, S, idx, len
end

function A.stem(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(pts, wfn)
  if o.cut then m:cut(o.cut) end
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.14, wrap = o.wrap or 0.3, cuts = o.cuts or (#ramp == 4 and { 0.3, 0.55, 0.8 } or CUTS), tok = o.tok, bias = o.bias })
  return m, n, T, S, idx, samp
end

-- almond / peach-stone outline: pointed teardrop along unit axis (ux,uy) centred cx,cy, half-length L, half-width W
-- returns mask, normals, U (-1 blunt .. 1 tip), V (-1..1 across, V<0 lit side)
function A.almond(cx, cy, ux, uy, L, W, pointy, flat)
  pointy = pointy or 0.9
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local m, n, U, V = HP.mask(), {}, {}, {}
  local B = floor(L + W) + 2
  for y = floor(cy) - B, floor(cy) + B do for x = floor(cx) - B, floor(cx) + B do
    local dx, dy = x - cx, y - cy
    local u = (dx * ux + dy * uy) / (L + 0.4)
    local v = (dx * px + dy * py)
    if u >= -1 and u <= 1 then
      -- width profile: round at blunt end (u=-1), pointed at tip (u=1)
      local w = u < 0 and W * sqrt(max(0, 1 - u * u)) or W * max(0, 1 - u * u) ^ pointy
      local vv = v / (w + 0.45)
      if abs(vv) <= 1 and w > 0.2 then
        m:set(x, y)
        local k = K(x, y)
        local nz = sqrt(max(0.03, 1 - vv * vv)) * (flat or 1)
        local nu = u ^ 3 * 0.8
        n[k] = { norm(px * vv + ux * nu, py * vv + uy * nu, nz) }
        U[k], V[k] = u, vv
      end
    end
  end end
  return m, n, U, V
end

-- paint char rows (map char -> hex); '.' skipped
function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
