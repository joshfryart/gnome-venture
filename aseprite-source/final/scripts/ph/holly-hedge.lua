local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:ground(32, 54, 18, 2.5, "#6a4528")
-- bush body: rounded, rugged lower edge
local body = c:rrect(10, 25, 54, 51, 12):add(c:ellipse(32, 38, 23, 12))
-- spiky crown: five holly-leaf points, zigzag
local crown = c:mask()
local tips = { {13,16}, {22,13}, {32,15}, {42,13}, {51,16} }
for _, t in ipairs(tips) do
  local x, ty = t[1], t[2]
  crown:add(c:poly({ {x - 6, 28}, {x - 3, ty + 6}, {x - 1, ty}, {x + 2, ty}, {x + 4, ty + 6}, {x + 7, 28} }))
end
crown:add(c:rrect(10, 22, 54, 31, 6))
crown:cut(body:copy():cut(c:rect(0, 0, 63, 27)))
local lz = function(x, y) return c:poly({ {x, y + 2.5}, {x + 2, y}, {x + 6, y}, {x + 8, y + 2.5}, {x + 6, y + 5}, {x + 2, y + 5} }) end
local p = c:build{
  { "body",  body,  GV.ramp("#2e5a2c") },
  { "crown", crown, "moss", { light = body:copy():add(crown) } },
  { "leaf1", lz(17, 34), GV.ramp("#7ab55c"), { flat = true } },
  { "leaf2", lz(35, 39), GV.ramp("#7ab55c"), { flat = true } },
  { "leaf3", lz(43, 31), GV.ramp("#7ab55c"), { flat = true } },
  { "b1", c:ellipse(22, 29, 3), "red", { gloss = false, rim = false } },
  { "b2", c:ellipse(29, 31, 3), "red", { gloss = false, rim = false } },
  { "b3", c:ellipse(27, 24.5, 3), "red", { gloss = false, rim = false } },
}
-- berry glints
for _, b in ipairs({ {21,28}, {28,30}, {26,23} }) do c:px(b[1], b[2], "#ff9158") end
-- leaf veins
for _, v in ipairs({ {{19,36},{23,37}}, {{37,41},{41,42}}, {{45,33},{49,34}} }) do
  for x = v[1][1], v[2][1] do c:px(x, v[1][2] + ((x - v[1][1]) >= 2 and 1 or 0), "#2f5a2a") end
end
local t = c:save(O .. "aseprite/ph/holly-hedge.aseprite", O .. "png/ph/holly-hedge.png")
print(GV.report(t))
