local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leafR = GV.ramp("#7ab55c")
local midR = GV.ramp("#58a03e")
local stemR = GV.ramp("#2f5a2a")
local px, py = 32, 36
-- pointed lens leaf from the pivot, length L, half-width W, rotated deg from up
local function leaf(deg, L, W)
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  local pts = {}
  local n = 12
  for i = 0, n do
    local t = i / n
    local w = W * math.sin(math.pi * t) ^ 0.8
    pts[#pts + 1] = { w, -L * t }
  end
  for i = n - 1, 1, -1 do
    local t = i / n
    local w = W * math.sin(math.pi * t) ^ 0.8
    pts[#pts + 1] = { -w, -L * t }
  end
  local out = {}
  for _, p in ipairs(pts) do
    out[#out + 1] = { px + p[1] * ca - p[2] * sa, py + p[1] * sa + p[2] * ca }
  end
  return c:poly(out)
end
local stem = c:rect(31, 34, 33, 55)
local p = c:build{
  { "stem", stem, stemR, { flat = true } },
  { "farL", leaf(-70, 24, 4.5), leafR, { gloss = false } },
  { "farR", leaf(70, 24, 4.5), leafR, { gloss = false } },
  { "L", leaf(-35, 26, 5), leafR, { gloss = false } },
  { "R", leaf(35, 26, 5), leafR, { gloss = false } },
  { "mid", leaf(0, 28, 5.5), midR, { gloss = { 30, 16 } } },
  { "bud", c:ellipse(32, 35, 5, 5), "petal", { gloss = { 30, 32 } } },
}
-- leaf midribs
c:fill(c:line({ {32, 12}, {32, 27} }, 1), midR.shade)
-- seed dot beside the stem foot
c:paint({ ".c.", "ccc", ".s." }, 36, 52, { c = "#f1ece0", s = "#c9a96e" })
c:ground(32, 57, 6, 1)
local t = c:save(O .. "aseprite/ph/bromeliad-seeds.aseprite", O .. "png/ph/bromeliad-seeds.png")
print(GV.report(t))
