local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tall narrow envelope with angled shoulders
local env = c:poly({ {21,6}, {43,6}, {47,13}, {47,58}, {17,58}, {17,13} })
local flap = c:poly({ {21,6}, {43,6}, {47,13}, {47,17}, {17,17}, {17,13} })
local win = c:rrect(21, 23, 43, 50, 5)
local seed = c:ellipse(32, 39, 7, 7)
local leaf = c:poly({ {33,27}, {36,23}, {41,22}, {40,26}, {36,29} })
local p = c:build{
  { "env",  env,  GV.ramp("#f1ece0") },
  { "flap", flap, GV.ramp("#dcb06a") },
  { "win",  win,  GV.ramp("#7ab55c"), { gloss = false } },
}
c:part(win:shrink(2), GV.ramp("#f4f0e0"), { gloss = false, contact = false })
c:part(seed, "moss")
c:line({ {32,32}, {32,27} }, 2)
c:fill(c:line({ {32,32}, {32,27} }, 2), "#2f5a2a")
c:part(leaf, GV.ramp("#4a8a3e"), { flat = true })
c:seam({ {18,17}, {46,17} })
c:button(30, 14)
for _, x in ipairs({ 26, 31, 36 }) do c:fill(c:rect(x, 53, x + 1, 54), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/camellia-seed.aseprite", O .. "png/ph/camellia-seed.png")
print(GV.report(t))
