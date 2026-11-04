-- _aB31_2.lua: private helpers for ph/fiddlehead-fry, fiddleheads, field-gladiolus-seed, fig (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end
function A.q(v, cuts) local i = 1 for j, t in ipairs(cuts) do if v >= t then i = j + 1 end end return i end
function A.line(c, pts, hex, tok, clip)
  HP.line(pts, 1):each(function(x, y) if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end end)
end

-- tube along an arbitrary sample list { {x,y,w}, ... }. Each pixel takes the sample it sits deepest inside
-- (min dist - w), so coils that pass close to themselves stay separate. returns m, n, T, S (S<0 = lit side)
function A.ptube(sm)
  local N = #sm
  for i, s in ipairs(sm) do
    local a, b = sm[max(1, i - 1)], sm[min(N, i + 1)]
    local tx, ty = b[1] - a[1], b[2] - a[2]
    local l = sqrt(tx*tx + ty*ty) if l == 0 then l = 1 end
    tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    s.tx, s.ty, s.px, s.py, s.t = tx, ty, px, py, (i - 1) / (N - 1)
  end
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do x0, y0, x1, y1 = min(x0, s[1]), min(y0, s[2]), max(x1, s[1]), max(y1, s[2]) end
  local m, n, T, S = HP.mask(), {}, {}, {}
  for y = floor(y0) - 4, floor(y1) + 4 do for x = floor(x0) - 4, floor(x1) + 4 do
    local best, bs
    for _, s in ipairs(sm) do
      local d = sqrt((x - s[1])^2 + (y - s[2])^2) - s[3]
      if not best or d < best then best, bs = d, s end
    end
    if best <= 0 then
      local sd = (x - bs[1]) * bs.px + (y - bs[2]) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs[3] + 0.5)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S
end

-- crozier path: cubic stem p (4 pts, ends pointing up) then a spiral coil. dir=+1 coil sits left of the stem top.
-- R = outer coil radius, turns, w(t01) half-width over the whole path (t01 0..1)
function A.crozier(p, dir, R, turns, wfn, ns, nc)
  ns, nc = ns or 40, nc or 90
  local out = {}
  local tot = ns + nc
  for i = 0, ns do local x, y = G.bez(p, i / ns) out[#out + 1] = { x, y } end
  local ex, ey = p[4][1], p[4][2]
  local cx, cy = ex - dir * R, ey
  local TH = turns * 2 * pi
  for i = 1, nc do
    local th = TH * i / nc
    local r = R * (1 - 0.72 * th / TH)
    out[#out + 1] = { cx + r * cos(th) * dir, cy - r * sin(th) }
  end
  for i, s in ipairs(out) do s[3] = wfn((i - 1) / (#out - 1)) end
  return out, cx, cy
end

-- darken seams where a tube touches itself (neighbour with far-away T): ambient line on the lower-T-light pixel
function A.seams(c, m, T, idx, ramp, tok, gap)
  gap = gap or 0.12
  local put = {}
  m:each(function(x, y) local k = K(x, y)
    for _, d in ipairs{ {1,0}, {-1,0}, {0,1}, {0,-1} } do
      local q = K(x + d[1], y + d[2])
      if T[q] and abs(T[q] - T[k]) > gap and T[k] < T[q] then put[#put + 1] = { x, y, k } break end
    end
  end)
  for _, p in ipairs(put) do c:put(p[1], p[2], ramp[max(1, min(2, (idx[p[3]] or 3) - 2))], tok) end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
