-- _aB30_0.lua: private helpers for ph/ember-shell, ember-spark, ensete, ensete-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

-- straight axis frame A->B: f(x,y) -> t (0..1), s (px, + = lower-right side); pt(t,s) -> x,y
function A.axis(ax, ay, bx, by)
  local vx, vy = bx - ax, by - ay
  local len = sqrt(vx*vx + vy*vy)
  local ux, uy = vx / len, vy / len
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local F = { len = len, ux = ux, uy = uy, px = px, py = py }
  function F.at(x, y) local rx, ry = x - ax, y - ay return (rx*ux + ry*uy) / len, rx*px + ry*py end
  function F.pt(t, s) return ax + ux * t * len + px * s, ay + uy * t * len + py * s end
  return F
end

-- quantise v by ascending cuts -> 1..#cuts+1
function A.q(v, cuts) local i = 1 for j, t in ipairs(cuts) do if v >= t then i = j + 1 end end return i end

function A.line(c, pts, hex, tok, clip)
  HP.line(pts, 1):each(function(x, y) if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end end)
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
