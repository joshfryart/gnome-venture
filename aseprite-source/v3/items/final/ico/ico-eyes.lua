local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-eyes: two big round eyeballs glancing sideways, teal irises.
-- quirk: one brow is raised and the other flat, so it looks suspicious.
local c = D.new("ico-eyes")
local EB = { "#9a8aa8", "#c6b8d0", "#e4dcee", "#f6f0fa", "#fffaf0", "#fffdf6" }
for _, cx in ipairs{ 18, 46 } do
  local e = c:ellipse(cx, 36, 11, 13)
  D.lit(e, EB, 9, { amb = 0.05 })
  local ix = cx + 4
  local ir = D.disc(ix, 38, 6)
  D.lit(ir, D.BLUE, 5)
  D.fill(D.disc(ix + 1, 39, 3), INK)
  c:px(ix - 2, 35, CR) c:px(ix - 1, 35, CR) c:px(ix - 2, 36, CR)
end
c:part(c:line({ {6,24},{16,20},{28,24} }, 3), D.BRN, { band = 1, nopop = true })
c:part(c:line({ {36,18},{46,10},{58,14} }, 3), D.BRN, { band = 1, nopop = true })
D.fin()
