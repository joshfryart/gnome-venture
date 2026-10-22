local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function star(cx, cy, r, ri)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local rr = (i % 2 == 0) and r or ri
    pts[#pts + 1] = { cx + rr * math.cos(a), cy + rr * math.sin(a) }
  end
  return c:poly(pts)
end

local goldR = GV.ramp("#e8a317", { gloss = "#fff1c8", shade = "#b8661a" })
-- roast dome: arch with a gently curved bottom
local dome = c:ellipse(31.5, 39, 17, 16):cut(c:rect(0, 40, 63, 63))
dome:add(c:ellipse(31.5, 40, 17, 3):cut(c:rect(0, 0, 63, 39)))

c:build{
  { "outer", c:ellipse(31.5, 45, 25.5, 10), GV.ramp("#d6c9b6"), { pale = true } },
  { "inner", c:ellipse(31.5, 43, 20, 7), GV.ramp("#f4f0e0"), { pale = true, rim = false } },
  { "greens", c:ellipse(46, 41, 5, 4), "moss" },
  { "dome", dome, goldR },
  { "taters", c:ellipse(16.5, 42, 5, 3.5), GV.ramp("#b07a10") },
  { "star", star(31.5, 13, 7, 3), GV.ramp("#f5cf6a"), { cres = 2 } },
}
-- roast ribs (scored crust)
c:seam({ { 22, 37 }, { 41, 37 } }, { on = 2, off = 1 })
c:seam({ { 33, 30 }, { 44, 30 } }, { on = 2, off = 1 })
-- platter rim seam
c:seam({ { 11, 50 }, { 15, 52 }, { 22, 54 }, { 41, 54 }, { 48, 52 }, { 52, 50 } })
-- greens: leafy dots
c:px(44, 40, "#c8d77a"); c:px(47, 39, "#c8d77a"); c:px(49, 41, "#4a8a3e")
local t = c:save(O .. "aseprite/ph/feast-mistmoor-supper.aseprite", O .. "png/ph/feast-mistmoor-supper.png")
print(GV.report(t))
