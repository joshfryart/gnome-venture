-- flowers-pixel/sprig-eucalyptus: silver-dollar eucalyptus. Coin leaves in opposite pairs that turn
-- 90 deg each node: a side-by-side pair, then a single coin facing out with the stem through it.
-- Dusty-rose stem, no halo (composites into a bouquet). Family: water/stone blend -> sage teal.
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/flowers-pixel/"
local c = GV.canvas{ w = 64, h = 96, mode = "sticker", halo = 0, close = 0, bleed = "b" }

local stemR = GV.ramp("#8a5a52")
local tones = { GV.ramp("#8fb4ae"), GV.ramp("#a3c4bd"), GV.ramp("#7fa6a2") }
local vein = "#5c867e"

-- stem: base (32,95) to tip (32,8), slight S sway
local stemPts = { {32,95}, {32,86}, {33,76}, {33,64}, {32,52}, {31,40}, {31,28}, {32,18}, {32,8} }
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

-- nodes, top first so lower coins overlap upper ones. kind "pair" = two coins either side,
-- "face" = one coin seen face-on, stem passing behind it
local nodes = {
  { 16, 3,   "face" }, { 26, 4, "pair" }, { 38, 4.5, "face" },
  { 51, 5.5, "pair" }, { 65, 5.5, "face" }, { 80, 6.5, "pair" },
}
local stem = c:line(stemPts, 3)
for _, N in ipairs(nodes) do
  if N[3] == "pair" then local x0 = sx(N[1]) stem:add(c:line({ { x0 - 4, N[1] - 1 }, { x0 + 4, N[1] - 1 } }, 2)) end
end
c:part(stem, stemR, { gloss = false })

local coins = {}
for i = 1, #nodes do
  local y, r, kind = nodes[i][1], nodes[i][2], nodes[i][3]
  local x0 = sx(y)
  local list = kind == "pair" and { { x0 - (r + 3), -1 }, { x0 + (r + 3), 1 } } or { { x0 + 0.5, 0 } }
  for j, L in ipairs(list) do
    local tone = tones[((i + j) % 3) + 1]
    local m = c:ellipse(L[1], y - 1, kind == "face" and r + 1 or r, r * 0.92)
    local p = c:part(m, tone, { gloss = (r >= 5) and true or false, flat = (r < 4) })
    coins[#coins + 1] = { p = p, cx = L[1], cy = y - 1, r = r, side = L[2] }
  end
end

-- terminal bud on the tip
c:part(c:ellipse(32, 9, 2, 2.5), stemR, { gloss = false, flat = true })

-- faint midrib: from the stem outward on pair coins, a short vertical on face coins
for _, k in ipairs(coins) do
  if k.r >= 4 then
    local m
    if k.side ~= 0 then
      m = c:line({ { k.cx - k.side * (k.r - 1), k.cy + 1 }, { k.cx + k.side * (k.r - 2), k.cy - 1 } }, 1)
    else
      local x = math.floor(k.cx)
      m = c:line({ { x, k.cy + k.r - 2 }, { x, k.cy - k.r + 3 } }, 1)
    end
    c:fill(m:clip(k.p.m:shrink(1)), vein)
  end
end

-- tiny gold binding stitch on the lower stem
c:seam({ { 32, 94 }, { 32, 87 } })

local t = c:save(O .. "aseprite/sprig-eucalyptus.aseprite", O .. "png/sprig-eucalyptus.png")
print(GV.report(t))
