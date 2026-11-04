-- _aC33_5.lua: private helpers for ph/picket-fence-gate, picket-fence-straight, picket-fence-tee, pickled-asparagus
-- (final pass, Opus). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- shared ramps (dark .. light)
A.PAINT = { "#4f3f5e", "#7d6f8c", "#b3a7b4", "#dcd2c8", "#f2ead6", "#fffbec" }   -- white-painted picket, cool shade
A.WOOD  = { "#3d2230", "#653a35", "#8c5236", "#b0743f", "#d39a5a", "#f0c587" }   -- natural post wood
A.IRON  = { "#25222f", "#3b3848", "#555467", "#77788c", "#9fa2b4", "#d0d4e0" }
A.BRASS = { "#5a3320", "#8f5a22", "#c4862a", "#e6ad35", "#f8d462", "#fff1b0" }

local IDX = {}
function A.new(name) IDX = {} return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.reg(idx, ramp, tok) for k, i in pairs(idx) do IDX[k] = { ramp = ramp, i = i, tok = tok } end end
-- step an already painted pixel d tones (negative = darker)
function A.step(c, x, y, d)
  local e = IDX[K(x, y)]
  if not e then return end
  e.i = max(1, min(#e.ramp, e.i + d))
  c:put(x, y, e.ramp[e.i], e.tok)
end
function A.setTone(c, x, y, i)
  local e = IDX[K(x, y)]
  if not e then return end
  e.i = max(1, min(#e.ramp, i))
  c:put(x, y, e.ramp[e.i], e.tok)
end
function A.idxAt(x, y) local e = IDX[K(x, y)] return e and e.i end
-- contact shadow cast by mask m (about to be painted) onto earlier parts
function A.cast(c, m, dx, dy, d)
  m:shift(dx, dy):each(function(x, y) if not m:has(x, y) then A.step(c, x, y, d or -1) end end)
end
-- darker-neighbour separation line on earlier SAME-ramp pixels touching m
function A.sep(c, m, ramp)
  local done = {}
  m:each(function(x, y)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      local qx, qy = x + d[1], y + d[2]
      local k = K(qx, qy)
      local e = IDX[k]
      if e and not m:has(qx, qy) and not done[k] and (not ramp or e.ramp == ramp) then
        done[k] = true
        e.i = min(e.i, 2) c:put(qx, qy, e.ramp[e.i], e.tok)
      end
    end
  end)
end

-- bevelled board. o: R, dir ("v"/"h"), grain (true), seed, bias, name, cuts, amb, wrap, knot {x,y}
function A.board(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 1.6, o.hs)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  local tok = { r = { name = o.name or "board" } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = tok })
  A.reg(idx, ramp, tok)
  if o.grain ~= false then
    local seed = o.seed or 1
    local inner = m:shrink(1)
    inner:each(function(x, y)
      local a, b = y, x
      if o.dir == "h" then a, b = x, y end
      local w = floor(sin(a * 0.31 + b * 1.7 + seed) * 0.9 + 0.5)
      local bb = b + w
      local lane = X.hash(bb, 7, seed) < (o.dens or 0.34)
      local seg = X.hash(bb, floor((a + bb * 3) / 4), seed + 9) < 0.62
      if lane and seg then
        local k = K(x, y) local i = idx[k]
        if i and i >= 2 then c:put(x, y, ramp[i - 1], tok) IDX[k].i = i - 1 end
      end
    end)
  end
  if o.knot then
    local kx, ky = o.knot[1], o.knot[2]
    A.setTone(c, kx, ky, 1) A.step(c, kx + 1, ky, -1) A.step(c, kx, ky - 1, -1) A.step(c, kx, ky + 1, -1)
  end
  return idx, tok, n
end

-- flat-faced two-plane pyramid cap (left face lit, right face shade) over mask m split at column xm
function A.pyramid(c, m, xm, ramp, tok)
  tok = tok or { r = { name = "cap" } }
  local idx = {}
  m:each(function(x, y) local i
    if x < xm then i = 5 elseif x == xm then i = 4 else i = 3 end
    idx[K(x, y)] = i c:put(x, y, ramp[i], tok) end)
  A.reg(idx, ramp, tok)
  return idx
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
