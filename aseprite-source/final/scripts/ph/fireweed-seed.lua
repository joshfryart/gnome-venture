local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(32, 43, 20, 14.5)
body:add(c:poly({ {23, 24}, {42, 24}, {49, 36}, {15, 36} }))
local mouth = c:poly({ {17, 14}, {48, 14}, {41, 26}, {24, 26} })
for x = 19, 46, 5 do mouth:add(c:ellipse(x, 14, 2.5, 2.5)) end
local cord = c:rrect(18, 24, 46, 28, 2)
local tail1 = c:line({ {42, 28}, {45, 33} }, 2)
local tail2 = c:line({ {37, 28}, {38, 34} }, 2)
local knot1 = c:ellipse(45.5, 34.5, 1.5, 1.5)
local knot2 = c:ellipse(38.5, 35.5, 1.5, 1.5)
local patch = c:ellipse(32, 44, 10, 10)

local P = GV.ramp("#e46a9b")
local p = c:build{
  { "body",  body,  GV.ramp("#f1ece0"), { pale = true, stitch = true } },
  { "mouth", mouth, GV.ramp("#f4f0e0"), { pale = true, cres = 3 } },
  { "cord",  cord,  P, { cres = 2 } },
  { "patch", patch, GV.ramp("#f4f0e0"), { pale = true, gloss = false, cres = 2 } },
}
-- dangling cord tails
c:part(tail1, P, { flat = true }); c:part(tail2, P, { flat = true })
c:part(knot1, P, { flat = true }); c:part(knot2, P, { flat = true })
-- bloom: five petals and a gold heart
local bloom = c:mask()
for i = 0, 4 do
  local a = -math.pi / 2 + i * 2 * math.pi / 5
  bloom:add(c:ellipse(32 + math.cos(a) * 4, 45 + math.sin(a) * 4, 3, 3))
end
c:part(bloom, GV.ramp("#e46a9b", { deep = "#a8241f" }), { cres = 2, gloss = { 29, 41 } })
c:part(c:rect(31, 44, 33, 46), "gold", { flat = true })
-- leaf and stem
c:part(c:line({ {35, 39}, {37, 36} }, 2), GV.ramp("#2e5a2c"), { flat = true })
c:part(c:poly({ {36, 36}, {39, 31}, {43, 30}, {41, 35}, {37, 37} }), GV.ramp("#58a03e"), { flat = true })
-- neck seam and knot button
c:seam({ {20, 30}, {44, 30} })
c:button(30, 24)

local t = c:save(O .. "aseprite/ph/fireweed-seed.aseprite", O .. "png/ph/fireweed-seed.png")
print(GV.report(t))
