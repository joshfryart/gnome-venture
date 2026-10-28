-- variety-tier-ferry.lua : stoptiers/ferry-1..4.png, 96x96 icon-mode Stitched Toy.
-- Subjects: 1 landing steps, 2 toll house, 3 second boat, 4 boatmen's hall.
-- Family: water band at the base, wood dock/hulls, stone steps, red lifebuoy and flag, gold coin/thread.
-- Drawn in a 76x76 box (see variety-tier-lib.lua).
local P = app.params
local ROOT = P.root or "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local OUT = P.out or (ROOT .. "extras-pixel/out/")
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local T = dofile(ROOT .. "extras-pixel/scripts/variety-tier-lib.lua")
local WOODL = GV.ramp("#d9a660")
local WOODD = GV.ramp("#8a4f2a")
local STONE = GV.ramp("#8b8f96")
local SLATE = GV.ramp("#2f6290")
local PLASTER = GV.ramp("#c9a96e")
local CREAM = GV.ramp("#f1ece0", { pale = true })
local RIP = "#c8ecdc"
local function save(c, n) T.save(c.raw, GV, ROOT, OUT, "ferry", n) end
local function water(c, y0, x0, x1)
  c:part(c:rrect(x0 or 0, y0, x1 or 75, 75, 4), "water", { stitch = false })
  for _, r in ipairs({ { 8, 7, 9 }, { 40, 12, 11 }, { 24, 17, 7 }, { 58, 8, 7 } }) do
    if y0 + r[2] <= 70 then c:fill(c:rect(r[1], y0 + r[2], r[1] + r[3], y0 + r[2] + 1), RIP) end
  end
end
local function buoy(c, x, y, r)
  c:part(c:ellipse(x, y, r, r), "red", { gloss = false })
  c:fill(c:ellipse(x, y, r - 4, r - 4), "#3f8fb0")
  c:fill(c:rect(x - 1, y - r, x + 1, y - r + 2), "#f1ece0")
  c:fill(c:rect(x - 1, y + r - 2, x + 1, y + r), "#f1ece0")
  c:fill(c:rect(x - r, y - 1, x - r + 2, y + 1), "#f1ece0")
  c:fill(c:rect(x + r - 2, y - 1, x + r, y + 1), "#f1ece0")
end

-- 1 landing steps
do
  local c = T.canvas(GV)
  c:part(c:rect(54, 8, 75, 20), STONE)
  c:part(c:rect(42, 20, 75, 31), STONE)
  c:part(c:rect(30, 31, 75, 42), STONE)
  c:part(c:rect(18, 42, 75, 53), STONE)
  -- mooring post with a rope
  c:part(c:rrect(2, 22, 13, 56, 3), "wood")
  c:seam({ { 3, 30 }, { 12, 30 } }); c:seam({ { 3, 34 }, { 12, 34 } })
  water(c, 52)
  save(c, 1)
end

-- 2 toll house
do
  local c = T.canvas(GV)
  c:part(c:rect(0, 50, 75, 62), "wood")
  c:seam({ { 3, 56 }, { 72, 56 } })
  c:part(c:rrect(2, 24, 44, 52, 2), PLASTER)
  c:part(c:poly({ { 0, 28 }, { 23, 4 }, { 46, 28 }, { 46, 32 }, { 0, 32 } }), "red")
  c:seam({ { 4, 36 }, { 42, 36 } })
  c:part(c:ellipse(23, 18, 6, 6), "gold", { flat = true })
  c:fill(c:ellipse(23, 18, 2, 2), "#b8661a")
  c:part(c:rrect(16, 38, 30, 52, 4):clip(c:rect(0, 0, 75, 52)), WOODD)
  -- toll bar across the dock, striped
  c:part(c:rect(62, 20, 71, 52), "wood")
  for i = 0, 3 do
    c:part(c:rect(38 + i * 8, 33, 38 + i * 8 + 7, 38), (i % 2 == 0) and "red" or CREAM, { flat = true })
  end
  c:part(c:rect(60, 28, 73, 33), GV.R.gold, { flat = true })
  water(c, 60)
  save(c, 2)
end

-- 3 second boat
do
  local c = T.canvas(GV)
  water(c, 46)
  -- far boat with a sail
  c:part(c:rect(50, 6, 53, 34), WOODD)
  c:part(c:poly({ { 54, 8 }, { 54, 32 }, { 72, 32 } }), "red")
  c:part(c:poly({ { 30, 34 }, { 75, 34 }, { 68, 48 }, { 38, 48 } }), WOODD)
  -- near boat
  c:part(c:poly({ { 2, 40 }, { 56, 40 }, { 48, 62 }, { 12, 62 } }), "wood")
  c:fill(c:rect(4, 40, 54, 42), "#e8a317")
  c:seam({ { 8, 50 }, { 50, 50 } })
  c:part(c:line({ { 18, 28 }, { 36, 50 } }, 3), WOODL, { flat = true })
  c:part(c:rect(14, 24, 20, 30), WOODD, { flat = true })
  c:part(c:rect(38, 28, 42, 40), CREAM, { flat = true })
  c:fill(c:rect(8, 63, 17, 64), RIP); c:fill(c:rect(50, 66, 61, 67), RIP); c:fill(c:rect(24, 68, 33, 69), RIP)
  save(c, 3)
end

-- 4 boatmen's hall
do
  local c = T.canvas(GV)
  c:part(c:rect(58, 0, 60, 14), WOODD)
  c:part(c:rect(60, 0, 72, 8), "red", { flat = true })
  c:part(c:rrect(4, 26, 71, 62, 3), "wood")
  c:seam({ { 8, 34 }, { 67, 34 } })
  c:part(c:poly({ { 0, 32 }, { 38, 4 }, { 76, 32 }, { 76, 36 }, { 0, 36 } }), SLATE)
  buoy(c, 38, 22, 7)
  c:part(c:rrect(30, 42, 46, 62, 6):clip(c:rect(0, 0, 75, 62)), WOODD)
  c:part(c:rect(10, 42, 22, 54), GV.R.glass, { flat = true })
  c:part(c:rect(54, 42, 66, 54), GV.R.glass, { flat = true })
  c:part(c:rect(0, 56, 75, 62), "wood")
  water(c, 64)
  c:part(c:poly({ { 40, 60 }, { 75, 60 }, { 69, 70 }, { 47, 70 } }), "wood")
  c:fill(c:rect(41, 60, 74, 61), "#e8a317")
  save(c, 4)
end
