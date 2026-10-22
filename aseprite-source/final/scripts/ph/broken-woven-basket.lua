local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wick = GV.ramp("#b07a10")
local straw = GV.ramp("#f5cf6a")
-- handle left half: bold arc from the rim up to a snapped end near the top
local handle = c:line({ {15, 33}, {16, 24}, {20, 16}, {26, 11}, {32, 9}, {36, 10} }, 4)
handle:del(38, 9); handle:del(39, 11); handle:set(39, 10); handle:del(37, 12)
-- right stub sticking up from the rim, ragged top
local stub = c:rect(46, 23, 50, 33)
stub:del(46, 23); stub:del(48, 23); stub:del(50, 23); stub:del(50, 24)
local body = c:poly({ {12, 33}, {54, 33}, {49, 55}, {17, 55} })
local rimband = c:rrect(10, 30, 54, 35, 2)
c:build{
  { "handle", handle, wick },
  { "stub", stub, wick },
  { "body", body, wick },
  { "rim", rimband, GV.ramp("#d0862a") },
}
-- weave bands (straw), clipped to body, broken by wicker ribs
for _, y in ipairs({ 39, 47 }) do
  c:fill(c:rect(14, y, 53, y + 1):clip(body), straw.base)
  for x = 17, 52, 6 do c:px(x, y, wick.shade); c:px(x, y + 1, wick.shade) end
end
for x = 20, 47, 6 do
  for y = 42, 45 do if body:has(x, y) then c:px(x, y, wick.shade) end end
  for y = 50, 53 do if body:has(x, y) then c:px(x, y, wick.shade) end end
end
-- knot where the handle meets the rim
c:part(c:ellipse(17, 32, 3.5, 3.5), GV.ramp("#8c4a1a"), { gloss = { 16, 30 } })
-- crack zigzag
c:line({ {34, 35}, {37, 40}, {32, 45}, {36, 50}, {33, 54} }, 2):each(function(x, y)
  if body:has(x, y) then c:px(x, y, "#2a1a10") end
end)
-- loose strand curling off the lower right, and a bent stub on the left
c:part(c:line({ {47, 51}, {51, 50}, {53, 47}, {52, 45} }, 2), straw, { flat = true })
c:part(c:line({ {13, 44}, {9, 43}, {8, 41} }, 2), straw, { flat = true })
c:ground(32.5, 56, 17, 1.5)
local t = c:save(O .. "aseprite/ph/broken-woven-basket.aseprite", O .. "png/ph/broken-woven-basket.png")
print(GV.report(t))
