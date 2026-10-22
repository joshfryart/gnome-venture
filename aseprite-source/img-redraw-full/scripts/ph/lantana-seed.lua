local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- leaf poking out of the gathered top (behind)
local leaf = c:poly{ { 36, 20 }, { 40, 12 }, { 47, 7 }, { 49, 9 }, { 46, 16 }, { 39, 22 } }
-- puffy body sagging right
local body = c:ellipse(33, 41, 17, 14):add(c:ellipse(36, 46, 14, 9))
-- gathered frilly top: neck plus three ruffle points
local top = c:rrect(25, 20, 40, 28, 2)
top:add(c:poly{ { 21, 22 }, { 22, 13 }, { 27, 18 }, { 32, 11 }, { 37, 18 }, { 43, 13 }, { 44, 23 } })
local patch = c:ellipse(33, 43, 9, 8)
local p = c:build{
  { "leaf", leaf, GV.ramp("#58a03e") },
  { "body", body, "cream", { stitch = { side = "lit" } } },
  { "top", top, GV.ramp("#f4f0e0"), { light = body:copy():add(top) } },
  { "patch", patch, GV.ramp("#e3cfa6") },
  { "seed", c:ellipse(33, 43, 6, 5.5), GV.ramp("#7a5cc0", { shade = "#4e3a8a" }) },
}
-- leaf vein
c:line({ { 38, 19 }, { 46, 9 } }, 1):each(function(x, y) if p.leaf.m:has(x, y) and not p.top.m:has(x, y) then c:px(x, y, "#2e5a2c") end end)
-- fold lines in the ruffles and body
c:paint({ "f....", ".f...", ".f...", "..f.." }, 26, 16, { f = "#d6c9b6" })
c:paint({ "..f", ".f.", ".f.", "f.." }, 37, 16, { f = "#d6c9b6" })
c:paint({ ".f", ".f", "f.", "f." }, 21, 33, { f = "#d6c9b6" })
-- string around the neck with a bow
local s, sS = "#c9a96e", "#9a6b3f"
local band = c:rect(25, 24, 40, 25)
c:fill(band, s); c:fill(c:rect(25, 25, 40, 25), sS)
local loops = c:ellipse(28, 23, 3, 2):cut(c:ellipse(28, 23, 1, 0.5))
loops:add(c:ellipse(37, 23, 3, 2):cut(c:ellipse(37, 23, 1, 0.5)))
c:fill(loops, s)
c:fill(c:line({ { 31, 26 }, { 29, 31 } }, 2), s)
c:fill(c:line({ { 34, 26 }, { 37, 31 } }, 2), s)
c:fill(c:rect(31, 23, 34, 26), sS); c:fill(c:rect(32, 23, 33, 25), s)
-- stitching around the seed patch
c:stitch(p.patch.m)
local t = c:save(O .. "aseprite/ph/lantana-seed.aseprite", O .. "png/ph/lantana-seed.png")
print(GV.report(t))
