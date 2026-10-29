-- banner-SEA-pets.lua : Cat Fish pet shop banner, Monsoon Mew Market (Monsoon Tangle, SEA).
-- claude/catfish-shops-art-spec.md (FRONT job). Matches the shipped region banners
-- (game/assets/img/scenes/banner-*.png): 240 x 60 grid written at 2x = 480 x 120, opaque, no border,
-- gvlib "scene" mode (3-tone umber outline per raised part), thread-gold hem stitch top and bottom, <= 24 colours.
-- Scene: a stilt-house pet shop on a market boardwalk over the river. Front gable roof with two cat-ear finials,
-- woven attap gable with a gold cat-head emblem (no text), teal/cream scalloped awning, warm gold lanterns,
-- shelves of rattan balls and fish toys, a ginger cat on the counter, a kitten in a paddy-hat bed, batik counter
-- cloth. Side thirds calm: palm, banana plant, sampan, a far stilt hut, lantern strings, late warm sun upper left.
-- Run: AppRun -b --script banner-SEA-pets.lua   Writes ../out/banner-SEA-pets.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local W, H = 240, 60
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }

-- one shared palette (<= 24 colours), ramps built from it so the count stays low
local WOOD  = { gloss = "#f5cf6a", dot = "#f5cf6a", rim = "#d9a660", base = "#b07a45", shade = "#8a4f2a", deep = "#5e2f1e", bounce = "#8a4f2a" }
local DARKW = { gloss = "#b07a45", dot = "#b07a45", rim = "#8a4f2a", base = "#5e2f1e", shade = "#4a2c1a", deep = "#4a2c1a", bounce = "#4a2c1a" }
local RED   = { gloss = "#f5cf6a", dot = "#fff1c8", rim = "#f2793a", base = "#dd3a2a", shade = "#ae2a2a", deep = "#8a4f2a", bounce = "#ae2a2a" }
local GOLD  = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a", deep = "#8a4f2a", bounce = "#b8661a" }
local TEAL  = { gloss = "#c8ecdc", dot = "#c8ecdc", rim = "#8fcbd8", base = "#3f8fb0", shade = "#2f6290", deep = "#2f6290", bounce = "#2f6290" }
local CREAM = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#fff1c8", base = "#f2e4c0", shade = "#d9a660", deep = "#b07a45", bounce = "#d9a660", pale = true }
local GREEN = { gloss = "#c8ecdc", dot = "#c8ecdc", rim = "#a4b86a", base = "#7ab55c", shade = "#4a8a3e", deep = "#4a8a3e", bounce = "#4a8a3e" }

local function under(f, x0, x1)
  local m = c:mask()
  for x = x0 or 0, x1 or W - 1 do
    local y0 = math.floor(f(x) + 0.5)
    for y = math.max(0, y0), H - 1 do m:set(x, y) end
  end
  return m
end

---------------------------------------------------------------- sky, sun, clouds, far jungle
c:bands(c:rect(0, 0, W - 1, H - 1), { "#8fcbd8", "#c8ecdc", "#f2e4c0", "#fff1c8", "#fff1c8" })
c:part(c:ellipse(26, 12, 6, 6), GOLD, { flat = true, outline = false })
c:fill(c:ellipse(25, 11, 4, 4), "#fff1c8")
local function cloud(x, y, w)
  local m = c:ellipse(x, y, w, 2.5):add(c:ellipse(x - w * 0.35, y - 2, w * 0.45, 2.5)):add(c:ellipse(x + w * 0.25, y - 3, w * 0.5, 3))
  c:part(m, CREAM, { flat = true, outline = false })
end
cloud(70, 10, 9); cloud(196, 8, 11); cloud(228, 15, 6)

local far = under(function(x) return 31 + 1.6 * math.sin(x / 6.5) + 1.1 * math.sin(x / 2.9 + 1) end)
c:part(far, { base = "#a4b86a", rim = "#a4b86a" }, { flat = true, outline = false, rim = false })
local mid = under(function(x) return 37 + 1.4 * math.sin(x / 4.1 + 2) + 0.9 * math.cos(x / 1.9) end)
c:part(mid, GREEN, { flat = true, outline = false })

