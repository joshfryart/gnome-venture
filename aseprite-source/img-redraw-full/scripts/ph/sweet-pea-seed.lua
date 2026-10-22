local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local burlap = GV.ramp("#c9a96e")
-- lumpy sack body
local sack = c:ellipse(32, 41, 20, 15)
sack:add(c:ellipse(20, 46, 8, 9)):add(c:ellipse(44, 45, 8, 10)):add(c:ellipse(32, 31, 13, 9))
sack:cut(c:rect(0, 57, 63, 63))
-- mouth fringe
local fringe = c:poly({ {21, 23}, {43, 23}, {46, 14}, {42, 17}, {40, 10}, {37, 16}, {34, 9}, {31, 15}, {28, 9}, {26, 16}, {23, 11}, {22, 17}, {18, 14} })
local twine = c:rrect(20, 22, 44, 25, 1)
local pod = c:line({ {15, 46}, {22, 43}, {29, 40}, {36, 36}, {42, 33}, {49, 30} }, 4)
pod:add(c:ellipse(24, 41, 4.5, 4.5)):add(c:ellipse(32, 37, 4.5, 4.5)):add(c:ellipse(40, 33, 4.5, 4.5))
local p = c:build{
  { "fringe", fringe, burlap, { gloss = false } },
  { "sack",   sack,   burlap, { stitch = { side = "lit" } } },
  { "twine",  twine,  GV.ramp("#8c4a1a"), { gloss = false } },
  { "pod",    pod,    GV.ramp("#7ab55c", { rim = "#a4b86a" }), { gloss = false } },
}
-- fringe strands
for _, x in ipairs({ 24, 29, 34, 39 }) do c:fill(c:rect(x, 15, x, 21):clip(fringe), "#9a6b3f") end
-- weave hatch on the lower half
for y = 44, 54, 4 do for x = 14, 50, 4 do
  local xx = x + ((y // 4) % 2) * 2
  if sack:shrink(3):has(xx, y) and not pod:grow(1):has(xx, y) then c:px(xx, y, "#9a6b3f") end
end end
-- twine bow
c:fill(c:ellipse(28, 22, 2.5, 1.5):cut(c:rect(28, 22, 28, 22)), "#a8582f")
c:fill(c:ellipse(36, 22, 2.5, 1.5):cut(c:rect(36, 22, 36, 22)), "#a8582f")
c:fill(c:rect(31, 22, 33, 24), "#5e2f1e")
c:px(31, 22, "#a8582f")
c:fill(c:line({ {30, 25}, {28, 29} }, 2), "#8c4a1a")
c:fill(c:line({ {34, 25}, {36, 29} }, 2), "#8c4a1a")
-- peas
for _, q in ipairs({ {24, 41}, {32, 37}, {40, 33} }) do
  local pe = c:ellipse(q[1], q[2], 3, 3)
  c:fill(pe, "#a4b86a")
  c:fill(pe:copy():cut(c:ellipse(q[1] - 0.5, q[2] - 0.5, 2.5, 2.5)), "#4a8a3e")
  c:px(q[1] - 1, q[2] - 1, "#e4eeb0"); c:px(q[1] - 2, q[2] - 1, "#c8d77a")
end
-- tendril
c:fill(c:line({ {13, 47}, {11, 50}, {12, 53}, {15, 53} }, 2), "#2f5a2a")
-- pod gloss

c:ground(32, 57, 18, 2.5, "#6a4528")
local t = c:save(O .. "aseprite/ph/sweet-pea-seed.aseprite", O .. "png/ph/sweet-pea-seed.png")
print(GV.report(t))
