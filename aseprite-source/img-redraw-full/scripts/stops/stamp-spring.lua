local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cx, cy = 31.5, 31.5
local plate = c:ellipse(cx, cy, 26, 26)
c:build{
  { "plate", plate, GV.ramp("#e8d9b0"), { gloss = { 14, 15 } } },
}
local ink, inkS, inkL = "#3f8fb0", "#2f6290", "#8fcbd8"
-- dotted outer ring: 2px dots on r23
for i = 0, 23 do
  local a = i * (2 * math.pi / 24)
  local x = math.floor(cx + 23 * math.cos(a) + 0.5)
  local y = math.floor(cy + 23 * math.sin(a) + 0.5)
  c:fill(c:rect(x - 1, y - 1, x, y), ink)
end
-- solid ring band 3px, thin inner ring 1px
c:fill(c:ellipse(cx, cy, 20, 20):cut(c:ellipse(cx, cy, 17, 17)), ink)
c:fill(c:ellipse(cx, cy, 16, 16):cut(c:ellipse(cx, cy, 15, 15)), inkL)
-- bowl: flat top, round bottom
local bowl = c:ellipse(31.5, 36, 11, 8):cut(c:rect(0, 0, 63, 36))
c:fill(bowl, "#5a86b8")
c:fill(bowl:copy():clip(c:ellipse(31.5, 36, 11, 8):shift(1, 1):cut(c:ellipse(31.5, 36, 9, 6))), inkS)
c:fill(c:rect(20, 35, 43, 37), inkS)
c:fill(c:rect(21, 35, 42, 35), inkL)
-- three S-curve wisps (2px) with shade side
local function wisp(x)
  local pts = { {x, 33}, {x - 2, 30}, {x, 27}, {x + 2, 24}, {x, 21} }
  c:fill(c:line(pts, 2):shift(1, 0), inkS)
  c:fill(c:line(pts, 2), inkL)
end
wisp(24); wisp(32); wisp(40)
-- little drop
c:paint({ ".d.", "ddd", ".d." }, 35, 40, { d = "#c8ecdc" })

local t = c:save(O .. "aseprite/stops/stamp-spring.aseprite", O .. "png/stops/stamp-spring.png")
print(GV.report(t))
