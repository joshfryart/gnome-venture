local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx, cy = 31.5, 31.5

-- pale parchment disc (sized so the icon halo stays inside the frame)
local disc = c:ellipse(cx, cy, 21, 21)
local leaf = GV.ramp("#7ab55c")
local stemR = "moss"

-- sprig parts
local stem = c:line({ { 31, 45 }, { 31, 22 } }, 3)
local leftLeaf = c:poly({ { 32, 40 }, { 26, 38 }, { 21, 33 }, { 20, 29 }, { 24, 30 }, { 29, 34 }, { 32, 37 } })
local rightLeaf = c:poly({ { 32, 35 }, { 37, 33 }, { 42, 28 }, { 44, 24 }, { 39, 25 }, { 34, 29 }, { 32, 32 } })
local bud = c:poly({ { 30, 24 }, { 34, 24 }, { 33, 19 }, { 31, 15 }, { 29, 18 } })
local bar = c:rect(21, 45, 42, 47)

c:build{
  { "disc", disc, GV.ramp("#f1ece0"), { pale = true, gloss = { 18, 19 } } },
  { "stem", stem, stemR, { flat = true } },
  { "lleaf", leftLeaf, leaf, { gloss = false } },
  { "rleaf", rightLeaf, leaf, { gloss = false } },
  { "bud", bud, GV.ramp("#a4b86a"), { flat = true } },
  { "bar", bar, GV.ramp("#2f5a2a"), { flat = true } },
}
-- leaf midribs
c:line({ { 30, 37 }, { 23, 31 } }, 1)
for _, q in ipairs({ { 29, 36 }, { 28, 35 }, { 27, 34 }, { 26, 33 }, { 25, 32 } }) do c:px(q[1], q[2], leaf.shade) end
for _, q in ipairs({ { 34, 31 }, { 35, 30 }, { 36, 29 }, { 37, 28 }, { 38, 27 }, { 39, 26 } }) do c:px(q[1], q[2], leaf.shade) end

-- rings: solid 2px inner at r17..18, dotted at r15? -> solid at r16, dotted outer at r19
local function ringAt(r0, r1)
  local m = c:ellipse(cx, cy, r1, r1):cut(c:ellipse(cx, cy, r0, r0))
  return m
end
local inner = ringAt(15, 16.5)
inner:each(function(x, y) c:px(x, y, "#4a2c1a") end)
for i = 0, 35 do
  local a = i * math.pi * 2 / 36
  c:px(math.floor(cx + 19 * math.cos(a) + 0.5), math.floor(cy + 19 * math.sin(a) + 0.5), "#74462a")
end

local t = c:save(O .. "aseprite/stops/stamp-herb.aseprite", O .. "png/stops/stamp-herb.png")
print(GV.report(t))
