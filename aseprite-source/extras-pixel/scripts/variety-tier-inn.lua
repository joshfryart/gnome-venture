-- variety-tier-inn.lua : stop tiers inn-1..4 (hearth bench, stable yard, singing room, grand dining hall)
-- Family: peach plaster walls, dark timber, terracotta roofs, warm gold-lit windows + lanterns, stone hearth.
local H = dofile((app.params.root or "/home/user/gnome-venture") .. "/aseprite-source/extras-pixel/scripts/variety-tier-common.lua")
local GV = H.GV
local PLASTER = GV.ramp("#f2c99a")
local STONE = GV.ramp("#8b8f96")
local PLANK = GV.ramp("#c9a96e")
local WOOD = GV.ramp("#9a6b3f")
local DWOOD = GV.ramp("#7a4a1f")
local TILE = GV.ramp("#c4572f")
local CREAM = GV.ramp("#f1ece0")

local function roof(c, poly, y0)
  c:part(poly, TILE, { cres = 8, deep = 2 })
  H.courses(c, poly, 6, "#8a3a25", y0)
end

local function lantern(c, x, y)
  H.box(c, x + 2, y - 3, x + 3, y, "#2a1a10")
  c:part(c:rrect(x, y + 1, x + 5, y + 8, 1), "gold", { cres = 2, deep = 1 })
  H.box(c, x + 2, y + 3, x + 3, y + 6, "#fff1c8")
end

local function mug(c, x, y)
  c:part(c:rrect(x, y, x + 7, y + 8, 1), CREAM, { cres = 3, deep = 1, gloss = false })
  c:part(c:rect(x + 8, y + 2, x + 10, y + 6), CREAM, { flat = true, contact = false })
  H.box(c, x + 1, y, x + 6, y + 1, "#e8a317")
end

local function note(c, x, y, beam)
  c:part(c:ellipse(x, y, 3, 2.5), "gold", { cres = 2, deep = 1, gloss = false })
  c:part(c:rect(x + 2, y - 12, x + 3, y), "gold", { flat = true, contact = false, contour = false })
  if beam then c:part(c:rect(x + 2, y - 12, x + 10, y - 10), "gold", { flat = true, contact = false, contour = false }); c:part(c:ellipse(x + 9, y - 2, 3, 2.5), "gold", { cres = 2, deep = 1, gloss = false }); c:part(c:rect(x + 11, y - 12, x + 12, y - 2), "gold", { flat = true, contact = false, contour = false }) end
end

----------------------------------------------------------------- tier 1: hearth bench
local function t1()
  local c = H.canvas()
  -- chimney + hearth
  c:part(c:rect(36, 10, 60, 40), STONE, { gloss = false })
  c:part(c:rrect(31, 8, 65, 15, 2), STONE, { cres = 3, deep = 1, gloss = false })
  c:part(c:rect(15, 36, 81, 82), STONE, { stitch = { side = "lit" }, gloss = false })
  for _, p in ipairs({ { 20, 56 }, { 22, 68 }, { 70, 54 }, { 72, 66 }, { 18, 46 } }) do c:part(c:rrect(p[1], p[2], p[1] + 5, p[2] + 3, 1), STONE, { flat = true, contact = false, contour = false }) end
  -- mantel with mug
  c:part(c:rrect(10, 34, 86, 43, 2), WOOD, { cres = 3, deep = 1 })
  c:seam({ { 12, 38 }, { 84, 38 } })
  mug(c, 66, 26)
  c:part(c:rrect(19, 24, 24, 34, 1), CREAM, { cres = 2, deep = 1, gloss = false })
  c:part(c:ellipse(21.5, 21, 2, 3), "flame", { cres = 1, deep = 1, gloss = false })
  -- firebox, logs, flame
  c:part(c:rrect(30, 46, 66, 82, 10), "#2a1a10", { flat = true, rim = false, contour = "#4a2c1a" })
  c:part(c:ellipse(48, 68, 12, 14):cut(c:rect(0, 78, 99, 99)), "flame", { cres = 6, deep = 2 })
  c:part(c:ellipse(48, 72, 6, 8):cut(c:rect(0, 78, 99, 99)), "gold", { cres = 3, deep = 1, gloss = false })
  c:part(c:line({ { 36, 80 }, { 60, 76 } }, 4), DWOOD, { flat = true, contact = false })
  c:part(c:line({ { 36, 76 }, { 60, 80 } }, 4), WOOD, { flat = true, contact = false })
  -- bench with red cushion
  c:part(c:rect(12, 80, 17, 86), DWOOD, { gloss = false })
  c:part(c:rect(79, 80, 84, 86), DWOOD, { gloss = false })
  c:part(c:rrect(9, 73, 87, 81, 2), WOOD, { cres = 3, deep = 1 })
  c:part(c:rrect(14, 66, 42, 75, 4), "red", { cres = 3, deep = 1, stitch = true })
  H.save(c, "inn", 1)
