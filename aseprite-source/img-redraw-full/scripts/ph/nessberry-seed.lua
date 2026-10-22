local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local purple = GV.ramp("#7a5cc0")
local dpurple = GV.ramp("#4e3a8a")
local body = c:rrect(17, 9, 46, 55, 2)
local flap = c:poly({ {17, 9}, {47, 9}, {32, 27} })
local label = c:rrect(20, 29, 43, 51, 5)
local p = c:build{
  { "body",  body,  "cream" },
  { "flap",  flap,  GV.ramp("#dcb06a") },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false } },
}
-- purple label border ring
c:fill(label:copy():cut(label:shrink(1)), "#7a5cc0")
-- berries pyramid: back row first
local bs = {
  { 26, 45, dpurple }, { 31.5, 45, purple }, { 37, 45, dpurple },
  { 29, 40, purple }, { 34, 40, dpurple },
  { 31.5, 35, purple },
}
for _, b in ipairs(bs) do
  c:part(c:ellipse(b[1], b[2], 3, 3), b[3], { gloss = { math.floor(b[1]) - 1, b[2] - 1 }, contact = false, rim = false })
end
-- stem and leaf
c:fill(c:rect(31, 30, 32, 32), "#2f5a2a")
c:part(c:poly({ {33, 32}, {36, 29}, {39, 29}, {37, 32}, {34, 33} }), GV.ramp("#58a03e"), { flat = true })
c:seam({ {18, 10}, {31, 25} }); c:seam({ {33, 25}, {46, 10} })
c:button(30, 22)
c:ground(31.5, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/nessberry-seed.aseprite", O .. "png/ph/nessberry-seed.png")
print(GV.report(t))
