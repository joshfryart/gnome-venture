-- ph/diver-s-creel : wicker creel with tall arch handle
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wick = GV.ramp("#e8a317", { shade = "#b8661a", deep = "#7a3a14" })
local hand = GV.ramp("#b07a45")

-- arch handle: half ellipse from (16,37) over (32,11) to (48,37)
local pts = {}
for i = 0, 24 do
  local a = math.pi * i / 24
  pts[#pts + 1] = { math.floor(32 - 14 * math.cos(a) + 0.5), math.floor(34 - 21 * math.sin(a) + 0.5) }
end
local handle = c:line(pts, 4)

-- tapered basket body with a rolled rim
local body = c:poly({ {14, 33}, {51, 33}, {46, 54}, {18, 54} })
local rim = c:rrect(12, 30, 51, 34, 2)

c:build{
  { "handle", handle, hand },
  { "body", body, wick, { gloss = { 21, 38 } } },
  { "rim", rim, wick, { gloss = false } },
}
-- weave bands (gold thread colour), clipped to the body
local b1 = c:line({ {14, 40}, {50, 40} }, 2):clip(body)
local b2 = c:line({ {16, 47}, {48, 47} }, 2):clip(body)
c:fill(b1, "#f5cf6a"); c:fill(b2, "#f5cf6a")
c:fill(c:line({ {14, 42}, {50, 42} }, 1):clip(body), "#b8661a")
c:fill(c:line({ {16, 49}, {48, 49} }, 1):clip(body), "#b8661a")
-- vertical wicker ticks between bands
for _, x in ipairs({ 20, 26, 32, 38, 44 }) do
  for _, y in ipairs({ 36, 37, 44, 45, 51, 52 }) do
    if body:has(x, y) then c:px(x, y, "#b8661a") end
  end
end
-- rim weave seam
c:seam({ {14, 32}, {49, 32} })
-- clasp: grey round disc on the rim
c:part(c:ellipse(32, 33, 3.5, 3.5), "stone", { gloss = { 31, 31 } })
c:px(32, 34, "#4a2c1a")

local t = c:save(O .. "aseprite/ph/diver-s-creel.aseprite", O .. "png/ph/diver-s-creel.png")
print(GV.report(t))
