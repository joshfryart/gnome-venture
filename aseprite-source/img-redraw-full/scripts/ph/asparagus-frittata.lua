local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cx = 26.5
local handle = c:rrect(46, 33, 54, 38, 2)
local pan = c:ellipse(cx, 41, 22, 12)
local crust = c:ellipse(cx, 37, 22, 11)
local top = c:ellipse(cx, 37, 17, 8)
c:build{
  { "handle", handle, GV.ramp("#5b6470") },
  { "pan", pan, GV.ramp("#5b6470") },
  { "crust", crust, GV.ramp("#dcb06a"), { gloss = { 10, 32 } } },
  { "top", top, GV.ramp("#b0bc66"), { gloss = { 17, 32 } } },
}
-- spears: dark green bars with bright bud tips, slight diagonal, parallel
local spears = { {15, 33, 37, 31}, {14, 37, 39, 35}, {16, 41, 38, 39} }
for _, s in ipairs(spears) do
  c:fill(c:line({ {s[1], s[2]}, {s[3], s[4]} }, 2), "#2f5a2a")
  c:fill(c:line({ {s[1], s[2]}, {s[3], s[4]} }, 1), "#4a8a3e")
  c:paint({ ".l.", "lgl", "ll." }, s[3], s[4] - 1, { l = "#7ab55c", g = "#c8d77a" })
end
local flecks = { {20, 30}, {33, 29}, {28, 43}, {39, 42}, {12, 39} }
for _, f in ipairs(flecks) do c:px(f[1], f[2], "#f4f0e0") end
local yolks = { {24, 30}, {32, 41}, {41, 36} }
for _, y in ipairs(yolks) do c:paint({ "ab", "bb" }, y[1], y[2], { a = "#f5cf6a", b = "#e8a317" }) end
c:px(51, 35, GV.C.hole); c:px(52, 35, GV.C.hole)
c:seam({ {6, 42}, {10, 46}, {18, 49}, {28, 50}, {38, 49}, {46, 46}, {49, 42} })
local t = c:save(O .. "aseprite/ph/asparagus-frittata.aseprite", O .. "png/ph/asparagus-frittata.png")
print(GV.report(t))
