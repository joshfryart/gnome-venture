local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function oval(cx, cy, rx, ry, deg)
  local m = c:mask(); local a = math.rad(deg); local ca, sa = math.cos(a), math.sin(a)
  local R = math.ceil(math.max(rx, ry)) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do for x = math.floor(cx - R), math.ceil(cx + R) do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local gold, amber = "gold", GV.ramp("#b07a10")
local awn = GV.ramp("#f5cf6a")
-- leaf sweeps up to the RIGHT (triticale's goes left)
local leaf = c:poly({ {31,53}, {36,48}, {41,42}, {44,36}, {40,40}, {34,45}, {30,49} })
local parts = {
  { "awnL", c:line({ {29,14}, {22,6} }, 2), awn, { flat = true } },
  { "awnR", c:line({ {35,14}, {42,6} }, 2), awn, { flat = true } },
  { "stalk", c:rect(31, 30, 33, 56), GV.ramp("#4a8a3e"), { flat = true } },
  { "leaf",  leaf, "moss", { gloss = false } },
  { "l4", oval(27, 41, 3.5, 5.5, -20), gold, { gloss = false } },
  { "r4", oval(37, 41, 3.5, 5.5, 20), amber, { gloss = false } },
  { "l3", oval(27, 34.5, 3.5, 5.5, -20), gold, { gloss = false } },
  { "r3", oval(37, 34.5, 3.5, 5.5, 20), amber, { gloss = false } },
  { "l2", oval(27, 28, 3.5, 5.5, -20), gold, { gloss = false } },
  { "r2", oval(37, 28, 3.5, 5.5, 20), amber, { gloss = false } },
  { "tip", oval(32, 15.5, 3.5, 7.5, 0), gold, { gloss = false } },
  { "l1", oval(27, 21.5, 3.5, 5.5, -20), gold, { gloss = { 25, 18 } } },
  { "r1", oval(37, 21.5, 3.5, 5.5, 20), amber, { gloss = false } },
}
c:build(parts)
c:px(31, 11, "#fff1c8")
local t = c:save(O .. "aseprite/ph/tritordeum.aseprite", O .. "png/ph/tritordeum.png")
print(GV.report(t))
