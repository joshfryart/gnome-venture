-- compost_bin-2 (tier 2, Opus single pass). The bin grows tall: square posts with a centre stile, a top rail and two
-- bottom boards, and a galvanised chicken-wire window between them so the layered compost shows through.
-- Material: bevelled weathered-oak planks with grain + knot, diamond wire mesh lit upper-left with a bright twist at
-- each crossing, compost strata behind the mesh, AO under the rail and where the heap sits.
-- quirk: a little hand-stitched red pennant flies from the left post.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new2("compost_bin-2")
local W, S = A.WOODG, A.STEEL
c:groundShadow(32, 57, 23, 2)
-- pennant (behind the heap): stick + flag
for y = 9, 20 do c:px(13, y, y < 12 and W[5] or W[4]) c:px(14, y, W[2]) end
A.map(c, {
  "hhb.....",
  "hbbbb...",
  "bbbbbbb.",
  "bbbbsss.",
  "bsss....",
}, 15, 9, { h = "#ff8a5c", b = "#e8493b", s = "#b52e3f" })
c:px(15, 13, "#6e2038") c:px(16, 13, "#6e2038")
-- heap
local hp = A.heap(c, 32, 22, 17, 10, { {25,16,"peel"}, {34,14,"egg"}, {29,19,"twig"}, {38,18,"leaf"}, {21,20,"crumb"}, {42,19,"crumb"} }, { seed = 9 })
-- compost strata behind the mesh
local win = c:rect(15, 27, 48, 41)
win:each(function(x, y)
  local band = (y + (X.hash(x, 0, 2) > 0.7 and 1 or 0)) % 5
  local col = (band == 0) and A.SOIL[4] or (band == 3 and A.SOIL[1] or A.SOIL[2])
  if X.hash(x, y, 8) > 0.92 then col = A.SOIL[5] end
  c:px(x, y, col)
end)
c:px(20, 33, "#ee6c22") c:px(21, 33, "#a2332e") c:px(41, 37, "#e9d8b4") c:px(27, 29, "#45954c")
-- wire mesh: diamonds, lit wire upper-left
win:each(function(x, y)
  local a, b = (x + y) % 4, (x - y) % 4
  if a == 0 and b == 0 then c:px(x, y, S[6])
  elseif a == 0 then c:px(x, y, (x + y) < 66 and S[5] or S[4])
  elseif b == 0 then c:px(x, y, (x + y) < 66 and S[4] or S[3]) end
end)
-- AO row under the top rail onto the mesh
for x = 15, 48 do c:px(x, 27, A.SOIL[1]) end
-- top rail + bottom boards
A.plank(c, 15, 22, 48, 26, W, { seed = 4 })
A.plank(c, 15, 42, 48, 46, W, { seed = 6 })
A.plank(c, 15, 48, 48, 52, W, { seed = 8 })
for x = 15, 48 do c:px(x, 47, A.SOIL[1]) end
for x = 17, 46 do if hp:has(x, 21) then c:px(x, 21, A.SOIL[1]) end end
-- centre stile over the mesh
A.plank(c, 30, 27, 33, 41, W, { seed = 10, R = 1.3 })
for y = 27, 41 do c:px(29, y, A.SOIL[1]) end
-- posts
A.plank(c, 11, 18, 14, 57, W, { seed = 2, cap = true, R = 1.4 })
A.plank(c, 49, 18, 52, 57, W, { seed = 3, cap = true, R = 1.4 })
for _, y in ipairs{ 22, 42, 48 } do for yy = y, y + 4 do c:px(15, yy, W[2]) c:px(48, yy, W[2]) end
  A.nail(c, 13, y + 2) A.nail(c, 51, y + 2) end
for y = 27, 41 do c:px(15, y, A.SOIL[1]) end
A.save2(c, "compost_bin-2")
