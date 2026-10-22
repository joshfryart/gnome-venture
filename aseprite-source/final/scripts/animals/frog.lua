-- animals/frog : chubby front-on frog, big eyes on top
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(31.5, 38, 22.5, 13):add(c:rrect(10, 38, 53, 52, 8))
local belly = c:ellipse(31.5, 47, 12.5, 6):clip(body)
local feet = c:ellipse(15, 52, 6.5, 2.5):add(c:ellipse(48, 52, 6.5, 2.5))
local bumps = c:ellipse(20, 22, 7.5):add(c:ellipse(43, 22, 7.5))
local whites = c:ellipse(20, 22, 4.5):add(c:ellipse(43, 22, 4.5))

c:build{
  { "body",   body,   "moss", { gloss = { 13, 33 } } },
  { "belly",  belly,  GV.ramp("#c8d77a"), { gloss = false, contact = false } },
  { "feet",   feet,   GV.ramp("#4a8a3e"), { gloss = false } },
  { "bumps",  bumps,  GV.ramp("#7ab55c", { rim = "#a4b86a" }), { gloss = { 15, 17 } } },
  { "whites", whites, "cream", { gloss = false, contact = false } },
}
-- locked eyes, slightly inward and low for a sleepy-friendly gaze
c:eye(19, 20); c:eye(40, 20)

-- wide smile + nostrils
local smile = "#2f5a2a"
c:fill(c:line({ {21, 37}, {25, 40}, {31, 41}, {32, 41}, {38, 40}, {42, 37} }, 1), smile)
c:px(20, 36, smile); c:px(43, 36, smile)
c:px(28, 33, smile); c:px(35, 33, smile)
-- toe splits on the feet
for _, x in ipairs({ 12, 16, 46, 50 }) do c:px(x, 53, GV.R.moss.deep) end

local t = c:save(O .. "aseprite/animals/frog.aseprite", O .. "png/animals/frog.png")
print(GV.report(t))
