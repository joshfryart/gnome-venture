local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- open lid tilted back and to the upper right, showing its inside
local lid = c:poly({ {14, 32}, {47, 32}, {53, 11}, {25, 11} })
local lemon = c:ellipse(28, 27, 11, 8):add(c:ellipse(39.5, 27, 2, 2))
local leaf = c:poly({ {31, 19}, {35, 14}, {41, 11}, {44, 12}, {40, 17}, {34, 20} })
local tin = c:rrect(10, 32, 46, 54, 3)
local lip = c:rect(10, 32, 46, 36)
local label = c:rrect(18, 40, 38, 49, 2)
c:build{
  { "lid",   lid,   "#7f848c" },
  { "lemon", lemon, "#f5cf6a" },
  { "leaf",  leaf,  "#58a03e", { flat = true } },
  { "tin",   tin,   "#a6a9ab" },
  { "lip",   lip,   "#b8b8b0", { gloss = false } },
  { "label", label, "#f1ece0", { gloss = false } },
}
c:fill(c:line({ {30, 21}, {31, 18} }, 2), "#2e5a2c")
c:spot(c:rrect(25, 42, 30, 47, 2), "#f5cf6a", "#fff1c8")
c:px(31, 43, "#58a03e"); c:px(32, 42, "#58a03e")
c:seam({ {13, 34}, {44, 34} })
c:button(41, 29)
local t = c:save(O .. "aseprite/ph/lemon-seed.aseprite", O .. "png/ph/lemon-seed.png")
print(GV.report(t))
