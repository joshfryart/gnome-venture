local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local crust = c:ellipse(31.5, 36, 20, 9)
for a = 0, 355, 20 do
  local r = math.rad(a)
  crust:add(c:ellipse(31.5 + 20 * math.cos(r), 36 + 9 * math.sin(r), 1.5))
end
local crustR = GV.ramp("#dcb06a", { rim = "#d9a660" })
c:build{
  { "tin",   c:ellipse(31.5, 41, 20, 9), GV.ramp("#a5663a") },
  { "crust", crust, crustR, { stitch = true, gloss = false } },
  { "fill",  c:ellipse(31.5, 35.5, 14, 5.5), "#f08a24", { gloss = { 21, 33 } } },
}
c:fill(c:line({ {20,32}, {43,39} }, 2), "#dcb06a")
c:fill(c:line({ {43,32}, {20,39} }, 2), "#dcb06a")
for _, p in ipairs({ {24,34}, {34,32}, {38,37}, {27,38} }) do
  c:paint({ ".gg", "gg." }, p[1], p[2], { g = "#4a8a3e" })
end
c:px(21, 33, "#fff1c8"); c:px(22, 33, "#fff1c8"); c:px(21, 34, "#fff1c8")
local t = c:save(O .. "aseprite/ph/spinach-quiche.aseprite", O .. "png/ph/spinach-quiche.png")
print(GV.report(t))
