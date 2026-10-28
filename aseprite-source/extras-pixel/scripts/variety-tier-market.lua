-- variety-tier-market.lua : stop tiers market-1..4 (awning, weighing house, fountain square, market hall)
-- Family: red/cream striped awnings, wood posts, gold trim + seams, stone, water. Drawn 96x96, icon mode.
local H = dofile((app.params.root or "/home/user/gnome-venture") .. "/aseprite-source/extras-pixel/scripts/variety-tier-common.lua")
local GV = H.GV

local CREAM = GV.ramp("#f1ece0")
local STONE = GV.ramp("#8b8f96")
local PLANK = GV.ramp("#c9a96e")
local WOOD = GV.ramp("#9a6b3f")
local DWOOD = GV.ramp("#7a4a1f")

-- scalloped awning mask: x0..x1 wide, top y0, valance bottom y1, scallop r, trapezoid inset
local function awning(c, x0, x1, ytop, ybot, inset, r)
  local m = c:poly({ { x0 + inset, ytop }, { x1 + 1 - inset, ytop }, { x1 + 1, ybot }, { x0, ybot } })
  local n = math.floor((x1 - x0 + 1) / (2 * r))
  for i = 0, n - 1 do m:add(c:ellipse(x0 + r + 2 * r * i - 0.5, ybot, r - 0.5, r - 1)) end
  return m, n
end

local function fruit(c, x, y, r, ramp)
  c:part(c:ellipse(x, y, r, r), ramp, { cres = 3, deep = 1 })
end

----------------------------------------------------------------- tier 1: striped awning
local function t1()
  local c = H.canvas()
  -- posts
  c:part(c:rect(15, 30, 20, 76), DWOOD, { gloss = false })
  c:part(c:rect(75, 30, 80, 76), DWOOD, { gloss = false })
  -- goods heaped in a crate behind the counter
  c:part(c:rrect(24, 54, 71, 62, 2), PLANK, { gloss = false })
  fruit(c, 31, 50, 5, "red"); fruit(c, 42, 49, 5, "red"); fruit(c, 53, 50, 5, "gold"); fruit(c, 64, 49, 5, "moss")
  -- counter
  c:part(c:rrect(10, 58, 85, 66, 2), PLANK, { cres = 3, deep = 1 })
  local body = c:part(c:rrect(13, 64, 82, 86, 3), WOOD, { stitch = { side = "lit" } })
  for _, x in ipairs({ 36, 59 }) do c:part(c:rect(x, 67, x + 1, 84), DWOOD, { flat = true, contact = false }) end
  c:seam({ { 15, 69 }, { 80, 69 } })
  -- striped awning
  local am = awning(c, 7, 88, 14, 36, 11, 5)
  c:part(am, "red", { cres = 8, deep = 2 })
  H.stripes(c, am, 7 + 5, 10, "red", CREAM)
  c:seam({ { 20, 17 }, { 75, 17 } })
  c:button(46, 22)
  H.save(c, "market", 1)
end

----------------------------------------------------------------- tier 2: weighing house
local function t2()
  local c = H.canvas()
  -- building
  local wall = c:rrect(14, 38, 81, 86, 2)
  c:part(wall, CREAM, { stitch = { side = "lit" }, gloss = false })
  -- timber frame
  for _, x in ipairs({ 14, 46, 79 }) do c:part(c:rect(x, 38, x + 2, 86), DWOOD, { flat = true, contact = false }) end
  c:part(c:rect(14, 62, 81, 64), DWOOD, { flat = true, contact = false })
  -- roof
  local roof = c:poly({ { 48, 9 }, { 89, 40 }, { 7, 40 } })
  c:part(roof, "red", { cres = 8, deep = 2 })
  H.courses(c, roof, 6, "#b8452f", 14)
  c:part(c:rrect(7, 38, 88, 44, 2), DWOOD, { gloss = false })
  c:seam({ { 10, 41 }, { 85, 41 } })
  -- door with striped awning
  c:part(c:rrect(38, 62, 57, 86, 2), DWOOD, { gloss = false })
  H.box(c, 41, 66, 54, 85, "#3d2a1c")
  local am = awning(c, 33, 62, 52, 62, 3, 5)
  c:part(am, "red", { cres = 5, deep = 1 })
  H.stripes(c, am, 33 + 5, 10, "red", CREAM)
  -- windows
  H.window(c, 19, 47, 12, 12); H.window(c, 66, 47, 12, 12)
  -- big gold balance sign hung in the gable
  c:part(c:rect(46, 14, 49, 34), "gold", { flat = true })
  c:part(c:rect(30, 15, 65, 18), "gold", { flat = true })
  c:part(c:ellipse(33, 28, 6, 3):cut(c:rect(0, 0, 99, 26)), "gold", { cres = 3, deep = 1, gloss = false })
  c:part(c:ellipse(62, 28, 6, 3):cut(c:rect(0, 0, 99, 26)), "gold", { cres = 3, deep = 1, gloss = false })
  for _, x in ipairs({ 29, 36, 58, 65 }) do c:px(x, 19, "#7a3a14"); c:px(x, 21, "#7a3a14"); c:px(x, 23, "#7a3a14"); c:px(x, 25, "#7a3a14"); c:px(x, 27, "#7a3a14") end
  -- sacks by the door
  fruit(c, 22, 80, 6, PLANK); fruit(c, 74, 80, 6, PLANK)
  c:px(22, 73, "#7a4a1f"); c:px(74, 73, "#7a4a1f")
  H.save(c, "market", 2)
