-- salsa-verde (first draft, Sonnet). A grey basalt molcajete bowl on three stubby feet, bright green salsa with
-- chunky cilantro flecks and seed dots, a husked tomatillo in front and a small stone pestle leaning on the rim.
-- quirk: a green drip runs over the lip of the bowl.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("salsa-verde")
local floor = math.floor
c:groundShadow(32, 54, 21, 4)
-- feet
for _, x in ipairs{ 17, 30, 43 } do A.lit(c, c:rrect(x, 46, x + 4, 53, 2), A.R("#444663"), 2, { amb = .1 }) end
-- bowl body (lower half dome)
local body = c:ellipse(32, 32, 24, 18):clip(c:rect(0, 32, 63, 51))
body:add(c:rect(8, 28, 55, 32))
local rp = A.R("#74758c")
A.lit(c, body, rp, 8, { amb = .08, wrap = .3 })
A.speck(c, body, { rp[2], rp[6], rp[3] }, .08, 31)
-- rim ellipse + sauce
local rim = c:ellipse(32, 28, 24, 8)
A.lit(c, rim, rp, 3, { amb = .06 })
local sauce = c:ellipse(32, 28, 20, 5.5)
A.lit(c, sauce, A.R("#6fb04a"), 2.5, { amb = .12, wrap = .35 })
A.speck(c, sauce, { "#c4e07a", "#3f9150", "#fff4d6" }, .13, 11)
for _, p in ipairs{ { 24, 27 }, { 33, 29 }, { 40, 26 }, { 29, 31 } } do c:px(p[1], p[2], "#24544a") c:px(p[1] + 1, p[2], "#3f9150") end
c:px(26, 26, "#e4f6a0") c:px(27, 26, "#e4f6a0")
-- drip over lip
c:fillMask(c:rect(51, 29, 52, 35), "#6fb04a") c:px(51, 36, "#6fb04a") c:px(52, 36, "#3f9150") c:px(52, 33, "#3f9150") c:px(51, 30, "#c4e07a")
-- pestle
A.rod(c, 40, 8, 31, 27, 1.9, "#aaa9b8", { amb = .1 })
A.sph(c, 41, 7, 2.6, "#aaa9b8", {})
-- tomatillo in front
local tm = A.sph(c, 17, 45, 5, "#9ac45a", {})
A.lit(c, c:ellipse(17, 45, 5.2, 5.2), A.R("#9ac45a"), 5, { amb = .1 })
for i = -4, 4, 2 do c:px(17 + i, 40 - (i * i) // 8, "#d8c890") end
c:px(15, 43, "#e4f6a0") c:px(14, 44, "#e4f6a0")
c:px(17, 39, "#7a6a3a") c:px(17, 40, "#7a6a3a")
A.fin()
