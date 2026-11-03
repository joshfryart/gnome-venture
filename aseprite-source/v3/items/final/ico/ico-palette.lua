-- ico-palette first draft (Sonnet). quirk: a paint-dipped brush is poked through the thumb hole and one blob is dripping
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-palette")
c:groundShadow(32, 58, 22, 2)
local pal = D.ell(30, 33, 24, 20, 0.15)
pal:cut(D.ell(14, 46, 8, 6)):cut(D.ell(36, 46, 0.5, 0.5))
D.lit(pal, { "#6b4a2a", "#9a6a3a", "#c08a50", "#dca865", "#efc582", "#fbe0a6" }, 10, { amb = .12 })
-- thumb hole
local th = D.ell(28, 46, 4, 3)
D.fill(th, "#51302b") D.fill(c:rect(25, 44, 29, 44), "#3a2030")
-- paint blobs
local blobs = { {18,23,"ember"}, {28,16,"gold"}, {40,18,"moss"}, {47,28,"sea"}, {40,38,"dusk"} }
for _, b in ipairs(blobs) do D.lit(D.ell(b[1], b[2], 4, 3.5), b[3], 2.5) end
-- drip
D.fill(c:rect(18, 27, 19, 31), "#e8493b") D.fill(c:rect(18, 32, 19, 33), "#b52e3f") c:px(18, 28, "#ff8a5c")
-- brush through hole
local h = c:line({ {58, 6}, {33, 44} }, 3)
D.lit(h, "wood", 1.5)
D.fill(c:poly{ {32, 43}, {38, 42}, {34, 52}, {28, 54}, {30, 48} }, "#f5809f")
D.fill(c:poly{ {32, 45}, {35, 44}, {33, 50}, {30, 52} }, "#ffc4d8")
D.fill(c:line({ {48, 21}, {42, 31} }, 5), "#aaa9b8") D.fill(c:line({ {47, 21}, {42, 29} }, 2), "#e2e0e6")
D.fin()
