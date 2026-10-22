local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(15, 12, 48, 55, 2)
local flap = c:poly({ {15, 12}, {49, 12}, {49, 21}, {32, 28}, {15, 21} })
local win = c:rrect(20, 30, 43, 50, 4)
local seed = c:ellipse(31.5, 42, 6.5, 6)

c:build{
  { "body", body, "cream" },
  { "flap", flap, GV.ramp("#dcb06a"), { gloss = { 18, 14 } } },
  { "win",  win,  GV.ramp("#f4f0e0"), { gloss = false } },
  { "seed", seed, GV.ramp("#dcb06a", { shade = "#a5663a" }) },
}
-- crimped top edge
for x = 16, 47, 3 do c:px(x, 13, "#a5663a") end
-- window border
c:fill(c:rrect(20, 30, 43, 50, 4):edge(), "#c9a96e")
-- sprout
c:paint({ "ss", "ss", "ss", "ss" }, 31, 32, { s = "#2e5a2c" })
c:paint({ "..llll..", ".llllll.", "llllllll", ".llllll." }, 33, 31, { l = "#58a03e" })
c:paint({ "..gg" }, 33, 31, { g = "#8fcf5e" })
-- print marks
c:paint({ "dd....dd....dd", "dd....dd....dd" }, 25, 52, { d = "#8c4a1a" })
-- fold seam across the flap base
c:seam({ {17, 20}, {32, 26}, {47, 20} })

local t = c:save(O .. "aseprite/ph/chrysanthemum-seed.aseprite", O .. "png/ph/chrysanthemum-seed.png")
print(GV.report(t))
