local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
-- drawn at 120x80, written 2x (240x160)
local c = GV.canvas{ w = 120, h = 80, mode = "scene", out = 2 }
-- hill: wavy top edge 59 -> 56 (centre) -> 52 (right)
local pts = {}
for x = -2, 122, 2 do
  local base = x <= 60 and (59 - 3 * x / 60) or (56 - 4 * (x - 60) / 60)
  pts[#pts + 1] = { x, base + 1.2 * math.sin(x / 9) }
end
pts[#pts + 1] = { 122, 82 }; pts[#pts + 1] = { -2, 82 }
local hill = c:poly(pts)
c:build{
  { "bg", c:rect(-2, -2, 121, 81), "#efdccb", { flat = true, outline = false, rim = false } },
  { "hill", hill, "#b0bc66", { gloss = false } },
}
-- gnome (centre x44, feet y63)
local tunic = c:rrect(35, 52, 53, 64, 3)
local face = c:ellipse(44.5, 44, 7.5, 6.5)
local beard = c:poly({ { 37, 48 }, { 52, 48 }, { 52, 54 }, { 48, 61 }, { 44.5, 64 }, { 41, 61 }, { 37, 54 } })
local hat = c:poly({ { 36, 38 }, { 44, 19 }, { 46, 19 }, { 53, 38 } })
local brim = c:rrect(34, 35, 54, 38, 2)
c:build{
  { "boots", c:rrect(37, 61, 51, 65, 1), "dusk", { gloss = false } },
  { "tunic", tunic, "#3f93b2" },
  { "face", face, "skin" },
  { "beard", beard, "cream", { gloss = { 39, 49 } } },
  { "nose", c:ellipse(44.5, 47, 2, 1.5), "skin", { flat = true } },
  { "hat", hat, "#d6322b" },
  { "brim", brim, "#c66b50" },
  { "pom", c:ellipse(45, 18, 3, 3), "gold", { gloss = false } },
}
c:seam({ { 35, 36.5 }, { 54, 36.5 } }, { on = 2, off = 1 })
c:eye(40, 42, true); c:eye(47, 42, true)
-- stat bars
local fills = { { 25, "#e46a9b" }, { 17, "#3f93b2" }, { 31, "#e8a317" }, { 21, "#7ab55c" } }
for i, f in ipairs(fills) do
  local y = 19 + (i - 1) * 9
  c:part(c:rrect(75, y, 109, y + 4, 2), GV.ramp("#fff3c8"), { gloss = false, cres = 2 })
  c:part(c:rrect(76, y + 1, 75 + f[1], y + 3, 1), GV.ramp(f[2]), { gloss = false, cres = 1, deep = 1, contour = false })
end
-- sparkle star and dot
c:part(c:poly({ { 100, 15 }, { 101, 19 }, { 105, 20 }, { 101, 21 }, { 100, 26 }, { 99, 21 }, { 95, 20 }, { 99, 19 } }):add(c:rect(99, 18, 100, 22)):add(c:rect(97, 19, 102, 20)), "gold", { flat = true })
c:part(c:ellipse(31, 30, 1.5, 1.5), "gold", { flat = true })
-- apple
c:build{
  { "stem", c:line({ { 88, 62 }, { 89, 59 } }, 2), "#4e3a8a", { flat = true } },
  { "leaf", c:ellipse(92, 60, 2.5, 1.5), "#58a03e", { flat = true } },
  { "apple", c:ellipse(88, 66, 4.5, 4), "#d6322b", { gloss = { 86, 64 } } },
}
-- hem stitch top and bottom
c:seam({ { 0, 1 }, { 119, 1 } }, { on = 2, off = 1, free = true })
c:seam({ { 0, 78 }, { 119, 78 } }, { on = 2, off = 1, free = true })
local t = c:save(O .. "aseprite/landing/stats.aseprite", O .. "png/landing/stats.png")
print(GV.report(t))
