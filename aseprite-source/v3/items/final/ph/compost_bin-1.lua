-- compost_bin-1 (tier 1, Opus single pass). A low open slatted crate: two slim square corner posts with pale end
-- grain, three horizontal oak slats with gaps that show the dark compost inside, a crumbly dome heaped above.
-- Material: bevelled planks with grain and a knot, nail heads, AO under each slat and where the heap sits on the rim.
-- quirk: a snail is slowly climbing the right post.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new2("compost_bin-1")
local W = A.WOOD
c:groundShadow(32, 56, 22, 2)
-- heap
local hp = A.heap(c, 32, 33, 16, 11, { {24,27,"egg"}, {33,25,"peel"}, {28,31,"leaf"}, {37,29,"twig"}, {22,31,"crumb"}, {40,27,"crumb"} })
-- dark interior visible through the gaps
local inside = c:rect(15, 33, 48, 52)
c:fillMask(inside, A.SOIL[2])
for x = 15, 48 do if X.hash(x, 1, 3) > 0.6 then c:px(x, 40, A.SOIL[3]) end if X.hash(x, 2, 3) > 0.6 then c:px(x, 47, A.SOIL[3]) end end
-- slats (each casts a dark row on the gap below)
local ys = { 33, 41, 48 }
for i, y in ipairs(ys) do
  local m = A.plank(c, 15, y, 48, y + 4, W, { seed = i * 5 })
  if i < 3 then for x = 15, 48 do c:px(x, y + 5, A.SOIL[1]) end end
end
-- heap sits on the top slat: ambient row
for x = 17, 46 do if hp:has(x, 32) then c:px(x, 32, A.SOIL[1]) end end
-- posts in front of the slat ends
A.plank(c, 11, 29, 14, 56, W, { seed = 2, cap = true, R = 1.4 })
A.plank(c, 49, 29, 52, 56, W, { seed = 3, cap = true, R = 1.4, bias = nil })
-- AO where slats tuck behind the posts
for _, y in ipairs(ys) do for yy = y, y + 4 do c:px(15, yy, W[2]) c:px(48, yy, W[2]) end end
-- nails
for _, y in ipairs(ys) do A.nail(c, 13, y + 2) A.nail(c, 51, y + 2) end
-- quirk: snail on the right post
A.map(c, {
  "..s.s..",
  "..k.k..",
  "..ShhH.",
  ".SbbBhH",
  "SbBcbbh",
  "SbBBbbs",
  ".sSSSs.",
}, 49, 35, { k = "#2b1c26", s = "#a89a8c", S = "#d8cdbc", h = "#f5809f", H = "#ffc4d8", b = "#c94f84", B = "#7d2c5e", c = "#ffe2ec" })
A.save2(c, "compost_bin-1")
