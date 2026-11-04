-- rose-arch (first draft, Sonnet). A slim wooden garden arch on two posts, climbed by a vine with leaves and a
-- scatter of glossy red and pink roses.
-- quirk: a tiny bee sits on the rose at the crown of the arch.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rose-arch")
c:groundShadow(15, 58, 7, 2) c:groundShadow(49, 58, 7, 2)
A.rod(c, 15, 22, 15, 57, 1.6, "wood", { amb = .1 })
A.rod(c, 49, 22, 49, 57, 1.6, "wood", { amb = .1 })
local arch = A.curve({ { 15, 24 }, { 15, 0 }, { 49, 0 }, { 49, 24 } }, 50)
A.lit(c, A.sweepM(arch, function() return 1.6 end), "wood", 1.6, { amb = .1 })
-- lattice rungs
for y = 30, 52, 7 do A.ln(c, 13, y, 17, y + 1, "#864c33") A.ln(c, 47, y, 51, y + 1, "#864c33") end
-- vine
local vine = A.curve({ { 14, 56 }, { 10, 30 }, { 18, 4 }, { 32, 6 } }, 40)
A.lit(c, A.sweepM(vine, function() return .8 end), "moss", 1, { amb = .1 })
local vine2 = A.curve({ { 50, 54 }, { 56, 32 }, { 46, 6 }, { 32, 7 } }, 40)
A.lit(c, A.sweepM(vine2, function() return .8 end), "moss", 1, { amb = .1 })
-- leaves
for _, l in ipairs{ { 12, 40, 6, 36 }, { 17, 30, 22, 26 }, { 15, 14, 9, 10 }, { 22, 7, 25, 2 }, { 50, 42, 56, 38 }, { 47, 28, 41, 25 }, { 48, 14, 54, 11 }, { 40, 7, 38, 2 }, { 16, 48, 22, 45 }, { 50, 52, 44, 49 } } do
  A.blade(c, l[1], l[2], l[3], l[4], 2.2, "moss", { veins = { 2 }, slant = 2 })
end
-- roses
for i, r in ipairs{ { 14, 34, 3, "ember" }, { 16, 19, 2.6, "petal" }, { 25, 6, 2.8, "ember" }, { 32, 6, 3, "petal" }, { 41, 7, 2.6, "ember" }, { 50, 19, 2.8, "petal" }, { 49, 36, 3, "ember" }, { 15, 49, 2.6, "petal" }, { 50, 50, 2.4, "ember" } } do
  local rp = A.R(r[4])
  A.sph(c, r[1], r[2], r[3], rp, {})
  c:px(r[1], r[2], rp[2]) c:px(r[1] + 1, r[2] - 1, rp[2]) c:px(r[1] - 1, r[2] + 1, rp[3])
end
-- bee on crown rose (32,6)
c:fillMask(c:rect(35, 2, 37, 3), "#f5b82e") c:px(36, 2, "#2b1c26") c:px(36, 3, "#2b1c26") c:px(35, 1, "#fff4d6") c:px(36, 1, "#e4f6ff")
A.fin()
