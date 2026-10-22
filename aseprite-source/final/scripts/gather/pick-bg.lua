-- gather/pick-bg : five wavy soil/rock strata, scene, 100x100 drawn, written 2x
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 100, h = 100, mode = "scene", out = 2 }
local W, H = 100, 100
local pi = math.pi

-- band boundaries (top edge of band i+1)
local function b1(x) return math.floor(25 + 2.2 * math.sin(x / 100 * 2 * pi * 1.3 + 0.4) + 0.5) end
local function b2(x) return math.floor(47 + 2.0 * math.sin(x / 100 * 2 * pi * 1.1 + 2.2) + 0.5) end
local function b3(x) return math.floor(68 + 1.6 * math.sin(x / 100 * 2 * pi * 1.4 + 4.0) + 0.5) end
local function b4(x) return math.floor(86 + 1.8 * math.sin(x / 100 * 2 * pi * 1.2 + 1.0) + 0.5) end

local bands = {
  { base = "#6e5238", rim = "#7d5f42", line = "#3d2a1c" }, -- topsoil
  { base = "#b99c6b", rim = "#c9ad7c", line = "#6e5238" }, -- sand
  { base = "#7d8088", rim = "#8b8f96", line = "#4f4a48" }, -- stone
  { base = "#a8643a", rim = "#b87448", line = "#5e3a24" }, -- clay
  { base = "#4f5563", rim = "#5b6470", line = "#2f3440" }, -- bedrock
}

c:fill(c:rect(0, 0, W-1, H-1), "#5b4430")
for x = 0, W-1 do
  local tops = { 0, b1(x), b2(x), b3(x), b4(x), H }
  for i = 1, 5 do
    local y0, y1 = tops[i], tops[i+1] - 1
    for y = y0, y1 do c:px(x, y, bands[i].base) end
    if i > 1 then
      c:px(x, y0, bands[i-1].line)        -- dark seam where strata meet
      c:px(x, y0 + 1, bands[i].rim)       -- lit lip of the lower band
    end
  end
  -- bedrock sits deeper: its lowest rows use the next-darker step
  for y = 96, H-1 do c:px(x, y, "#454a57") end
end

local function dot(cx, cy, rx, ry, hex) c:fill(c:ellipse(cx, cy, rx, ry), hex) end
-- topsoil pebbles
dot(8, 8, 1.5, 1, "#8a6c48"); dot(22, 15, 1, 1, "#8a6c48"); dot(80, 6, 1.5, 1, "#8a6c48"); dot(91, 17, 1, 1, "#8a6c48")
-- sand flecks
dot(6, 36, 1, 1, "#d3b985"); dot(30, 41, 1.5, 1, "#d3b985"); dot(72, 33, 1, 1, "#d3b985"); dot(93, 40, 1.5, 1, "#d3b985")
-- stone streaks and pebble
c:fill(c:line({ {5, 57}, {20, 55}, {35, 56} }, 1), "#9a9da6")
c:fill(c:line({ {55, 60}, {72, 58}, {90, 59} }, 1), "#9a9da6")
dot(75, 52, 4.5, 2, "#6b6e76")
c:fill(c:line({ {72, 51}, {76, 51} }, 1), "#8b8f96")
-- clay
dot(10, 76, 1, 1, "#c98550"); dot(62, 80, 1.5, 1, "#c98550"); dot(88, 75, 1, 1, "#c98550")
c:fill(c:line({ {20, 80}, {24, 79}, {29, 80} }, 1), "#7d4424")
-- bedrock
dot(15, 93, 1, 1, "#6b7280"); dot(50, 92, 1.5, 1, "#6b7280"); dot(84, 94, 1, 1, "#6b7280")
-- cracks
c:fill(c:line({ {35, 0}, {32, 12}, {36, 21} }, 1), "#2f241a")
c:fill(c:line({ {65, 50}, {63, 60}, {68, 66} }, 1), "#2f241a")
c:fill(c:line({ {13, 70}, {17, 78} }, 1), "#2f241a")

local t = c:save(O .. "aseprite/gather/pick-bg.aseprite", O .. "png/gather/pick-bg.png")
print(GV.report(t))
