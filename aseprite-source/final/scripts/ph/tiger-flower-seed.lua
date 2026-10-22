local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- mouth rim (back lip) and dark opening
local rim = c:ellipse(32, 24, 17, 4.5)
local hole = c:ellipse(32, 24, 14, 2.5)
-- bud popping out
local bud = c:ellipse(31, 18, 8.5, 7)
local leaf = c:ascii({
  "..xxx",
  ".xxxxx",
  "xxxxxx",
  "xxxxx.",
  ".xxx..",
}, 37, 10)
-- cone front: triangle plus lower half of the rim
local cone = c:poly({ {15, 24}, {50, 24}, {33, 50} })
cone:add(c:ellipse(32, 24, 17, 4.5):cut(c:rect(0, 0, 63, 25)))
-- twisted curl at the tip
local curl = c:ascii({
  "xxxx",
  ".xxx",
  "xxx.",
  "xxxx",
  ".xx.",
}, 30, 48)

c:build{
  { "rim",  rim,  "#f4f0e0", { gloss = false } },
  { "hole", hole, "#7a4a1f", { flat = true } },
  { "bud",  bud,  GV.ramp("#e46a9b", { shade = "#c0466e", deep = "#ae2a2a" }) },
  { "leaf", leaf, "#7ab55c", { gloss = false } },
  { "curl", curl, "#d9a660", { gloss = false } },
  { "cone", cone, "#f1ece0" },
}
-- petal split lines on the bud
c:paint({ "p", "p", ".p" }, 30, 12, { p = "#ae2a2a" })
-- fold crease and its seam
c:fill(c:line({ {24, 30}, {32, 47} }, 1), "#d9a660")
c:seam({ {26, 30}, {33, 45} })

local t = c:save(O .. "aseprite/ph/tiger-flower-seed.aseprite", O .. "png/ph/tiger-flower-seed.png")
print(GV.report(t))
