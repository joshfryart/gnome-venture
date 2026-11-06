-- _aB11_2.lua: private helpers for the aB11_2 broken-tool set (Opus single pass). Uses hp.lua + hpx.lua read-only.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua") X.init(HP)
local K = X.K
local sqrt, floor, max, min, abs, sin, cos = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos
local H = { HP = HP, X = X, K = K }

H.STEEL   = { "#3a3d58", "#55597a", "#7c809c", "#a7aabf", "#d2d4e0", "#f3f1f6" }
H.WOOD    = { "#4a2a26", "#6e3e2e", "#91573a", "#b47548", "#d29a62", "#ecc287" }
H.BRASS   = { "#5e3420", "#8f5a1f", "#c48a26", "#e8b23a", "#f8d870", "#fff1b8" }
H.RED     = { "#5a1a30", "#8a2338", "#bd3438", "#e2553e", "#f58560", "#ffb88a" }
H.CANVAS  = { "#22423a", "#33613f", "#4f8446", "#71a352", "#9cc46a", "#c9e09a" }
H.LEATHER = { "#3e2224", "#5e3229", "#814832", "#a6643f", "#c98a58", "#e6b27c" }
H.PINK    = { "#6e2a44", "#a3475e", "#d06e7c", "#ec9aa0", "#ffc4c0" }
H.MOSS    = { "#1d4a3a", "#2f6e44", "#4f9a4c", "#7cc35a", "#b4dc78" }
H.SPEC, H.VOID = "#fff6e0", "#2a2030"
H.CUTS = { 0.17, 0.33, 0.5, 0.66, 0.83 }

function H.new(name)
  return HP.canvas{ w = 64, h = 64, scale = 1, name = name }
end
function H.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along cubic bezier p, half width wfn(t), only t in [t0,t1]. returns mask, normals, T, S (S<0 = lit side)
function H.tube(p, wfn, t0, t1)
  t0, t1 = t0 or 0, t1 or 1
  local N = 140
  local sm = {}
  for i = 0, N do
    local t = t0 + (t1 - t0) * i / N
    local x, y = H.bez(p, t)
    local x2, y2 = H.bez(p, min(1, t + 0.003))
    local x1, y1 = H.bez(p, max(0, t - 0.003))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, w = wfn(t), tx = tx, ty = ty }
  end
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  local m, n, T, S = HP.mask(), {}, {}, {}
  for y = floor(by0) - 6, floor(by1) + 6 do for x = floor(bx0) - 6, floor(bx1) + 6 do
    local best, bs
    for _, s in ipairs(sm) do
      local q = (x - s.x)^2 + (y - s.y)^2
      if not best or q < best then best, bs = q, s end
    end
    local along = (x - bs.x) * bs.tx + (y - bs.y) * bs.ty
    local endcap = (bs == sm[1] and along < -0.3) or (bs == sm[#sm] and along > 0.3)
    if not endcap and bs.w > 0 and sqrt(best) <= bs.w then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-0.96, min(0.96, sd / (bs.w + 0.5)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S, sm
end
-- paint mask with normals n onto ramp. o: cuts, amb, wrap, bias, spec(power,thr), specCol, bounce, tok
function H.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.2 })
  local tok = o.tok or { r = { name = o.name or tostring(ramp) } }
  local cuts = o.cuts
  if not cuts then
    if #ramp == 6 then cuts = H.CUTS else cuts = { 0.2, 0.4, 0.6, 0.8 } end
  end
  local idx = X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = tok })
  if o.bounce then
    local r = X.rim(n)
    m:edge():each(function(x, y) local k = K(x, y) if r[k] and r[k] > 0.72 and idx[k] <= 3 then c:put(x, y, o.bounce, tok) end end)
  end
  if o.spec then
    local s = X.spec(n, o.spec)
    m:each(function(x, y) local k = K(x, y)
      if s[k] > (o.specThr or 0.82) then c:put(x, y, o.specCol or ramp[#ramp], tok) idx[k] = #ramp end end)
  end
  return idx, tok, v
end
-- pillow-lit flat-ish slab
function H.slab(c, m, R, ramp, o)
  o = o or {}
  local n = X.pillow(m, R, o.h or 1)
  local idx, tok = H.shade(c, m, n, ramp, o)
  return idx, tok, n
end
function H.erase(c, m)
  m:each(function(x, y) if x >= 0 and y >= 0 and x < c.w and y < c.h then
    c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end)
end
-- wood grain: darken idx-1 along wavy lines parallel to the tube axis
function H.grain(c, m, T, S, idx, ramp, len, tok, seed)
  seed = seed or 1
  local lines = { -0.55, -0.1, 0.35, 0.75 }
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    if t and s then
      for i, l0 in ipairs(lines) do
        local l = l0 + 0.12 * sin(t * len * 0.35 + i * 1.7 + seed)
        if abs(s - l) < 0.11 and X.hash(floor(t * len / 3), i, seed) > 0.25 then
          local j = max(1, (idx[k] or 3) - 1) c:put(x, y, ramp[j], tok) end
      end
    end
  end)
end
function H.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2 + 0.5) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined %dx%d)", dx, dy, W, Hh))
end
function H.fin(c, src)
  local name = src:match("([^/\\]+)%.lua$")
  local dir = src:match("^@?(.*)[/\\][^/\\]*$")
  local out = app.params.out or (dir .. "/")
  H.recentre(c)
  c:finish{ outline = true }
  HP.assertClean(c)
  HP.report(c)
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return H
