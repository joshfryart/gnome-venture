-- flowers/sprig-eucalyptus
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 96, mode = "sticker" }

local stemR = GV.ramp("#7a6a4a")
local tones = { GV.ramp("#8fc0a6"), GV.ramp("#a4cdb5"), GV.ramp("#7bb095") }
local rib = "#5f8f78"

-- gentle S-curve stem
local stemPts = { {32,86}, {32,78}, {31,68}, {30,58}, {30,48}, {31,38}, {32,28}, {33,20}, {34,13} }
local function sx(y)
  for i = 1, #stemPts - 1 do
    local a, b = stemPts[i], stemPts[i+1]
    if y <= a[2] and y >= b[2] then
      local t = (a[2] - y) / (a[2] - b[2])
      return math.floor(a[1] + (b[1] - a[1]) * t + 0.5)
    end
  end
  return 32
end

-- leaves alternating, shrinking upward: {y, side, r}
local leaves = {
  { 78, -1, 6.5 }, { 70, 1, 6.5 },
  { 62, -1, 6 },   { 54, 1, 5.5 },
  { 46, -1, 5.5 }, { 38, 1, 5 },
  { 30, -1, 4.5 }, { 22, 1, 4.5 },
}
local stem = c:line(stemPts, 3)
-- short petioles so the stem shows between the coins
for _, L in ipairs(leaves) do
  local x0 = sx(L[1] + 2)
  stem:add(c:line({ { x0, L[1] + 2 }, { x0 + L[2] * 6, L[1] } }, 2))
end
c:part(stem, stemR, { gloss = false })

local parts = {}
for i, L in ipairs(leaves) do
  local tone = tones[((i - 1) % 3) + 1]
  local cx = sx(L[1]) + L[2] * (L[3] + 5)
  L.cx = cx
  local m = c:ellipse(cx, L[1], L[3], L[3])
  parts[i] = c:part(m, tone, { gloss = (L[3] >= 6) and true or false })
end
local top = c:ellipse(34, 9, 4, 4)
local tp = c:part(top, tones[2], { gloss = false })

-- midribs from the stem side toward the far edge
for i, L in ipairs(leaves) do
  local p = parts[i]
  local mr = c:line({ { L.cx - L[2] * L[3], L[1] + 1 }, { L.cx + L[2] * (L[3] - 2), L[1] - 1 } }, 1):clip(p.m:shrink(1))
  c:fill(mr, rib)
end
c:fill(c:line({ {34,12}, {34,8} }, 1):clip(tp.m:shrink(1)), rib)

c:stitch(parts[1].m, { side = "lit" })
c:stitch(parts[2].m, { side = "lit" })

local t = c:save(O .. "aseprite/flowers/sprig-eucalyptus.aseprite", O .. "png/flowers/sprig-eucalyptus.png")
print(GV.report(t))
