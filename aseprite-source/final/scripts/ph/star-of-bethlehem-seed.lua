local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-hybrid/"

local packet = c:poly({ {16,12}, {48,12}, {52,17}, {52,57}, {13,57}, {13,17} })
local frame  = c:rrect(18, 22, 46, 50, 6)
local win    = c:rrect(20, 24, 44, 48, 5)
local bulb   = c:ellipse(32, 38.5, 8, 7.5)
local p = c:build{
  { "packet", packet, GV.ramp("#f1ece0") },
  { "frame",  frame,  GV.ramp("#f08a24"), { flat = true, contact = false } },
  { "win",    win,    GV.ramp("#f4f0e0"), { flat = true, contour = false, contact = false } },
  { "bulb",   bulb,   GV.ramp("#f08a24", { shade = "#e0501f" }) },
}
-- sprout
c:fill(c:line({ {32,26}, {32,30} }, 2), "#2f5a2a")
c:paint({ "..ll", ".lLl", "lLl.", "ll.." }, 34, 25, { l = "#58a03e", L = "#7ab55c" })
c:paint({ "..ll", ".lL.", "ll.." }, 27, 27, { l = "#58a03e", L = "#7ab55c" })
-- bulb root tuft
c:paint({ "u.u.u" }, 30, 46, { u = "#8c4a1a" })
-- fold seam + button
c:seam({ {14,18}, {51,18} })
c:button(30, 14)
-- dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 52, x+1, 53), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/star-of-bethlehem-seed.aseprite", O .. "png/ph/star-of-bethlehem-seed.png")
print(GV.report(t))
