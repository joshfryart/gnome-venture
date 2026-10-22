local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local orange = GV.ramp("#f08a24", { shade = "#e0501f", deep = "#b8452f" })
local body = c:ellipse(31.5, 38, 16, 14.5)
local knob = c:rrect(26, 18, 37, 27, 4)
local stem = c:rect(30, 12, 32, 19)
-- right-angled leaf lying out to the right
local leaf = c:poly({ {33, 17}, {37, 13}, {43, 11}, {51, 12}, {46, 16}, {40, 18}, {35, 19} })

local p = c:build{
  { "body", body, orange, { cres = 6, deep = 3, gloss = { 23, 30 } } },
  { "knob", knob, orange, { gloss = false, cres = 3, deep = 1 } },
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "leaf", leaf, "#58a03e", { gloss = false } },
}
-- midrib
for x = 36, 48 do
  local y = 16 - math.floor((x - 36) * 3 / 12 + 0.5)
  c:px(x, y, "#4a8a3e")
end
-- pores on lit side
c:px(28, 31, "#e0501f"); c:px(21, 38, "#e0501f"); c:px(25, 43, "#e0501f"); c:px(33, 29, "#e0501f")

local t = c:save(D .. "img-redraw-full/aseprite/ph/tangelo.aseprite", D .. "img-redraw-full/png/ph/tangelo.png")
print(GV.report(t))
