-- sauerkraut (first draft, Sonnet). A tall glass preserving jar with a gold screw lid, packed with pale yellow-green
-- shredded cabbage in wavy strands, caraway seeds, brine line and a flat stone weight on top.
-- quirk: three fizzing bubbles rise through the brine and one has popped a cabbage curl above the weight.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sauerkraut")
local floor = math.floor
c:groundShadow(32, 56, 17, 3)
local body = c:rrect(16, 17, 47, 55, 5)
A.lit(c, body, A.R("#b6f0e0"), 3, { amb = .15, wrap = .4 })
-- glass interior = cabbage
local inner = c:rrect(18, 19, 45, 53, 4)
local cab = A.R("#c8d878")
A.lit(c, inner, cab, 5, { amb = .12, wrap = .3 })
-- shreds: wavy light/dark strands
inner:each(function(x, y)
  local w = floor(3 * math.sin(x * .55 + y * .35)) + y
  local m = w % 5
  if m == 0 then c:px(x, y, cab[6]) elseif m == 2 then c:px(x, y, cab[2]) end
end)
-- caraway seeds
for _, p in ipairs{ { 24, 36 }, { 33, 44 }, { 39, 30 }, { 28, 49 }, { 41, 47 } } do c:px(p[1], p[2], "#6a4a2a") c:px(p[1] + 1, p[2] + 1, "#6a4a2a") end
-- brine line at top + weight
c:fillMask(c:rect(18, 22, 45, 22), "#e4f6d0")
local wt = c:ellipse(32, 24, 11, 3)
A.lit(c, wt, A.R("#aaa9b8"), 2, { amb = .1 })
-- glass left shine + right shade
for y = 21, 51 do c:px(19, y, "#f4fffc") c:px(44, y, "#7aa8a8") end
-- bubbles
A.sph(c, 24, 28, 1.6, "#e4f6ff", { nospec = true }) c:px(24, 27, "#fff4d6")
A.sph(c, 38, 40, 1.9, "#e4f6ff", { nospec = true }) c:px(37, 39, "#fff4d6")
A.sph(c, 29, 40, 1.2, "#e4f6ff", { nospec = true })
-- neck + lid
local neck = c:rect(20, 12, 43, 18)
A.lit(c, neck, A.R("#b6f0e0"), 2, { amb = .15, wrap = .4 })
local lid = c:rrect(18, 5, 45, 13, 2)
A.lit(c, lid, A.R("#f5b82e"), 3, { amb = .08 })
for x = 21, 43, 3 do c:px(x, 8, "#d98322") c:px(x, 9, "#d98322") end
c:px(22, 6, "#ffe38a") c:px(23, 6, "#ffe38a")
-- popped cabbage curl poking from beside lid
A.bezLine(c, { { 46, 15 }, { 52, 10 }, { 54, 18 }, { 50, 19 } }, "#c8d878", 20)
A.bezLine(c, { { 46, 16 }, { 52, 11 }, { 54, 19 }, { 50, 20 } }, "#8ea850", 20)
A.fin()
