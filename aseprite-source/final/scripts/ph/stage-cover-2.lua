local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local mound = c:ellipse(31.5, 44, 21, 8)
local top = c:ellipse(31.5, 42, 17, 5)
local light = mound:copy()
local cx = { 16.5, 26.5, 36.5, 46.5 }
local cy = { 37, 33.5, 37, 33.5 }
local col = { "#58a03e", "#7ab55c", "#58a03e", "#7ab55c" }
local parts = {
  { "mound", mound, "#8c4a1a", { stitch = { side = "lit" } } },
  { "top", top, "#a5663a", { gloss = false, contact = false } },
}
-- back row first (taller ones), then front row so contours fall between
local order = { 2, 4, 1, 3 }
for _, i in ipairs(order) do
  local m = c:ellipse(cx[i], cy[i], 6, 6)
  -- small leafy notch at the top of each tuft
  m:cut(c:rect(math.floor(cx[i]), math.floor(cy[i] - 6), math.floor(cx[i]), math.floor(cy[i] - 5)))
  parts[#parts + 1] = { "tuft" .. i, m, col[i] }
end
c:build(parts)
-- tiny centre vein on each tuft (leaf fold)
for i = 1, 4 do
  local x, y = math.floor(cx[i]), math.floor(cy[i])
  c:px(x, y - 3, GV.ramp(col[i]).shade)
  c:px(x, y - 2, GV.ramp(col[i]).shade)
end
local t = c:save(O .. "aseprite/ph/stage-cover-2.aseprite", O .. "png/ph/stage-cover-2.png")
print(GV.report(t))
