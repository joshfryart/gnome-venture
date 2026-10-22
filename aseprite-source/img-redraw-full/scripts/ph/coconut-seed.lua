local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cream = GV.ramp("#f1ece0")
local label = GV.ramp("#f4f0e0")
local nut   = GV.ramp("#8c4a1a", { rim = "#d9a660" })
local leaf  = GV.ramp("#58a03e")

-- sprout behind the envelope shoulder
c:part(c:line({ {45, 18}, {45, 11} }, 2), GV.ramp("#2e5a2c"), { flat = true })
local lf = c:poly({ {43, 10}, {46, 6}, {50, 4}, {54, 5}, {52, 9}, {48, 11} })
c:part(lf, leaf, { gloss = false })

local p = c:build{
  { "env",   c:rrect(20, 12, 44, 57, 2), cream, { pale = true } },
  { "flap",  c:poly({ {20, 12}, {45, 12}, {32, 26} }), cream, { pale = true, gloss = false } },
  { "label", c:rrect(23, 29, 41, 49, 5), "#8c4a1a", { flat = true } },
  { "win",   c:rrect(25, 31, 39, 47, 4), label, { pale = true, gloss = false, contact = false } },
  { "nut",   c:ellipse(32, 39.5, 6.5, 7), nut },
}
-- flap lower edge tint
for i = 0, 10 do c:px(21 + i, 13 + i, "#dcb06a") end
for i = 0, 10 do c:px(43 - i, 13 + i, "#dcb06a") end
-- darker cap on the coconut top
c:paint({ ".kkkkk.", "kk...kk" }, 29, 33, { k = "#44281c" })
-- three coconut eyes
c:paint({ "ee", "ee" }, 29, 36, { e = "#2a1a10" })
c:paint({ "ee", "ee" }, 34, 36, { e = "#2a1a10" })
c:paint({ "ee", "ee" }, 31, 40, { e = "#2a1a10" })
-- seams on the flap V
c:seam({ {22, 15}, {30, 23} }, { free = true })
c:seam({ {42, 15}, {34, 23} }, { free = true })
c:button(30, 22)
-- price dots
for _, x in ipairs({ 26, 31, 36 }) do c:paint({ "dd", "dd" }, x, 52, { d = "#8c4a1a" }) end

local t = c:save(O .. "aseprite/ph/coconut-seed.aseprite", O .. "png/ph/coconut-seed.png")
print(GV.report(t))
