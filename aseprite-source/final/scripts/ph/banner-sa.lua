-- ph/banner-sa : rainforest wall, 120x40 grid written at 2x (240x80)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local N = "ph/banner-sa"
local c = GV.canvas{ mode = "scene", w = 120, h = 40, out = 2, ol = 1, olx = 1, cres = 2, deep = 1 }

-- back wall: upper green, lower olive, with flat distant trunk shadows
c:fill(c:rect(0, 0, 119, 39), "#b0bc66")
c:fill(c:rect(0, 0, 119, 20), "#7ab55c")
for _, x in ipairs({ 10, 30, 50, 70, 90, 110 }) do c:fill(c:rect(x - 1, 8, x, 30), "#94a856") end

-- trunks
local bark = GV.ramp("#b6814d", { rim = "#f0d49a", shade = "#8a4f2a" })
local XS = { 0, 20, 40, 60, 80, 100, 120 }
for _, x in ipairs(XS) do
  c:part(c:rect(x - 2, 0, x + 2, 39), bark, { gloss = false, contact = false })
  c:fill(c:rect(x, 18, x, 19):add(c:rect(x - 1, 26, x - 1, 27)), "#8a4f2a") -- bark knots
end
-- a branch stub for the bird to perch on
c:part(c:rect(50, 22, 57, 23), bark, { flat = true, contact = false })

-- canopy dark: continuous top with bumpy leaf blobs
local dark = c:rect(0, 0, 119, 3)
for i, x in ipairs(XS) do
  local y = (i % 2 == 1) and 6 or 10
  dark:add(c:ellipse(x, y, 7.5, 6)):add(c:ellipse(x - 5, y + 3, 3.5)):add(c:ellipse(x + 5, y + 3, 3.5))
end
c:part(dark, GV.ramp("#2e5a2c"), { gloss = false, contact = false })
-- canopy light: leaf clusters
for _, x in ipairs(XS) do
  local cx = x + 4.5
  local m = c:ellipse(cx, 11, 4.5, 3.5):add(c:ellipse(cx - 3, 13, 2.5)):add(c:ellipse(cx + 3, 13, 2.5))
  c:part(m, GV.ramp("#58a03e"), { gloss = { cx - 3, 9 }, contact = false })
end

-- vines (1 px on the half grid = 2 px out) with little leaves
local vine = "#b0bc66"
c:fill(c:line({ {36, 2}, {38, 6}, {38, 10}, {37, 13} }, 1), vine)
c:fill(c:line({ {75, 2}, {73, 5}, {73, 8}, {74, 11} }, 1), vine)
for _, p in ipairs({ {39, 5}, {37, 8}, {39, 11}, {74, 4}, {72, 7}, {75, 9} }) do c:px(p[1], p[2], "#7ab55c") end
c:px(37, 14, "#58a03e"); c:px(74, 12, "#58a03e")

-- floor
c:part(c:rect(0, 29, 119, 39), GV.ramp("#2e5a2c"), { gloss = false, contact = false, rim = false })
-- bushes: back row light green, front row moss
local back = c:mask()
for _, x in ipairs({ 0, 17, 34.5, 51.5, 68.5, 85.5, 103, 120 }) do back:add(c:ellipse(x, 31, 4.5, 2.5)) end
c:part(back, GV.ramp("#58a03e"), { gloss = false, contact = false })
local front = c:mask()
for _, x in ipairs({ 6, 23, 40.5, 57.5, 74.5, 91.5, 109 }) do front:add(c:ellipse(x, 36, 4, 2)) end
c:part(front, "moss", { gloss = false, contact = false })
for _, x in ipairs({ 6, 23, 40, 57, 74, 91, 109 }) do c:px(x - 2, 35, "#c8d77a") end
for _, x in ipairs({ 0, 17, 34, 51, 68, 85, 103, 119 }) do c:px(x - 2, 30, "#a4b86a") end

-- bird: red body, yellow head, perched on the stub, facing right
c:paint({
  "......ooo..",
  "oo...oyyyo.",
  "oroooryyeyb",
  ".orrrrrryo.",
  "..orwwwro..",
  "...ooooo...",
}, 47, 16, { o = "#2a1a10", r = "#d6322b", w = "#ae2a2a", y = "#e8a317", e = "#2a1a10", b = "#f08a24" })
c:px(53, 17, "#fff1c8") -- head gloss
c:px(49, 19, "#f2793a") -- back rim

-- corner vignette (flat)
c:paint({ "vvvv", "vv", "v" }, 0, 0, { v = "#17361c" })
c:paint({ "vvvv", "..vv", "...v" }, 116, 0, { v = "#17361c" })
c:paint({ "v", "vv", "vvvv" }, 0, 37, { v = "#17361c" })
c:paint({ "...v", "..vv", "vvvv" }, 116, 37, { v = "#17361c" })

-- hem stitches along top and bottom
c:seam({ {5, 1}, {114, 1} }, { free = true })
c:seam({ {5, 38}, {114, 38} }, { free = true })

local t = c:save(O .. "aseprite/" .. N .. ".aseprite", O .. "png/" .. N .. ".png")
print(GV.report(t))
