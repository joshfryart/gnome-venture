local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- heart/cone body: two shoulder lobes + taper to rounded tip
local body = c:ellipse(24, 30, 9, 9)
body:add(c:ellipse(40, 30, 9, 9))
body:add(c:ellipse(32, 29, 12, 8))
body:add(c:poly({ {15, 31}, {50, 31}, {38, 52}, {26, 52} }))
body:add(c:ellipse(32, 50, 5, 4))

local upper = body:copy():clip(c:rect(0, 0, 63, 34))
local orange = GV.ramp("#f08a24")
local moss = GV.ramp("#a4b86a")

local stem = c:rrect(30, 13, 33, 23, 1)
local leaf = c:poly({ {34, 18}, {37, 12}, {42, 8}, {48, 7}, {46, 12}, {41, 17} })

c:build{
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "leaf", leaf, "#7ab55c", { gloss = false } },
  { "lower", body, orange, { gloss = false } },
  { "upper", upper, moss, { light = body, bounce = false, contour = false, contact = false, gloss = { 20, 25 } } },
}
-- leaf vein
c:line({ {36, 16}, {40, 12}, {45, 9} }, 1)
c:px(36, 16, "#2f5a2a"); c:px(37, 15, "#2f5a2a"); c:px(38, 14, "#2f5a2a"); c:px(39, 13, "#2f5a2a")
c:px(40, 12, "#2f5a2a"); c:px(41, 11, "#2f5a2a"); c:px(42, 11, "#2f5a2a"); c:px(43, 10, "#2f5a2a"); c:px(44, 9, "#2f5a2a")

-- U-scale bumps, rows offset
local function scale(x, y, hex)
  c:paint({ "u...u", ".uuu." }, x, y, { u = hex })
end
local mline = moss.shade
for _, x in ipairs({ 18, 26, 34, 42 }) do scale(x, 26, mline) end
for _, x in ipairs({ 22, 30, 38 }) do scale(x, 31, mline) end
for _, x in ipairs({ 18, 26, 34, 42 }) do scale(x, 37, "#e0501f") end
for _, x in ipairs({ 22, 30, 38 }) do scale(x, 43, "#e0501f") end
scale(30, 48, "#e0501f")

c:ground(32, 56, 11, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/cherimoya.aseprite", D .. "img-redraw-full/png/ph/cherimoya.png")
print(GV.report(t))