-- far stilt huts (flat, no outline: pushed back)
local function hut(x, y, w)
  c:fill(c:rect(x + 1, y + 6, x + 1, y + 10):add(c:rect(x + w - 2, y + 6, x + w - 2, y + 10)), "#8a4f2a")
  c:fill(c:rect(x, y + 3, x + w - 1, y + 6), "#d9a660")
  c:fill(c:rect(x + w // 2 - 1, y + 4, x + w // 2, y + 6), "#8a4f2a")
  c:fill(c:poly({ { x - 2, y + 4 }, { x + w / 2, y - 2 }, { x + w + 2, y + 4 } }), "#f2793a")
end
hut(4, 30, 12); hut(196, 31, 12); hut(214, 33, 9)

---------------------------------------------------------------- water and boardwalk
local water = c:rect(0, 51, W - 1, H - 1)
c:part(water, TEAL, { flat = true, outline = false, rim = false })
for _, r in ipairs({ { 6, 55 }, { 50, 57 }, { 72, 54 }, { 100, 56 }, { 140, 55 }, { 178, 57 }, { 206, 54 }, { 232, 56 }, { 20, 57 }, { 160, 57 } }) do
  c:fill(c:rect(r[1], r[2], r[1] + 4, r[2]), "#8fcbd8")
end
-- deck posts in the water
for x = 6, W - 1, 22 do c:fill(c:rect(x, 51, x + 1, 54), "#5e2f1e") end
local deck = c:rect(-2, 46, W + 1, 50)
c:part(deck, WOOD, { gloss = false })
for x = 4, W - 1, 11 do c:fill(c:rect(x, 47, x, 49), "#8a4f2a") end
c:fill(c:rect(0, 51, W - 1, 51), "#2f6290") -- deck shadow on the water

---------------------------------------------------------------- left third: palm, banana, sampan, lantern string
local function leaf(bx, by, ang, len, wd)
  local tx, ty = bx + len * math.cos(ang), by + len * math.sin(ang)
  local mx, my = bx + 0.55 * len * math.cos(ang), by + 0.55 * len * math.sin(ang)
  local nx, ny = -math.sin(ang) * wd, math.cos(ang) * wd
  return c:poly({ { bx, by }, { mx + nx, my + ny }, { tx, ty }, { mx - nx, my - ny } })
end
local function palm(bx, by, tx, ty, dir)
  local trunk = c:line({ { bx, by }, { (bx + tx) / 2 + dir, (by + ty) / 2 }, { tx, ty } }, 3)
  c:part(trunk, WOOD, { gloss = false })
  for y = ty + 3, by - 2, 4 do c:px(math.floor(tx + (bx - tx) * (y - ty) / (by - ty) + 0.5), y, "#5e2f1e") end
  local m = c:mask()
  local angs = { 0.45, -0.25, -0.95, -1.6, -2.2, -2.9, -3.6 }
  local lens = { 13, 16, 13, 10, 13, 16, 13 }
  for i, a in ipairs(angs) do m:add(leaf(tx, ty, a, lens[i], 1.8)) end
  c:part(m, GREEN, { gloss = false })
  c:part(c:ellipse(tx + 1, ty + 2, 2, 1.5), DARKW, { flat = true, outline = false })
end
palm(34, 46, 29, 17, -1)
palm(218, 46, 222, 18, 1)

-- banana plants flanking the shop (broad paddle leaves with a midrib)
local function paddle(bx, by, ang, len, wd)
  local ca, sa = math.cos(ang), math.sin(ang)
  local nx, ny = -sa, ca
  local function at(t, w) return { bx + len * t * ca + nx * w, by + len * t * sa + ny * w } end
  return c:poly({ at(0, 0.6), at(0.25, wd), at(0.85, wd), at(1, wd * 0.4), at(1, -wd * 0.4), at(0.85, -wd), at(0.25, -wd), at(0, -0.6) })
end
local function banana(bx, dir)
  local leaves = {
    { -math.pi / 2 - 0.75 * dir, 13 }, { -math.pi / 2 + 0.05 * dir, 17 }, { -math.pi / 2 + 0.8 * dir, 13 },
  }
  c:part(c:rect(bx - 1, 36, bx + 1, 46), GREEN, { flat = true })
  for _, l in ipairs(leaves) do
    local m = paddle(bx, 38, l[1], l[2], 3)
    c:part(m, GREEN, { gloss = false })
    for t = 3, l[2] - 2 do
      c:px(math.floor(bx + t * math.cos(l[1]) + 0.5), math.floor(38 + t * math.sin(l[1]) + 0.5), "#a4b86a")
    end
  end
end
banana(64, -1)
banana(176, 1)

-- sampan on the river (left) with an arched woven roof
local boat = c:poly({ { 36, 49 }, { 41, 52 }, { 61, 52 }, { 66, 49 }, { 62, 57 }, { 41, 57 } })
c:part(boat, WOOD, { gloss = false })
c:fill(c:rect(42, 54, 60, 54), "#d9a660")
local canopy = c:ellipse(51, 52, 7, 4):cut(c:rect(0, 52, W, H))
c:part(canopy, GOLD, { flat = true })
for x = 46, 56, 3 do c:fill(c:rect(x, 49, x, 51), "#b8661a") end

-- lantern strings from the shop eaves to the palms
local function lanternString(x0, y0, x1, y1, n)
  for i = 0, 40 do
    local t = i / 40
    local x = x0 + (x1 - x0) * t
    local y = y0 + (y1 - y0) * t + 4 * math.sin(t * math.pi)
    c:px(math.floor(x + 0.5), math.floor(y + 0.5), "#4a2c1a")
  end
  for i = 1, n do
    local t = i / (n + 1)
    local x = math.floor(x0 + (x1 - x0) * t + 0.5)
    local y = math.floor(y0 + (y1 - y0) * t + 4 * math.sin(t * math.pi) + 0.5)
    c:part(c:rrect(x - 1, y + 1, x + 1, y + 4, 0), (i % 2 == 0) and RED or GOLD, { flat = true, outline = false })
    c:px(x - 1, y + 1, (i % 2 == 0) and "#f2793a" or "#fff1c8")
  end
end
lanternString(31, 19, 70, 23, 3)
lanternString(170, 23, 221, 20, 3)

---------------------------------------------------------------- the shop (focal, centre)
local CX = 120
local function edge1(m, col) -- 1 px dark contour just outside a small mask (no 2 px scene outline)
  m:grow(1):cut(m):each(function(x, y) c:px(x, y, col or "#4a2c1a") end)
end
-- walls, then a lamp-lit interior
c:part(c:rect(78, 21, 162, 46), WOOD, { gloss = false })
c:fill(c:rect(85, 28, 155, 40), "#d9a660")
for x = 91, 155, 9 do c:fill(c:rect(x, 30, x, 40), "#b07a45") end
c:fill(c:rect(85, 33, 109, 33), "#8a4f2a") -- shelf board
c:fill(c:rect(85, 34, 109, 34), "#b07a45")
-- shelf goods: rattan balls (sepak takraw) and plush fish
local function rattan(x, y)
  local m = c:ellipse(x, y, 2, 2)
  c:part(m, GOLD, { flat = true, outline = false }); edge1(m, "#8a4f2a")
  c:px(x, y, "#b8661a"); c:px(x + 1, y + 1, "#b8661a"); c:px(x - 1, y - 1, "#fff1c8")
end
local function fish(x, y, col)
  local rows = { "..bbbb...b", ".bbbbbb.bb", "bebbbbbbbb", ".bbbbbb.bb", "..bbbb...b" }
  local m = c:ascii(rows, x, y)
  c:part(m, col, { flat = true, outline = false }); edge1(m, "#8a4f2a")
  c:paint({ "..ssss...s" }, x, y + 4, { s = col.shade })
  c:px(x + 1, y + 2, "#2a1a10"); c:px(x + 3, y + 1, col.gloss)
end
rattan(88, 31); rattan(93, 31)
fish(98, 28, RED)
-- left of the cat: a jar of kibble
local jar = c:rrect(92, 35, 102, 40, 2)
c:part(jar, TEAL, { flat = true, outline = false }); edge1(jar, "#5e2f1e")
c:fill(c:rect(93, 35, 101, 35), "#dd3a2a")
c:px(93, 36, "#c8ecdc"); c:px(93, 37, "#c8ecdc")
for _, p in ipairs({ { 96, 38 }, { 98, 37 }, { 100, 38 }, { 97, 39 }, { 99, 39 } }) do c:px(p[1], p[2], "#8a4f2a") end
-- right of the cat: kitten asleep in an upturned paddy-hat bed
local kit = c:ellipse(145, 35.5, 6, 4)
kit:add(c:poly({ { 139, 35 }, { 140, 29 }, { 144, 32 } })):add(c:poly({ { 146, 32 }, { 150, 29 }, { 151, 35 } }))
c:part(kit, CREAM, { flat = true, outline = false }); edge1(kit, "#8a4f2a")
c:paint({ "aa...aa", ".......", "...n..." }, 142, 35, { a = "#4a2c1a", n = "#dd3a2a" })
c:paint({ "a.a" }, 144, 38, { a = "#b07a45" })
c:px(141, 32, "#f2793a"); c:px(141, 33, "#f2793a"); c:px(149, 32, "#f2793a"); c:px(149, 33, "#f2793a")
-- grey tabby stripes on the kitten's crown
c:fill(c:rect(144, 31, 144, 32):add(c:rect(146, 31, 146, 32)), "#d9a660")
local hat = c:poly({ { 133, 39 }, { 157, 39 }, { 153, 42 }, { 137, 42 } }):add(c:rect(134, 38, 156, 39))
c:part(hat, GOLD, { flat = true, outline = false }); edge1(hat, "#8a4f2a")
for x = 136, 154, 3 do c:px(x, 40, "#b8661a"); c:px(x + 1, 41, "#b8661a") end
c:fill(c:rect(134, 38, 156, 38), "#f5cf6a")

-- counter and batik cloth
c:part(c:rect(82, 41, 158, 42), WOOD, { flat = true, outline = false })
c:fill(c:rect(82, 43, 158, 43), "#5e2f1e")
c:part(c:rect(84, 44, 156, 46), TEAL, { flat = true, outline = false })
for x = 87, 153, 6 do c:paint({ ".g.", "gdg", ".g." }, x, 44, { g = "#f5cf6a", d = "#2f6290" }) end
c:fill(c:rect(84, 46, 156, 46), "#2f6290")

-- front posts
for _, x in ipairs({ 78, 157 }) do
  local m = c:rect(x, 23, x + 5, 46)
  c:part(m, WOOD, { gloss = false, outline = false }); edge1(m)
end

-- roof: front gable with cat-ear finials (its outline spills down; the awning covers it)
local roof = c:poly({ { 64, 23 }, { CX, 5 }, { CX + 1, 5 }, { 177, 23 } })
local gable = c:poly({ { 87, 22 }, { CX, 11 }, { CX + 1, 11 }, { 154, 22 } })
roof:cut(gable)
local earL = c:poly({ { 105, 12 }, { 107, 2 }, { 116, 8 } })
local earR = c:poly({ { 125, 8 }, { 134, 2 }, { 136, 12 } })
c:part(roof:copy():add(earL):add(earR), RED, { gloss = false, cres = 3 })
c:fill(c:poly({ { 108, 10 }, { 108, 6 }, { 113, 9 } }), "#f2e4c0")
c:fill(c:poly({ { 128, 9 }, { 133, 6 }, { 133, 10 } }), "#f2e4c0")
-- small enamel comma on the lit left slope
c:fill(c:line({ { 80, 16 }, { 86, 12 } }, 1), "#f2793a"); c:px(84, 14, "#f5cf6a"); c:px(85, 13, "#f5cf6a")
-- woven attap gable
c:part(gable, CREAM, { gloss = false, outline = false, flat = true })
gable:each(function(x, y) if y % 3 == 0 or (y % 3 ~= 0 and (x + (y // 3) * 2) % 4 == 0) then c:px(x, y, "#d9a660") end end)
edge1(gable, "#ae2a2a")
-- gold emblem: cat head (no text)
local disc = c:ellipse(CX, 17, 5, 5)
c:part(disc, GOLD, { gloss = false, outline = false, flat = true }); edge1(disc)
c:paint({
  "s.....s",
  "ss...ss",
  "sssssss",
  "s.sss.s",
  "sssssss",
  ".sssss.",
}, CX - 3, 14, { s = "#5e2f1e" })
-- gold seam along the eaves (a real join between tiles and trim)
c:seam({ { 67, 21 }, { CX, 6 } }, {})
c:seam({ { CX + 1, 6 }, { 174, 21 } }, {})

-- awning: teal and cream stripes, scalloped hem
local awn = c:rect(72, 22, 168, 25)
for x = 72, 168, 8 do awn:add(c:ellipse(x + 3.5, 25, 4, 2.4)) end
awn:cut(c:rect(0, 28, W, H)):cut(c:rect(169, 0, W, H)):cut(c:rect(0, 0, 71, H))
local stripeT, stripeC = c:mask(), c:mask()
awn:each(function(x, y) if ((x - 72) // 8) % 2 == 0 then stripeT:set(x, y) else stripeC:set(x, y) end end)
c:part(stripeC, CREAM, { flat = true, outline = false })
c:part(stripeT, TEAL, { flat = true, outline = false })
-- crescent: the bottom row of each scallop is shaded
awn:each(function(x, y)
  if not awn:has(x, y + 1) or x >= 166 then
    c:px(x, y, stripeT:has(x, y) and "#2f6290" or "#d9a660")
  end
end)
c:fill(c:rect(72, 22, 168, 22), "#8a4f2a")
edge1(awn:copy():cut(c:rect(0, 0, W, 22)))

-- big lanterns hanging at the eave corners (warm light)
local function lantern(x)
  c:fill(c:rect(x, 24, x, 25), "#4a2c1a")
  local m = c:rrect(x - 3, 26, x + 3, 33, 2)
  c:part(m, GOLD, { gloss = false, outline = false, cres = 2 }); edge1(m)
  c:fill(c:rect(x - 2, 26, x + 2, 26):add(c:rect(x - 2, 33, x + 2, 33)), "#dd3a2a")
  c:fill(c:rect(x - 2, 28, x - 2, 30), "#fff1c8")
  c:px(x, 34, "#dd3a2a"); c:px(x, 35, "#dd3a2a")
end
lantern(71); lantern(169)

-- ginger cat sitting on the counter (the hero of the banner), ears in front of the awning
local tail = c:line({ { 125, 40 }, { 129, 40 }, { 131, 39 } }, 2)
local body = c:ellipse(CX + 0.5, 37, 7, 4):cut(c:rect(0, 41, W, H))
local head = c:ellipse(CX + 0.5, 31, 6.5, 4.5)
head:add(c:poly({ { 113, 30 }, { 115, 23 }, { 119, 28 } })):add(c:poly({ { 122, 28 }, { 126, 23 }, { 128, 30 } }))
c:part(tail, GOLD, { flat = true, outline = false })
c:part(body, GOLD, { gloss = false, outline = false, cres = 3 })
c:part(head, GOLD, { gloss = false, outline = false, cres = 3 })
edge1(tail:copy():add(body):add(head))
c:fill(c:rect(115, 26, 115, 28):add(c:rect(116, 27, 116, 28)), "#f2793a")
c:fill(c:rect(126, 26, 126, 28):add(c:rect(125, 27, 125, 28)), "#f2793a")
c:fill(c:rect(118, 33, 123, 35), "#fff1c8")                      -- muzzle
c:eye(115, 30, true); c:eye(123, 30, true)
c:fill(c:rect(120, 33, 121, 33), "#dd3a2a")                      -- nose
c:paint({ "m.m" }, 119, 35, { m = "#8a4f2a" })
c:paint({ "s.s" }, 119, 28, { s = "#b8661a" })
c:px(115, 37, "#b8661a"); c:px(116, 38, "#b8661a"); c:px(125, 37, "#b8661a"); c:px(124, 38, "#b8661a")
c:fill(c:rect(116, 40, 118, 40):add(c:rect(123, 40, 125, 40)), "#fff1c8") -- paws
c:px(116, 29, "#fff1c8") -- gloss dot on the lit cheek

-- deck shadow under the shop
c:fill(c:rect(70, 50, 170, 50), "#8a4f2a")

---------------------------------------------------------------- hem stitch (banners only)
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(OUT .. "banner-SEA-pets.aseprite", OUT .. "banner-SEA-pets.png")
print(GV.report(t))
