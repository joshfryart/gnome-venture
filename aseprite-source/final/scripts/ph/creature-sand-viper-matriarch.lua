local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
-- coil: back loop (filled oval) with the front loop overlapping it
local back = c:ellipse(35, 43, 17, 8)
back:add(c:line({ {47,37}, {52,35}, {55,36} }, 3))
local coil = c:line({ {13,46}, {22,50}, {34,51}, {45,48}, {51,43} }, 8)
local belly = coil:copy():cut(coil:shift(0,-3)):clip(c:rect(17,0,50,63))
local neck = c:line({ {14,47}, {13,42}, {14,37}, {16,32} }, 8)
local head = c:ellipse(16.5, 28.5, 9, 8.5)
head:add(c:poly({ {22,23}, {29,27}, {32,31}, {29,35}, {20,36} }))
local p = c:build{
  { "back",  back,  tan },
  { "coil",  coil,  tan, { stitch = { side = "lit" } } },
  { "belly", belly, "#f8eed2", { flat = true } },
  { "neck",  neck,  tan },
  { "head",  head,  tan, { gloss = { 10, 23 } } },
}
local dia = { "..d..", ".ddd.", "ddddd", ".ddd.", "..d.." }
for _, q in ipairs({ {22,47}, {32,48}, {42,46}, {46,39}, {37,38}, {28,39} }) do
  c:spot(c:ascii(dia, q[1]-2, q[2]-2), "#a5663a")
end
c:eye(11, 24); c:eye(18, 24)
c:paint({ "mmmmm" }, 22, 33, { m = "#2a1a10" })
c:paint({ "....rr", "rrrr..", "....rr" }, 32, 30, { r = "#d6322b" })
local t = c:save(D .. "test100/aseprite/ph/creature-sand-viper-matriarch.aseprite", D .. "test100/png/ph/creature-sand-viper-matriarch.png")
print(GV.report(t))
