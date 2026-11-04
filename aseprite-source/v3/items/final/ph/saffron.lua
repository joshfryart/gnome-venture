-- saffron (first draft, Sonnet). A violet crocus with veined petals, a yellow anther pair and three long
-- crimson stigma threads curling over the lip, a pale stem, two white-striped grass leaves and a small corm.
-- quirk: a dew drop sits on the front petal.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("saffron")
local floor = math.floor
A.blade(c, 32, 57, 12, 30, 2.4, "moss", { veins = {}, slant = 2 })
A.blade(c, 32, 57, 53, 30, 2.4, "moss", { veins = {}, slant = 2 })
A.sph(c, 32, 56, 4.2, "wood", { spec = "#e8b982" })
A.rod(c, 32, 56, 32, 38, 1.1, "#d8e8b0", { amb = .15 })
local pet = { { 24, 25, 4.6, 10, -.5, "#5a459e" }, { 40, 25, 4.6, 10, .5, "#5a459e" }, { 32, 19, 4.6, 10, 0, "#6a55b0" },
  { 27, 29, 4.8, 10, -.22, "#8a6fd0" }, { 37, 29, 4.8, 10, .22, "#8a6fd0" }, { 32, 31, 4.6, 9, 0, "#9a82e0" } }
for _, p in ipairs(pet) do
  local m = A.ell(p[1], p[2], p[3], p[4], p[5])
  A.lit(c, m, p[6], 2.2, { amb = .1 })
  A.ln(c, p[1], floor(p[2] - p[4] * .5), p[1], floor(p[2] + p[4] * .6), "#35295f", m)
end
for _, p in ipairs{ { 29, 28 }, { 35, 28 }, { 32, 30 } } do c:px(p[1], p[2], "#c9b2f0") end
c:fillMask(c:rect(30, 33, 34, 35), "#f5b82e")
c:px(31, 34, "#8f4a1f")
-- stigmas
for _, th in ipairs{ { { 31, 28 }, { 28, 20 }, { 22, 14 }, { 17, 19 } }, { { 32, 28 }, { 32, 18 }, { 34, 10 }, { 37, 7 } }, { { 33, 28 }, { 37, 20 }, { 43, 15 }, { 46, 20 } } } do
  local pts = A.curve(th, 20)
  A.lit(c, A.sweepM(pts, function() return .6 end), "ember", 1, { amb = .2, nospec = true })
  local e = pts[#pts] c:px(floor(e[1]), floor(e[2]), "#ff8a5c")
end
-- dew
A.sph(c, 37, 33, 1.8, "#b6f0e0", { spec = "#fff4d6" })
A.fin()
