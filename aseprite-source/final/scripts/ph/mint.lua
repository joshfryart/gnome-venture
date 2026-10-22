local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function hw(y)
  if y <= 33 then return 19 * ((y - 10) / 23) ^ 0.75 end
  local u = (y - 33) / 19
  return 19 * math.sqrt(math.max(0, 1 - u * u))
end
-- toothed edge: 4 teeth per side between y 14 and 46
local function tooth(y)
  if y < 14 or y > 47 then return 0 end
  local ph = ((y - 14) / 8.25) % 1          -- sawtooth: tip at start, notch at end
  return 3.5 * (1 - ph) - 1.5
end
local L, R = {}, {}
for y = 10, 52 do
  local w = hw(y) + tooth(y)
  if w < 0.5 then w = 0.5 end
  L[#L+1] = { 31.5 - w, y }; R[#R+1] = { 32.5 + w, y }
end
local pts = {}
for i = 1, #R do pts[#pts+1] = R[i] end
for i = #L, 1, -1 do pts[#pts+1] = L[i] end
local leaf = c:poly(pts)
local leafR = GV.ramp("#4fb88a", { rim = "#a8e0c0" })
local p = c:build{
  { "stem", c:line({ {31,55}, {31,50} }, 3), "#4a8a3e", { flat = true } },
  { "leaf", leaf, leafR, { gloss = { 22, 24 } } },
}
local V = "#2f8a64"
local veins = c:line({ {31,50}, {31,15} }, 2)
veins:add(c:line({ {31,38}, {21,30} }, 2))
veins:add(c:line({ {32,30}, {41,22} }, 2))
veins:add(c:line({ {31,45}, {23,39} }, 2))
veins:add(c:line({ {32,42}, {41,35} }, 2))
veins:clip(leaf:shrink(2))
c:fill(veins, V)
-- bright highlight thread on the centre vein (lit side)
for y = 17, 46, 1 do if y % 3 ~= 0 then c:px(31, y, "#7fd8a8") end end
local t = c:save(O .. "aseprite/ph/mint.aseprite", O .. "png/ph/mint.png")
print(GV.report(t))
