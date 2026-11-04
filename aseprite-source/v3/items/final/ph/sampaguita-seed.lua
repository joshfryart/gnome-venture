-- sampaguita-seed (first draft, Sonnet). Four tiny blackish-plum jasmine seeds (pale pinprick hilum) on a glossy ovate
-- jasmine leaf scrap; the right seed sprouted: a twining stem, two opposite ovate leaves and a white five-petal star flower.
-- quirk: the twining stem curls round a tiny tendril loop.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sampaguita-seed")
local pi = math.pi, math.floor
local floor = math.floor
local LF = A.R("#3f9150")
A.scrap(c, 4, 56, 56, 50, 10, LF, { 7, 12, 17, 22, 27, 32, 37, 42 })
local sd = A.R("#4a2c4a")
for _, s in ipairs{ { 14, 53, 2.5, 1.8, .2 }, { 22, 55, 2.4, 1.8, -.4 }, { 31, 52, 2.5, 1.8, .5 }, { 41, 50, 2.6, 1.9, -.2 } } do
  A.seed(c, s[1], s[2], s[3], s[4], s[5], sd, LF[1], "#e8d8f0")
  c:px(s[1] + 2, s[2] + 1, "#d8c8a0")
end
-- twining stem (S curve) with a curl
local p = A.curve({ { 41, 47 }, { 34, 40 }, { 46, 32 }, { 40, 22 } }, 40)
for i, q in ipairs(p) do A.sph(c, floor(q[1] + .5), floor(q[2] + .5), 1.2, "#6a9a48", { nospec = true }) end
-- tendril curl off the stem
A.bezLine(c, { { 44, 33 }, { 52, 31 }, { 53, 38 }, { 49, 38 } }, "#8ec060", 20)
A.blade(c, 40, 29, 27, 26, 3.2, "#3f9150", { veins = { 4, 8 }, slant = 2 })
A.blade(c, 41, 28, 54, 22, 3.2, "#3f9150", { veins = { 4, 8 }, slant = 2 })
A.blade(c, 40, 22, 33, 15, 2.3, "#62ad55", { veins = { 3 }, slant = 2 })
-- white star flower
for i = 0, 4 do
  local a = -pi / 2 + i * 2 * math.pi / 5
  local px, py = 40 + math.cos(a) * 3.5, 12 + math.sin(a) * 3.5
  A.sph(c, floor(px + .5), floor(py + .5), 2, "#f4efe4", { nospec = true })
end
c:px(40, 12, "#ffe38a") c:px(40, 11, "#ffe38a") c:px(39, 12, "#f5b82e")
A.fin()
