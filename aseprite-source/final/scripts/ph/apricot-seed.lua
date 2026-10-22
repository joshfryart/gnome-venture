local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local O = D .. "img-redraw-full/"

local tin   = GV.ramp("#f1ece0")
local band  = GV.ramp("#dcb06a")
local label = GV.ramp("#f4f0e0")
local apri  = GV.ramp("#f08a24")
local green = GV.ramp("#2e5a2c")

-- open lid flap, hinged at the back-right, tilted up
local flap = c:poly({ {30, 14}, {44, 6}, {52, 13}, {50, 16} })
-- tin body
local body = c:rrect(14, 15, 49, 55, 3)
local lidband = c:rect(14, 15, 49, 20)
local lab = c:rrect(19, 24, 44, 49, 5)
local labIn = c:rrect(21, 26, 42, 47, 4)

local p = c:build{
  { "flap", flap, green, { gloss = false } },
  { "body", body, tin, { gloss = { 17, 26 } } },
  { "lid",  lidband, band, { gloss = false } },
  { "label", lab, apri, { gloss = false, rim = false, bounce = false } },
  { "inner", labIn, label, { gloss = false, contact = false } },
}
-- apricot
local fruit = c:ellipse(31.5, 38, 6.5, 6)
c:part(fruit, apri, { gloss = { 28, 35 } })
c:paint({ "gg", "gg", "gg" }, 31, 29, { g = "#2f5a2a" })
c:part(c:ellipse(36, 30, 2.5, 1.5), "moss", { flat = true })
c:px(32, 35, "#e0501f")
-- seed dots
for _, x in ipairs({ 25, 31, 37 }) do
  c:fill(c:rect(x, 51, x + 2, 53), "#8c4a1a")
  c:px(x, 51, "#b8661a")
end
c:seam({ { 16, 18 }, { 47, 18 } })
c:button(44, 15)

c:ground(31.5, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/apricot-seed.aseprite", O .. "png/ph/apricot-seed.png")
print(GV.report(t))
