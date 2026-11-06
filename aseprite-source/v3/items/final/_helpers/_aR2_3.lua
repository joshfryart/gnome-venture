-- _aR2_3.lua: private helpers for ph/apple-chutney, apple-cider, apple-crumble, apple-seed (final pass, Opus).
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

-- surface of revolution about a vertical axis cx, radius rfn(y) (float) for y0..y1.
-- returns mask, normals, S (x offset -1..1, <0 lit), R (radius per row)
function A.lathe(cx, y0, y1, rfn, o)
  o = o or {}
  local m, n, S = HP.mask(), {}, {}
  for y = y0, y1 do
    local r = rfn(y)
    if r and r > 0 then
      local dr = ((rfn(y + 1) or r) - (rfn(y - 1) or r)) / 2
      for x = floor(cx - r - 1), floor(cx + r + 1) do
        local s = (x - cx) / (r + 0.5)
        if abs(x - cx) <= r then
          m:set(x, y)
          local ss = max(-0.97, min(0.97, s))
          local cz = sqrt(1 - ss * ss)
          local k = K(x, y)
          n[k] = { norm(ss, -dr * cz * (o.slope or 1) + (o.tilt or 0) * cz, cz) }
          S[k] = ss
        end
      end
    end
  end
  return m, n, S
end

-- shift tone index of one pixel
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- serrated ovate leaf along A-C-B (apple leaf): midrib + angled veins
function A.leaf(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local teeth = o.teeth or 2.4
  local wfn = o.wfn or function(t)
    if t > 0.985 then return -1 end
    local base = w * sin(pi * min(1, t * 0.95 + 0.06) ^ (o.pk or 0.85)) ^ (o.pw or 0.75)
    return max(0.4, base)
  end
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.42 })
  if o.serrate ~= false then
    local cut = {}
    m:edge():each(function(x, y) local k = K(x, y)
      local ph = (T[k] * len / teeth) + (S[k] > 0 and 0.5 or 0)
      if T[k] > 0.1 and T[k] < 0.92 and (ph - floor(ph)) < 0.34 and abs(S[k]) > 0.5 then cut[#cut + 1] = k end
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
    elseif t > 0.1 and t < 0.86 and abs(s) > 0.3 and abs(s) < 0.78 and o.veins ~= false then
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

-- teardrop (apple pip): blunt round end, pointed tip, along unit (ux,uy); U -1 blunt..1 tip, V across (<0 lit)
function A.pip(cx, cy, ux, uy, L, W, pointy, flat)
  pointy = pointy or 1.1
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local m, n, U, V = HP.mask(), {}, {}, {}
  local B = floor(L + W) + 2
  for y = floor(cy) - B, floor(cy) + B do for x = floor(cx) - B, floor(cx) + B do
    local dx, dy = x - cx, y - cy
    local u = (dx * ux + dy * uy) / (L + 0.4)
    local v = (dx * px + dy * py)
    if u >= -1 and u <= 1 then
      local w = u < 0 and W * sqrt(max(0, 1 - u * u)) or W * max(0, 1 - u * u) ^ pointy
      local vv = v / (w + 0.45)
      if abs(vv) <= 1 and w > 0.2 then
        m:set(x, y)
        local k = K(x, y)
        local nz = sqrt(max(0.03, 1 - vv * vv)) * (flat or 1)
        local nu = (u < 0 and u ^ 3 or u ^ 3 * 0.5)
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

-- 1px line (bresenham) in one colour
function A.ln(c, x0, y0, x1, y1, hex, tok)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    c:put(x0, y0, hex, tok)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy x0 = x0 + sx end
    if e2 <= dx then err = err + dx y0 = y0 + sy end
  end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
