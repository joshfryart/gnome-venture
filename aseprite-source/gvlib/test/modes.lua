-- test/modes.lua : smoke test of icon, bust, scene (2x) modes
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
-- icon
local c = GV.canvas{ mode = "icon" }
c:part(c:rrect(14, 16, 49, 47, 8), GV.R.water, { stitch = true })
c:part(c:ellipse(31.5, 31.5, 8), GV.R.gold)
c:button(30, 30)
print("icon  ", GV.report(c:save(nil, D .. "test/mode-icon.png")))
-- bust
local b = GV.canvas{ mode = "bust" }
b:part(b:poly({ {6, 100}, {14, 78}, {66, 78}, {74, 100} }), GV.R.water)
b:part(b:ellipse(40, 60, 18, 17), GV.R.moss)
b:eye(28, 53); b:eye(47, 53)
b:seam({ {40, 80}, {40, 99} }); b:button(39, 78)
print("bust  ", GV.report(b:save(nil, D .. "test/mode-bust.png")))
-- scene, 100x75 grid written at 2x
local s = GV.canvas{ mode = "scene", w = 100, h = 75, out = 2 }
s:bands(nil, { "#a9d6ea", "#8fcbd8", "#6fb3cf", "#5a9ac0", "#3f8fb0" })
s:part(s:rect(0, 55, 99, 74), GV.R.leaf, { gloss = false })
s:part(s:ellipse(50, 45, 14, 11), GV.R.petal)
s:limb({ {30, 56}, {28, 64} })
s:seam({ {0, 56}, {99, 56} }, { free = true })
print("scene ", GV.report(s:save(nil, D .. "test/mode-scene.png")))
