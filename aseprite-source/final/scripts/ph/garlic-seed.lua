local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rect(16, 14, 48, 54)
body:cut(c:poly({ {46, 14}, {49, 14}, {49, 17} })) -- dog-ear nick
local flap = c:poly({ {16, 14}, {49, 14}, {49, 25}, {32, 30}, {16, 25} })
flap:cut(c:poly({ {46, 14}, {49, 14}, {49, 17} }))
local label = c:rrect(22, 32, 42, 49, 3)
local bulb = c:ellipse(32, 43, 6, 5):add(c:poly({ {28, 40}, {37, 40}, {33, 35}, {32, 35} }))

local paper = GV.ramp("#f1ece0")
local p = c:build{
  { "body",  body, paper },
  { "flap",  flap, GV.ramp("#dcb06a") },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false } },
  { "bulb",  bulb, GV.ramp("#f1ece0", { shade = "#dcb06a" }), { gloss = { 29, 41 } } },
}
-- fold line along V
c:fill(c:line({ {16, 25}, {32, 29} }, 1), "#b07a45")
c:fill(c:line({ {32, 29}, {48, 25} }, 1), "#b07a45")
-- dog-ear fold triangle
c:paint({ "..d", ".dd", "ddd" }, 46, 14, { d = "#dcb06a" })
-- bulb clove lines and leaf
c:fill(c:line({ {32, 39}, {32, 47} }, 1), "#dcb06a")
c:paint({ ".gg", "gg.", "g.." }, 32, 32, { g = "#58a03e" })
c:fill(c:rect(31, 33, 31, 35), "#58a03e")
-- seed dots
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x - 1, 51, x, 52), "#8c4a1a") end
c:seam({ {18, 23}, {30, 26} }); c:seam({ {34, 26}, {46, 23} })
c:ground(32, 56, 15, 1.2, "#7a4a1f")
local t = c:save(O .. "aseprite/ph/garlic-seed.aseprite", O .. "png/ph/garlic-seed.png")
print(GV.report(t))
