-- _aB10_0.lua: private helpers for bougainvillea-seed, bought-garden-vegetable-soup, box-hedge, box-hedge-corner
-- (final pass, Opus). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.save(c, name)
  local out = app.params.out or (DIR .. "/../ph/")
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end

-- paint a hand map: rows of chars, map char -> hex
function A.map(c, x0, y0, rows, cmap, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if cmap[ch] then c:put(x0 + xx - 1, y0 + yy - 1, cmap[ch], tok) end end end
end

-- boxwood leaf texture bias: jittered 3px cells, each a tiny leaf clump lit upper-left, cavities between
function A.leafBias(x, y, seed)
  local best, bdx, bdy, bh = 1e9, 0, 0, 0
  local cx0, cy0 = floor(x / 3), floor(y / 3)
  for j = cy0 - 1, cy0 + 1 do for i = cx0 - 1, cx0 + 1 do
    local h1, h2 = X.hash(i, j, seed), X.hash(i, j, seed + 7)
    local px, py = i * 3 + 0.5 + h1 * 2, j * 3 + 0.5 + h2 * 2
    local dx, dy = x - px, y - py
    local q = dx*dx + dy*dy
    if q < best then best, bdx, bdy, bh = q, dx, dy, X.hash(i, j, seed + 3) end
  end end
  local d = sqrt(best)
  if d > 1.75 then return (bh < 0.25) and -2 or -1 end
  if bdx + bdy < -0.6 and d > 0.4 then return 1 end
  if bdx + bdy > 1.1 then return -1 end
  return 0
end

-- clipped box hedge in 3/4 view. plan = mask in ground coords; Hh = height in px.
-- returns all, top, front masks and zmap (height of the visible point; Hh for top).
function A.hedge(c, plan, Hh, ramp, o)
  o = o or {}
  local x0, y0, x1, y1 = plan:bbox()
  local all, top, front, Z = HP.mask(), HP.mask(), HP.mask(), {}
  for y = y0 - Hh - 1, y1 + 1 do for x = x0, x1 do
    for z = Hh, 0, -1 do
      if plan:has(x, y + z) then
        all:set(x, y) Z[K(x, y)] = z
        if z == Hh then top:set(x, y) else front:set(x, y) end
        break
      end
    end
  end end
  local tp = top:copy()
  local pn = X.pillow(plan, o.R or 2.5)
  local n = {}
  -- screen-space normal from world (wx, forward, up)
  local function scr(wx, fw, up) return { norm(wx, fw * 0.35 - up * 0.8, fw * 0.94 + up * 0.6) } end
  top:each(function(x, y) local q = pn[K(x, y + Hh)]
    n[K(x, y)] = scr(q[1] * 1.3, q[2] * 1.3, q[3]) end)
  local fdist = X.dist(front)
  front:each(function(x, y) local k = K(x, y)
    local z = Z[k]
    local up = max(0, 1 - (Hh - z) / 3)
    -- sideways rounding near the ends of each front run
    local l, r = 0, 0
    while front:has(x - l - 1, y) and l < 4 do l = l + 1 end
    while front:has(x + r + 1, y) and r < 4 do r = r + 1 end
    local wx = 0
    if l < 3 and not all:has(x - l - 1, y) then wx = -(3 - l) / 3 end
    if r < 3 and not all:has(x + r + 1, y) then wx = (3 - r) / 3 end
    n[k] = scr(wx * 1.2, 1, up * 0.45 - (z <= 1 and 0.25 or 0))
  end)
  local bias = {}
  all:each(function(x, y) local k = K(x, y)
    local b = A.leafBias(x, y, o.seed or 11)
    if front:has(x, y) then
      if Z[k] <= 1 then b = b - 1 end
      if Z[k] == 0 then b = b - 1 end
      -- ambient where a front run meets the top of a nearer arm to its left / right
      if top:has(x - 1, y) or top:has(x - 2, y) or top:has(x + 1, y) or top:has(x + 2, y) then b = b - 1 end
    end
    bias[k] = b
  end)
  if o.bias then for k, v in pairs(o.bias) do bias[k] = (bias[k] or 0) + v end end
  local tok = o.tok or { r = { name = "hedge" } }
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  local idx = X.tone(c, all, v, ramp, { cuts = o.cuts or { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = tok })
  return all, top, front, Z, idx, tok, n
end

-- mulch / soil strip along the bottom of a plan (z = 0 ground, nearer than the hedge)
function A.mulch(c, plan, ramp, seed, cover)
  local m2 = HP.mask()
  plan:each(function(x, y) if not plan:has(x, y + 1) then
    for d = 1, 2 do for dx = -1, 1 do
      if not plan:has(x + dx, y + d) and not (cover and cover:has(x + dx, y + d)) then m2:set(x + dx, y + d) end end end end end)
  local tok = { r = { name = "mulch" } }
  m2:each(function(x, y)
    local h = X.hash(x, y, seed or 5)
    local i = (m2:has(x, y + 1) and 3 or 2) + (h > 0.62 and 1 or 0) + (h > 0.9 and 1 or 0) - (h < 0.12 and 1 or 0)
    c:put(x, y, ramp[max(1, min(#ramp, i))], tok)
  end)
  return m2
end
return A
