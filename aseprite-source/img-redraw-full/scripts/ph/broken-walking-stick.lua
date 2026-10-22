local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function pill(m, a, b, r)
  local n = math.ceil(math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2])))
  for k = 0, n do
    local t = k / n
    m:add(c:ellipse(a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, r, r))
  end
  return m
end
local woodS = GV.ramp("#d9a660")
-- upper half with jagged lower end
local upper = pill(c:mask(), { 41, 19 }, { 35, 30 }, 2.5)
upper:add(c:poly({ {32, 31}, {35, 34}, {36, 31}, {38, 33}, {39, 29} }))
-- lower half with jagged upper end
local lower = pill(c:mask(), { 27, 41 }, { 21, 50 }, 2.5)
lower:add(c:poly({ {24, 40}, {25, 37}, {27, 39}, {28, 36}, {30, 41} }))
local sliver = c:poly({ {11, 42}, {17, 39}, {19, 40}, {13, 44} })
local chip = c:poly({ {41, 43}, {45, 41}, {46, 45}, {42, 46} })
local knob = c:ellipse(43.5, 15.5, 5.5, 5.5)
c:build{
  { "sliver", sliver, "wood", { flat = true } },
  { "chip", chip, "wood", { flat = true } },
  { "lower", lower, woodS, { light = upper:copy():add(lower) } },
  { "upper", upper, woodS },
  { "knob", knob, GV.ramp("#7a3f22", { gloss = "#ecc58a" }) },
}
-- pale torn fibres on the break faces
c:paint({ "p.p", ".p." }, 33, 31, { p = "#ecc58a" })
c:paint({ ".p.", "p.p" }, 25, 39, { p = "#ecc58a" })
-- crack on the upper half
c:paint({ "k.", ".k", "k." }, 38, 23, { k = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/broken-walking-stick.aseprite", O .. "png/ph/broken-walking-stick.png")
print(GV.report(t))
