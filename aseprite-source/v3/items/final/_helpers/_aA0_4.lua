-- _aA0_4.lua: private helpers for ico-arrow-left, ico-arrow-right, ico-arrow-up, ico-autumn-leaf (final pass, Opus).
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
  enamel = { "#1f2a5c", "#2a4a7a", "#3468a6", "#4790c8", "#6cbce2", "#b8f0f0" },
  denim  = { "#1c2250", "#28366c", "#33508c", "#4470aa", "#6092c6", "#a0c8e8" },
  glass  = { "#20366e", "#2e5c94", "#3e8ab8", "#5fbcd4", "#9ce4e8", "#e0fff6" },
  ash    = { "#3e2228", "#5e3529", "#86502f", "#b0733e", "#d29a58", "#efc585" },
  plume  = { "#4c1a32", "#7a2238", "#a82e3c", "#d4443e", "#f06a4c", "#ff9c74" },
  twine  = { "#5a3220", "#86502a", "#b47a36", "#dca448", "#f4ca6c", "#fff0b0" },
  steel  = { "#262840", "#3a3c5a", "#555878", "#7a7c9a", "#a6a8c0", "#dcdce8" },
  maple  = { "#5a1830", "#8a2434", "#bc3a32", "#e2602e", "#f68e3a", "#ffc463" },
  scarlet= { "#4a1430", "#741c36", "#a42838", "#cc3c38", "#ea5c3c", "#ff8a5c" },
  amber  = { "#6a3a1c", "#9a521e", "#c87624", "#eaa02c", "#f8c84c", "#ffea9a" },
  stalk  = { "#3a2226", "#5a3428", "#7e4c30", "#a46c3c", "#c8925a", "#e8bc84" },
  bug    = { "#4c1a32", "#7a2238", "#b82e3a", "#e2443c", "#ff7a5c", "#ffb08a" },
  worm   = { "#173f36", "#24594a", "#2f7a4a", "#4c9e4e", "#7cc35a", "#c4e07a" },
}

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

-- pillow-bevel lighting of a mask; o.R bevel, o.bias, o.cuts. returns idx, n
function A.face(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 3)
  if o.nfn then m:each(function(x, y) local k = K(x, y) n[k] = { norm(o.nfn(x, y, n[k])) } end) end
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias = o.bias, tok = o.tok })
  return idx, n
end

function A.shadeN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias = o.bias, tok = o.tok })
end

function A.setI(c, idx, ramp, x, y, i)
  i = max(1, min(#ramp, i)) idx[K(x, y)] = i c:put(x, y, ramp[i])
end
function A.step(c, idx, ramp, x, y, d)
  local i = idx[K(x, y)]
  if not i then return end
  A.setI(c, idx, ramp, x, y, i + d)
end

-- polygon fill (pixel centres), concave ok
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

-- Bresenham 1px segment mask
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
return A
