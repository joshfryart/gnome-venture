-- _aR2_1.lua: private helpers for ph/alstroemeria-seed, ph/amaranth, ph/amaranth-seed, ph/amber-lamppost (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + quantise a normal field; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- shift one toned pixel by d steps
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- tear a blade mask along a jagged line across it. side "hi" drops T > t0 + j, "lo" drops T < t0 + j.
-- returns the torn-edge mask (pixels of m next to the removed part)
function A.tear(m, T, S, t0, side, amp, seed)
  local cut = HP.mask()
  m:each(function(x, y) local k = K(x, y)
    local band = floor((S[k] + 1) * 3.2)
    local j = (X.hash(band, 3, seed or 1) - 0.5) * 2 * amp + S[k] * amp * 0.7
    local drop
    if side == "hi" then drop = T[k] > t0 + j else drop = T[k] < t0 + j end
    if drop then cut:set(x, y) end
  end)
  m:cut(cut)
  local e = HP.mask()
  m:each(function(x, y) if cut:has(x + 1, y) or cut:has(x - 1, y) or cut:has(x, y + 1) or cut:has(x, y - 1) then e:set(x, y) end end)
  return e, cut
end

-- contact shadow + AO of caster onto target mask (bias table)
function A.contact(bias, target, caster, d)
  X.ao(bias, target, caster, 1, -1)
  G.cast(bias, target, caster, 1, d or 1, -1)
  return bias
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
