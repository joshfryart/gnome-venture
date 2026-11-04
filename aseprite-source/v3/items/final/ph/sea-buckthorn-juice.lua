-- sea-buckthorn-juice (first draft, Sonnet). A slim round-shouldered glass bottle with a long neck and cork, filled
-- with glowing orange juice (surface line, bubbles), glass rim shine on the left, pale pulp flecks.
-- quirk: a fresh berry hangs on a twine loop around the neck like a tag, and one drip slides down the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sea-buckthorn-juice")
local floor = math.floor
c:groundShadow(32, 57, 14, 3)
local body = c:ellipse(32, 41, 14, 14):clip(c:rect(0, 28, 63, 56))
body:add(c:rect(18, 40, 46, 55))
A.lit(c, body, A.R("#b6f0e0"), 3, { amb = .15, wrap = .4 })
local neck = c:rect(27, 10, 37, 30)
neck:add(c:poly{ { 27, 28 }, { 37, 28 }, { 46, 40 }, { 18, 40 } })
A.lit(c, neck, A.R("#b6f0e0"), 2, { amb = .15, wrap = .4 })
-- juice (inside glass, inset)
local liq = c:ellipse(32, 41, 12, 12):clip(c:rect(0, 32, 63, 54))
liq:add(c:rect(20, 40, 44, 53))
liq:add(c:rect(29, 20, 35, 33))
local jr = A.R("#f08a22")
A.lit(c, liq, jr, 7, { amb = .12, wrap = .35 })
A.speck(c, liq, { "#ffd070", jr[3] }, .06, 8)
-- surface line + bubbles
c:fillMask(c:rect(29, 20, 35, 20), "#ffd070")
c:px(25, 36, "#ffe38a") c:px(26, 36, "#ffe38a") c:px(24, 37, "#fff4d6")
A.sph(c, 38, 46, 1.4, "#ffd070", { nospec = true }) A.sph(c, 31, 50, 1.2, "#ffd070", { nospec = true })
-- glass shine
for y = 12, 52 do local xx = (y < 30) and 28 or (y < 38 and 24 or 20) c:px(xx, y, "#f4fffc") end
for y = 32, 52 do c:px(44, y, "#5f9ad0") end
-- cork + twine
local cork = c:rrect(27, 3, 37, 11, 2)
A.lit(c, cork, A.R("#c79a5e"), 2, {})
c:px(30, 5, "#e8c18a") c:px(34, 8, "#8a5a36")
for x = 27, 37 do c:px(x, 14, "#e8c18a") c:px(x, 15, "#a88a5a") end
A.bezLine(c, { { 37, 15 }, { 46, 14 }, { 48, 22 }, { 47, 28 } }, "#d8b87a", 20)
A.sph(c, 47, 32, 3.2, "#f08a22", { spec = "#fff4d6" })
c:px(47, 28, "#5fa04a") c:px(48, 27, "#7cc35a")
-- drip
c:px(45, 42, "#ffd070") c:px(45, 43, "#f08a22") c:px(45, 44, "#f08a22") c:px(45, 45, "#ffd070")
A.fin()