end

----------------------------------------------------------------- tier 2: stable yard
local function t2()
  local c = H.canvas()
  -- inn wing
  c:part(c:rect(8, 46, 50, 86), PLASTER, { stitch = { side = "lit" }, gloss = false })
  for _, x in ipairs({ 8, 48 }) do c:part(c:rect(x, 46, x + 2, 86), DWOOD, { flat = true, contact = false }) end
  roof(c, c:poly({ { 29, 20 }, { 55, 48 }, { 7, 48 } }), 26)
  c:part(c:rrect(7, 45, 52, 51, 2), DWOOD, { gloss = false })
  c:seam({ { 10, 48 }, { 49, 48 } })
  c:part(c:rrect(15, 62, 31, 86, 6):cut(c:rect(0, 87, 99, 99)), DWOOD, { gloss = false })
  H.box(c, 18, 66, 28, 85, "#f5cf6a"); H.box(c, 18, 78, 28, 85, "#e8a317")
  H.litwindow(c, 36, 56, 10, 12)
  -- stable lean-to
  c:part(c:rect(52, 54, 87, 86), WOOD, { gloss = false })
  for x = 59, 85, 7 do for y = 56, 85 do if c:get(x, y) == WOOD.base or c:get(x, y) == WOOD.shade then c:px(x, y, "#5e2f1e") end end end
  c:part(c:poly({ { 50, 42 }, { 88, 50 }, { 88, 58 }, { 50, 52 } }), TILE, { cres = 5, deep = 1 })
  c:part(c:rect(50, 50, 88, 56), DWOOD, { gloss = false })
  c:part(c:rect(58, 58, 82, 86), "#2a1a10", { flat = true, rim = false, contour = "#4a2c1a" })
  -- horse head in the stall
  local chest = GV.ramp("#a8582f")
  c:part(c:ellipse(70, 71, 8, 10), chest, { cres = 5, deep = 2 })
  c:part(c:rrect(65, 76, 77, 86, 3), GV.ramp("#c47a52"), { cres = 3, deep = 1 })
  c:part(c:rect(63, 58, 66, 63), chest, { flat = true, contact = false })
  c:part(c:rect(73, 58, 76, 63), chest, { flat = true, contact = false })
  c:part(c:rect(68, 60, 72, 74), DWOOD, { flat = true, contact = false })
  c:eye(63, 67, true)
  H.box(c, 66, 82, 67, 83, "#2a1a10"); H.box(c, 74, 82, 75, 83, "#2a1a10")
  -- hay
  c:part(c:rrect(52, 76, 62, 86, 2), "gold", { cres = 3, deep = 1, gloss = false })
  c:seam({ { 53, 80 }, { 61, 80 } })
  lantern(c, 52, 56)
  H.save(c, "inn", 2)
end

