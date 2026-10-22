local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local body = c:ellipse(31.5, 38, 25, 18)
-- slight top dent
body:cut(c:ellipse(31.5, 18, 5, 2))
-- 5-point star calyx
local pts = {}
local cx, cy = 31.5, 23
for i = 0, 9 do
  local a = -math.pi / 2 + i * math.pi / 5
  local r = (i % 2 == 0) and 13 or 5
  pts[#pts + 1] = { cx + r * math.cos(a), cy + r * 0.8 * math.sin(a) }
end
local star = c:poly(pts):cut(c:rect(0, 0, 63, 14)):add(c:ellipse(31.5, 23, 6, 4))
local stem = c:rrect(29, 9, 34, 19, 2)

local p = c:build{
  { "body", body, "red" },
  { "calyx", star, "moss", { gloss = false } },
  { "stem", stem, GV.ramp("#4a8a3e", { deep = "#2f5a2a" }) },
}
-- veins
local v = "#2f5a2a"
c:paint({ "v...", ".v..", "..v." }, 22, 23, { v = v })
c:paint({ "...v", "..v.", ".v.." }, 38, 23, { v = v })
c:paint({ "v", "v", "v" }, 26, 28, { v = v })
c:paint({ "v", "v", "v" }, 37, 28, { v = v })
local t = c:save(O .. "aseprite/ico/ico-tomato.aseprite", O .. "png/ico/ico-tomato.png")
print(GV.report(t))
