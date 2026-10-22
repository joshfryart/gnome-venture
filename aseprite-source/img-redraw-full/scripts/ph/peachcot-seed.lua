local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
-- cone leaning right: flared bottom, narrow top
local cone = c:poly({ {13,57}, {51,57}, {46,24}, {38,13}, {30,13}, {19,24} })
local twist = c:poly({ {30,14}, {38,14}, {41,6}, {37,9}, {34,5}, {31,9}, {27,6} })
local band = c:poly({ {18,23}, {47,19}, {48,24}, {17,28} }):clip(cone)
local win = c:ellipse(32.5, 41, 12, 10.5)
local seed = c:ellipse(32.5, 41, 8, 6)
local tag = c:poly({ {46,9}, {52,18}, {41,18} })
local p = c:build{
  { "twist", twist, tan, { gloss = false } },
  { "cone",  cone,  GV.ramp("#f1ece0") },
  { "band",  band,  tan, { flat = true } },
  { "rim",   win,   GV.ramp("#f08a24"), { gloss = false } },
  { "win",   win:shrink(2), GV.ramp("#f4f0e0"), { gloss = false, contour = false } },
  { "seed",  seed,  GV.ramp("#f08a24") },
  { "tag",   tag,   GV.ramp("#2e5a2c"), { gloss = false } },
}
-- string from tag to twist
c:line({ {38,11}, {43,13} }, 1)
c:fill(c:line({ {38,11}, {43,13} }, 1), "#8c4a1a")
c:seam({ {18,25}, {47,21} })
for _, d in ipairs({ {27,41}, {32,38}, {36,40} }) do
  c:fill(c:rect(d[1], d[2], d[1]+1, d[2]+1), "#e46a9b")
end
c:fill(c:rect(23, 44, 24, 46), "#2e5a2c")
for _, x in ipairs({ 24, 31, 38 }) do c:fill(c:rect(x, 53, x+1, 54), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/peachcot-seed.aseprite", O .. "png/ph/peachcot-seed.png")
print(GV.report(t))
