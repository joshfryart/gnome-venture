local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local blue = GV.ramp("#5a86b8", { shade = "#2f6290" })
local lidr = GV.ramp("#8fcbd8")
local p = c:build{
  { "pennant", c:poly({ {46, 4}, {54, 19}, {38, 19} }), GV.ramp("#4a8a3e") },
  { "body", c:rrect(13, 28, 51, 55, 4), blue, { gloss = false } },
  { "lid", c:rrect(10, 17, 54, 29, 4), lidr },
  { "label", c:rrect(18, 33, 46, 51, 5), "cream", { gloss = false, contact = false } },
}
-- seam on lid join
c:seam({ {14, 28}, {50, 28} })
-- hinge
c:fill(c:rect(16, 27, 20, 31), "#2a3c6c")
c:px(17, 28, "#8fcbd8"); c:px(19, 30, "#8fcbd8")
-- label rim
c:fill(c:rrect(18, 33, 46, 51, 5):edge(), "#7a5cc0")
-- purple crescent seed
local seed = c:ellipse(32, 37, 13, 11):cut(c:ellipse(30, 32, 13, 10))
seed:clip(c:rrect(20, 35, 44, 49, 4))
c:part(seed, GV.ramp("#7a5cc0"), { gloss = false, contact = false })
c:fill(c:ellipse(27, 44, 1, 1), "#4e3a8a")
c:fill(c:ellipse(32, 45, 1, 1), "#4e3a8a")
c:fill(c:ellipse(37, 44, 1, 1), "#4e3a8a")
-- rivets
for _, q in ipairs({ {16, 33}, {48, 33}, {16, 51}, {48, 51}, {14, 21}, {50, 21} }) do c:px(q[1], q[2], "#f5cf6a") end
c:ground(32, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/sago-seed.aseprite", O .. "png/ph/sago-seed.png")
print(GV.report(t))
