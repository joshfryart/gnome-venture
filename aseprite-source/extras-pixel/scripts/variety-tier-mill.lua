-- variety-tier-mill.lua : stop tiers mill-1..4 (sack hoist, mill sluice, flour loft, bakehouse hall)
-- Family: thatch roofs (tan), plank wood, cream flour sacks, water-blue sluice + waterwheel, gold hoist pulley.
local H = dofile((app.params.root or "/home/user/gnome-venture") .. "/aseprite-source/extras-pixel/scripts/variety-tier-common.lua")
local GV = H.GV
local CREAM = GV.ramp("#f1ece0")
local STONE = GV.ramp("#8b8f96")
local PLANK = GV.ramp("#c9a96e")
local WOOD = GV.ramp("#9a6b3f")
local DWOOD = GV.ramp("#7a4a1f")
local THATCH = GV.ramp("#d9a660")

local function sack(c, x, y, w, h)
  local m = c:rrect(x, y + 3, x + w - 1, y + h - 1, 4)
  m:add(c:rrect(x + w // 2 - 3, y, x + w // 2 + 2, y + 5, 1))
  c:part(m, CREAM, { cres = 4, deep = 1, gloss = false })
  H.box(c, x + w // 2 - 3, y + 5, x + w // 2 + 2, y + 5, "#e8a317")
end

-- plank wall: base part + vertical plank lines
local function planks(c, x0, y0, x1, y1, ramp, step)
  local m = c:rect(x0, y0, x1, y1)
  c:part(m, ramp or WOOD, { gloss = false })
  for x = x0 + step, x1 - 1, step do for y = y0 + 2, y1 - 2 do
    if c:get(x, y) then c:px(x, y, "#5e2f1e") end
  end end
  return m
end

local function thatch(c, poly, y0)
  c:part(poly, THATCH, { cres = 8, deep = 2 })
  H.courses(c, poly, 6, "#a8582f", y0)
end

-- waterwheel: wooden ring, 4 spokes, gold hub, paddles
local function wheel(c, cx, cy, r)
  local ring = c:ellipse(cx, cy, r, r):cut(c:ellipse(cx, cy, r - 5, r - 5))
  local sp = c:mask()
  sp:add(c:line({ { cx - r + 3, cy }, { cx + r - 3, cy } }, 3)); sp:add(c:line({ { cx, cy - r + 3 }, { cx, cy + r - 3 } }, 3))
  c:part(c:ellipse(cx, cy, r - 5, r - 5), "#3f8fb0", { flat = true, contour = false, contact = false, rim = false })
  c:part(sp:copy(), DWOOD, { flat = true, contact = false })
  c:part(ring, WOOD, { cres = 4, deep = 1, gloss = false })
  for i = 0, 7 do
    local a = i * math.pi / 4 + math.pi / 8
    local px, py = math.floor(cx + math.cos(a) * (r + 1) + 0.5), math.floor(cy + math.sin(a) * (r + 1) + 0.5)
    c:part(c:rect(px - 2, py - 2, px + 2, py + 2), PLANK, { flat = true, contact = false })
  end
  c:part(c:ellipse(cx, cy, 4, 4), "gold", { cres = 2, deep = 1 })
end

----------------------------------------------------------------- tier 1: sack hoist
local function t1()
  local c = H.canvas()
  -- shed
  planks(c, 10, 40, 54, 86, WOOD, 7)
  local roof = c:poly({ { 32, 14 }, { 62, 42 }, { 2 + 4, 42 } })
  thatch(c, roof, 20)
  c:part(c:rrect(8, 40, 58, 46, 2), DWOOD, { gloss = false })
  c:seam({ { 10, 43 }, { 55, 43 } })
  -- loft door and hoist beam
  c:part(c:rrect(24, 50, 42, 68, 2), DWOOD, { gloss = false })
  H.box(c, 27, 53, 39, 67, "#3d2a1c")
  c:part(c:rect(40, 30, 84, 35), DWOOD, { gloss = false })
  c:part(c:line({ { 44, 54 }, { 58, 36 } }, 3), DWOOD, { flat = true, contact = false })
  -- pulley, rope and the hanging sack
  c:part(c:ellipse(80, 40, 4, 4), "gold", { cres = 2, deep = 1 })
  H.box(c, 79, 44, 80, 56, "#c9a96e")
  sack(c, 71, 54, 18, 17)
  -- floor sacks
  sack(c, 60, 72, 14, 14); sack(c, 74, 72, 14, 14)
  H.save(c, "mill", 1)
end

----------------------------------------------------------------- tier 2: mill sluice
local function t2()
  local c = H.canvas()
  planks(c, 8, 42, 50, 86, WOOD, 7)
  local roof = c:poly({ { 28, 18 }, { 57, 44 }, { 1 + 6, 44 } })
  thatch(c, roof, 24)
  c:part(c:rrect(7, 42, 54, 48, 2), DWOOD, { gloss = false })
  c:seam({ { 9, 45 }, { 51, 45 } })
  H.window(c, 15, 54, 12, 12)
  c:part(c:rrect(32, 60, 46, 86, 2), DWOOD, { gloss = false })
  H.box(c, 35, 64, 43, 85, "#3d2a1c")
  -- sluice flume + falling water
  c:part(c:rect(50, 20, 88, 28), DWOOD, { cres = 3, deep = 1 })
  H.box(c, 52, 20, 86, 21, "#8fcbd8")
  c:part(c:rect(80, 28, 84, 52), DWOOD, { gloss = false })
  c:part(c:rect(62, 28, 71, 40), "water", { flat = true, contour = false, contact = false })
  wheel(c, 66, 62, 19)
  -- pool
  c:part(c:ellipse(66, 84, 22, 4), "water", { cres = 3, deep = 1, gloss = false })
  H.box(c, 56, 83, 62, 83, "#c8ecdc")
  H.save(c, "mill", 2)
end

----------------------------------------------------------------- tier 3: flour loft
local function t3()
  local c = H.canvas()
  -- stone ground floor, timber loft
  c:part(c:rect(8, 62, 66, 86), STONE, { gloss = false })
  c:part(c:rect(8, 36, 66, 62), CREAM, { stitch = { side = "lit" }, gloss = false })
  for _, x in ipairs({ 8, 36, 64 }) do c:part(c:rect(x, 36, x + 2, 62), DWOOD, { flat = true, contact = false }) end
  local roof = c:poly({ { 36, 8 }, { 72, 40 }, { 4 + 3, 40 } })
  thatch(c, roof, 14)
  c:part(c:rrect(7, 37, 70, 43, 2), DWOOD, { gloss = false })
  c:seam({ { 8, 40 }, { 67, 40 } })
  -- loft hatch + hoist beam + hanging sack
  c:part(c:rrect(26, 46, 44, 62, 2), DWOOD, { gloss = false })
  H.box(c, 29, 49, 41, 61, "#3d2a1c")
  sack(c, 30, 52, 12, 10)
  c:part(c:rect(40, 26, 84, 31), DWOOD, { gloss = false })
  c:part(c:ellipse(80, 36, 4, 4), "gold", { cres = 2, deep = 1 })
  H.box(c, 79, 40, 80, 48, "#c9a96e")
  sack(c, 73, 48, 14, 13)
  H.window(c, 12, 46, 10, 11)
  H.litwindow(c, 50, 46, 10, 11)
  -- door
  c:part(c:rrect(24, 66, 42, 86, 7):cut(c:rect(0, 87, 99, 99)), DWOOD, { gloss = false })
  H.box(c, 27, 70, 39, 85, "#3d2a1c")
  -- small wheel on the side
  wheel(c, 72, 70, 12)
  c:part(c:ellipse(72, 83, 11, 2), "water", { flat = true, contour = false })
  sack(c, 10, 74, 12, 12)
  H.save(c, "mill", 3)
end

----------------------------------------------------------------- tier 4: bakehouse hall
local function t4()
  local c = H.canvas()
  -- windmill tower behind the roof
  c:part(c:rrect(37, 24, 59, 54, 2), WOOD, { gloss = false })
  -- hall: stone base, cream timber
  c:part(c:rect(8, 70, 88, 86), STONE, { gloss = false })
  c:part(c:rect(8, 50, 88, 70), CREAM, { stitch = { side = "lit" }, gloss = false })
  for _, x in ipairs({ 8, 30, 64, 86 }) do c:part(c:rect(x, 50, x + 2, 70), DWOOD, { flat = true, contact = false }) end
  -- chimney
  c:part(c:rrect(70, 28, 80, 54, 1), STONE, { gloss = false })
  c:part(c:rect(68, 26, 82, 30), STONE, { cres = 3, deep = 1, gloss = false })
  c:part(c:ellipse(76, 19, 5, 4), CREAM, { cres = 3, deep = 1, gloss = false })
  c:part(c:ellipse(82, 12, 4, 3), CREAM, { cres = 3, deep = 1, gloss = false })
  -- roof
  local roof = c:poly({ { 48, 30 }, { 88, 54 }, { 8, 54 } })
  thatch(c, roof, 36)
  c:part(c:rrect(7, 50, 88, 56, 2), DWOOD, { gloss = false })
  c:seam({ { 9, 53 }, { 86, 53 } })
  -- oven arch glowing
  c:part(c:rrect(39, 60, 57, 86, 7):cut(c:rect(0, 87, 99, 99)), DWOOD, { gloss = false })
  H.box(c, 42, 66, 54, 85, "#5e2f1e")
  c:part(c:ellipse(48, 78, 5, 6), "flame", { cres = 3, deep = 1 })
  -- loaves on shelves each side
  for _, x in ipairs({ 14, 21, 68, 76 }) do c:part(c:ellipse(x + 3, 78, 4, 3), "wood", { cres = 2, deep = 1 }) end
  H.litwindow(c, 14, 57, 12, 9); H.litwindow(c, 70, 57, 12, 9)
  -- sails over the tower
  local hx, hy, L = 48, 36, 19
  for _, d in ipairs({ { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }) do
    local ex, ey = hx + d[1] * L, hy + d[2] * L
    local nx, ny = -d[2], d[1]  -- perpendicular
    local sx, sy = hx + d[1] * 6, hy + d[2] * 6
    local q = c:poly({ { sx, sy }, { ex, ey }, { ex + nx * 7, ey + ny * 7 }, { sx + nx * 7, sy + ny * 7 } })
    c:part(q, CREAM, { cres = 3, deep = 1, gloss = false })
  end
  for _, d in ipairs({ { 1, 1 }, { 1, -1 } }) do
    c:part(c:line({ { hx - d[1] * L, hy - d[2] * L }, { hx + d[1] * L, hy + d[2] * L } }, 3), DWOOD, { flat = true, contact = false })
  end
  c:part(c:ellipse(hx, hy, 5, 5), "gold", { cres = 3, deep = 1 })
  H.save(c, "mill", 4)
end

local fns = { t1, t2, t3, t4 }
for i, f in ipairs(fns) do if H.want(i) then f() end end
