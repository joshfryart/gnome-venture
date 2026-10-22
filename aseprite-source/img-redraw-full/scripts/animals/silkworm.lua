local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- mulberry leaf: pointed oval, tilted, upper area
local leaf = c:poly({ {9, 22}, {13, 15}, {20, 11}, {30, 10}, {39, 12}, {47, 16}, {42, 21}, {34, 25}, {24, 27}, {15, 27} })
-- wavy body: chain of overlapping discs along a sine path
local body = c:mask()
local pts = {}
for i = 0, 27 do
  local x = 13 + i
  local y = 46 - (x - 13) * 0.4 + 3 * math.sin((x - 13) / 5)
  pts[#pts + 1] = { x, y }
  body:add(c:ellipse(x, y, 5, 5))
end
local head = c:ellipse(46, 33, 6.5, 6)

local p = c:build{
  { "leaf", leaf, "moss" },
  { "body", body, "cream", { stitch = false } },
  { "head", head, "cream" },
}
-- leaf midrib and veins
c:line({ {12, 21}, {22, 18}, {33, 15}, {44, 16} }, 1):each(function(x, y) if leaf:has(x, y) then c:px(x, y, "#4a8a3e") end end)
c:px(18, 15, "#4a8a3e"); c:px(17, 16, "#4a8a3e"); c:px(28, 14, "#4a8a3e"); c:px(27, 15, "#4a8a3e")
c:px(22, 20, "#4a8a3e"); c:px(21, 21, "#4a8a3e"); c:px(31, 19, "#4a8a3e")

-- segment lines across the body every 7 px
for _, i in ipairs({ 5, 11, 17, 23 }) do
  local q = pts[i + 1]
  local x0 = math.floor(q[1] + 0.5)
  for dy = -3, 3 do
    local y = math.floor(q[2] + 0.5) + dy
    if body:has(x0, y) then c:px(x0, y, "#d9d2b6") end
  end
end
-- stubby legs under the body (lavender, 2px)
for _, i in ipairs({ 2, 8, 14, 20 }) do
  local q = pts[i + 1]
  local x, y = math.floor(q[1] + 0.5), math.floor(q[2] + 0.5) + 5
  c:fill(c:rect(x, y, x + 1, y + 1), GV.C.leg)
end
-- antennae ticks with club tips
c:line({ {43, 28}, {41, 25} }, 2):each(function(x, y) c:px(x, y, "#3e2f66") end)
c:line({ {49, 28}, {51, 25} }, 2):each(function(x, y) c:px(x, y, "#3e2f66") end)
c:fill(c:rect(39, 22, 41, 24), "#3e2f66"); c:px(39, 22, "#7b66b4")
c:fill(c:rect(51, 22, 53, 24), "#3e2f66"); c:px(51, 22, "#7b66b4")
-- sleepy eye + content smile
c:eye(46, 31, true)
c:paint({ "u..u", ".uu." }, 45, 35, { u = "umber" })
local t = c:save(O .. "aseprite/animals/silkworm.aseprite", O .. "png/animals/silkworm.png")
print(GV.report(t))
