local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glassR = GV.ramp("#a9d6ea")
local body = c:poly({ {13, 44}, {13, 30}, {21, 13}, {43, 13}, {51, 30}, {51, 44} })
local ridge = c:rrect(28, 8, 36, 14, 2)        -- roof ridge cap
local lampL = c:rrect(8, 23, 14, 31, 2)
local lampR = c:rrect(50, 23, 56, 31, 2)
local plants = c:mask()
for _, x in ipairs({ 17, 23, 29, 35, 41, 47 }) do plants:add(c:ellipse(x + 0.5, 37, 4, 4)) end
plants:add(c:rect(15, 37, 49, 42))
local base = c:rrect(11, 42, 53, 51, 2)

local p = c:build{
  { "ridge", ridge, "stone" },
  { "body", body, glassR, { gloss = false } },
  { "lampL", lampL, "gold", { gloss = false } },
  { "lampR", lampR, "gold", { gloss = false } },
  { "plants", plants, "moss", { gloss = false } },
  { "base", base, "stone" },
}
-- pale pane frame
local pane = "#f4f0e0"
local frames = c:mask()
frames:add(c:line({ {16, 29}, {23, 15} }, 1)); frames:add(c:line({ {48, 29}, {41, 15} }, 1))
frames:add(c:rect(16, 30, 48, 30))
frames:add(c:rect(23, 16, 41, 16))
for _, x in ipairs({ 25, 32, 39 }) do frames:add(c:rect(x, 16, x, 33)) end
frames:clip(body:shrink(1)); frames:cut(plants)
c:fill(frames, pane)
-- glass glints
c:paint({ "g.", "gg", ".g" }, 27, 19, { g = "#fff3c8" })
c:px(17, 27, "#e4f4fa"); c:px(18, 25, "#e4f4fa")
-- blooms
for _, b in ipairs({ { 22, 34 }, { 38, 33 } }) do
  c:paint({ ".r.", "rgr", ".r." }, b[1] - 1, b[2] - 1, { r = "#d6322b", g = "#ffc27a" })
end
-- lamp flames
c:paint({ "y", "o" }, 11, 26, { y = "#fff1c8", o = "#f08a24" })
c:paint({ "y", "o" }, 53, 26, { y = "#fff1c8", o = "#f08a24" })
-- base lip seam
c:seam({ { 14, 45 }, { 50, 45 } })

local t = c:save(D .. "img-redraw-full/aseprite/ph/greenhouse-lantern.aseprite",
                 D .. "img-redraw-full/png/ph/greenhouse-lantern.png")
print(GV.report(t))
