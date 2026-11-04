-- _aB11_3.lua: private helpers for broken-garden-hoe, broken-garden-snips, broken-gathering-basket,
-- broken-gathering-pouch (aB11_3, Opus single pass). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local sqrt, floor, max, min = math.sqrt, math.floor, math.max, math.min
local A = { G = G, HP = HP, X = X, K = K }
A.OUT = app.params.out or (DIR .. "/../ph/")
A.CUTS = { 0.22, 0.4, 0.57, 0.72, 0.86 }
A.INK = "#2b1c26"
A.WOOD   = { "#4a2a2a", "#74402f", "#9a5c3a", "#bf7f4c", "#dba267", "#f2c98c" }
A.STEEL  = { "#2f3350", "#4f5675", "#737c99", "#9aa3bb", "#c3cad9", "#eef2f7" }
A.BRASS  = { "#5a3320", "#8f5a22", "#c08a2a", "#e3b23c", "#f5d46a", "#fff0a8" }
A.GRIP   = { "#5e1c34", "#8f2638", "#c03a3c", "#e45a44", "#f5855a", "#ffb98a" }
A.WICKER = { "#5b3424", "#8a5530", "#b77f43", "#d6a35a", "#ebc47a", "#f8e2a6" }
A.TEAL   = { "#1f3a4f", "#255a66", "#2f7d80", "#43a097", "#6cc1ad", "#a8e0c6" }
A.LEAF   = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
A.SOIL   = { "#3b2426", "#5a3a2e", "#7a5338", "#9a6e48" }
A.CORD   = { "#4a2e26", "#7a5034", "#a8784a", "#d8b07a" }
A.SPEC = "#fff4d6"

function A.new(name) A.name = name return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tone(c, m, n, R, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, R, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or { r = { name = o.name or "p" } } })
  return idx, v
end
function A.erase(c, m) m:each(function(x, y) local i = y * c.w + x c.pix[i] = nil c.own[i] = nil end) end
function A.lineP(ax, ay, bx, by)
  return { { ax, ay }, { ax + (bx - ax) / 3, ay + (by - ay) / 3 }, { ax + 2 * (bx - ax) / 3, ay + 2 * (by - ay) / 3 }, { bx, by } }
end
function A.tube(p, w) return G.tube(p, type(w) == "function" and w or function() return w end) end
-- shift tone index of a pixel by d (reads current colour in ramp R)
function A.nudge(c, x, y, R, d)
  local cur = c:get(x, y) if not cur then return end
  for i, h in ipairs(R) do if h:lower() == cur then c:put(x, y, R[max(1, min(#R, i + d))]) return end end
end
function A.save(c)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. A.name .. ".aseprite", png = A.OUT .. A.name .. ".png", scale = 1 }
end
return A
