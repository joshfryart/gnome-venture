-- ico/ico-sunflower : 8 rounded yellow petals round a big dark seed disc, short stem and one leaf
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local cx, cy = 31.5, 26.5

local petals = c:mask()
for i = 0, 7 do
  local a = i * math.pi / 4 + math.pi / 8
  local d = 13
  petals:add(c:ellipse(cx + math.cos(a)*d, cy + math.sin(a)*d, 5.5, 6.5))
end

local leaf = c:poly({ {34, 47}, {41, 42}, {50, 42}, {46, 48}, {38, 50} })

c:build{
  { "stem",   c:rect(29, 36, 34, 53), GV.ramp("#58a03e"), { gloss = false } },
  { "leaf",   leaf, GV.ramp("#58a03e"), { gloss = false } },
  { "petals", petals, GV.ramp("#f2cf4a"), { gloss = { 22, 16 } } },
  { "disc",   c:ellipse(cx, cy, 9), GV.ramp("#5a3008"), { gloss = false } },
}

-- seed dots in a loose grid, glint upper-left
for _, q in ipairs({ {28,25}, {32,23}, {35,26}, {30,29}, {34,30}, {27,29}, {31,32}, {36,22} }) do
  c:px(q[1], q[2], "#2a1a10")
end
c:px(27, 21, "#c08a50"); c:px(28, 21, "#c08a50"); c:px(27, 22, "#c08a50")
-- leaf vein
c:fill(c:line({ {38, 47}, {46, 44} }, 1), "#2f5a2a")

local t = c:save(O .. "aseprite/ico/ico-sunflower.aseprite", O .. "png/ico/ico-sunflower.png")
print(GV.report(t))
