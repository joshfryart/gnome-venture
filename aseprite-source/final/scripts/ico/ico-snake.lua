local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- S body: thick stroke, tail tapering at lower left
local body = c:line({ {19, 46}, {27, 48}, {37, 45}, {41, 41}, {37, 36}, {25, 32}, {18, 27}, {22, 21}, {32, 19} }, 7)
body:add(c:line({ {14, 45}, {19, 46} }, 4))
body:add(c:line({ {11, 44}, {14, 45} }, 3))
local head = c:ellipse(41, 20, 8, 6.5)
local tongue = c:line({ {48, 22}, {50, 22} }, 2)
tongue:add(c:line({ {50, 22}, {52, 19} }, 2)):add(c:line({ {50, 22}, {52, 25} }, 2))

local p = c:build{
  { "tongue", tongue, GV.ramp("#d6322b"), { flat = true } },
  { "body", body, GV.ramp("#58a03e") },
  { "head", head, GV.ramp("#4a9033") },
}
-- back diamonds along the lower curve
for _, d in ipairs({ {21, 46}, {28, 47}, {35, 45}, {39, 40}, {32, 35}, {24, 31} }) do
  c:paint({ ".s.", "sss", ".s." }, d[1] - 1, d[2] - 1, { s = "#2e7a2c" })
end
c:eye(38, 15)
c:paint({ "uuu" }, 44, 23, { u = "umber" })

local t = c:save(O .. "aseprite/ico/ico-snake.aseprite", O .. "png/ico/ico-snake.png")
print(GV.report(t))
