-- ico-basket first draft (Sonnet). quirk: a shiny red apple peeking out of the basket
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-basket"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local WK = D.WICK
local h = c:line({{15,32},{14,22},{20,13},{32,10},{44,13},{50,22},{49,32}}, 3) D.lit(h, W, 1.5)
local ap = B.ell(27,27,6.5,6.5) D.lit(ap, EM, 3)
D.fill(c:rect(26,19,27,21), W[1]) D.fill(c:rect(28,19,31,20), MO[3]) c:px(29,19,MO[5])
local body = c:poly{{11,30},{53,30},{49,54},{15,54}} D.cyl(body, WK, 11, 53)
body:each(function(x, y)
  local r = floor((y - 30) / 3) local sh = (r % 2) * 2
  if (y - 30) % 3 == 2 then c:px(x, y, WK[2])
  elseif (x + sh) % 5 == 0 then c:px(x, y, WK[2]) end
end)
local rim = c:rrect(10,28,54,33,2) D.lit(rim, W, 1.5)
D.fin()
