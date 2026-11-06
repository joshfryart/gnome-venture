-- _aC20_3.lua: private helpers for ph/lilac-seed, ph/lily-of-the-valley-seed, ph/lime, ph/lime-cordial (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, abs, sqrt, cos, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.cos, math.sin
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
A.VEIN, A.COOL = "#c2e48c", "#3a6c72"
A.SEED = { "#3e2422", "#5e3a2a", "#84552f", "#a87240", "#cc9c5e", "#ecc98e" }
A.STEM = { "#3f7a4f", "#5f9c5a", "#86b86c", "#b8dc92" }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok }), v
end
-- tear a blade mask: drop pixels past/before Lcut px along its length with a jagged per-band edge.
-- from = "end" tears the t=1 end, "start" the t=0 end. Returns the torn-edge mask (remaining border pixels at the tear).
function A.tear(m, T, S, len, Lcut, from, seed)
  local drop = {}
  m:each(function(x, y) local k = K(x, y)
    local band = floor((S[k] + 1) * 4.5)
    local j = X.hash(band, 3, seed or 1) * 3.2 + (band % 2) * 0.8
    local d = (from == "start") and (T[k] * len) or ((1 - T[k]) * len)
    if d < Lcut - j then drop[#drop + 1] = k end
  end)
  for _, k in ipairs(drop) do m.s[k] = nil end
  local gone = HP.mask() for _, k in ipairs(drop) do gone.s[k] = true end
  local edge = HP.mask()
  gone:grow(1):each(function(x, y) if m:has(x, y) then edge:set(x, y) end end)
  return edge
end
-- paint a pixel with ramp index clamped
function A.rp(c, x, y, ramp, i, tok) c:put(x, y, ramp[max(1, min(#ramp, i))], tok) end
function A.save(c, name) G.save2(c, name) end
return A
