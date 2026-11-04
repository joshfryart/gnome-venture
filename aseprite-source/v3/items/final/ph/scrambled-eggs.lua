-- scrambled-eggs (first draft, Sonnet). A round white plate with a blue rim ring, heaped with soft buttery yellow
-- curds (lumpy overlapping spheres), flecks of green chive and black pepper, a curl of steam.
-- quirk: a bit of eggshell sits on top of the pile like a tiny hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("scrambled-eggs")
local floor = math.floor
c:groundShadow(32, 55, 25, 4)
local plate = c:ellipse(32, 46, 26, 9)
A.lit(c, plate, A.R("#f4efe4"), 3, { amb = .08 })
c:fillMask(c:ellipse(32, 45, 20, 6.5), "#e0e8f0")
local ring = c:ellipse(32, 45, 23, 7.8):cut(c:ellipse(32, 45, 21, 6.8))
c:fillMask(ring, "#8bc4ea")
-- curds
local y = A.R("#f5d040")
local blobs = { { 20, 40, 7 }, { 30, 36, 8 }, { 42, 39, 7.5 }, { 26, 31, 6 }, { 37, 30, 6.5 }, { 46, 43, 5 }, { 15, 44, 5 }, { 32, 42, 6 } }
for _, b in ipairs(blobs) do
  A.sph(c, b[1], b[2], b[3], y, { nospec = true })
  c:px(floor(b[1] - b[3] * .4), floor(b[2] - b[3] * .5), "#fff0a0") c:px(floor(b[1] - b[3] * .4) + 1, floor(b[2] - b[3] * .5), "#fff0a0")
end
for _, p in ipairs{ { 24, 34 }, { 35, 38 }, { 44, 41 }, { 28, 40 }, { 18, 41 }, { 40, 33 } } do c:px(p[1], p[2], "#5fa04a") c:px(p[1] + 1, p[2], "#7cc35a") end
for _, p in ipairs{ { 26, 36 }, { 33, 33 }, { 42, 37 }, { 21, 43 } } do c:px(p[1], p[2], "#2b1c26") end
-- steam
A.bezLine(c, { { 28, 24 }, { 24, 18 }, { 32, 14 }, { 28, 6 } }, "#fff4d6", 20)
A.bezLine(c, { { 38, 24 }, { 34, 18 }, { 42, 14 }, { 38, 8 } }, "#e4f6ff", 20)
-- eggshell hat
local hat = c:ellipse(36, 23, 5, 3.4):clip(c:rect(0, 0, 63, 24))
hat:add(c:rect(32, 22, 40, 23))
A.lit(c, hat, A.R("#f0e0c0"), 2, {})
for _, x in ipairs{ 32, 34, 36, 38, 40 } do c:px(x, 24, "#f0e0c0") end
c:px(34, 21, "#fff4d6")
A.fin()
