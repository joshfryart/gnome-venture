local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local R = GV.R

local body = c:poly({ {16,11}, {48,11}, {51,17}, {51,55}, {13,55}, {13,17} })
local flap = body:copy():clip(c:rect(13, 11, 51, 18))
c:build{
  { "body",   body, GV.ramp("#f1ece0"), { stitch = true } },
  { "flap",   flap, GV.ramp("#dcb06a"), { gloss = { 17, 13 } } },
  { "frame",  c:rrect(18, 22, 46, 50, 6), "moss", { gloss = false } },
  { "win",    c:rrect(20, 24, 44, 48, 4), GV.ramp("#f4f0e0"), { gloss = false, contact = false } },
  { "leaf",   c:poly({ {33,26}, {39,30}, {42,36}, {41,42}, {37,47}, {30,47}, {26,42}, {25,36}, {28,30}, {34,26} }), "moss" },
}
-- veins
c:fill(c:line({ {33,29}, {33,45} }, 2), "#2f5a2a")
c:fill(c:line({ {32,40}, {29,37} }, 1), "#2f5a2a")
c:fill(c:line({ {35,37}, {38,34} }, 1), "#2f5a2a")
-- fold line seam
c:seam({ {16, 18}, {48, 18} })
-- seed dots
for _, x in ipairs({ 26, 32, 38 }) do
  c:paint({ ".s.", "sss", ".sd" }, x - 1, 52, { s = "#8a4f2a", d = "#5e2f1e" })
end
local t = c:save(B .. "aseprite/ph/brussels-sprouts-seed.aseprite", B .. "png/ph/brussels-sprouts-seed.png")
print(GV.report(t))
