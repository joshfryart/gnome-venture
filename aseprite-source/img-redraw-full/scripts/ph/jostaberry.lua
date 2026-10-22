local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dark = GV.ramp("#3e2f66")
local darker = GV.ramp("#33265a")
local lit = GV.ramp("#4e3c80")
local leaf = c:poly({ {32,19}, {36,11}, {44,6}, {46,7}, {43,14}, {36,19} })
local p = c:build{
  { "stem", c:line({ {31,24}, {31,15} }, 3), "moss", { flat = true } },
  { "leaf", leaf, "leaf" },
  { "b1", c:ellipse(18.5, 48.5, 8, 8), dark },
  { "b3", c:ellipse(45.5, 48.5, 8, 8), darker },
  { "b2", c:ellipse(32, 49.5, 8, 8), darker },
  { "m1", c:ellipse(24.5, 38, 8, 8), dark },
  { "m2", c:ellipse(39.5, 38, 8, 8), dark },
  { "top", c:ellipse(32, 28, 8, 8), lit },
}
c:seam({ {34,17}, {42,9} }, { free = true })
-- crowns: small star-blossom remnants at each berry top-right
for _, q in ipairs({ {22,43}, {49,43}, {35,44}, {28,32}, {43,32}, {35,22} }) do
  c:paint({ ".s.", "sss", ".s." }, q[1], q[2], { s = "#291d4a" })
end
local t = c:save(O .. "aseprite/ph/jostaberry.aseprite", O .. "png/ph/jostaberry.png")
print(GV.report(t))
