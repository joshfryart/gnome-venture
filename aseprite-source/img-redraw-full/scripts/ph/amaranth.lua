local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stalk = c:line({ {31, 55}, {31, 40}, {29, 26} }, 3)
local leafL = c:poly({ {31, 46}, {26, 39}, {18, 35}, {11, 35}, {15, 40}, {22, 45} })
local leafR = c:poly({ {32, 36}, {37, 29}, {45, 24}, {53, 23}, {49, 28}, {41, 34} })
-- plume: fat tassel rising from stalk top, arching over to the right and drooping
local plume = c:mask()
local path = { {29,25,5}, {28,20,6}, {30,15,6.5}, {34,12,6}, {39,12,5.5}, {43,15,5}, {46,19,4.5}, {48,24,4}, {49,29,3}, {49,33,2.5}, {48,36,2} }
for _, q in ipairs(path) do plume:add(c:ellipse(q[1], q[2], q[3], q[3])) end
local p = c:build{
  { "stalk", stalk, "#4a8a3e", { flat = true } },
  { "leafL", leafL, "moss" },
  { "leafR", leafR, "moss" },
  { "plume", plume, GV.ramp("#b8452f", { rim = "#dd3a2a" }) },
}
c:fill(c:line({ {29, 44}, {23, 40}, {16, 37} }, 1):clip(leafL), "#2f5a2a")
c:fill(c:line({ {34, 34}, {40, 29}, {48, 25} }, 1):clip(leafR), "#2f5a2a")
for _, d in ipairs({ {28, 18}, {36, 12}, {45, 21} }) do
  c:fill(c:rect(d[1], d[2], d[1] + 2, d[2] + 2), "#ae2a2a")
end
c:px(29, 18, "#f6b8cf"); c:px(37, 12, "#f6b8cf")
c:paint({ "a.a", ".a." }, 37, 18, { a = "#ae2a2a" })
local t = c:save(O .. "aseprite/ph/amaranth.aseprite", O .. "png/ph/amaranth.png")
print(GV.report(t))
