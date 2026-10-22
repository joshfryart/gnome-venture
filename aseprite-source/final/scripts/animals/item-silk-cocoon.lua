local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- egg: narrow top, fuller bottom
local body = c:ellipse(31.5, 32, 14.5, 23)
body:add(c:ellipse(31.5, 37, 17, 18))
local cream = GV.ramp("#f6f2e4")
local tailPts = { {41, 51}, {44, 54}, {47, 54}, {49, 52}, {48, 50} }
c:build{
  { "body", body, cream, { cres = 4, deep = 2 } },
  { "cap", c:ellipse(31.5, 12, 5, 2.5), GV.ramp("#cfc7a8"), { flat = true, contact = false } },
  { "tail", c:line(tailPts, 2), GV.ramp("#d9d2b6"), { flat = true, contact = false } },
}
c:fill(c:rect(30, 12, 33, 12), "#a89f80")
-- thread bands: curves bowing downward, inside the body
local band, bandS = "#d9d2b6", "#bfb592"
local inner = body:shrink(2)
local function bow(y, x0, x1, drop)
  local pts = {}
  for i = 0, 10 do
    local u = (i / 10) * 2 - 1
    pts[#pts + 1] = { math.floor(x0 + (x1 - x0) * i / 10 + 0.5), math.floor(y + drop * (1 - u * u) + 0.5) }
  end
  c:line(pts, 2):clip(inner):each(function(x, yy)
    if (x - 31.5) + (yy - 32) > 10 then c:px(x, yy, bandS) else c:px(x, yy, band) end
  end)
end
bow(20, 19, 44, 4)
bow(31, 16, 47, 4)
bow(42, 17, 46, 4)
local t = c:save(O .. "aseprite/animals/item-silk-cocoon.aseprite", O .. "png/animals/item-silk-cocoon.png")
print(GV.report(t))
