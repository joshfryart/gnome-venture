-- _aA1_4.lua: private helpers for ico-boot, ico-bouquet, ico-bow, ico-box (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"

-- 6-tone ramps, dark .. light
A.R = {
  green = { "#1b3a36", "#24544a", "#2c7048", "#3d8c4e", "#5eab57", "#9acd6e" },
  red   = { "#4c1a32", "#6e2038", "#982a3c", "#c23a3c", "#e45a40", "#ff905e" },
  gold  = { "#6a3a1c", "#8f4a1f", "#c27322", "#e6a12c", "#f8c94c", "#ffeaa2" },
  brass = { "#4e2e22", "#7e4c26", "#ae742e", "#d6a03e", "#f0cc6a", "#fff0b8" },
  page  = { "#8a6458", "#b38e78", "#d4b794", "#e8d3ac", "#f6e7c4", "#fff4d6" },
  blue  = { "#222e5c", "#2a4a7a", "#3769a4", "#4c8ec4", "#70b4dc", "#b2e2ee" },
  plum  = { "#2c2150", "#432f6c", "#5c449c", "#7a5ebe", "#9e86da", "#ccb8f2" },
  orange= { "#5e2630", "#943a2c", "#c45a2a", "#e47e36", "#f6a656", "#ffd28c" },
  hide  = { "#38222a", "#51302b", "#713f2f", "#955a3c", "#ba8150", "#e0b07a" },
  moss  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" },
  quill = { "#5a4e78", "#8a82a8", "#b8b2cc", "#dcd8e6", "#f0eef4", "#fff4d6" },
}

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

-- lit face: pillow bevel (o.R) blended onto a base plane normal o.base={x,y,z}; optional grain.
-- returns idx (tone index per key), n
function A.face(c, m, ramp, o)
  o = o or {}
  local bx, by, bz = norm(table.unpack(o.base or { 0, 0, 1 }))
  local n
  if (o.R or 0) > 0 then n = X.pillow(m, o.R) else n = {} m:each(function(x, y) n[K(x, y)] = { 0, 0, 1 } end) end
  local s = o.bev or 0.9
  for k, nn in pairs(n) do n[k] = { norm(nn[1] * s + bx, nn[2] * s + by, bz) } end
  if o.nfn then m:each(function(x, y) local k = K(x, y) n[k] = { norm(o.nfn(x, y, n[k])) } end) end
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local bias = o.bias or {}
  if o.grain then
    local inner = m:shrink(1)
    inner:each(function(x, y)
      local h = X.hash(x, y, o.seed or 7)
      local k = K(x, y)
      if h < o.grain then bias[k] = (bias[k] or 0) - 1
      elseif h > 1 - o.grain * 0.5 then bias[k] = (bias[k] or 0) + 1 end
    end)
  end
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias = bias, tok = o.tok })
  return idx, n
end

-- shift tone index of a painted pixel
function A.step(c, idx, ramp, x, y, d)
  local k = K(x, y)
  local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d))
  idx[k] = i
  c:put(x, y, ramp[i])
end

-- polyline of single pixels (Bresenham) -> mask
function A.seg(x0, y0, x1, y1)
  local m = HP.mask()
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    m:set(x0, y0)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy x0 = x0 + sx end
    if e2 <= dx then err = err + dx y0 = y0 + sy end
  end
  return m
end

-- convex/concave polygon fill (pixel centres)
function A.poly(pts)
  local m = HP.mask()
  local y0, y1 = 1e9, -1e9
  for _, p in ipairs(pts) do y0 = min(y0, p[2]) y1 = max(y1, p[2]) end
  for y = floor(y0), math.ceil(y1) do
    local yc = y + 0.5
    local xs = {}
    for i = 1, #pts do
      local a, b = pts[i], pts[i % #pts + 1]
      if (a[2] <= yc and b[2] > yc) or (b[2] <= yc and a[2] > yc) then
        xs[#xs + 1] = a[1] + (yc - a[2]) / (b[2] - a[2]) * (b[1] - a[1])
      end
    end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do
      for x = math.ceil(xs[i] - 0.5), floor(xs[i + 1] - 0.5) do m:set(x, y) end
    end
  end
  return m
end

function A.ellM(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local dx, dy = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if dx * dx + dy * dy <= 1 then m:set(x, y) end
  end end
  return m
end

-- char map painter, (x0,y0) = top-left
function A.map(c, rows, x0, y0, pal)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch]) end
  end end
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end

-- extra (aA1_4): 6-tone ramps for this set
A.R.leather = { "#3a1f26", "#5a2e2a", "#7e4430", "#a8623a", "#cc8a4e", "#eab47a" }
A.R.wool    = { "#7a5a5e", "#a8868a", "#cdb0a8", "#e6d2c0", "#f6ead6", "#fff4d6" }
A.R.sole    = { "#24161e", "#3a2630", "#523844", "#6e4e58", "#8c6a72", "#b08e92" }
A.R.oak     = { "#3e2228", "#5e3529", "#86502f", "#b0733e", "#d29a58", "#efc585" }
A.R.iron    = { "#262840", "#3a3c5a", "#555878", "#7a7c9a", "#a6a8c0", "#dcdce8" }
A.R.kraft   = { "#5a3628", "#86553a", "#b07c4e", "#d2a466", "#ead08e", "#fff0c0" }
A.R.rose    = { "#5e1e44", "#8c2c5c", "#c04a7a", "#e8709a", "#ff9cbc", "#ffd0e0" }
A.R.daisy   = { "#7a6a8c", "#a49cb8", "#cdc8da", "#e8e4ee", "#f8f4f0", "#fff4d6" }
A.R.corn    = { "#1e2a5e", "#2a3e8a", "#3a5cba", "#5a84dc", "#88b0f0", "#c4dcff" }
A.R.ribbon  = { "#4a1630", "#741e36", "#a82a3a", "#d6403e", "#f46a50", "#ff9c78" }
A.R.feather = { "#2a3466", "#34508e", "#4474b4", "#62a0d6", "#94ccec", "#d0f0ff" }

-- paint a mask by normal field n with ramp; extra bias table; returns idx
function A.shadeN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias = o.bias })
end
-- set an absolute ramp index for a pixel inside idx
function A.setI(c, idx, ramp, x, y, i)
  i = max(1, min(#ramp, i)) idx[K(x, y)] = i c:put(x, y, ramp[i])
end
-- step any painted pixel that uses one of A.R's ramps by d tones (lookup by colour)
function A.darken(c, x, y, d)
  local h = c:get(x, y)
  if not h then return end
  h = h:lower()
  for _, r in pairs(A.R) do for i, v in ipairs(r) do if v:lower() == h then
    c:put(x, y, r[max(1, min(#r, i + (d or -1)))]) return end end end
end
return A
