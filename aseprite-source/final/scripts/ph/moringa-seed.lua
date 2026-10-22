local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tab   = c:poly({ {44, 7}, {51, 19}, {38, 19} })
local body  = c:rrect(17, 15, 46, 55, 2)
local flap  = c:poly({ {17, 15}, {47, 15}, {32, 31} })
local frame = c:rrect(20, 33, 43, 51, 5)
local win   = c:rrect(22, 35, 41, 49, 4)
local leaf  = c:poly({ {32, 35}, {37, 40}, {38, 45}, {35, 49}, {32, 50}, {29, 49}, {26, 45}, {27, 40} })

local p = c:build{
  { "tab",   tab,   "leaf" },
  { "body",  body,  "cream" },
  { "flap",  flap,  GV.ramp("#d9a660") },
  { "frame", frame, "gold", { gloss = false } },
  { "win",   win,   GV.ramp("#f4f0e0"), { gloss = false, contact = false } },
  { "leaf",  leaf,  "moss" },
}
-- midrib and veins
c:fill(c:line({ {32, 38}, {32, 48} }, 1), "#2f5a2a")
c:px(31, 42, "#2f5a2a"); c:px(30, 41, "#2f5a2a")
c:px(33, 42, "#2f5a2a"); c:px(34, 41, "#2f5a2a")
c:px(31, 46, "#2f5a2a"); c:px(30, 45, "#2f5a2a")
c:px(33, 46, "#2f5a2a"); c:px(34, 45, "#2f5a2a")
-- closure dots
for _, x in ipairs({ 26, 31, 36 }) do c:fill(c:rect(x, 52, x + 1, 53), "#d0862a") end

c:seam({ {19, 17}, {32, 30}, {45, 17} })
c:button(30, 27)
c:ground(31.5, 57, 17, 2)

local t = c:save(R .. "img-redraw-full/aseprite/ph/moringa-seed.aseprite", R .. "img-redraw-full/png/ph/moringa-seed.png")
print(GV.report(t))
