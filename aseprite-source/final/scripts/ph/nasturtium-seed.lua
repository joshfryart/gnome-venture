local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:poly({ {16,11}, {48,11}, {51,17}, {51,55}, {13,55}, {13,17} })
local flap = body:copy():clip(c:rect(13, 11, 51, 18))
c:build{
  { "body",  body, GV.ramp("#f1ece0"), { stitch = true } },
  { "flap",  flap, GV.ramp("#dcb06a"), { gloss = { 17, 13 } } },
  { "frame", c:rrect(18, 22, 46, 50, 6), "petal", { gloss = false } },
  { "win",   c:rrect(20, 24, 44, 48, 4), GV.ramp("#f4f0e0"), { gloss = false, contact = false } },
  { "stem",  c:rect(32, 27, 33, 33), "moss", { flat = true } },
  { "leaf",  c:poly({ {34,30}, {36,27}, {40,25}, {42,25}, {41,28}, {38,31}, {35,32} }), "moss", { gloss = false } },
  { "bloom", c:ellipse(32.5, 39, 7.5, 7), "petal" },
}
c:fill(c:rect(32, 27, 33, 32), "#2f5a2a")
-- petal notches to read as a flower
c:paint({ "u" }, 32, 32, { u = "#2f5a2a" })
c:seam({ {16, 18}, {48, 18} })
for _, x in ipairs({ 26, 32, 38 }) do
  c:paint({ ".s.", "sss", ".sd" }, x - 1, 52, { s = "#8a4f2a", d = "#5e2f1e" })
end
local t = c:save(B .. "aseprite/ph/nasturtium-seed.aseprite", B .. "png/ph/nasturtium-seed.png")
print(GV.report(t))