----------------------------------------------------------------- tier 3: singing room
local function t3()
  local c = H.canvas()
  c:part(c:rect(12, 36, 84, 86), PLASTER, { stitch = { side = "lit" }, gloss = false })
  for _, x in ipairs({ 12, 47, 82 }) do c:part(c:rect(x, 36, x + 2, 86), DWOOD, { flat = true, contact = false }) end
  c:part(c:rect(12, 60, 84, 63), DWOOD, { flat = true, contact = false })
  roof(c, c:poly({ { 48, 10 }, { 88, 38 }, { 8, 38 } }), 16)
  c:part(c:rrect(8, 36, 88, 42, 2), DWOOD, { gloss = false })
  c:seam({ { 11, 39 }, { 85, 39 } })
  -- three lit windows upstairs
  for _, x in ipairs({ 18, 42, 66 }) do H.litwindow(c, x, 45, 12, 14) end
  -- balcony rail
  c:part(c:rrect(12, 58, 84, 63, 1), WOOD, { cres = 3, deep = 1, gloss = false })
  for x = 16, 80, 8 do H.box(c, x, 56, x + 1, 59, "#5e2f1e") end
  -- door and side windows
  c:part(c:rrect(37, 66, 59, 86, 8):cut(c:rect(0, 87, 99, 99)), DWOOD, { gloss = false })
  H.box(c, 41, 71, 55, 85, "#f5cf6a"); H.box(c, 41, 79, 55, 85, "#e8a317")
  H.litwindow(c, 18, 68, 12, 12); H.litwindow(c, 66, 68, 12, 12)
  lantern(c, 31, 66); lantern(c, 61, 66)
  -- music
  note(c, 17, 32, true)
  note(c, 79, 28, false)
  H.save(c, "inn", 3)
end

----------------------------------------------------------------- tier 4: grand dining hall
local function t4()
  local c = H.canvas()
  -- wings
  c:part(c:rect(8, 54, 88, 86), PLASTER, { stitch = { side = "lit" }, gloss = false })
  roof(c, c:poly({ { 20, 38 }, { 28, 56 }, { 8, 56 } }), 40)
  roof(c, c:poly({ { 76, 38 }, { 88, 56 }, { 68, 56 } }), 40)
  -- chimneys with smoke
  c:part(c:rrect(12, 30, 20, 50, 1), STONE, { gloss = false })
  c:part(c:rrect(76, 30, 84, 50, 1), STONE, { gloss = false })
  c:part(c:ellipse(16, 24, 4, 3), CREAM, { cres = 3, deep = 1, gloss = false })
  c:part(c:ellipse(80, 24, 4, 3), CREAM, { cres = 3, deep = 1, gloss = false })
  c:part(c:ellipse(82, 16, 3, 3), CREAM, { flat = true })
  -- central hall
  c:part(c:rect(26, 38, 70, 86), PLASTER, { stitch = { side = "lit" }, gloss = false })
  for _, x in ipairs({ 26, 68 }) do c:part(c:rect(x, 38, x + 2, 86), DWOOD, { flat = true, contact = false }) end
  roof(c, c:poly({ { 48, 8 }, { 78, 40 }, { 18, 40 } }), 14)
  c:part(c:rrect(18, 38, 78, 44, 2), DWOOD, { gloss = false })
  c:seam({ { 21, 41 }, { 75, 41 } })
  -- lantern cupola finial
  c:part(c:ellipse(47.5, 20, 5, 5), "gold", { cres = 3, deep = 1 })
  -- wing windows
  H.litwindow(c, 11, 62, 11, 12); H.litwindow(c, 74, 62, 11, 12)
  H.litwindow(c, 31, 48, 9, 12); H.litwindow(c, 56, 48, 9, 12)
  -- big double doors with red carpet
  c:part(c:rrect(37, 58, 59, 86, 9):cut(c:rect(0, 87, 99, 99)), DWOOD, { gloss = false })
  H.box(c, 41, 64, 55, 85, "#f5cf6a"); H.box(c, 41, 74, 55, 85, "#e8a317")
  H.box(c, 47, 64, 48, 85, "#8a4f2a")
  c:part(c:rect(43, 80, 53, 87), "red", { flat = true, contact = false })
  -- hanging gold sign over the door
  c:part(c:rrect(38, 47, 58, 55, 2), "gold", { cres = 3, deep = 1, gloss = false })
  c:seam({ { 40, 51 }, { 56, 51 } })
  lantern(c, 30, 66); lantern(c, 62, 66)
  H.save(c, "inn", 4)
end

local fns = { t1, t2, t3, t4 }
for i, f in ipairs(fns) do if H.want(i) then f() end end
