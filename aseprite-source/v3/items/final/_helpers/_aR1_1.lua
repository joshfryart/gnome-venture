-- _aR1_1.lua: private helpers for ico/ico-wind, ico-wind-chime, ico-wizard, ico-wolf (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local T = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
T.HP, T.X, T.K = HP, X, K
T.INK, T.CREAM = "#2b1c26", "#fff4d6"
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
T.norm = norm
local CUT = {
  [3] = { 0.3, 0.62 },
  [4] = { 0.26, 0.5, 0.76 },
  [5] = { 0.22, 0.4, 0.6, 0.8 },
  [6] = { 0.2, 0.36, 0.52, 0.68, 0.84 },
}
T.CUT = CUT
function T.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function T.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUT[#ramp], bias = o.bias, tok = o.tok or { r = { name = o.name or "p" } } })
  return idx, v
end
function T.pil(c, m, ramp, R, o)
  local n = X.pillow(m, R or 2, o and o.hs)
  local idx, v = T.shade(c, m, n, ramp, o)
  return idx, n, v
end
function T.blend(na, nb, w)
  local n = {}
  for k, a in pairs(na) do local b = nb[k] or a
    n[k] = { norm(a[1] * (1 - w) + b[1] * w, a[2] * (1 - w) + b[2] * w, a[3] * (1 - w) + b[3] * w) } end
  return n
end
function T.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end
function T.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end end end
end
function T.ln(c, x0, y0, x1, y1, hex, clip, tok)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do local t = i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end end
end
-- sweep a tube along any path f(t)->x,y (t 0..1), half width wfn(t). Nearest-sample, so self-crossing
-- paths need a gap > 2w. Returns mask, normals, T, S (S<0 lit/upper-left side), samples.
function T.sweep(f, wfn, N)
  N = N or 240
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = f(t)
    local x2, y2 = f(min(1, t + 0.002)) local x1, y1 = f(max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty) if l == 0 then l = 1 end tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
  end
  local m, n, TT, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 7, floor(by1) + 7 do for x = floor(bx0) - 7, floor(bx1) + 7 do
    local best, bs
    for _, s in ipairs(sm) do
      local q = (x + 0.5 - s.x)^2 + (y + 0.5 - s.y)^2
      if not best or q < best then best, bs = q, s end
    end
    if bs.w > 0 and sqrt(best) <= bs.w then
      local sd = (x + 0.5 - bs.x) * bs.px + (y + 0.5 - bs.y) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.4)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) }
      TT[k], S[k] = bs.t, sn
    end
  end end
  return m, n, TT, S, sm
end
function T.save(c, name, folder)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../" .. (folder or "ico") .. "/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return T
