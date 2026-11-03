-- ico-books first draft (Sonnet). quirk: a seedling sprouting from the top book
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-books"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local function book(x0, y0, x1, y1, ramp, band)
  D.lit(c:rrect(x0, y0, x1, y1, 2), ramp, 2.5)
  D.lit(c:rect(x1 - 6, y0 + 1, x1, y1 - 1), D.CREAM, 1)
  for y = y0 + 3, y1 - 3, 3 do for x = x1 - 5, x1 - 1 do c:px(x, y, D.CREAM[2]) end end
  D.fill(c:rect(x0 + 4, y0, x0 + 5, y1), band)
  D.fill(c:rect(x0 + 8, y0, x0 + 8, y1), band)
end
book(8, 43, 53, 54, D.BLUE, GO[4])
book(12, 31, 57, 42, D.GREEN, GO[4])
book(10, 19, 50, 30, D.RED, GO[4])
D.fill(c:rect(29,11,30,18), MO[2])
D.lit(B.ell(25,10,4,2.2,-0.4), MO, 1.5) D.lit(B.ell(35,9,4,2.2,0.4), MO, 1.5)
D.fin()
