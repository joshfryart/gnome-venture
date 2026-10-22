local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tall arch handle
local arc = {}
for i = 0, 16 do
  local a = math.pi * i / 16
  arc[#arc + 1] = { math.floor(31.5 - 16 * math.cos(a) + 0.5), math.floor(33 - 18 * math.sin(a) + 0.5) }
end
local handle = c:line(arc, 4)

local body = c:poly({ {12, 34}, {53, 34}, {48, 57}, {17, 57} })
local berries = c:ellipse(24, 29, 3, 3)
berries:add(c:ellipse(31.5, 26.5, 3.5, 3.5))
berries:add(c:ellipse(39, 29, 3, 3))
local lip = c:rrect(10, 31, 54, 35, 2)

local wood = "wood"
local p = c:build{
  { "handle", handle, GV.ramp("#c48a50"), { flat = true } },
  { "body", body, wood, { gloss = { 22, 39 } } },
  { "berries", berries, "red", { gloss = false } },
  { "lip", lip, GV.ramp("#d9a660"), { gloss = false } },
}

-- weave rows
local R = GV.R.wood
for _, y in ipairs({ 41, 49 }) do
  local m = c:mask()
  m:add(c:rect(0, y, 63, y + 1)); m:clip(body:shrink(2))
  m:each(function(x, yy) c:px(x, yy, R.rim) end)
  m:each(function(x, yy) if yy == y + 1 then c:px(x, yy, R.shade) end end)
end
-- vertical ticks alternating between rows
for _, band in ipairs({ { 36, 40, 0 }, { 43, 48, 3 }, { 51, 54, 0 } }) do
  for x = 14 + band[3], 52, 6 do
    for y = band[1], band[2] do
      if body:shrink(2):has(x, y) then c:px(x, y, R.shade) end
    end
  end
end

-- berry glints and leaf
c:px(22, 28, GV.R.red.gloss); c:px(30, 25, GV.R.red.gloss); c:px(29, 25, GV.R.red.gloss); c:px(37, 28, GV.R.red.gloss)
c:paint({ ".ll", "lll", "ll." }, 33, 22, { l = "#6a9a3a" })
c:px(34, 22, "#7ab55c")

c:ground(32, 58, 17, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/gathering-basket.aseprite", D .. "img-redraw-full/png/ph/gathering-basket.png")
print(GV.report(t))
