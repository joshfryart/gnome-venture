local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-four-leaf-clover: lucky clover, four rounded heart leaves, curved stem.
-- quirk: a blue dew drop sits on the top-right leaf.
local c = D.new("ico-four-leaf-clover")
c:part(c:line({ {32,30},{34,42},{30,50},{36,58} }, 3), D.GREEN, { band = 1, nopop = true })
local dirs = { {-1,-1},{1,-1},{-1,1},{1,1} }
local cx, cy = 32, 28
for i, d in ipairs(dirs) do
  local ox, oy = cx + d[1] * 8, cy + d[2] * 8
  local m = c:ellipse(ox + d[1] * 2, oy, 8, 8):add(c:ellipse(ox, oy + d[2] * 2, 8, 8))
  m:cut(c:rect(ox - 14 * d[1] > 0 and 0 or 0, 0, 0, 0))
  m = D.isect(m, c:rect(0, 0, 63, 63))
  D.lit(m, D.GREEN, 7, { amb = 0.05 })
  D.ln(c, cx, cy, cx + d[1] * 13, cy + d[2] * 13, D.GREEN[2], m)
end
D.lit(D.disc(32, 28, 2), D.GREEN, 2)
D.fill(c:rect(42, 10, 44, 12), "#78b4ea") c:px(42, 10, CR) c:px(44, 12, "#3a6aa6")
D.fin()
