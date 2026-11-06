-- _aC35_4.lua: private helpers for pluot-jam, pluot-seed, pohutukawa-seed, poi (final pass, Opus; copy of _aR1_2 pattern).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.DIR = DIR
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + quantise; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- index of v in cuts (1..#cuts+1)
function A.q(v, cuts)
  local i = 1
  for j, t in ipairs(cuts or A.CUTS) do if v >= t then i = j + 1 end end
  return i
end

-- shift one already-toned pixel by d steps
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- sphere normals blended with a pillow (soft-edged round things)
function A.dome(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 3)
  local ns = X.sphere(cx, cy, r, m)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

function A.save(c, folder, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../" .. folder .. "/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
-- shift idx of pixels in mask by d (AO / pits) and repaint
function A.bump(c, idx, ramp, m, d, tok)
  m:each(function(x, y) A.step(c, idx, ramp, x, y, d, tok) end)
end
-- vertical lathe normals (jars, pounders): nx from (x-cx)/r(y), blended with pillow for rounded ends
function A.lathe(m, cx, rfn, R, wP)
  local np = X.pillow(m, R or 2)
  local n = {}
  wP = wP or 0.35
  m:each(function(x, y) local k = K(x, y)
    local r = rfn(y)
    local sx = max(-0.97, min(0.97, (x + 0.5 - cx) / (r + 0.5)))
    local a = { sx, 0, sqrt(1 - sx * sx) }
    local b = np[k]
    n[k] = { norm(a[1] * (1 - wP) + b[1] * wP, a[2] * (1 - wP) + b[2] * wP, a[3] * (1 - wP) + b[3] * wP) }
  end)
  return n
end
return A
