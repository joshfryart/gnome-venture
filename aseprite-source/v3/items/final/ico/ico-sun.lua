local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-sun: round golden sun with eight chunky triangular rays and a content face.
-- quirk: it wears tiny dark sunglasses with one cream glint.
local c = D.new("ico-sun")
for i = 0, 7 do
  local a = i * pi / 4 + pi / 8 local ux, uy = cos(a), sin(a) local px, py = -uy, ux
  local pts = { { 32 + ux * 17 + px * 5, 32 + uy * 17 + py * 5 }, { 32 + ux * 29, 32 + uy * 29 }, { 32 + ux * 17 - px * 5, 32 + uy * 17 - py * 5 } }
  for _, p in ipairs(pts) do p[1] = floor(p[1] + .5) p[2] = floor(p[2] + .5) end
  D.poly(c, pts, D.ORG, 3, { amb = 0.2 })
end
D.disc(c, 32, 32, 15, D.YEL)
D.rect(c, 21, 28, 42, 28, D.INK) D.rect(c, 22, 29, 29, 33, D.INK) D.rect(c, 34, 29, 41, 33, D.INK) D.rect(c, 30, 29, 33, 30, D.INK)
D.rect(c, 23, 30, 24, 30, D.CREAM) D.rect(c, 35, 30, 36, 30, D.CREAM)
D.rect(c, 31, 35, 32, 36, D.ORG[3])
D.rect(c, 27, 39, 28, 39, D.ORG[2]) D.rect(c, 29, 40, 34, 40, D.ORG[2]) D.rect(c, 35, 39, 36, 39, D.ORG[2])
D.fin()
