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
local pink, red = GV.R.petal, GV.ramp("#a8241f")
local leaf = c:poly({ {32,51}, {27,47}, {22,42}, {21,38}, {25,41}, {30,45}, {34,48} })
local parts = {
  { "stalk", c:rect(31, 26, 33, 55), GV.ramp("#4a8a3e"), { flat = true } },
  { "leaf",  leaf, "moss", { gloss = false } },
  { "l3", oval(26, 38, 4.5, 6.5, -25), pink, { gloss = false } },
  { "r3", oval(38, 38, 4.5, 6.5, 25), red, { gloss = false } },
  { "l2", oval(26, 30.5, 4.5, 6.5, -25), pink, { gloss = false } },
  { "r2", oval(38, 30.5, 4.5, 6.5, 25), red, { gloss = false } },
  { "tip", oval(32, 16, 4, 7, 0), pink, { gloss = false } },
  { "l1", oval(26, 23, 4.5, 6.5, -25), pink, { gloss = { 24, 19 } } },
  { "r1", oval(38, 23, 4.5, 6.5, 25), red, { gloss = false } },
}
c:build(parts)
c:px(30, 12, "#fff3c8")
local t = c:save(O .. "aseprite/ph/triticale.aseprite", O .. "png/ph/triticale.png")
print(GV.report(t))
