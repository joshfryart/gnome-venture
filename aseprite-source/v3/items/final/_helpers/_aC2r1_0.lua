-- _aC2r1_0.lua: private helpers for ph/naranjilla-seed, ph/nasturtium-seed, ph/nav-almanac, ph/nav-arranging
-- (final pass, Opus single pass). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + tone a normal field into a 6-tone ramp (dark..light); returns idx
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or { r = { name = o.name or tostring(ramp) } } })
  return idx, v
end

-- tok helper so later parts know who owns a pixel
function A.tok(name) return { r = { name = name } } end

-- re-tone already-placed pixels of mask m by idx offset (AO, cast shadows): needs idx table from shade
function A.retone(c, m, idx, ramp, bias, tok)
  for k, b in pairs(bias) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    if m:has(x, y) and idx[k] then
      local i = max(1, min(#ramp, idx[k] + b))
      idx[k] = i
      c:put(x, y, ramp[i], tok)
    end
  end
end

-- jagged torn edge: remove pixels of m whose coordinate f(x,y) < base + jitter (deterministic)
function A.tear(m, f, base, amp, seed)
  local cut = {}
  m:each(function(x, y)
    local v = f(x, y)
    local j = (X.hash(floor(v * 0 + x), floor(y), seed or 1) - 0.5) * amp
    local zz = ((x + y) % 3) * amp * 0.25
    if v < base + j + zz then cut[#cut + 1] = { x, y } end
  end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  return m
end

-- remove isolated pixels / 1px spurs (keeps outlines clean)
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

-- line of pixels (Bresenham-ish) drawn only inside clip (optional)
function A.ln(c, x0, y0, x1, y1, hex, clip, tok)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do
    local x, y = floor(x0 + (x1 - x0) * i / n + .5), floor(y0 + (y1 - y0) * i / n + .5)
    if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end
  end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  local r = HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
  return r
end
return A
