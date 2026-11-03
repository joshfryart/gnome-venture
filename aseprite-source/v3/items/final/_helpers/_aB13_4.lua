-- _aB13_4.lua: private helpers for ph/cabbage, cabbage-seed, california-poppy-seed, camellia-seed (final pass, Opus).
-- Read-only use of _aA0_0.lua and batch2/_b2g2.lua (-> batch1/_g1.lua -> _h.lua -> lib). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/_aA0_0.lua")
local G2 = dofile(DIR .. "/../../batch2/_b2g2.lua")
local HP, X, K = A.HP, A.X, A.K
local M = setmetatable({}, { __index = A })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
M.palm, M.drop, M.path = G2.palm, G2.drop, G2.path
M.OUT = app.params.out or (DIR .. "/../ph/")

-- tear a mask: remove pixels beyond a jagged line through (ax,ay) with outward normal (nx,ny). returns torn-edge mask
function M.tear(m, ax, ay, nx, ny, amp, seed)
  local l = sqrt(nx * nx + ny * ny) nx, ny = nx / l, ny / l
  local cut = HP.mask()
  m:each(function(x, y)
    local p = (x - ax) * nx + (y - ay) * ny
    local q = -(x - ax) * ny + (y - ay) * nx
    local j = amp * (X.hash(floor(q / 2), seed or 1, 7) - 0.5) * 2 + ((floor(q) % 3 == 0) and 0.7 or 0)
    if p > j then cut:set(x, y) end
  end)
  m:cut(cut)
  local te = HP.mask()
  m:edge():each(function(x, y)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do if cut:has(x + d[1], y + d[2]) then te:set(x, y) return end end
  end)
  return te
end

-- tube along an arbitrary polyline of samples {x,y}; wfn(t) half width. returns m, n, T, S
function M.ptube(pts, wfn)
  local sm = {}
  local Np = #pts
  for i, p in ipairs(pts) do
    local a, b = pts[max(1, i - 1)], pts[min(Np, i + 1)]
    local tx, ty = b[1] - a[1], b[2] - a[2]
    local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[i] = { x = p[1], y = p[2], t = (i - 1) / (Np - 1), px = px, py = py, w = wfn((i - 1) / (Np - 1)) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 4, floor(by1) + 4 do for x = floor(bx0) - 4, floor(bx1) + 4 do
    local best, bs
    for _, s in ipairs(sm) do
      local q = (x - s.x) ^ 2 + (y - s.y) ^ 2
      if not best or q < best then best, bs = q, s end
    end
    if sqrt(best) <= bs.w then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-0.95, min(0.95, sd / (bs.w + 0.5)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn * sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S
end

-- round seed ball: tone + glint. returns mask, idx
function M.ball(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m, n = A.oval(cx, cy, rx, ry, ang or 0, o.flat or 0.8)
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "seed" } }
  local idx = A.toneN(c, m, n, ramp, { bias = o.bias, tok = tok, amb = 0.1, wrap = 0.3, cuts = o.cuts or { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  if o.glint ~= false then
    local bx, by = A.specAt(m, n, 30)
    if bx then c:put(bx, by, o.glint or "#fff4e6", tok) end
  end
  return m, idx, n
end

-- water bead (glass cue): ink-free, dark lower-right rim, pale core, bright spark upper-left
function M.bead(c, cx, cy, r, base)
  local tok = { r = { name = "bead" } }
  local m = c:ellipse(cx, cy, r, r * 0.85)
  m:each(function(x, y)
    local dx, dy = (x - cx) / (r + .5), (y - cy) / (r * 0.85 + .5)
    local col = base[3]
    if dx + dy > 0.55 then col = base[5] elseif dx + dy < -0.5 then col = base[2] elseif dx + dy > 0.1 then col = base[4] end
    c:put(x, y, col, tok)
  end)
  c:put(floor(cx - r * 0.4 + .5), floor(cy - r * 0.4 + .5), "#fbfff0", tok)
  return m
end

function M.save(c, name)
  A.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = M.OUT .. name .. ".aseprite", png = M.OUT .. name .. ".png", scale = 1 }
end
return M
