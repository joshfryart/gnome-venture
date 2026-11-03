local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- beehive-painted: a straw skep with rings painted candy pink, white and blue with a little flower on the door arch, on a blue plank. quirk: a bee perches on the painted flower as if it were real.
local c = D.new("beehive-painted")
c:groundShadow(32, 57, 20, 2)
D.lit(c:rect(12, 50, 52, 55), D.TEAL, 2.5) D.ln(13, 51, 51, 51, "#b4e8d0")
D.lit(c:rect(16, 55, 20, 57), D.TEAL, 1.5) D.lit(c:rect(44, 55, 48, 57), D.TEAL, 1.5)
local y = 51
local rampsR = { D.PINK, D.CRM, D.PINK, D.CRM }
for i = 1, 4 do
  local w = 17 - (i - 1) * 3.2
  local m = D.ell(32, y - 5, w, 7.5 + (i == 4 and 1.5 or 0), 0)
  D.lit(m, rampsR[i], 3)
  if i > 1 then D.seam(c, m, D.ell(32, y - 14, w - 3, 7.5, 0), "#7d2c5e") end
  for k = -floor(w) + 3, floor(w) - 3, 5 do D.px(32 + k, y - 2, i % 2 == 1 and D.PINK[2] or D.CRM[2]) end
  y = y - 8
end
c:fillMask(c:poly{ {28, 50}, {28, 46}, {30, 43}, {34, 43}, {36, 46}, {36, 50} }, "#2c1a1e")
D.lit(D.ell(32, 12, 2.4, 2.4, 0), D.SEA, 1.6)
for _, p in ipairs{{22, 39}, {42, 39}} do
  for _, o in ipairs{{-2, 0}, {2, 0}, {0, -2}, {0, 2}} do c:px(p[1] + o[1], p[2] + o[2], "#78b4ea") end c:px(p[1], p[2], "#f8d048")
end
D.bee(50, 30)
D.fin()
