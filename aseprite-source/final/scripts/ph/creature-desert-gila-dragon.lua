local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pink = GV.ramp("#d9667f")
local legR = GV.ramp("#9c2a1e")
local tail = c:line({ {18,33}, {14,34}, {11,36}, {9,39}, {9,42}, {11,44}, {14,44} }, 5)
local body = c:ellipse(31.5, 33, 16, 7.5)
local belly = c:ellipse(31.5, 38, 11, 3):clip(body)
local legs = c:poly({ {17,36}, {24,36}, {22,44}, {15,44} }):add(c:poly({ {38,36}, {45,36}, {48,44}, {41,44} }))
local head = c:ellipse(46, 28, 7, 6.5):add(c:poly({ {48,23}, {54,25}, {57,28}, {56,32}, {47,34} }))
local p = c:build{
  { "legs", legs, legR },
  { "tail", tail, pink },
  { "body", body, pink, { stitch = { side = "lit" } } },
  { "belly", belly, "petal", { flat = true } },
  { "head", head, pink },
}
local dia = { ".xx.", "xxxx", "xxxx", ".xx." }
for _, s in ipairs({ {18,31}, {23,27}, {29,31}, {34,27}, {39,31} }) do
  c:spot(c:ascii(dia, s[1], s[2]), "#9c2a1e")
end
c:eye(46, 23)
c:px(55, 27, "#ae2a2a")
c:paint({ "m...", ".mmm" }, 50, 31, { m = "#6b1b2c" })
c:ground(31.5, 47, 16, 1.5)
local t = c:save(O .. "aseprite/ph/creature-desert-gila-dragon.aseprite", O .. "png/ph/creature-desert-gila-dragon.png")
print(GV.report(t))