end

----------------------------------------------------------------- tier 3: fountain square
local function t3()
  local c = H.canvas()
  -- back: two small striped stalls
  for _, x0 in ipairs({ 9, 58 }) do
    c:part(c:rect(x0 + 2, 26, x0 + 4, 56), DWOOD, { gloss = false })
    c:part(c:rect(x0 + 25, 26, x0 + 27, 56), DWOOD, { gloss = false })
    c:part(c:rrect(x0 + 1, 46, x0 + 28, 56, 2), WOOD, { cres = 4, deep = 1 })
    local am = awning(c, x0, x0 + 29, 18, 32, 5, 5)
    c:part(am, "red", { cres = 5, deep = 1 })
    H.stripes(c, am, x0 + 5, 10, "red", CREAM)
  end
  -- paving + basin
  c:part(c:ellipse(47.5, 74, 40, 13), STONE, { cres = 5, deep = 2, gloss = false })
  c:part(c:ellipse(47.5, 72, 34, 10), "water", { cres = 4, deep = 2, gloss = false, contour = "#4a2c1a" })
  c:part(c:ellipse(47.5, 71, 27, 7), GV.ramp("#8fcbd8"), { flat = true, rim = false, contour = false, contact = false })
  -- pedestal and tiers
  c:part(c:rrect(41, 40, 54, 72, 3), STONE, { gloss = false })
  c:part(c:ellipse(47.5, 60, 14, 5), STONE, { cres = 3, deep = 1, gloss = false })
  c:part(c:ellipse(47.5, 54, 10, 3), "water", { flat = true, contour = false })
  c:part(c:ellipse(47.5, 44, 17, 6), STONE, { cres = 5, deep = 2, gloss = false })
  c:part(c:ellipse(47.5, 43, 13, 4), "water", { flat = true, contour = false })
  -- spray
  c:part(c:rect(45, 20, 50, 40), "water", { flat = true, contour = false, contact = false })
  c:part(c:ellipse(47.5, 20, 6, 5), "water", { cres = 3, deep = 1 })
  for _, p in ipairs({ { 33, 36 }, { 36, 31 }, { 59, 31 }, { 62, 36 }, { 31, 42 }, { 64, 42 } }) do c:part(c:rect(p[1], p[2], p[1] + 2, p[2] + 2), "water", { flat = true, contour = false, contact = false }) end
  -- gold coin pile on the stone rim (the market)
  c:part(c:ellipse(18, 78, 4, 3), "gold", { cres = 2, deep = 1 }); c:part(c:ellipse(78, 78, 4, 3), "gold", { cres = 2, deep = 1 })
  H.save(c, "market", 3)
end

----------------------------------------------------------------- tier 4: market hall
local function t4()
  local c = H.canvas()
  -- clock tower (behind the roof ridge)
  c:part(c:rrect(37, 14, 58, 34, 2), CREAM, { gloss = false })
  c:part(c:poly({ { 48, 5 }, { 62, 14 }, { 34, 14 } }), "gold", { cres = 5, deep = 2 })
  c:part(c:ellipse(47.5, 21, 6, 6), "gold", { cres = 3, deep = 1 })
  H.box(c, 47, 17, 48, 21, "#7a3a14"); H.box(c, 47, 21, 51, 22, "#7a3a14")
  -- hall body (cream upper, stone base)
  c:part(c:rrect(10, 46, 85, 86, 2), CREAM, { stitch = { side = "lit" }, gloss = false })
  c:part(c:rect(10, 76, 85, 86), STONE, { gloss = false })
  -- arcade: 3 arches with goods
  for i = 0, 2 do
    local x = 15 + i * 25
    c:part(c:rrect(x, 58, x + 19, 86, 6):cut(c:rect(0, 87, 99, 99)), DWOOD, { gloss = false })
    H.box(c, x + 3, 64, x + 16, 85, "#3d2a1c")
    c:part(c:ellipse(x + 9.5, 68, 6, 6):cut(c:rect(0, 0, 99, 64)), "#3d2a1c", { flat = true, contour = false, contact = false })
    c:part(c:rect(x + 2, 78, x + 17, 85), PLANK, { flat = true, contour = false })
    fruit(c, x + 6, 75, 3, "red"); fruit(c, x + 13, 75, 3, "gold")
  end
  -- roof
  local roof = c:poly({ { 48, 22 }, { 88, 50 }, { 8, 50 } })
  c:part(roof, "red", { cres = 9, deep = 2 })
  H.courses(c, roof, 6, "#b8452f", 28)
  c:part(c:rrect(7, 46, 88, 53, 2), DWOOD, { gloss = false })
  c:seam({ { 10, 49 }, { 85, 49 } })
  -- striped valance across the hall front
  local am = awning(c, 10, 85, 53, 60, 0, 5)
  c:part(am, "red", { cres = 4, deep = 1 })
  H.stripes(c, am, 15, 10, "red", CREAM)
  -- gold roundel in the gable
  c:part(c:ellipse(47.5, 40, 5, 5), "gold", { cres = 3, deep = 1 })
  H.save(c, "market", 4)
end

local fns = { t1, t2, t3, t4 }
for i, f in ipairs(fns) do if H.want(i) then f() end end
