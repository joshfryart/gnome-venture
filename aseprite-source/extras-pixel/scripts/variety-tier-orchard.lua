-- variety-tier-orchard.lua : stoptiers/orchard-1..4.png, 96x96 icon-mode Stitched Toy.
-- Subjects: 1 picking ladders, 2 cider press, 3 grafting bench, 4 harvest barn.
-- Family: wood bases, moss/leaf canopy, red apples, gold thread. Drawn in a 76x76 box (see variety-tier-lib.lua).
local P = app.params
local ROOT = P.root or "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local OUT = P.out or (ROOT .. "extras-pixel/out/")
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local T = dofile(ROOT .. "extras-pixel/scripts/variety-tier-lib.lua")
local WOODL = GV.ramp("#d9a660")
local WOODD = GV.ramp("#8a4f2a")
local BARN = GV.ramp("#c0392b")
local CREAM = GV.ramp("#f1ece0", { pale = true })
local function save(c, n) T.save(c.raw, GV, ROOT, OUT, "orchard", n) end
local function apple(c, x, y, r)
  c:part(c:ellipse(x, y, r, r), "red", { gloss = false })
  c:px(x - 1, y - r, GV.R.moss.deep)
  c:px(x - 2, y - 1, GV.R.red.gloss)
end

-- 1 picking ladders
do
  local c = T.canvas(GV)
  c:part(c:rect(27, 34, 39, 75), "wood")
  c:part(c:ellipse(36, 24, 36, 23), "moss", { stitch = false })
  apple(c, 14, 20, 4); apple(c, 40, 12, 4); apple(c, 30, 32, 4); apple(c, 58, 8, 4)
  -- ladder leaning on the canopy: two rails and rungs
  local function lx(x0, y) return x0 - (75 - y) * 0.06 end
  c:part(c:line({ { 50, 75 }, { lx(50, 22), 22 } }, 4), WOODD)
  c:part(c:line({ { 71, 75 }, { lx(71, 22), 22 } }, 4), WOODD)
  for i = 0, 4 do
    local y = 29 + i * 11
    c:part(c:line({ { lx(50, y) + 1, y }, { lx(71, y), y } }, 3), WOODL, { flat = true })
  end
  -- basket with apples
  c:part(c:rrect(0, 56, 24, 75, 4), WOODL)
  c:seam({ { 3, 66 }, { 21, 66 } })
  apple(c, 6, 54, 4); apple(c, 14, 52, 4); apple(c, 21, 55, 4)
  save(c, 1)
end

-- 2 cider press
do
  local c = T.canvas(GV)
  c:part(c:rect(8, 6, 17, 58), WOODD)
  c:part(c:rect(59, 6, 68, 58), WOODD)
  c:part(c:rect(4, 4, 72, 15), "wood")
  c:button(6, 6)
  c:part(c:rrect(2, 52, 73, 75, 4), WOODL)
  c:seam({ { 6, 60 }, { 69, 60 } })
  c:seam({ { 6, 69 }, { 69, 69 } })
  apple(c, 20, 49, 5); apple(c, 37, 47, 5); apple(c, 54, 49, 5)
  c:part(c:rect(32, 14, 44, 34), GV.R.gold)
  c:part(c:rrect(14, 30, 62, 39, 2), "wood")
  c:part(c:rect(20, 19, 56, 24), WOODD)
  save(c, 2)
end

-- 3 grafting bench
do
  local c = T.canvas(GV)
  c:part(c:rect(6, 50, 15, 75), WOODD)
  c:part(c:rect(60, 50, 69, 75), WOODD)
  c:part(c:rect(6, 62, 69, 67), WOODD)
  c:part(c:rrect(0, 44, 75, 56, 3), "wood")
  c:seam({ { 4, 53 }, { 71, 53 } })
  -- sapling in a pot, grafted join bound with gold twine
  c:part(c:rect(21, 14, 26, 36), "wood", { flat = true })
  c:part(c:ellipse(13, 15, 9, 6), "moss")
  c:part(c:ellipse(33, 9, 10, 7), "moss")
  c:part(c:ellipse(27, 21, 5, 4), "moss")
  c:part(c:rect(20, 26, 27, 30), GV.R.gold, { flat = true })
  apple(c, 36, 20, 4)
  c:part(c:rrect(11, 32, 36, 46, 3), GV.ramp("#b8452f"))
  -- knife
  c:part(c:poly({ { 44, 34 }, { 62, 34 }, { 70, 38 }, { 44, 42 } }), GV.ramp("#c9c5bc"))
  c:part(c:rect(40, 32, 50, 42), GV.R.red, { flat = true })
  -- roll of green grafting tape
  c:part(c:ellipse(60, 22, 7, 7), "moss")
  c:fill(c:ellipse(60, 22, 3, 3), "#2f5a2a")
  save(c, 3)
end

-- 4 harvest barn
do
  local c = T.canvas(GV)
  c:part(c:rrect(4, 26, 71, 75, 3), BARN)
  c:part(c:poly({ { 0, 30 }, { 38, 0 }, { 76, 30 }, { 76, 35 }, { 0, 35 } }), WOODD)
  c:seam({ { 6, 40 }, { 69, 40 } })
  c:part(c:rect(30, 14, 46, 26), GV.R.gold, { flat = true })   -- hay loft hatch
  c:part(c:rect(22, 44, 54, 75), CREAM)
  c:part(c:line({ { 24, 46 }, { 52, 74 } }, 3), WOODD, { flat = true })
  c:part(c:line({ { 52, 46 }, { 24, 74 } }, 3), WOODD, { flat = true })
  c:part(c:rect(37, 44, 39, 75), WOODD, { flat = true })
  c:part(c:rrect(57, 56, 75, 75, 2), WOODL)
  apple(c, 62, 54, 4); apple(c, 70, 54, 4)
  c:part(c:ellipse(4, 66, 7, 9), "moss", { stitch = false })
  save(c, 4)
end
