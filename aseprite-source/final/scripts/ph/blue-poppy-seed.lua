local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local paper = GV.ramp("#f1ece0")
local flapR = GV.ramp("#f1ece0", { shade = "#dcb06a" })
local win = GV.ramp("#f4f0e0", { rim = "#e46a9b" })
local seedR = GV.ramp("#e46a9b", { deep = "#a8241f" })

local p = c:build{
  { "packet", c:rect(13, 16, 51, 56), paper },
  { "flap", c:poly({ {13, 16}, {52, 16}, {32, 32} }), flapR, { gloss = false } },
  { "window", c:rrect(18, 34, 46, 52, 4), win, { gloss = false } },
  { "seed", c:ellipse(32, 45, 6), seedR },
  { "leaf", c:ellipse(35.5, 37.5, 2.5, 1.5), "#58a03e", { flat = true } },
}
-- sprout stem
c:fill(c:rect(31, 36, 32, 39), "#2e5a2c")
-- tab dots along the bottom hem
for _, x in ipairs({ 25, 31, 37 }) do
  c:fill(c:rrect(x, 53, x + 2, 55, 1), "#8c4a1a")
end
c:seam({ {15, 18}, {31, 30} })
c:seam({ {33, 30}, {50, 18} })
c:button(30, 27)
c:gloss(p.packet.m, paper, { 16, 36 })
local t = c:save(B .. "img-redraw-full/aseprite/ph/blue-poppy-seed.aseprite",
                 B .. "img-redraw-full/png/ph/blue-poppy-seed.png")
print(GV.report(t))
