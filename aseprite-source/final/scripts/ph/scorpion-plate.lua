local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local outer = c:poly({ {32,7},{54,19},{51,46},{32,57},{13,46},{10,19} })
local inner = c:poly({ {32,14},{47,22},{44,41},{32,49},{20,41},{17,22} })
local p = c:build{
  { "outer", outer, GV.ramp("#dcb06a"), { gloss = {16, 19} } },
  { "inner", inner, GV.ramp("#a5663a"), { light = outer, gloss = false } },
}
-- central ridge: dark spine with a lit left edge
c:fill(c:rect(31, 10, 32, 53), "#2a1a10")
for y = 11, 52 do if p.outer.m:has(30, y) or p.inner.m:has(30,y) then c:px(30, y, "#ecc58a") end end
-- cross grooves
for _, y in ipairs({24, 32, 40}) do
  local w = (y == 40) and 7 or 9
  c:fill(c:rect(31 - 2 - w, y, 28, y), "#5e2f1e")
  c:fill(c:rect(35, y, 35 + w - 1, y), "#5e2f1e")
  c:fill(c:rect(31 - 2 - w, y - 1, 28, y - 1), "#c58a52")
  c:fill(c:rect(35, y - 1, 35 + w - 1, y - 1), "#c58a52")
end
-- small gloss dot on inner plate
c:px(22, 25, "#ecc58a"); c:px(23, 25, "#ecc58a"); c:px(22, 26, "#ecc58a")
local t = c:save(O .. "aseprite/ph/scorpion-plate.aseprite", O .. "png/ph/scorpion-plate.png")
print(GV.report(t))
