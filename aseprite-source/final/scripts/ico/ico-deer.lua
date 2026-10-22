local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local antL = c:line({ {26,26}, {22,12} }, 3):add(c:line({ {24,19}, {17,15} }, 3))
local antR = c:line({ {37,26}, {41,12} }, 3):add(c:line({ {39,19}, {46,15} }, 3))
local earL = c:poly({ {23,27}, {14,23}, {8,24}, {9,29}, {15,35}, {23,35} }):add(c:ellipse(13, 28, 4.5, 4))
local earR = c:poly({ {40,27}, {49,23}, {55,24}, {54,29}, {48,35}, {40,35} }):add(c:ellipse(50, 28, 4.5, 4))
local head = c:poly({ {21,25}, {43,25}, {43,32}, {40,44}, {32,54}, {24,44}, {20,32} })
head:add(c:rrect(20, 24, 43, 34, 5))
local muz = c:ellipse(31.5, 47, 7.5, 5.5)
local p = c:build{
  { "antL", antL, "#dcb06a", { gloss = false } },
  { "antR", antR, "#dcb06a", { gloss = false } },
  { "earL", earL, "#8c4a1a", { gloss = false } },
  { "earR", earR, "#8c4a1a", { gloss = false } },
  { "head", head, "#a5663a" },
  { "muz", muz, "#f8eed2", { gloss = false } },
}
c:fill(c:poly({ {21,28}, {13,25}, {11,27}, {15,32}, {21,32} }), "#e8a0a8")
c:fill(c:poly({ {42,28}, {50,25}, {52,27}, {48,32}, {42,32} }), "#e8a0a8")
c:eye(23, 32); c:eye(36, 32)
c:paint({ ".nnn.", "nannn", ".nnn." }, 29, 43, { n = "#2a1a10", a = "#5e3a2a" })
c:paint({ "n", "n" }, 31, 46, { n = "#4a2c1a" })
c:paint({ "nn.nn" }, 29, 48, { n = "#4a2c1a" })
local t = c:save(O .. "aseprite/ico/ico-deer.aseprite", O .. "png/ico/ico-deer.png")
print(GV.report(t))
