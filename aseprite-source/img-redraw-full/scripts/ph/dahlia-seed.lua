local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- orange tuber seed peeking out (behind the cone)
c:part(c:rect(31, 5, 32, 10), GV.ramp("#2e5a2c"), { flat = true })
c:part(c:ellipse(36.5, 6.5, 3, 1.5), GV.ramp("#58a03e"), { flat = true })
c:part(c:ellipse(31.5, 16, 8.5, 7.5), GV.ramp("#f08a24", { shade = "#e0501f" }), { gloss = { 27, 11 } })
-- paper cone, point down
local cone = c:poly({ {15, 25}, {49, 25}, {33, 53}, {31, 53} }):add(c:ellipse(32, 51, 2, 2))
c:part(cone, "cream", { stitch = { side = "lit" } })
-- twist band and fold line
c:fill(c:line({ {18, 27}, {35, 50} }, 4):clip(cone:shrink(2)), "#dcb06a")
c:fill(c:line({ {40, 29}, {33, 46} }, 1):clip(cone:shrink(2)), "#d6c9b6")
-- top rim
c:part(c:rrect(12, 20, 51, 27, 3), GV.ramp("#c9a96e"), { gloss = { 15, 22 } })
c:seam({ {14, 25}, {50, 25} })
c:ground(31.5, 55, 9, 1.5)
local t = c:save(O .. "aseprite/ph/dahlia-seed.aseprite", O .. "png/ph/dahlia-seed.png")
print(GV.report(t))
