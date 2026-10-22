local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(32,49.5,21,6.5)
local top = c:ellipse(32,47,16,3.5)
local A, Bm = "moss", GV.ramp("#4a8a3e")
-- dome of six clumps, outer first, middle tallest and in front
local parts = {
  { "soil", mound, GV.ramp("#8c4a1a") },
  { "top", top, GV.ramp("#a5663a"), { gloss = false } },
  { "c1", c:ellipse(15,42,6,5.5), Bm },
  { "c6", c:ellipse(49,42,6,5.5), Bm },
  { "c2", c:ellipse(22,36,7,6.5), A },
  { "c5", c:ellipse(42,36,7,6.5), A },
  { "c3", c:ellipse(28,29,7,7), Bm },
  { "c4", c:ellipse(37,27,7,7.5), A },
}
local p = c:build(parts)
-- leaf veins (short dark notches)
for _, v in ipairs({ {15,44},{49,44},{22,39},{42,39},{28,32},{37,30} }) do
  c:px(v[1], v[2], "#2f5a2a"); c:px(v[1], v[2]+1, "#2f5a2a")
end
-- four blossoms: 4x4 petals, 2px light centre
local function bloom(x, y)
  c:paint({ ".bb.", "bccb", "bccb", ".bb." }, x, y, { b = "#7a5cc0", c = "#a894dc" })
  c:px(x+1, y+1, "#d8c8f4")
end
bloom(34,18); bloom(22,30); bloom(42,33); bloom(27,24)
local t = c:save(O .. "aseprite/ph/stage-herb-4.aseprite", O .. "png/ph/stage-herb-4.png")
print(GV.report(t))
