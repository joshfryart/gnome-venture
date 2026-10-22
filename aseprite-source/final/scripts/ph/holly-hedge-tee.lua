local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "lrb" }
-- spikier holly edge: tighter, smaller lobes with points between
local hedge = c:mask()
for x = -2, 66, 5 do hedge:add(c:ellipse(x, 27.5, 3.5)); hedge:add(c:ellipse(x + 2.5, 37.5, 3.5)) end
hedge:add(c:rect(0, 27, 63, 37))
for x = 0, 63, 5 do hedge:set(x, 23); hedge:set(x + 2, 41) end           -- leaf spines
for y = 41, 70, 5 do hedge:add(c:ellipse(27.5, y, 3.5)); hedge:add(c:ellipse(37.5, y + 2.5, 3.5)) end
hedge:add(c:rect(27, 32, 37, 63))
for y = 43, 63, 5 do hedge:set(23, y); hedge:set(41, y + 2) end
local soil = c:rect(0, 37, 63, 44):add(c:rect(36, 37, 45, 63))
c:build{
  { "soil", soil, "#7a4a1f", { flat = true } },
  { "hedge", hedge, GV.ramp("#4a8a3e"), { gloss = { 6, 26 } } },
}
-- dashed top/left highlight
for x = 1, 63, 5 do c:paint({ "hh" }, x, 26, { h = "#7ab55c" }) end
for y = 40, 63, 5 do c:paint({ "h", "h" }, 26, y, { h = "#7ab55c" }) end
-- berry clusters (3x3 round, glint, contact shadow), irregular spacing
local function berry(x, y)
  c:paint({ ".r.", "rrr", ".r." }, x, y, { r = "#dd3a2a" })
  c:px(x + 1, y + 1, "#dd3a2a"); c:px(x, y + 1, "#ff9158")
  c:px(x + 1, y + 3, "#6b1b2c"); c:px(x + 2, y + 2, "#6b1b2c")
end
local B = { {3,29},{8,32},{19,29},{24,31},{41,29},{46,32},{57,29},{60,32},
            {29,38},{34,44},{30,50},{33,53},{29,58} }
for _, b in ipairs(B) do berry(b[1], b[2]) end
local t = c:save(O .. "aseprite/ph/holly-hedge-tee.aseprite", O .. "png/ph/holly-hedge-tee.png")
print(GV.report(t))
