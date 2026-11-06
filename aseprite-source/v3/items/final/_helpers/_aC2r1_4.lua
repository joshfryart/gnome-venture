-- _aC2r1_4.lua: private helpers for ph/nav-tasks, ph/nav-today, ph/nav-together
-- (final pass, Opus single pass). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
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

-- light a normal field into a 6-tone ramp (dark..light); returns idx table (k -> ramp index)
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias })
end

-- shift tone of painted pixels (in idx) where pred(x,y) gives a step (negative = darker)
function A.adjust(c, m, idx, ramp, f)
  m:each(function(x, y)
    local k = K(x, y)
    if idx[k] then
      local d = f(x, y, idx[k])
      if d and d ~= 0 then
        local i = max(1, min(#ramp, idx[k] + d))
        idx[k] = i
        c:put(x, y, ramp[i])
      end
    end
  end)
end

-- contact shadow: pixels of m (with idx) covered by `over` shifted by (dx,dy) but not by `over` itself get darker
function A.cast(c, m, idx, ramp, over, dx, dy, amt)
  local sh = over:shift(dx, dy)
  A.adjust(c, m, idx, ramp, function(x, y)
    if sh:has(x, y) and not over:has(x, y) then return amt or -2 end
  end)
end

function A.ln(c, x0, y0, x1, y1, hex, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do
    local x, y = floor(x0 + (x1 - x0) * i / n + .5), floor(y0 + (y1 - y0) * i / n + .5)
    if not clip or clip:has(x, y) then c:put(x, y, hex) end
  end
end

-- remove isolated pixels / 1px spurs
function A.clean(m)
  for _ = 1, 2 do
    local cut = {}
    m:each(function(x, y)
      local n = 0
      for _, d in ipairs{ {1,0}, {-1,0}, {0,1}, {0,-1} } do if m:has(x + d[1], y + d[2]) then n = n + 1 end end
      if n <= 1 then cut[#cut + 1] = { x, y } end
    end)
    for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  end
  return m
end

-- union of normal fields: later wins
function A.merge(dst, src) for k, v in pairs(src) do dst[k] = v end return dst end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  local r = HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
  return r
end
return A
