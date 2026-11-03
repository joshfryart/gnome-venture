-- _aR0_3.lua: private helpers for ico-tier-easy, ico-tier-expert, ico-tomato, ico-toolbox (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + quantise; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- normals from a height function H(x,y) (pixel units), sampled at pixel centres
function A.hfield(m, H)
  local n = {}
  m:each(function(x, y)
    local gx = (H(x + 1, y) - H(x - 1, y)) / 2
    local gy = (H(x, y + 1) - H(x, y - 1)) / 2
    n[K(x, y)] = { norm(-gx, -gy, 1) }
  end)
  return n
end

-- pillow bevel blended with a gentle tilt/dome (keeps a flat face from being one tone)
function A.slab(m, R, cx, cy, rad, w)
  local np = X.pillow(m, R or 3)
  local n = {}
  w = w or 0.35
  for k, a in pairs(np) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local sx, sy = (x - cx) / rad, (y - cy) / rad
    n[k] = { norm(a[1] + sx * w, a[2] + sy * w, a[3]) }
  end
  return n
end

-- shift one already-toned pixel by d steps
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- map rows of chars to colours
function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

-- jigsaw piece mask. o: cx, cy (centre), S (body side), r (knob radius), ang (rad), k (knob offset, x r),
-- e = { t=, r=, b=, l= } 1 knob out, -1 socket in, 0 flat; cr corner radius on corners between two flat
-- edges (or every corner if o.roundAll). Returns mask, U, V (local coords, +v down).
function A.piece(o)
  local ca, sa = cos(o.ang or 0), sin(o.ang or 0)
  local h, r = o.S / 2, o.r
  local off = r * (o.k or 0.85)
  local cr = o.cr or 0
  local D = { t = { 0, -1 }, r = { 1, 0 }, b = { 0, 1 }, l = { -1, 0 } }
  local e = o.e
  local m, U, V = HP.mask(), {}, {}
  local R = h + 2 * r + 3
  for y = floor(o.cy - R), floor(o.cy + R) do for x = floor(o.cx - R), floor(o.cx + R) do
    local dx, dy = x + 0.5 - o.cx, y + 0.5 - o.cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    local inside = abs(u) <= h and abs(v) <= h
    if inside and cr > 0 then
      local su, sv = u < 0 and "l" or "r", v < 0 and "t" or "b"
      if o.roundAll or (e[su] == 0 and e[sv] == 0) then
        local qu, qv = max(abs(u) - h + cr, 0), max(abs(v) - h + cr, 0)
        if qu * qu + qv * qv > cr * cr then inside = false end
      end
    end
    for side, val in pairs(e) do if val == 1 then
      local d = D[side]
      local q = (u - d[1] * (h + off))^2 + (v - d[2] * (h + off))^2
      if q <= r * r then inside = true end
    end end
    for side, val in pairs(e) do if val == -1 then
      local d = D[side]
      local q = (u - d[1] * (h - off))^2 + (v - d[2] * (h - off))^2
      if q <= r * r then inside = false end
    end end
    if inside then m:set(x, y) U[K(x, y)], V[K(x, y)] = u, v end
  end end
  return m, U, V
end

-- cardboard thickness under a face mask (down-right), 2 tones + fibre flecks; returns side mask
function A.thick(c, face, T, cols, tok, skip)
  local side = HP.mask()
  for i = 1, T do side:add(face:shift(0, i)) side:add(face:shift(1, i)) end
  side:cut(face)
  if skip then side:cut(skip) end
  side:each(function(x, y)
    local top = face:has(x, y - 1) or face:has(x - 1, y - 1)
    local col = top and cols[2] or cols[1]
    if not top and X.hash(x, y, 7) > 0.8 then col = cols[3] end
    c:put(x, y, col, tok)
  end)
  return side
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
