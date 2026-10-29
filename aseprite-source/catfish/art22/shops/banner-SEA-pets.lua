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
  local angs = { -0.1, -0.6, -1.15, -1.75, -2.35, -2.95 }
  local lens = { 13, 15, 12, 12, 15, 13 }
  for i, a in ipairs(angs) do m:add(leaf(tx, ty, a + (i % 2) * 0.12, lens[i], 2.2)) end
  c:part(m, GREEN, { gloss = false })
  c:part(c:ellipse(tx + 1, ty + 2, 2, 1.5), DARKW, { flat = true, outline = false })
end
palm(34, 46, 29, 17, -1)
palm(218, 46, 222, 18, 1)

-- banana plants flanking the shop (paddle leaves)
local function banana(bx, dir)
  local m = c:mask()
  m:add(leaf(bx, 45, -math.pi / 2 - 0.5 * dir, 14, 3.2))
  m:add(leaf(bx, 45, -math.pi / 2 + 0.15 * dir, 16, 3.4))
  m:add(leaf(bx, 45, -math.pi / 2 + 0.85 * dir, 12, 3))
  c:part(c:rect(bx - 1, 38, bx, 46), GREEN, { flat = true, outline = false })
  c:part(m, GREEN, { gloss = false })
  -- midribs
  for t = 2, 12 do
    c:px(math.floor(bx + t * math.cos(-math.pi / 2 + 0.15 * dir) + 0.5), math.floor(45 + t * math.sin(-math.pi / 2 + 0.15 * dir) + 0.5), "#a4b86a")
  end
end
banana(62, -1)
banana(178, 1)

-- sampan on the river (left)
local boat = c:poly({ { 40, 52 }, { 62, 52 }, { 59, 56 }, { 44, 56 } })
c:part(boat, WOOD, { gloss = false })
c:fill(c:rect(43, 53, 58, 53), "#d9a660")
local canopy = c:ellipse(51, 52, 5, 3):cut(c:rect(0, 52, W, H))
c:part(canopy, CREAM, { flat = true })

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
lanternString(31, 20, 70, 26, 3)
lanternString(170, 26, 220, 21, 3)

---------------------------------------------------------------- the shop (focal, centre)
local CX = 120
-- stilts under the deck line are hidden by the deck; walls and posts
local wall = c:rect(78, 24, 162, 45)
c:part(wall, WOOD, { gloss = false })
-- interior (warm lamp-lit brown) with two shelves
local inner = c:rect(85, 31, 155, 40)
c:fill(inner, "#8a4f2a")
c:fill(c:rect(85, 31, 155, 31), "#5e2f1e")
c:fill(c:rect(85, 35, 155, 35), "#5e2f1e")
c:fill(c:rect(85, 31, 85, 40):add(c:rect(155, 31, 155, 40)), "#5e2f1e")
-- shelf goods: rattan balls (sepak takraw), fish toys, yarn balls
local function rattan(x, y)
  c:part(c:ellipse(x, y, 1.5, 1.5), GOLD, { flat = true, outline = false })
  c:px(x, y, "#b8661a"); c:px(x - 1, y - 1, "#fff1c8")
end
local function fish(x, y, col)
  local m = c:poly({ { x, y }, { x + 4, y - 1 }, { x + 4, y + 2 }, { x, y + 1 } })
  m:add(c:rect(x + 4, y - 1, x + 5, y + 2):cut(c:rect(x + 5, y, x + 5, y + 1)))
  c:part(m, col, { flat = true, outline = false })
  c:px(x + 1, y, "#2a1a10")
end
for i, x in ipairs({ 89, 95, 101 }) do rattan(x, 33) end
fish(140, 33, RED); fish(147, 33, GOLD)
c:part(c:ellipse(90, 38, 2, 2), TEAL, { flat = true, outline = false }); c:px(89, 37, "#c8ecdc")
c:part(c:ellipse(96, 38, 2, 2), RED, { flat = true, outline = false }); c:px(95, 37, "#f2793a")
fish(141, 37, TEAL); fish(148, 37, RED)

-- front posts
c:part(c:rect(78, 26, 82, 45), WOOD, { gloss = false })
c:part(c:rect(158, 26, 162, 45), WOOD, { gloss = false })

-- counter and batik cloth
local counter = c:rect(80, 40, 160, 41)
c:part(counter, WOOD, { gloss = false })
local cloth = c:rect(83, 42, 157, 46)
c:part(cloth, TEAL, { gloss = false, outline = false })
for x = 86, 154, 6 do
  local y = 44
  c:paint({ ".g.", "gdg", ".g." }, x, y - 1, { g = "#f5cf6a", d = "#2f6290" })
end
c:seam({ { 83, 42 }, { 157, 42 } }, { free = true })
c:outline(cloth:copy():cut(c:rect(0, 46, W, H)))

