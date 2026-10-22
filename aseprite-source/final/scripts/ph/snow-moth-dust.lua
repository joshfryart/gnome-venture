local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wingR = GV.ramp("#b0bc66")
-- left wing: big forewing lobe + smaller hindwing lobe
local lw = c:poly({ {32,26}, {22,13}, {14,11}, {9,15}, {8,23}, {12,29}, {32,33} })
lw:add(c:ellipse(15, 18, 6, 6))
lw:add(c:poly({ {32,31}, {14,32}, {11,37}, {14,44}, {20,47}, {26,44}, {32,38} }))
lw:add(c:ellipse(17, 40, 6, 5))
local rw = c:mask()
lw:each(function(x, y) rw:set(63 - x, y) end)
local all = lw:copy(); all:add(rw)
c:build{
  { "lwing", lw, wingR, { light = all, gloss = { 15, 15 } } },
  { "rwing", rw, wingR, { light = all, gloss = false } },
}
-- dusty diamond flecks
local function diamond(x, y, hex)
  c:paint({ ".f.", "fff", ".f." }, x - 1, y - 1, { f = hex })
end
for _, p in ipairs({ {17,23}, {46,23}, {19,38}, {44,38} }) do diamond(p[1], p[2], "#c8d77a") end
c:px(24, 20, "#c8d77a"); c:px(39, 20, "#c8d77a")
c:px(13, 29, wingR.shade); c:px(50, 29, wingR.shade)
c:px(24, 41, wingR.shade); c:px(39, 41, wingR.shade)
-- body
local body = c:rrect(30, 22, 33, 48, 2)
c:part(body, GV.ramp("#2a1a10", { rim = "#5e2a3a", shade = "#2a1a10", deep = "#2a1a10", bounce = "#35161f", gloss = "#5e2a3a", dot = "#7b4a5a" }), { contour = false, gloss = { 31, 24 } })
for y = 30, 46, 4 do c:px(30, y, "#5e2a3a") end
-- antennae with clubs
c:limb({ {31,22}, {28,17}, {26,14} }, 2)
c:limb({ {32,22}, {35,17}, {37,14} }, 2)
c:paint({ ".ll.", "llll", "llll", ".ll." }, 23, 10, { l = "#54447f" })
c:paint({ ".ll.", "llll", "llll", ".ll." }, 37, 10, { l = "#54447f" })
c:px(24, 11, "#7b66b4"); c:px(38, 11, "#7b66b4")
local t = c:save(O .. "aseprite/ph/snow-moth-dust.aseprite", O .. "png/ph/snow-moth-dust.png")
print(GV.report(t))
