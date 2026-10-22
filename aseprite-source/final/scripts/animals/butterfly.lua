local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"
local ul = c:ellipse(18, 20, 11, 10):add(c:poly({ {12, 24}, {24, 12}, {32, 30}, {30, 34} }))
local ur = c:ellipse(45, 20, 11, 10):add(c:poly({ {51, 24}, {39, 12}, {33, 30}, {35, 34} }))
local ll = c:ellipse(23, 45, 8, 8):add(c:poly({ {20, 37}, {31, 34}, {31, 46}, {22, 44} }))
local lr = c:ellipse(40, 45, 8, 8):add(c:poly({ {43, 37}, {32, 34}, {32, 46}, {41, 44} }))
local body = c:ellipse(31.5, 37, 3, 12)
local head = c:ellipse(31.5, 22, 4.5, 4)
c:build{
  { "ll", ll, "#e0501f" },
  { "lr", lr, "#e0501f" },
  { "ul", ul, "#f08a24" },
  { "ur", ur, "#f08a24" },
  { "anL", c:line({ {30, 19}, {27, 15}, {25, 12} }, 2), "dusk", { flat = true } },
  { "anR", c:line({ {33, 19}, {36, 15}, {38, 12} }, 2), "dusk", { flat = true } },
  { "clubL", c:rrect(22, 8, 25, 11, 1), "dusk", { flat = true } },
  { "clubR", c:rrect(38, 8, 41, 11, 1), "dusk", { flat = true } },
  { "body", body, "dusk", { gloss = false } },
  { "head", head, "dusk", { gloss = false } },
}
c:spot(c:ellipse(16, 22, 3, 2.5)); c:spot(c:ellipse(47, 22, 3, 2.5))
c:spot(c:ellipse(21, 47, 2, 2.5)); c:spot(c:ellipse(42, 47, 2, 2.5))
c:eye(28, 20, true); c:eye(33, 20, true)
local t = c:save(O .. "aseprite/animals/butterfly.aseprite", O .. "png/animals/butterfly.png")
print(GV.report(t))
