local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-castle")
local CR, INK = D.CR, D.INK
-- ico-castle: grey stone keep with two round-topped towers, crenellations, wooden arched gate with a portcullis bar.
-- quirk: a red pennant flies from the left tower and a pink face peeks out of a window.
c:groundShadow(32, 58, 24, 2)
local function tower(x0, x1, top)
  local m = c:rect(x0, top, x1, 56)
  for x = x0, x1 - 2, 4 do m:add(c:rect(x, top - 3, x + 2, top)) end
  D.lit(m, D.GRY, 2.5, { amb = 0.15 })
  D.fill(c:rect(x0 - 1, top, x1 + 1, top + 1), D.GRY[2])
  D.fill(c:rect(x0 + 3, top + 7, x0 + 4, top + 12), D.GRY[1])
end
local mid = c:rect(21, 24, 42, 56)
for x = 21, 40, 4 do mid:add(c:rect(x, 21, x + 2, 24)) end
D.lit(mid, D.GRY, 2.5, { amb = 0.15 })
tower(8, 19, 16) tower(44, 55, 16)
D.lit(c:rect(26, 40, 37, 56):add(c:ellipse(31.5, 40, 6, 5)), D.WOODR, 3)
for x = 28, 35, 3 do D.rect(x, 38, x, 55, D.WOODR[2]) end
D.rect(26, 47, 37, 47, D.GRY[3])
D.fill(c:rect(29, 28, 34, 33), D.GRY[1]); D.fill(c:rect(30, 29, 33, 33), "#f5809f"); D.px(31, 31, INK) D.px(32, 31, INK) D.px(30, 29, "#ffd6e2")
D.rect(13, 3, 13, 15, D.WOODR[3])
D.fill(c:poly{ {14, 3}, {22, 5}, {14, 8} }, "#e8493b"); D.px(15, 4, "#ff9a78")
D.fin()
