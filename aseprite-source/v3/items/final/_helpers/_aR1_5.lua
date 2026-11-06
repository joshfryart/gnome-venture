-- _aR1_5.lua: private helpers for agapanthus-seed, aged-goat-cheese, allamanda-seed, almond (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua). Saves into final/ph/.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
A.HP, A.X, A.K = HP, X, K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
A.FINAL = DIR .. "/../ph/"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- paint a mask from a lit value map v with a ramp (dark..light) and cuts, bias optional
function A.toneV(c, m, v, ramp, o)
  o = o or {}
  return X.tone(c, m, v, ramp, { cuts = o.cuts, bias = o.bias, tok = o.tok or { r = { name = o.name or "p" } } })
end

-- darken one step: index into ramp for an existing hex; returns hex one step darker in that ramp
function A.step(ramp, hex, d)
  for i, h in ipairs(ramp) do if h == hex then return ramp[max(1, min(#ramp, i + d))] end end
  return hex
end

-- jagged tear along a mask edge: cut pixels whose hash is low on the given side
function A.tear(m, test, seed, amt)
  local cut = {}
  m:edge():each(function(x, y) if test(x, y) and X.hash(x, y, seed) < (amt or 0.5) then cut[#cut + 1] = { x, y } end end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  return m
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.FINAL .. name .. ".aseprite", png = A.FINAL .. name .. ".png", scale = 1 }
  if app.params.out then c:save{ png = app.params.out .. name .. ".png", scale = 1 } end
end
return A
