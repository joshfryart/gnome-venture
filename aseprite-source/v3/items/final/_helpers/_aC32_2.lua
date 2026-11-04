-- _aC32_2.lua: private helpers for ph/passion-fruit-seed, passionflower-seed, pea, pea-seed (final pass, Opus).
-- Copy of the _aA0_0 pattern. Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
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

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

-- light + tone a normal field; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- blend of sphere-ish normal (about cx,cy, radius r) and pillow normals: round body with a soft silhouette
function A.body(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 5)
  local ns = X.sphere(cx, cy, r, m)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

-- re-tone one pixel by delta steps using idx
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- leaf blade along quadratic bezier A-C-B; wfn optional; veins every `vs` px; returns mask, T, S
function A.leaf(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local wfn = o.wfn or function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.98 + 0.04)) ^ (o.pw or 0.75))
  end
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.45 })
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "leaf" } }
  local idx = G.toneN(c, m, n, ramp, { amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok, bias = o.bias })
  local vs = o.vs or 3.2
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.16 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and ramp[min(6, (idx[k] or 3) + 2)] or ramp[max(2, (idx[k] or 3) - 1)], tok)
    elseif t > 0.12 and t < 0.86 and abs(s) > 0.3 and abs(s) < 0.8 then
      local d = (t * len - abs(s) * w * 1.1) % vs
      if d < 0.9 then c:put(x, y, s < 0 and ramp[min(6, (idx[k] or 3) + 1)] or ramp[max(1, (idx[k] or 3) - 1)], tok) end
    end
  end)
  return m, T, S, idx
end

-- tube with lighting; returns m, n, T, S, idx, samp
function A.stem(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(pts, wfn)
  if o.cut then m:cut(o.cut) end
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.14, wrap = o.wrap or 0.3, cuts = o.cuts or (#ramp == 4 and { 0.3, 0.55, 0.8 } or CUTS), tok = o.tok, bias = o.bias })
  return m, n, T, S, idx, samp
end

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

-- torn edge: remove pixels of m on the far side of a jagged line through (x0,y0) with unit normal (nx,ny)
-- (pixels with (p-p0).n > jag are cut). jag varies per position with a hashed zigzag.
function A.tear(m, x0, y0, nx, ny, amp, seed)
  local cut = HP.mask()
  m:each(function(x, y)
    local d = (x - x0) * nx + (y - y0) * ny
    local along = (x - x0) * -ny + (y - y0) * nx
    local a = floor(along / 2)
    local j = (X.hash(a, 7, seed or 1) - 0.5) * 2 * (amp or 1.6) + ((a % 2 == 0) and 0.8 or -0.4)
    if d > j then cut:set(x, y) end
  end)
  m:cut(cut)
  return cut
end

-- paint a mask region darker by one step (contact shadow / AO) using an idx table and ramp
function A.darken(c, m, idx, ramp, region, d, tok)
  region:each(function(x, y) if m:has(x, y) then A.step(c, idx, ramp, x, y, d or -1, tok) end end)
end

-- small tendril spiral from (x,y), start angle a0, turns, radius start r0 growth dr per step, dir +1/-1
function A.tendril(c, pts, hexA, hexB, tok)
  for i, p in ipairs(pts) do c:put(p[1], p[2], (i % 3 == 0) and hexB or hexA, tok) end
end
function A.spiral(cx, cy, a0, r0, dr, n, dir)
  local out, seen = {}, {}
  for k = 0, n do
    local a = a0 + dir * k * 0.42
    local r = r0 + k * dr
    local x, y = floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5)
    local key = K(x, y)
    if not seen[key] then seen[key] = true out[#out + 1] = { x, y } end
  end
  return out
end
function A.erase(c, x, y) local i = y * c.w + x c.pix[i] = nil c.own[i] = nil end
-- lit oval seed. o: flat, bias, cut, tok, pits (0..1 density), pitSeed, spec (hex or false), amb
function A.seed(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang, o.flat or 0.8)
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "seed" } }
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.08, wrap = o.wrap or 0.25, bias = o.bias, tok = tok, cuts = o.cuts })
  if o.pits then
    local inner = m:shrink(1)
    local pit = {}
    inner:each(function(x, y) if X.hash(x, y, o.pitSeed or 3) < o.pits and not pit[K(x - 1, y)] and not pit[K(x, y - 1)] then pit[K(x, y)] = true end end)
    for k in pairs(pit) do local x, y = k % 1024 - 256, k // 1024 - 256
      A.step(c, idx, ramp, x, y, -2, tok)
      if inner:has(x + 1, y + 1) and not pit[K(x + 1, y + 1)] then A.step(c, idx, ramp, x + 1, y + 1, 1, tok) end
    end
  end
  if o.spec ~= false then
    local sx, sy = G.specAt(m:shrink(1), n, 30)
    if sx then c:put(sx, sy, o.spec or ramp[#ramp], tok) end
  end
  return m, n, idx, tok
end
return A
