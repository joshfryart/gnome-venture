local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#8fcbd8")
local jar = c:rrect(13, 19, 50, 55, 8)
local neck = c:rrect(21, 13, 42, 21, 2)
local cork = c:poly({ {22, 5}, {42, 5}, {40, 15}, {24, 15} })
local seeds = c:rrect(16, 31, 47, 52, 6)
local label = c:ellipse(31.5, 39, 9.5, 9.5)
local p = c:build{
  { "jar",   jar,   glass, { gloss = false } },
  { "seeds", seeds, GV.ramp("#9a6b3f"), { gloss = false, rim = false } },
  { "neck",  neck,  glass, { gloss = false } },
  { "cork",  cork,  "wood" },
  { "label", label, "cream" },
}
-- seed stripes: diamond pattern
for y = 33, 51, 3 do
  for x = 17, 47, 4 do
    local xx = x + ((y // 3) % 2) * 2
    if seeds:has(xx, y) and not label:grow(1):has(xx, y) then
      c:px(xx, y, "#f1ece0"); if seeds:has(xx, y + 1) and not label:grow(1):has(xx, y+1) then c:px(xx, y + 1, "#3d2a1c") end
    end
  end
end
-- fill line highlight
for x = 18, 45 do if not label:grow(1):has(x, 31) then c:px(x, 31, "#c9a96e") end end
-- cork grain
c:paint({ "a..a..a", ".a..a.." }, 28, 8, { a = "#a8582f" })
c:paint({ "a...a" }, 29, 12, { a = "#a8582f" })
-- sunflower on label
local ring = c:ellipse(31.5, 39.5, 6.5, 6.5)
c:fill(ring, GV.R.gold.base)
for _, d in ipairs({ {-6,-6},{6,-6},{-6,6},{6,6},{0,-7},{0,7},{-7,0},{7,0} }) do end
c:paint({ "a.....a", ".......", ".......", ".......", ".......", ".......", "a.....a" }, 28, 36, { a = "#f4f0e0" })
c:fill(c:ellipse(31.5, 39.5, 6.5, 6.5):cut(c:ellipse(31.5, 39.5, 5.5, 5.5)):clip(c:rect(32, 40, 63, 63)), GV.R.gold.shade)
c:fill(c:ellipse(31.5, 39.5, 3, 3), "#7a3a14")
c:px(26, 34, GV.R.gold.gloss); c:px(27, 34, GV.R.gold.gloss)
c:px(30, 38, "#b8661a"); c:px(33, 40, "#5e2f1e")
-- glass gloss: long vertical comma + dot
c:fill(c:rect(17, 23, 18, 38), "#e6f8ef")
c:fill(c:rect(19, 22, 19, 26), "#e6f8ef")
c:px(17, 41, "#e6f8ef"); c:px(18, 41, "#e6f8ef")
c:px(45, 24, "#e6f8ef")
c:fill(c:rect(24, 15, 39, 15), "#5e2f1e")
c:ground(32, 57, 17, 2.5, "#6a4528")
local t = c:save(O .. "aseprite/ph/sunflower-seed.aseprite", O .. "png/ph/sunflower-seed.png")
print(GV.report(t))
