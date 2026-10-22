local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local burlap = GV.ramp("#c9a96e", { shade = "#9a6b3f" })
local sack = c:ellipse(31.5, 40, 19, 15)
sack:add(c:poly({ {25, 22}, {39, 22}, {46, 32}, {17, 32} }))
local frill = c:poly({ {21, 13}, {26, 16}, {29, 12}, {32, 15}, {35, 12}, {38, 16}, {43, 13}, {40, 23}, {24, 23} })
local stem = c:line({ {33, 12}, {34, 17} }, 2)
local ear = c:ellipse(36, 10, 3, 5)

local p = c:build{
  { "stem", stem, "gold", { flat = true } },
  { "frill", frill, burlap },
  { "sack", sack, burlap, { stitch = { side = "lit" } } },
  { "ear", ear, "gold", { gloss = { 35, 7 } } },
}
-- wheat ear grain notches
for _, y in ipairs({ 8, 11, 14 }) do c:px(36, y, "#b8661a"); c:px(35, y - 1, "#d0862a"); c:px(37, y - 1, "#d0862a") end
-- burlap weave flecks
for _, q in ipairs({ {24, 38}, {30, 44}, {38, 38}, {27, 49}, {36, 47}, {42, 43}, {33, 36} }) do
  c:px(q[1], q[2], "#9a6b3f"); c:px(q[1] + 1, q[2], "#9a6b3f")
end
-- twine band and bow
c:fill(c:rect(24, 23, 40, 25), "#7a4a1f")
c:fill(c:rect(24, 23, 40, 23), "#a8582f")
c:paint({
  ".tt...tt.",
  "t..t.t..t",
  "t..tkt..t",
  ".tt.k.tt.",
  "...t.t...",
  "..t...t..",
}, 28, 20, { t = "#7a4a1f", k = "#5e2f1e" })
-- spilled grains
for _, g in ipairs({ {19, 53}, {25, 55}, {41, 54}, {46, 52} }) do
  c:paint({ "aaa", ".bb" }, g[1], g[2], { a = "#f5cf6a", b = "#e8a317" })
end

c:ground(31.5, 56, 15, 1.5)
local t = c:save(O .. "aseprite/ph/wheat-seed.aseprite", O .. "png/ph/wheat-seed.png")
print(GV.report(t))