-- awning: teal and cream stripes, scalloped hem
local awn = c:rect(74, 25, 166, 29)
for x = 74, 166, 6 do awn:add(c:ellipse(x + 2.5, 29, 3, 2):cut(c:rect(0, 0, W, 29))) end
awn:cut(c:rect(0, 32, W, H))
local stripeT, stripeC = c:mask(), c:mask()
awn:each(function(x, y) if ((x - 74) // 6) % 2 == 0 then stripeT:set(x, y) else stripeC:set(x, y) end end)
c:part(stripeC, CREAM, { light = awn, outline = false, gloss = false })
c:part(stripeT, TEAL, { light = awn, outline = false, gloss = false })
c:outline(awn)
c:fill(c:rect(75, 25, 165, 25), "#fff1c8")

-- roof: front gable with cat-ear finials
local roof = c:poly({ { 66, 26 }, { CX, 5 }, { CX + 1, 5 }, { 175, 26 } })
local gable = c:poly({ { 84, 25 }, { CX, 12 }, { CX + 1, 12 }, { 157, 25 } })
roof:cut(gable)
local earL = c:poly({ { 106, 12 }, { 108, 2 }, { 116, 8 } })
local earR = c:poly({ { 125, 8 }, { 133, 2 }, { 135, 12 } })
local roofAll = roof:copy():add(earL):add(earR)
c:part(roofAll, RED, { gloss = { 92, 17 } })
c:fill(c:poly({ { 109, 10 }, { 109, 6 }, { 113, 9 } }), "#f2e4c0")
c:fill(c:poly({ { 128, 9 }, { 132, 6 }, { 132, 10 } }), "#f2e4c0")
-- tile rows on the slopes
for _, t in ipairs({ 0.35, 0.65 }) do
  for x = 66, 175 do
    local yl = 26 - (x - 66) * 21 / 54
    local yr = 26 - (175 - x) * 21 / 54
    local y = math.floor(math.max(yl, yr) + 0.5)
    local inside = roof:has(x, y + 2) and not gable:has(x, y + 2)
    if x % 3 == 0 and inside and t == 0.35 then c:px(x, y + 2, "#ae2a2a") end
  end
end
-- woven attap gable
c:part(gable, CREAM, { gloss = false, outline = false })
gable:each(function(x, y)
  if (x + y) % 5 == 0 or (x - y) % 5 == 0 then c:px(x, y, "#d9a660") end
end)
c:outline(gable, { ol = 1, olx = 0 })
-- gold emblem: cat head (no text)
local disc = c:ellipse(CX + 0.5, 19, 4.5, 4.5)
c:part(disc, GOLD, { gloss = false })
c:paint({
  "s...s",
  "ss.ss",
  "sssss",
  "s.s.s",
  "sssss",
  ".sss.",
}, CX - 2, 16, { s = "#5e2f1e" })
-- eave trim seam
c:seam({ { 68, 25 }, { CX, 6 } }, {})
c:seam({ { CX + 1, 6 }, { 173, 25 } }, {})

-- hanging lanterns under the awning
local function lantern(x)
  c:px(x, 32, "#4a2c1a"); c:px(x + 1, 32, "#4a2c1a")
  local m = c:rrect(x - 2, 33, x + 3, 38, 1)
  c:part(m, GOLD, { gloss = false })
  c:fill(c:rect(x - 1, 33, x + 2, 33):add(c:rect(x - 1, 38, x + 2, 38)), "#dd3a2a")
  c:px(x - 1, 34, "#fff1c8"); c:px(x - 1, 35, "#fff1c8")
end
lantern(92); lantern(148)

-- ginger cat sitting on the counter
local tail = c:line({ { 127, 39 }, { 130, 38 }, { 131, 35 } }, 2)
c:part(tail, GOLD, { flat = true })
local body = c:ellipse(CX + 0.5, 37, 6, 3.5):cut(c:rect(0, 40, W, H))
local head = c:ellipse(CX + 0.5, 32, 5, 3.5)
head:add(c:poly({ { 115, 31 }, { 116, 27 }, { 119, 29 } })):add(c:poly({ { 122, 29 }, { 125, 27 }, { 126, 31 } }))
c:part(body, GOLD, { gloss = false })
c:part(head, GOLD, { gloss = { 117, 30 } })
c:fill(c:rect(116, 29, 116, 29):add(c:rect(125, 29, 125, 29)), "#f2793a")
c:eye(116, 31, true); c:eye(122, 31, true)
c:px(120, 34, "#2a1a10"); c:px(121, 34, "#2a1a10")
c:px(120, 29, "#b8661a"); c:px(121, 29, "#b8661a")
c:px(115, 37, "#b8661a"); c:px(124, 36, "#b8661a")
c:fill(c:rect(117, 39, 118, 39):add(c:rect(122, 39, 123, 39)), "#f2e4c0") -- paws

-- kitten curled in a paddy-hat bed (right of the cat)
local hat = c:poly({ { 132, 38 }, { 154, 38 }, { 150, 40 }, { 136, 40 } }):add(c:rect(134, 37, 152, 38))
local kit = c:ellipse(143.5, 35.5, 5, 2.5):cut(c:rect(0, 38, W, H))
c:part(kit, CREAM, { gloss = false })
c:part(c:poly({ { 138, 34 }, { 139, 31 }, { 141, 33 } }), CREAM, { flat = true })
c:px(140, 35, "#2a1a10"); c:px(142, 35, "#2a1a10")
c:part(hat, GOLD, { gloss = false })
for x = 135, 152, 3 do c:px(x, 39, "#b8661a") end
-- jar of fish treats (left of the cat)
local jar = c:rrect(101, 33, 108, 39, 2)
c:part(jar, TEAL, { gloss = false })
c:fill(c:rect(102, 32, 107, 33), "#dd3a2a")
fish(102, 36, RED)
c:px(102, 34, "#c8ecdc")

-- deck shadow under the shop
c:fill(c:rect(70, 50, 170, 50), "#8a4f2a")

---------------------------------------------------------------- hem stitch (banners only)
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(OUT .. "banner-SEA-pets.aseprite", OUT .. "banner-SEA-pets.png")
print(GV.report(t))
