local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 37, 17, 16.5)
-- spikes around the rim, irregular
local sp = { {200,3}, {228,4}, {252,3}, {280,4}, {305,3}, {330,4}, {355,3}, {20,4}, {45,3}, {150,3}, {175,4}, {115,3}, {72,3} }
for _, s in ipairs(sp) do
  local a = math.rad(s[1]); local h = s[2]
  local ca, sa = math.cos(a), math.sin(a)
  local function P(r, off) return { 32 + ca * r - sa * off, 37 + sa * r + ca * off } end
  body:add(c:poly({ P(15, -3), P(17 + h, 0), P(15, 3), }))
end
local stem = c:rect(31, 13, 33, 21)
local leaf = c:poly({ {33, 18}, {36, 12}, {41, 8}, {45, 7}, {44, 11}, {40, 16}, {35, 19} })
local p = c:build{
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "body", body, "gold", { gloss = { 23, 27 } } },
  { "leaf", leaf, GV.ramp("#4a8a3e"), { gloss = false } },
}
-- surface pyramids: small diamonds, varied
local spots = { {26,34}, {36,30}, {40,40}, {30,44}, {22,42}, {44,32}, {34,50}, {26,51}, {42,48}, {18,36}, {32,24}, {46,41} }
for _, s in ipairs(spots) do
  local x, y = s[1], s[2]
  c:paint({ ".t.", "tbb", ".b." }, x - 1, y - 1, { t = "#f5cf6a", b = "#b8661a" })
end
c:px(41, 11, "#2f5a2a"); c:px(39, 13, "#2f5a2a"); c:px(37, 15, "#2f5a2a")
c:ground(32, 56, 14, 1.5)
local t = c:save(O .. "aseprite/ph/durian.aseprite", O .. "png/ph/durian.png")
print(GV.report(t))
