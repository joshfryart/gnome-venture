local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-hedgehog: side-on hedgehog with a spiky back and pale snout. quirk: a red apple stuck on its spines.
local c = D.new("ico-hedgehog")
c:groundShadow(30, 56, 20, 2)
local cx, cy, rx, ry = 27, 38, 21, 16
local sp = HP.mask()
for i = 0, 16 do
  local t = math.pi * (0.95 + i * 0.055)
  local px, py = cx + rx * math.cos(t), cy + ry * math.sin(t)
  local tx, ty = cx + (rx + 6) * math.cos(t), cy + (ry + 6) * math.sin(t)
  local a1, a2 = t - 0.16, t + 0.16
  sp:add(D.poly2({ { fl(cx + rx * math.cos(a1)), fl(cy + ry * math.sin(a1)) }, { fl(cx + rx * math.cos(a2)), fl(cy + ry * math.sin(a2)) }, { fl(tx), fl(ty) } }))
end
local body = D.ell(cx, cy, rx, ry):add(sp)
body:cut(D.rect(0, cy + 8, 63, 63))
D.lit(body, D.BRN, 8, { amb = 0.1 })
for i = 0, 11 do
  local t = math.pi * (1.0 + i * 0.07)
  D.ln(fl(cx + 6 * math.cos(t)), fl(cy + 5 * math.sin(t)), fl(cx + (rx + 3) * math.cos(t)), fl(cy + (ry + 3) * math.sin(t)), D.BRN[2])
end
D.px(14, 28, D.BRN[6]) D.px(17, 24, D.BRN[6]) D.px(22, 21, D.BRN[6])
-- feet
D.lit(D.ell(16, 52, 4, 3), D.CREAM, 2) D.lit(D.ell(36, 53, 4, 3), D.CREAM, 2)
-- face
local face = D.poly2({ { 40, 28 }, { 59, 42 }, { 40, 52 } }):add(D.ell(44, 42, 8, 8))
D.lit(face, D.CREAM, 4, { amb = 0.12 })
D.fill(D.ell(58, 43, 2, 2), D.INK) D.px(57, 42, D.CR)
c:eyeSmall(46, 36)
D.lit(D.ell(41, 31, 3, 3), D.BRN, 1.5) -- ear
-- apple
D.lit(D.disc(21, 20, 5), D.RED, 5, { amb = 0.05 }) D.px(19, 18, D.CR) D.px(20, 18, D.CR)
D.ln(21, 14, 22, 11, D.BRN[3]) D.fill(D.rect(23, 11, 25, 12), D.GREEN[4])
D.fin()
