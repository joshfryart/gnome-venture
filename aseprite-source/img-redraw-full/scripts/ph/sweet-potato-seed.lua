local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local env  = c:rrect(19, 8, 45, 55, 2)
local flap = c:poly({ {19, 8}, {46, 8}, {32, 26} })
local tuber = c:poly({ {28, 32}, {36, 32}, {40, 35}, {42, 40}, {41, 45}, {37, 50}, {33, 55}, {31, 55}, {27, 50}, {23, 45}, {22, 40}, {24, 35} })
local leafL = c:poly({ {30, 33}, {25, 27}, {23, 29}, {24, 32}, {27, 33} })
local leafR = c:poly({ {34, 33}, {39, 27}, {41, 29}, {40, 32}, {37, 33} })
c:build{
  { "env",  env,  "#f1ece0" },
  { "flap", flap, "#f4f0e0", { gloss = false } },
  { "leafL", leafL, "moss", { flat = true } },
  { "leafR", leafR, "moss", { flat = true } },
  { "tuber", tuber, GV.ramp("#c97f62"), { gloss = { 28, 37 } } },
}
-- tuber eyes
c:paint({ "eee" }, 29, 41, { e = "#8c4a1a" })
c:paint({ "eee" }, 33, 46, { e = "#8c4a1a" })
-- leaf veins

c:fill(c:line({ {29, 32}, {26, 29} }, 1), "#4a8a3e")
c:fill(c:line({ {35, 32}, {38, 29} }, 1), "#4a8a3e")
-- flap seam
c:seam({ {21, 10}, {32, 24} }); c:seam({ {43, 10}, {32, 24} })
-- wax seal
c:paint({ ".rr.", "rhrr", "rrrd", ".dd." }, 30, 25, { r = "#d6322b", h = "#ff9158", d = "#ae2a2a" })
-- pale rules near bottom
c:fill(c:line({ {22, 51}, {26, 51} }, 1), "#dcb06a")
c:fill(c:line({ {38, 51}, {42, 51} }, 1), "#dcb06a")
c:ground(32, 57, 13, 2)
local t = c:save(O .. "aseprite/ph/sweet-potato-seed.aseprite", O .. "png/ph/sweet-potato-seed.png")
print(GV.report(t))
