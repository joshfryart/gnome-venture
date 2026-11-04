-- sago (first draft, Sonnet). A wooden bowl heaped with glossy pearly sago grains (cream with a faint pink
-- blush), a long wooden spoon leaning in the heap.
-- quirk: a single pearl has rolled out of the bowl and leaves two motion ticks behind.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("sago")
local floor = math.floor
c:groundShadow(32, 58, 22, 3)
local bowl = c:ellipse(31.5, 42, 22, 15):clip(c:rect(0, 38, 63, 63))
A.lit(c, bowl, "wood", 5, { amb = .1 })
for x = 11, 52 do if bowl:has(x, 39) then c:px(x, 39, "#51302b") end end
for _, y in ipairs{ 46, 52 } do for x = 9, 54 do if bowl:has(x, y) then c:px(x, y, "#864c33") end end end
-- heap
local dome = c:ellipse(31.5, 38, 18, 12):clip(c:rect(0, 0, 63, 40))
local pr = A.R("#f0d8c0")
local i = 0
for y = 28, 40, 3 do
  i = i + 1
  for x = 14 + (i % 2) * 2, 50, 3.6 do
    local cx, cy = floor(x), y + floor(A.hash(x, y, 3) * 2)
    if dome:has(cx, cy) then A.sph(c, cx, cy, 1.9, pr, { nospec = A.hash(cx, cy, 8) < .5, spec = "#ffffff" and "#fffbf0" }) end
  end
end
-- spoon
A.rod(c, 50, 10, 38, 34, .9, "#d9a070", { amb = .1 })
A.lit(c, A.ell(51, 8, 3.2, 4.2, -.4), "#e8b982", 1.6)
-- runaway pearl
A.sph(c, 56, 53, 2.2, pr, { spec = "#fffbf0" })
c:px(52, 52, "#74758c") c:px(53, 55, "#74758c")
A.fin()
