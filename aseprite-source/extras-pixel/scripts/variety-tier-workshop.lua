-- variety-tier-workshop.lua : stoptiers/workshop-1..4.png, 96x96 icon-mode Stitched Toy.
-- 1 workbench, 2 forge corner, 3 crane and pulley, 4 makers' hall.
-- Family: wood + soil bases, stone (iron), gold gear, ember/red accents. Drawn in a 76x76 box (see variety-tier-lib.lua).
-- Run: Aseprite -b --script-param root=<repo>/aseprite-source/ --script-param out=<dir>/ --script variety-tier-workshop.lua
local P = app.params
local ROOT = P.root or "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local OUT = P.out or (ROOT .. "extras-pixel/out/")
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local T = dofile(ROOT .. "extras-pixel/scripts/variety-tier-lib.lua")
local IRON = GV.ramp("#5b6470")
local DIRON = GV.ramp("#434a56")
local STONE = GV.ramp("#8b8f96")
local WOODL = GV.ramp("#d9a660")
local WOODD = GV.ramp("#8a4f2a")
local PLASTER = GV.ramp("#c9a96e")
local function save(c, n) T.save(c.raw, GV, ROOT, OUT, "workshop", n) end

-- 1 workbench
do
  local c = T.canvas(GV)
  c:part(c:rect(6, 44, 15, 75), WOODD)
  c:part(c:rect(60, 44, 69, 75), WOODD)
  c:part(c:rect(6, 58, 69, 64), WOODD)
  c:part(c:rrect(0, 34, 75, 46, 3), "wood")
  c:seam({ { 4, 43 }, { 71, 43 } })
  -- red toolbox with a gold handle
  c:part(c:rrect(3, 18, 23, 34, 2), "red")
  c:part(c:rect(9, 14, 17, 18), GV.R.gold, { flat = true })
  -- mallet
  c:part(c:rect(32, 12, 36, 34), WOODL, { flat = true })
  c:part(c:rrect(25, 8, 44, 20, 2), IRON)
  -- gear
  T.gear(c, 58, 24, 7)
  save(c, 1)
end

-- 2 forge corner
do
  local c = T.canvas(GV)
  c:part(c:rect(12, 0, 31, 28), DIRON)
  c:part(c:rrect(0, 22, 48, 75, 4), STONE)
  c:part(c:rrect(8, 38, 40, 75, 9):clip(c:rect(0, 0, 75, 75)), GV.ramp("#3d2a1c"), { flat = true, rim = false, contact = false })
  c:part(c:ellipse(24, 68, 11, 12):clip(c:rect(0, 0, 75, 73)), "flame", { gloss = false })
  c:part(c:ellipse(24, 70, 5, 7):clip(c:rect(0, 0, 75, 73)), GV.ramp("#f5cf6a"), { flat = true })
  -- anvil
  c:part(c:rect(54, 62, 74, 75), DIRON)
  c:part(c:rect(58, 54, 70, 64), DIRON)
  c:part(c:poly({ { 46, 44 }, { 75, 44 }, { 75, 55 }, { 50, 55 } }), IRON)
  c:part(c:rect(58, 38, 72, 43), GV.R.flame, { flat = true })
  c:px(56, 33, "#f5cf6a"); c:px(64, 31, "#f5cf6a"); c:px(72, 33, "#f5cf6a")
  save(c, 2)
end

-- 3 crane and pulley
do
  local c = T.canvas(GV)
  c:part(c:rrect(0, 66, 75, 75, 3), WOODD)
  c:seam({ { 4, 71 }, { 71, 71 } })
  c:part(c:rect(0, 34, 9, 60), IRON)
  c:part(c:line({ { 22, 62 }, { 38, 20 } }, 5), "wood")
  c:part(c:rect(12, 10, 22, 68), "wood")
  c:part(c:rect(12, 6, 68, 16), "wood")
  c:button(14, 8)
  T.gear(c, 58, 26, 6)
  c:part(c:rect(57, 32, 59, 46), GV.R.cream, { flat = true })
  c:part(c:rrect(46, 46, 72, 64, 2), WOODL)
  c:part(c:rect(57, 46, 61, 64), GV.R.gold, { flat = true })
  c:seam({ { 48, 56 }, { 70, 56 } })
  save(c, 3)
end

-- 4 makers' hall
do
  local c = T.canvas(GV)
  c:part(c:rect(54, 2, 64, 26), IRON)
  c:part(c:rrect(4, 28, 71, 75, 3), PLASTER)
  c:part(c:rect(4, 63, 71, 75), STONE, { gloss = false })
  c:part(c:poly({ { 0, 36 }, { 38, 0 }, { 76, 36 }, { 76, 40 }, { 0, 40 } }), "red")
  c:seam({ { 6, 44 }, { 69, 44 } })
  T.gear(c, 38, 22, 6)
  c:part(c:rrect(29, 48, 45, 75, 7):clip(c:rect(0, 0, 75, 75)), WOODD)
  c:button(34, 54)
  c:part(c:rect(10, 48, 22, 60), GV.R.glass, { flat = true })
  c:part(c:rect(52, 48, 64, 60), GV.R.glass, { flat = true })
  save(c, 4)
end
