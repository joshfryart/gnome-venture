local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- five-point star cross-section, rounded tips
local cx, cy, R, r = 31.5, 37, 22, 13
local pts, tips = {}, {}
for i = 0, 9 do
  local a = -math.pi / 2 + i * math.pi / 5
  local rad = (i % 2 == 0) and R or r
  pts[#pts + 1] = { cx + rad * math.cos(a), cy + rad * math.sin(a) }
  if i % 2 == 0 then tips[#tips + 1] = { cx + (R - 7) * math.cos(a), cy + (R - 7) * math.sin(a) } end
end
local body = c:poly(pts):closed(2)
body = body:shrink(3):grow(3)

local fruit = GV.ramp("#f5cf6a", { shade = "#d0862a", deep = "#b8661a" })
local p = c:build{
  { "stem", c:rect(30, 9, 33, 18), "wood" ,{ flat = true } },
  { "leaf", c:ellipse(39, 13, 4.5, 2.5), "moss", { flat = true } },
  { "body", body, fruit, { gloss = { 22, 30 } } },
}
-- ridge lines from the core to each point
for _, t in ipairs(tips) do
  local m = c:line({ { math.floor(cx), math.floor(cy) }, { math.floor(t[1] + 0.5), math.floor(t[2] + 0.5) } }, 2)
  m:clip(body:shrink(3))
  c:fill(m, "#e8a317")
end
-- core pip
c:fill(c:ellipse(31.5, 36.5, 2, 2), "#d0862a")
local t = c:save(O .. "aseprite/ph/starfruit.aseprite", O .. "png/ph/starfruit.png")
print(GV.report(t))
