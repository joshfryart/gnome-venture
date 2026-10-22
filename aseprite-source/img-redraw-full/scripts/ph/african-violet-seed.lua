local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tall narrow envelope
local body = c:rect(18, 12, 45, 53)
local flap = c:poly({ { 18, 12 }, { 46, 12 }, { 46, 14 }, { 32, 28 }, { 18, 14 } })
local label = c:rrect(21, 30, 42, 48, 4)
local p = c:build{
  { "body", body, GV.ramp("#c9a96e") },
  { "flap", flap, GV.ramp("#9a6b3f"), { gloss = { 22, 14 } } },
  { "label", label, "cream", { gloss = false } },
}
-- violet: five petals around (31.5,38)
c:paint({
  "....vvv....",
  "...vLvvd...",
  ".vv.vvd.vv.",
  "vLvv.d.vLvv",
  "vvvd.g.vvvd",
  ".vdggggsdd.",
  "....ggs....",
  "..vvv.vvv..",
  ".vLvvdvLvvd",
  ".vvvd.vvvd.",
  "..dd...dd..",
}, 26, 33, { v = "#7b66b4", L = "#a894dc", d = "#3e2f66", g = "#f5cf6a", s = "#e8a317" })
-- stem and leaves under the flower
c:fill(c:rect(31, 45, 32, 46), "#4a8a3e")
-- flap seam along the V and button at the tip
c:seam({ { 20, 16 }, { 31, 27 } }, { free = true })
c:seam({ { 44, 16 }, { 33, 27 } }, { free = true })
c:button(30, 26)
-- tiny seeds below the label
for _, x in ipairs({ 26, 31, 36 }) do c:paint({ "ss", "sd" }, x, 50, { s = "#7a4a1f", d = "#5a3008" }) end
c:ground(31.5, 55, 17, 2)
local t = c:save(O .. "aseprite/ph/african-violet-seed.aseprite", O .. "png/ph/african-violet-seed.png")
print(GV.report(t))
