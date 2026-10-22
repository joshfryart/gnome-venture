local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 28, 19, 25):cut(c:rect(0, 0, 63, 25)):add(c:rect(13, 24, 51, 28))
body:cut(c:rect(0, 51, 63, 63))
body:add(c:rrect(16, 42, 48, 51, 6))
c:build{
  { "handles", c:rrect(8, 22, 15, 28, 3):add(c:rrect(49, 22, 56, 28, 3)), "#6a6070", { gloss = false } },
  { "pot",  body, "#968f96" },
  { "rim",  c:ellipse(32, 24, 20.5, 6.5), "#6a6070", { gloss = false, bounce = false } },
  { "stew", c:ellipse(32, 24, 17, 4.5), "#f5cf6a", { gloss = { 19, 22 }, contact = false } },
}
for _, p in ipairs({ {23, 22}, {30, 25}, {39, 22}, {26, 26}, {43, 25} }) do
  c:paint({ ".c.", "ccC", ".C." }, p[1] - 1, p[2] - 1, { c = "#dcb06a", C = "#b08a4a" })
end
c:paint({ "..gg", ".ggG", "gGG.", "u..." }, 33, 20, { g = "#7ab55c", G = "#4a8a3e", u = "#4a8a3e" })
c:seam({ {18, 30}, {46, 30} })
local t = c:save(O .. "aseprite/ph/chickpea-stew.aseprite", O .. "png/ph/chickpea-stew.png")
print(GV.report(t))
