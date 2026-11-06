-- _aA9_0: helper for ico-roadworks, ico-roast, ico-rod, ico-rope (Opus artist pass). Read-only use of batch2/_b2g1.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local D = { G = G, HP = HP, X = X, K = K, INK = "#2b1c26", CREAM = "#fff4d6" }
-- 6-tone ramps, dark -> light
D.RED   = { "#5c1a2e", "#8e2236", "#c2303a", "#e8493b", "#ff7552", "#ffa982" }
D.CRM   = { "#8a6670", "#bf9c8a", "#e3c7a2", "#f6e2bc", "#fff0d2", "#fffae8" }
D.WOOD  = { "#3e2328", "#5e3530", "#864c33", "#b07444", "#d49a60", "#efc488" }
D.STEEL = { "#2e3050", "#4a4c6c", "#6e7090", "#9a9cb4", "#c8cad8", "#eef0f6" }
D.AMBER = { "#7a2e1c", "#b8481e", "#e8701e", "#ffa02e", "#ffd060", "#fff3b0" }
D.CRUST = { "#4a1e22", "#7a3222", "#a8521f", "#d07a2a", "#eda645", "#ffd27a" }
D.BONE  = { "#6a5060", "#a08a8c", "#cdb9a8", "#ecdcc0", "#fff0d4", "#fffaea" }
D.CORK  = { "#5a3424", "#8a5634", "#b47e4e", "#d4a46c", "#ecc88e", "#fbe4b4" }
D.ROPE  = { "#4a2a22", "#7a4a30", "#a8743e", "#cc9a54", "#e8c078", "#f9e2a8" }
D.SNAIL = { "#4a2a4a", "#7a3e6a", "#b05a8a", "#e08aa8", "#ffc4d8" }
function D.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function D.tone(c, m, n, ramp, o) return G.toneN(c, m, n, ramp, o) end
function D.find(ramp, hex) for i, h in ipairs(ramp) do if h:lower() == (hex or ""):lower() then return i end end end
function D.shift(c, x, y, ramp, d)
  local i = D.find(ramp, c:get(x, y)) if i then c:put(x, y, ramp[max(1, min(#ramp, i + d))], c.own[y * c.w + x]) end
end
function D.set(c, x, y, hex, tok) c:put(x, y, hex, tok or c.own[y * c.w + x]) end
function D.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ico/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return D
