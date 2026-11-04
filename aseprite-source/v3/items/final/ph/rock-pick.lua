-- rock-pick (first draft, Sonnet). Slim steel pickaxe: curved double-pointed head on a long wood handle with a
-- leather-wrapped grip, iron socket collar with a rivet, bright bevel along the head's top edge.
-- quirk: a little pebble is stuck on the right point of the pick.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rock-pick")
local floor = math.floor
local function hx(y) return 30 + (y - 14) * (6 / 43) end
A.rod(c, 30, 14, 36, 55, 1.8, "wood", { amb = .1 })
for y = 22, 44, 4 do c:px(floor(hx(y)) - 1, y, "#864c33") c:px(floor(hx(y)) , y + 2, "#e8b982") end
for y = 44, 53, 2 do for x = floor(hx(y)) - 2, floor(hx(y)) + 2 do c:px(x, y, (y % 4 == 0) and "#c79a5e" or "#8a5a36") end end
A.sph(c, 36, 56, 2.4, "wood", { nospec = true })
local head = A.sweepM(A.curve({ { 6, 29 }, { 14, 5 }, { 49, 5 }, { 57, 29 } }, 50), function(t) return .6 + 3.1 * math.sin(math.pi * t) ^ .9 end)
A.lit(c, head, "#8a9ab8", 2.6, { amb = .08 })
head:each(function(x, y) if not head:has(x, y - 1) then c:px(x, y, "#e6eefa") end end)
-- collar
local col = c:rect(27, 9, 35, 17)
A.lit(c, col, "#74758c", 1.8)
c:px(30, 13, "#e2e0e6") c:px(30, 14, "#444663")
for x = 27, 35 do c:px(x, 17, "#35395a") end
-- pebble stuck on the right point
A.sph(c, 58, 31, 2.4, "#9b8a78", { spec = "#fff4d6" })
c:px(57, 29, "#8a9ab8")
A.fin()
