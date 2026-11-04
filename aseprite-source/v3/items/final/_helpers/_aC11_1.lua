-- _aC11_1.lua: private helpers for ph/hat-brewroot, hat-rootwarden, hat-seedkeeper, hat-thornblade (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.24 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- y of the lower elliptic arc (crown base / band line)
function A.arcY(x, cx, cy, rw, ry)
  local u = (x - cx) / rw
  if abs(u) >= 1 then return cy end
  return cy + ry * sqrt(1 - u * u)
end
function A.arcClip(m, cx, cy, rw, ry)
  local cut = HP.mask()
  m:each(function(x, y) if y > A.arcY(x, cx, cy, rw, ry) + 0.3 then cut:set(x, y) end end)
  m:cut(cut) return m
end

-- brim: flat disc seen from slightly above + a thickness band below. returns top, under, idx
function A.brim(c, cx, cy, rx, ry, th, ramp, o)
  o = o or {}
  local top = HP.mask()
  for y = floor(cy - ry - 1), floor(cy + ry + 1) do for x = floor(cx - rx - 1), floor(cx + rx + 1) do
    local u, v = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if u*u + v*v <= 1 then top:set(x, y) end
  end end
  if o.shape then o.shape(top) end
  local under = HP.mask()
  for d = 1, th do top:shift(0, d):each(function(x, y) if not top:has(x, y) then under:set(x, y) end end) end
  local np = X.pillow(top, o.R or 2.5, 0.7)
  local n = {}
  top:each(function(x, y) local k = K(x, y) local a = np[k]
    local sx = (x - cx) / rx
    n[k] = { norm(a[1] * 0.9 + sx * 0.3, a[2] * 0.9 - 0.55, a[3]) } end)
  local tok = o.tok or { r = { name = o.name or "brim" } }
  local idx = A.shade(c, top, n, ramp, { bias = o.bias, tok = tok, amb = 0.1, wrap = 0.3 })
  under:each(function(x, y)
    local sx = (x - cx) / rx
    local i = sx < -0.55 and 3 or (sx < 0.2 and 2 or 1)
    if not top:has(x, y - 1) and top:has(x, y - 2) then i = max(1, i - 0) end
    idx[K(x, y)] = i
    c:put(x, y, ramp[i], tok)
  end)
  -- bright front lip on the lit left half, specular dash
  top:each(function(x, y)
    if under:has(x, y + 1) then
      local sx = (x - cx) / rx
      if sx < -0.15 and sx > -0.85 then local k = K(x, y) idx[k] = min(6, (idx[k] or 4) + 1) c:put(x, y, ramp[idx[k]], tok) end
    end
  end)
  return top, under, idx, tok
end

-- felt nap: sparse 1px speckle a tone darker/lighter
function A.felt(c, m, idx, ramp, tok, seed, rate)
  m:each(function(x, y) local k = K(x, y) local i = idx[k]
    if i then
      local h = X.hash(x, y, seed or 1)
      if h < (rate or 0.07) and i >= 3 then A.step(c, idx, ramp, x, y, -1, tok)
      elseif h > 1 - (rate or 0.07) * 0.6 and i >= 2 and i <= 4 then A.step(c, idx, ramp, x, y, 1, tok) end
    end
  end)
end

-- fold creases across a tube: {t, s0, s1, tilt}; dark groove + lit lip above
function A.creases(c, m, idx, T, S, len, ramp, tok, list)
  local put = {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    if t then for _, r in ipairs(list) do
      if s > r[2] and s < r[3] then
        local d = (t - r[1]) * len + s * (r[4] or 0) + s * s * 1.2
        local cur = idx[k] or 3
        if d > -0.5 and d < 0.5 then put[#put + 1] = { x, y, max(1, cur - 2) }
        elseif d >= -1.5 and d <= -0.5 and cur >= 3 then put[#put + 1] = { x, y, min(6, cur + 1) } end
      end
    end end
  end)
  for _, p in ipairs(put) do idx[K(p[1], p[2])] = p[3] c:put(p[1], p[2], ramp[p[3]], tok) end
end

function A.tubeLen(samp)
  local L = 0
  for i = 2, #samp do L = L + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
  return L
end

-- band: pixels of crown m between arc-h and arc; lit with crown normals n
function A.bandMask(m, cx, cy, rw, ry, h)
  local b = HP.mask()
  m:each(function(x, y) local a = A.arcY(x, cx, cy, rw, ry)
    if y > a - h - 0.3 and y <= a + 0.3 then b:set(x, y) end end)
  return b
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
return A
