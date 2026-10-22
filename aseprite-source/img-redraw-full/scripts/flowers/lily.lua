local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local CX, CY = 31.5, 30.5
local function rot(a, l, s)
  local r = math.rad(a)
  local dx, dy = math.cos(r), -math.sin(r)
  return { CX + dx * l - dy * s, CY + dy * l + dx * s }
end
local function petal(a, L, W)
  return c:poly({ rot(a, 0, -2), rot(a, L * 0.35, -W), rot(a, L * 0.7, -W * 0.7), rot(a, L, -0.5), rot(a, L, 0.5),
    rot(a, L * 0.7, W * 0.7), rot(a, L * 0.35, W), rot(a, 0, 2) })
end
local parts = {}
for _, a in ipairs({ 90, 210, 330 }) do
  parts[#parts + 1] = { "o" .. a, petal(a, 18, 6), "petal", { gloss = false } }
end
local inner = GV.ramp("#f6b8cf")
for _, a in ipairs({ 30, 150, 270 }) do
  parts[#parts + 1] = { "i" .. a, petal(a, 21, 6), inner, { gloss = false } }
end
c:build(parts)
-- veins and gloss streaks on inner petals
for _, a in ipairs({ 30, 150, 270 }) do
end
for _, a in ipairs({ 30, 150, 270 }) do
  local p, q = rot(a, 12, 0), rot(a, 19, 0)
  for i = 0, 6 do
    local t = i / 6
    c:px(math.floor(p[1] + (q[1] - p[1]) * t + 0.5), math.floor(p[2] + (q[2] - p[2]) * t + 0.5), "#e46a9b")
  end
  local g1, g2 = rot(a, 9, -2), rot(a, 16, -3)
  for i = 0, 7 do
    local t = i / 7
    c:px(math.floor(g1[1] + (g2[1] - g1[1]) * t + 0.5), math.floor(g1[2] + (g2[2] - g1[2]) * t + 0.5), inner.gloss)
  end
end
-- stamens and centre
local st = {}
for _, a in ipairs({ 30, 150, 270 }) do
  local e = rot(a, 11, 0)
  st[#st + 1] = { "f" .. a, c:line({ { CX, CY }, e }, 2), "#b7791f", { flat = true, contour = false, contact = false } }
end
for _, a in ipairs({ 30, 150, 270 }) do
  local e = rot(a, 12, 0)
  st[#st + 1] = { "an" .. a, c:ellipse(math.floor(e[1]) + 0.5, math.floor(e[2]) + 0.5, 2.5, 1.5), "#e8891a", { gloss = false } }
end
st[#st + 1] = { "centre", c:ellipse(CX, CY, 3.5, 3.5), "#8bbf5a", { gloss = false } }
c:build(st)
c:px(30, 29, GV.ramp("#8bbf5a").gloss)
for k = 0, 5 do
  local p = rot(k * 60, 6, 0)
  c:px(math.floor(p[1] + 0.5), math.floor(p[2] + 0.5), "#7a2e4a")
end
local t = c:save(O .. "aseprite/flowers/lily.aseprite", O .. "png/flowers/lily.png")
print(GV.report(t))
