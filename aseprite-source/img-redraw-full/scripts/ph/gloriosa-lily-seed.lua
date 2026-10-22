local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tall narrow envelope with pointed flap top
local env = c:rect(16, 16, 47, 56)
env:add(c:poly({ {16, 17}, {31.5, 8}, {48, 17} }))
local label = c:rrect(20, 24, 43, 48, 5)
local p = c:build{
  { "env", env, GV.ramp("#f1ece0") },
  { "label", label, GV.ramp("#e8a317"), { flat = true, contact = false } },
}
-- inner label paper
c:fill(c:rrect(22, 26, 41, 46, 4), "#f4f0e0")
-- flap crease (V shape)
c:fill(c:line({ {17, 17}, {31, 24} }, 2), "#dcb06a")
c:fill(c:line({ {32, 24}, {46, 17} }, 2), "#dcb06a")
-- golden seed
local seed = c:ellipse(31.5, 37, 6, 6.5)
local sp = c:part(seed, GV.ramp("#e8a317", { shade = "#b07a10" }), { contact = false })
-- sprout
c:fill(c:rect(31, 28, 32, 31), "#2e5a2a")
c:fill(c:ascii({ "..xx", ".xxx", "xxx." }, 33, 26), "#58a03e")
c:px(35, 26, "#8cc85a")
-- rust dots
for _, x in ipairs({ 24, 31, 38 }) do c:fill(c:rect(x, 51, x + 1, 52), "#8c4a1a") end

local t = c:save(O .. "aseprite/ph/gloriosa-lily-seed.aseprite", O .. "png/ph/gloriosa-lily-seed.png")
print(GV.report(t))
