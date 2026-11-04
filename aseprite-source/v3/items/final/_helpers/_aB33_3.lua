-- _aB33_3.lua: private helpers for ph/garden-honey, garden-oak, garden-pond, garden-salad (final pass, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi, atan = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.CUTS = CUTS
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

-- ramps dark -> light (6 tones)
A.R = {
  honey = { "#6a2a1e", "#a2441b", "#d06e17", "#ee9a1e", "#fbc645", "#ffe797" },
  glass = { "#2f4f7a", "#4f7fae", "#7fb4d6", "#b2dceb", "#dcf4f6", "#f4fffb" },
  cloth = { "#5c1a30", "#8c2538", "#bd383c", "#e2523e", "#f8805a", "#ffb48a" },
  check = { "#7a3a4a", "#b0605e", "#d8907a", "#efbb98", "#fbdcb8", "#fff1d8" },
  twine = { "#5a3a2a", "#8a6040", "#b88a5a", "#ddb57e" },
  wood  = { "#3e2124", "#5c3328", "#83492f", "#a8683f", "#c98c58", "#e8b982" },
  bark  = { "#2f1d22", "#4a2c2a", "#6a4232", "#8c5a3c", "#ad7a4e", "#cf9f6a" },
  leaf  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" },
  lettuce = { "#21593f", "#357a3e", "#559a3e", "#7dbb48", "#a8d65e", "#d8f08a" },
  stone = { "#33354f", "#4f526c", "#74758c", "#9a9aac", "#c4c3d0", "#e6e4ec" },
  water = { "#1d3466", "#264d88", "#3070aa", "#4598c4", "#72c2d6", "#b8ecea" },
  red   = { "#5e1a30", "#93243a", "#c8333a", "#e8493b", "#ff7a5a", "#ffb08a" },
  petal = { "#7d2c5e", "#b04880", "#d86a98", "#f5809f", "#ffadc6", "#ffd8e6" },
  cream = { "#8a6a5a", "#b8967a", "#dcc09a", "#f0dcb6", "#fbeccd", "#fff4d6" },
  ochre = { "#5e3020", "#8f4a1f", "#bb6e26", "#d98f30", "#f2b84a", "#ffdf88" },
}

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- blend of normal fields: a*(1-w) + b*w
function A.blend(na, nb, w)
  local n = {}
  for k, a in pairs(na) do local b = nb[k] or a
    n[k] = { norm(a[1] * (1 - w) + b[1] * w, a[2] * (1 - w) + b[2] * w, a[3] * (1 - w) + b[3] * w) } end
  return n
end

-- vertical cylinder normals (x0..x1 span), blended with pillow for rounded ends
function A.vcyl(m, x0, x1, R, wp)
  local cx, r = (x0 + x1) / 2, (x1 - x0) / 2 + 0.5
  local nc = {}
  m:each(function(x, y) local s = max(-0.97, min(0.97, (x - cx) / r))
    nc[K(x, y)] = { s, 0, sqrt(1 - s*s) } end)
  local np = X.pillow(m, R or 3)
  return A.blend(nc, np, wp or 0.35)
end

function A.ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local u, v = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if u*u + v*v <= 1 then m:set(x, y) end
  end end
  return m
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

function A.leaf(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local wfn = o.wfn or function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.98 + 0.04)) ^ (o.pw or 0.75))
  end
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.45 })
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "leaf" } }
  local idx = G.toneN(c, m, n, ramp, { amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok, bias = o.bias })
  local vs = o.vs or 3.2
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.16 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and ramp[min(6, (idx[k] or 3) + 2)] or ramp[max(2, (idx[k] or 3) - 1)], tok)
    elseif t > 0.12 and t < 0.86 and abs(s) > 0.3 and abs(s) < 0.8 then
      local d = (t * len - abs(s) * w * 1.1) % vs
      if d < 0.9 then c:put(x, y, s < 0 and ramp[min(6, (idx[k] or 3) + 1)] or ramp[max(1, (idx[k] or 3) - 1)], tok) end
    end
  end)
  return m, T, S, idx
end

function A.stem(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(pts, wfn)
  if o.cut then m:cut(o.cut) end
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.14, wrap = o.wrap or 0.3, cuts = o.cuts or CUTS, tok = o.tok, bias = o.bias })
  return m, n, T, S, idx, samp
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
