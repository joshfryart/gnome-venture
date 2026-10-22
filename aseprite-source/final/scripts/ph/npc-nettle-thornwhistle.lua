local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(40, 52, 35, 35)
local jacket = c:ellipse(39.5, 102, 33.5, 25)
local collar = c:poly({ {29, 72}, {51, 72}, {40, 89} })
local head = c:ellipse(40, 55, 22, 20)
local antL = c:line({ {33, 39}, {24, 26}, {17, 18} }, 2):add(c:rrect(14, 14, 18, 18, 1))
local antR = c:line({ {47, 39}, {56, 26}, {63, 18} }, 2):add(c:rrect(62, 14, 66, 18, 1))
local vine = c:line({ {18, 46}, {29, 47}, {40, 48}, {51, 47}, {62, 46} }, 2)

local green = GV.ramp("#58a03e")
local parts = {
  { "disc", disc, GV.ramp("#e6d2ae") },
  { "antL", antL, green, { flat = true } },
  { "antR", antR, green, { flat = true } },
  { "jacket", jacket, "gold", { stitch = { side = "lit" } } },
  { "collar", collar, GV.ramp("#f8eed2"), { cres = 2, deep = 1, gloss = false } },
  { "head", head, "moss" },
  { "vine", vine, green, { flat = true } },
}
local blooms = {
  { 21, 43, "#d9667f" }, { 29, 40, "#f5cf6a" }, { 36, 43, "#f8eed2" },
  { 43, 40, "#c3b2ea" }, { 50, 43, "#d9667f" }, { 58, 40, "#f5cf6a" },
}
for i, b in ipairs(blooms) do
  parts[#parts + 1] = { "b" .. i, c:ellipse(b[1], b[2], 3, 3), GV.ramp(b[3]),
    { cres = 2, deep = 1, gloss = false, contact = false } }
end
local p = c:build(parts)
for _, b in ipairs(blooms) do
  c:px(b[1], b[2], "#e8a317"); c:px(b[1] - 1, b[2] - 1, "#fff1c8")
end

c:seam({ {40, 90}, {40, 99} })
c:button(38, 86)
c:eye(23, 52); c:eye(52, 52)
c:paint({ "u.......u", ".uuuuuuu." }, 36, 63, { u = "#2a1a10" })

local t = c:save(O .. "aseprite/ph/npc-nettle-thornwhistle.aseprite", O .. "png/ph/npc-nettle-thornwhistle.png")
print(GV.report(t))
