local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
-- drawn at 120x40, written 2x
local c = GV.canvas{ w = 120, h = 40, mode = "scene", out = 2 }
local W, H = 120, 40

local function hill(y0, amp, f1, f2, ph)
  local m = c:mask()
  for x = 0, W - 1 do
    local top = math.floor(y0 + amp * math.sin(x * f1 + ph) + amp * 0.5 * math.sin(x * f2 + ph * 2) + 0.5)
    m:add(c:rect(x, top, x, H - 1))
  end
  return m
end

-- sky bands (lighter upward)
c:bands(c:rect(0, 0, W - 1, 22), { "#f1ebe0", "#e9e0d2", "#dfd4c3", "#d6c9b6" }, { dir = "v" })

c:part(hill(15, 2.5, 0.07, 0.19, 0.3), GV.ramp("#968f96"), { gloss = false })
c:part(hill(22, 2.0, 0.09, 0.23, 1.7), GV.ramp("#7a5cc0"), { gloss = false })

-- stepped mist band (hard 2-tone)
local mist = c:ellipse(60, 24, 54, 1.5):add(c:ellipse(38, 24, 20, 2)):add(c:ellipse(88, 24, 22, 2))
c:fill(mist, "#f4f0e0")
c:fill(mist:copy():cut(mist:shift(0, -1)), "#e2d8ec")

c:part(hill(30, 1.2, 0.11, 0.27, 2.4), "moss", { gloss = false })

-- heather dots (1x1 at half size = 2x2 final)
local dots = { {6,27},{14,29},{19,26},{27,28},{33,29},{38,27},{44,26},{51,28},{57,29},{63,26},{69,27},{74,29},
  {80,26},{86,28},{92,29},{97,27},{103,26},{109,28},{115,29},{11,26},{31,25},{55,25},{77,25},{100,25} }
for i, d in ipairs(dots) do
  c:px(d[1], d[2], (i % 2 == 0) and "#c3b2ea" or "#4e3a8a")
end

-- standing stone
c:part(c:rrect(21, 18, 24, 31, 1), GV.ramp("#6a6070", { rim = "#968f96" }), { gloss = false })

-- low stone wall: one part, blocks painted
c:part(c:rect(66, 32, 91, 36), GV.ramp("#968f96"), { gloss = false, cres = 1, deep = 0 })
for i = 0, 6 do
  local x0 = 66 + i * 4
  if i % 2 == 1 then c:fill(c:rect(x0, 33, x0 + 2, 34), "#6a6070") end
  c:fill(c:rect(x0 + 3, 32, x0 + 3, 36), "#4a2c1a")
end
c:fill(c:rect(66, 35, 91, 35), "#4a2c1a")
for i = 0, 5 do
  local x0 = 68 + i * 4
  if i % 2 == 0 then c:fill(c:rect(x0, 36, x0 + 2, 36), "#6a6070") end
end

-- hem stitches top and bottom
c:seam({ { 1, 1 }, { W - 2, 1 } }, { free = true })
c:seam({ { 1, H - 2 }, { W - 2, H - 2 } }, { free = true })

local t = c:save(O .. "aseprite/ph/banner-nwe.aseprite", O .. "png/ph/banner-nwe.png")
print(GV.report(t))
