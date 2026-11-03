-- ico-blossom first draft (Sonnet). quirk: a ladybird resting on one petal
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-blossom"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

for k = 0, 4 do
  local a = math.rad(k * 72 - 90)
  local cx, cy = 32 + 11 * math.cos(a), 32 + 11 * math.sin(a)
  local m = B.ell(cx, cy, 9, 7, a)
  D.lit(m, PE, 3.5)
  local tx, ty = floor(32 + 19.5 * math.cos(a) + .5), floor(32 + 19.5 * math.sin(a) + .5)
  c:px(tx, ty, PE[1])
end
local ce = B.ell(32,32,5.5,5.5) D.lit(ce, GO, 3)
for _, p in ipairs{{30,30},{34,31},{31,34},{35,34}} do c:px(p[1],p[2],GO[1]) end
D.lit(B.ell(46,29,3,2.5), EM, 1.5) D.fill(c:rect(49,28,50,30), D.INK)
c:px(45,28,D.INK) c:px(47,30,D.INK)
D.fin()
