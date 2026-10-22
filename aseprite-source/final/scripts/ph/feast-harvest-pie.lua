-- ph/feast-harvest-pie : domed golden pie on a wide cream plate, gold star above
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function star(cx, cy, R, r)
  local p = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local rr = (i % 2 == 0) and R or r
    p[#p + 1] = { cx + math.cos(a) * rr, cy + math.sin(a) * rr }
  end
  return c:poly(p)
end

local plate = c:ellipse(31.5, 45, 25, 9)
local dish  = c:ellipse(31.5, 43, 20, 6)
local dome  = c:ellipse(31.5, 38, 17, 15):cut(c:rect(0, 43, 63, 63)):add(c:ellipse(31.5, 42, 17, 3))
local crust = c:rrect(13, 39, 50, 45, 3)
c:build{
  { "plate", plate, "cream" },
  { "dish",  dish,  GV.ramp("#f4f0e0"), { gloss = false } },
  { "dome",  dome,  GV.ramp("#dcb06a"), { gloss = { 20, 27 } } },
  { "crust", crust, GV.ramp("#c98a3f"), { gloss = false } },
  { "plum",  c:ellipse(23, 33, 3.5), GV.ramp("#a5663a"), { gloss = false } },
  { "berry", c:ellipse(40, 32, 4), "moss", { gloss = false } },
  { "apri",  c:ellipse(31.5, 26, 3), "gold", { gloss = false } },
  { "star",  star(31.5, 13, 9, 4), "gold", { gloss = false } },
}
c:px(22, 31, "#d9a58a"); c:px(38, 30, "#c8d77a"); c:px(30, 24, "#fff1c8"); c:px(29, 10, "#fff1c8"); c:px(30, 11, "#fff1c8")
c:seam({ {16, 42}, {47, 42} })
c:ground(31.5, 55, 18, 1.5)
local t = c:save(O .. "aseprite/ph/feast-harvest-pie.aseprite", O .. "png/ph/feast-harvest-pie.png")
print(GV.report(t))
