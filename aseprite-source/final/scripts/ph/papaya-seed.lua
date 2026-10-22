local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local packet = c:rrect(14, 12, 50, 54, 3)
local flap = c:poly({ {14,12}, {51,12}, {32.5,31} }):clip(packet)
local frame = c:rrect(18, 33, 46, 50, 4)
local win = c:rrect(20, 35, 44, 48, 3)
c:build{
  { "packet", packet, GV.ramp("#f1ece0") },
  { "flap", flap, GV.ramp("#dcb06a") },
  { "frame", frame, GV.ramp("#f08a24"), { flat = true } },
  { "win", win, GV.ramp("#f4f0e0"), { flat = true, contour = false, contact = false } },
  { "papaya", c:ellipse(32, 42, 5.5, 5), GV.ramp("#f08a24", { shade = "#e0501f" }) },
}
c:fill(c:rect(32, 36, 33, 37), "#2e5a2c")
c:part(c:ellipse(36.5, 36.5, 2.5, 1.5), GV.ramp("#58a03e"), { flat = true, contour = false })
c:paint({ "ss.ss", "s...s", ".sss." }, 30, 40, { s = "#7a3a14" })
c:seam({ {15, 13}, {32, 30}, {49, 13} })
c:button(30, 27)
for _, x in ipairs({ 24, 31, 38 }) do c:fill(c:rect(x, 51, x + 1, 52), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/papaya-seed.aseprite", O .. "png/ph/papaya-seed.png")
print(GV.report(t))
