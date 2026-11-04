-- sago-seed (first draft, Sonnet). Three plump orange-red sago-palm seeds on a feathery pinnate frond scrap
-- (a rachis with paired narrow leaflets); the right seed sprouts a curled fiddlehead frond that is just starting to
-- unfurl, with two small leaflet arms.
-- quirk: the fiddlehead's curl is tipped with fuzzy brown felt.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("sago-seed")
local floor = math.floor
local rach = A.curve({ { 4, 56 }, { 20, 54 }, { 38, 50 }, { 60, 40 } }, 40)
for i = 3, #rach - 2, 2 do
  local p = rach[i]
  local nx, ny = -p[4], p[3]
  A.blade(c, p[1], p[2], p[1] + nx * 8 + p[3] * 3, p[2] + ny * 8 + p[4] * 3, 1.3, "#2f7a44", { veins = {}, norib = true, slant = 2 })
  A.blade(c, p[1], p[2], p[1] - nx * 8 + p[3] * 3, p[2] - ny * 8 + p[4] * 3, 1.3, "#3f9150", { veins = {}, norib = true, slant = 2 })
end
A.lit(c, A.sweepM(rach, function() return 1 end), "#7a5a3a", 1, { amb = .1 })
local sd = A.R("#e8602a")
for _, s in ipairs{ { 16, 49, .2 }, { 28, 51, -.2 }, { 43, 46, 0 } } do
  A.seed(c, s[1], s[2], 5, 4, s[3], sd, "#1f553f", "#ffc4a0")
  c:px(s[1] + 4, s[2], "#8f4a1f")
end
-- fiddlehead
local fh = A.curve({ { 43, 42 }, { 43, 32 }, { 41, 22 }, { 45, 16 } }, 20)
A.lit(c, A.sweepM(fh, function() return 1.4 end), "moss", 1, { amb = .15 })
for a = 0, 9 do local ang = -.3 + a * .6 A.px_ = nil c:px(floor(45 + math.cos(ang) * (3.4 - a * .12)), floor(13 + math.sin(ang) * (3.4 - a * .12)), a % 2 == 0 and "#7cc35a" or "#c4e07a") end
c:fillMask(c:rect(45, 14, 46, 15), "#8f6a3a") c:px(46, 13, "#b08a5a")
A.blade(c, 43, 34, 30, 28, 1.4, "#3f9150", { veins = {}, norib = true, slant = 2 })
A.blade(c, 43, 30, 56, 25, 1.4, "#3f9150", { veins = {}, norib = true, slant = 2 })
A.fin()
