local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local seedR = GV.ramp("#7ab55c", { shade = "#4a8a3e", gloss = "#c8d77a" })
local leafR = GV.ramp("#58a03e", { shade = "#2e5a2c" })
local woodR = GV.ramp("#b07a45", { shade = "#8a4f2a" })
local rimR = GV.ramp("#d9a660", { shade = "#8a4f2a" })
local braceR = GV.ramp("#a8582f")

local seed = c:ellipse(31.5, 20, 9, 8)
local stem = c:line({ {32,13}, {33,11} }, 2)
local leaf = c:ellipse(37.5, 11, 3.5, 2)
local body = c:rrect(13, 28, 50, 52, 2)
local brace = c:line({ {16,49}, {48,31} }, 3):clip(body:shrink(1))
local rim = c:rrect(11, 24, 52, 30, 2)

c:build{
  { "seed", seed, seedR },
  { "stem", stem, leafR, { flat = true } },
  { "leaf", leaf, leafR, { flat = true } },
  { "body", body, woodR },
  { "brace", brace, braceR, { gloss = false } },
  { "rim", rim, rimR },
}

-- plank gaps (not over the brace)
for _, y in ipairs({ 37, 44 }) do
  for x = 15, 48 do
    if not brace:has(x, y) then c:px(x, y, "#5e2f1e") end
  end
end
-- nails
for _, p in ipairs({ {15,32}, {47,32}, {15,48}, {47,48} }) do
  c:paint({ "nn", "nn" }, p[1], p[2], { n = "#5e2f1e" })
end

local t = c:save(O .. "aseprite/ph/melon-seed.aseprite", O .. "png/ph/melon-seed.png")
print(GV.report(t))
