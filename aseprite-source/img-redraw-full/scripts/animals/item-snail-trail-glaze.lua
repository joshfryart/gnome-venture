local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local belly = c:ellipse(31.5, 38, 16, 13)
local glass = belly:copy():add(c:rect(26, 18, 37, 27))
-- liquid: inside the belly, wavy top around y 36
local inner = belly:shrink(2)
local liq = c:mask()
inner:each(function(x, y)
  local top = 36 + math.floor(math.sin((x - 14) / 2.6) * 1.3 + 0.5)
  if y >= top then liq:set(x, y) end
end)
local p = c:build{
  { "glass", glass, GV.ramp("#bfe4ee") },
  { "liquid", liq, GV.ramp("#8fcbd8"), { gloss = false, rim = false } },
  { "cork", c:rrect(24, 11, 39, 19, 2), "wood" },
}
c:seam({ { 25, 19 }, { 38, 19 } })
-- cork grain
c:px(28, 14, "#8a4f2a"); c:px(33, 16, "#8a4f2a"); c:px(36, 13, "#8a4f2a")
-- silver snail-trail squiggle
c:fill(c:line({ { 24, 42 }, { 27, 44 }, { 30, 43 }, { 33, 45 }, { 36, 43 }, { 39, 41 } }, 1), "#eef8fa")
c:fill(c:line({ { 24, 43 }, { 27, 45 }, { 30, 44 }, { 33, 46 }, { 36, 44 }, { 39, 42 } }, 1), "#c8ecdc")
-- bubbles
c:fill(c:rect(38, 39, 39, 40), "#c8ecdc"); c:px(38, 39, "#eef8fa")
c:fill(c:rect(29, 38, 30, 39), "#c8ecdc"); c:px(29, 38, "#eef8fa")
c:px(43, 46, "#c8ecdc")
-- glass edge reflection at the left shoulder
c:fill(c:line({ { 19, 33 }, { 18, 36 }, { 18, 42 } }, 1), "#3f8fb0")
c:ground(31.5, 52, 13, 1.5)
local t = c:save(O .. "aseprite/animals/item-snail-trail-glaze.aseprite", O .. "png/animals/item-snail-trail-glaze.png")
print(GV.report(t))
