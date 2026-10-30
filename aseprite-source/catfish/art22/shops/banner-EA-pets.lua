-- banner-EA-pets.lua : Cat Fish pet shop banner for Blossom Lantern Cattery (Blossomreach, EA).
-- Matches the shipped region banners (game/assets/img/scenes/banner-*.png): 240x60 grid written at 2x = 480x120,
-- scene mode (no black border), opaque, gold hem stitch along top and bottom, <= 24 colours, EA palette
-- (blossom pinks, moss hills, sandy path, dusk-violet roof). Focal: one tiled-roof cattery front in the
-- market town, warm lit doorway with a red noren (paw emblem), round window with a cat, a maneki-neko in the
-- shop window, two red lanterns, a tabby asleep on the roof ridge, a lantern garland under the top band.
-- Run: AppRun -b --script banner-EA-pets.lua   Writes ../out/banner-EA-pets.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local W, H = 240, 60
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 0 }
local floor, sin = math.floor, math.sin
local function px(x, y, hex) if x >= 0 and x < W and y >= 0 and y < H then c:px(x, y, hex) end end

-- palette (24 max): every colour used below is one of these
local P = {
  band = "#3d2a1c", gold = "#f5cf6a", goldS = "#e8a317",
  pink = "#e46a9b", pinkL = "#f6b8cf", pinkD = "#b84a7a", cream = "#f2e4c0",
  hill = "#a4b86a", grass = "#7ab55c", grassD = "#4f9a45",
  path = "#c9a96e", pathL = "#d8c49a",
  ol1 = "#74462a", ol2 = "#4a2c1a", ol3 = "#2a1a10",
  roof = "#4e3a8a", roofL = "#7b66b4", roofD = "#3e2f66",
  wood = "#b8452f", woodD = "#8a4f2a",
  red = "#dd3a2a", redD = "#ae2a2a", orange = "#f2793a",
}
local function R(base, rim, shade, deep, gloss, dot)
  return { base = base, rim = rim, shade = shade, deep = deep or shade, bounce = shade,
           gloss = gloss or rim, dot = dot or gloss or rim, pale = false }
end
local ROOF  = R(P.roof, P.roofL, P.roofD, P.roofD, P.roofL)
local WALL  = R(P.cream, P.cream, P.pathL, P.path)
local WOOD  = R(P.wood, P.orange, P.woodD, P.ol1)
local DARKW = R(P.woodD, P.wood, P.ol1, P.ol2)
local RED   = R(P.red, P.orange, P.redD, P.redD, P.orange, P.gold)
local BLOS  = R(P.pink, P.pinkL, P.pinkD, P.pinkD, P.pinkL, P.cream)
local TABBY = R(P.orange, P.gold, P.wood, P.woodD, P.gold, P.cream)
local CAT   = R(P.cream, P.cream, P.pathL, P.path)
local STONE = R(P.pathL, P.cream, P.path, P.woodD)
local PINE  = R(P.grass, P.hill, P.grassD, P.grassD)

-------------------------------------------------------------------- sky, sun, clouds
c:bands(c:rect(0, 0, W - 1, 44), { P.pink, P.pinkL, P.pinkL, P.cream }, { dir = "v" })
c:fill(c:ellipse(34, 17, 7, 7), P.gold)                       -- low warm sun, upper left
c:fill(c:ellipse(33, 16, 4, 4), P.cream)
local function cloud(x, y, w)
  c:fill(c:rrect(x, y, x + w, y + 2, 1), P.cream)
  c:fill(c:rrect(x + 3, y - 2, x + floor(w * 0.6), y, 1), P.cream)
end
cloud(52, 13, 16); cloud(176, 10, 20); cloud(214, 17, 12); cloud(8, 22, 11)

-------------------------------------------------------------------- far hills with distant blossom puffs
local hillTop = {}
for x = 0, W - 1 do hillTop[x] = floor(37 + 2.4 * sin(x / 13 + 0.4) + 1.2 * sin(x / 5.5) + 0.5) end
for x = 0, W - 1 do c:fill(c:rect(x, hillTop[x], x, 47), P.hill) end
for _, t in ipairs({ { 14, 2 }, { 24, 3 }, { 192, 2 }, { 226, 3 }, { 236, 2 } }) do
  local x, r = t[1], t[2]
  local y = hillTop[x] - r + 1
  c:fill(c:ellipse(x, y, r, r - 0.5), P.pinkL)
  px(x - 1, y - r + 1, P.cream)
end
-- grass band
for x = 0, W - 1 do
  local g = floor(44 + 0.8 * sin(x / 7 + 1) + 0.5)
  c:fill(c:rect(x, g, x, 49), P.grass)
end
-- path
c:fill(c:rect(0, 50, W - 1, H - 1), P.path)
for x = 0, W - 1 do if (x % 9) < 5 then px(x, 50, P.pathL) end end

-------------------------------------------------------------------- top band + lantern garland
c:fill(c:rect(0, 0, W - 1, 3), P.band)
local gy = {}
for x = 0, W - 1 do gy[x] = floor(4 + 1.6 * (1 - math.cos((x % 40) / 40 * 2 * math.pi)) / 2 * 2 + 0.5) end
local function onG(x) return x < 68 or x > 172 end
for x = 0, W - 1 do if onG(x) then px(x, gy[x], P.ol2) end end
local lcol = { P.red, P.cream, P.pinkL }
local n = 0
for x = 6, W - 6, 13 do if onG(x - 2) and onG(x + 2) then
  n = n + 1
  local col = lcol[(n % 3) + 1]
  local y = gy[x] + 1
  c:fill(c:rect(x - 1, y, x + 1, y + 3), col)
  px(x - 1, y, P.band); px(x + 1, y, P.band); px(x, y, P.ol2)
  px(x - 1, y + 3, P.band); px(x + 1, y + 3, P.band); px(x, y + 3, P.ol2)
  px(x + 1, y + 2, col == P.red and P.redD or P.pathL)      -- crescent, lower right
  px(x - 1, y + 1, col == P.red and P.orange or P.gold)     -- lit glint
end end

-------------------------------------------------------------------- left blossom tree, right stone lantern + small tree
local function tree(cx, cy, r, yb)
  local tx = floor(cx)
  c:part(c:rect(tx - 1, floor(cy), tx + 1, yb), DARKW, { flat = true })
  local crown = c:ellipse(cx, cy, r, r * 0.8)
  crown:add(c:ellipse(cx - r * 0.7, cy + 2, r * 0.55, r * 0.5)):add(c:ellipse(cx + r * 0.7, cy + 2, r * 0.55, r * 0.5))
  c:part(crown, BLOS, { gloss = false, cres = 3, deep = 1 })
  local blob = c:ellipse(cx - r * 0.35, cy - r * 0.3, r * 0.45, r * 0.35):clip(crown:shrink(1))
  c:fill(blob, P.pinkL)
  local bx, by = blob:bbox()
  if bx then px(bx + 1, by, P.cream) end
end
tree(56, 30, 10, 48)
tree(214, 35, 7, 49)

-- stone lantern (toro) right of the shop: wide cap, lit box, post, base
local toro = c:mask()
toro:add(c:rect(181, 46, 189, 48))            -- base
toro:add(c:rect(184, 42, 186, 45))            -- post
toro:add(c:rect(182, 38, 188, 41))            -- fire box
toro:add(c:poly({ { 178, 38 }, { 182, 34 }, { 189, 34 }, { 193, 38 } }))  -- cap
toro:add(c:rect(184, 32, 186, 33))            -- finial
c:part(toro, STONE, { cres = 2, deep = 1, gloss = false })
c:fill(c:rect(184, 39, 186, 40), P.orange); px(184, 39, P.gold)
c:fill(c:rect(179, 37, 192, 37), P.path)

-------------------------------------------------------------------- the cattery
-- stone plinth
c:part(c:rect(84, 48, 156, 50), STONE, { cres = 1, deep = 0, gloss = false })
-- wall
c:part(c:rect(86, 27, 154, 47), WALL, { cres = 3, deep = 1, gloss = false })
-- posts + beam
local frame = c:mask()
frame:add(c:rect(86, 27, 88, 47)):add(c:rect(152, 27, 154, 47))
frame:add(c:rect(107, 29, 108, 47)):add(c:rect(132, 29, 133, 47))
frame:add(c:rect(86, 29, 154, 30))
c:part(frame, WOOD, { flat = true })
-- doorway glow and the inside floor
local door = c:rect(109, 31, 131, 47)
c:fill(door, P.gold)
c:fill(c:rect(109, 44, 131, 47), P.orange)
c:fill(c:rect(109, 31, 131, 31), P.goldS)
-- a cream cat sitting inside the door, looking out (back-lit), between noren and floor
local doorcat = c:mask()
doorcat:add(c:ellipse(121, 44.5, 3, 2)):add(c:ellipse(121, 41, 2.5, 2))
doorcat:add(c:poly({ { 119, 41 }, { 119, 38 }, { 121, 40 } })):add(c:poly({ { 122, 40 }, { 123, 38 }, { 123, 41 } }))
c:part(doorcat, CAT, { cres = 2, deep = 1, gloss = false })
c:fill(c:line({ { 124, 46 }, { 126, 45 }, { 126, 43 } }, 1), P.pathL)
px(120, 41, P.ol3); px(122, 41, P.ol3); px(121, 42, P.pink)
-- noren curtain: three red panels with gaps, paw print on the middle one
local noren = c:mask()
noren:add(c:rect(109, 31, 115, 37)):add(c:rect(117, 31, 123, 37)):add(c:rect(125, 31, 131, 37))
c:part(noren, RED, { cres = 2, deep = 1, gloss = false, outline = false })
c:fill(c:rect(109, 31, 131, 31), P.redD)
c:paint({ "c.c.c", ".ccc.", ".ccc." }, 118, 33, { c = P.cream })   -- paw print
-- round window with a sitting cat silhouette
local rw = c:ellipse(97.5, 38, 6.5, 6.5)
c:part(rw, DARKW, { flat = true })
local pane = c:ellipse(97.5, 38, 5, 5)
c:fill(pane, P.gold)
c:fill(c:rect(91, 42, 104, 43):clip(pane), P.orange)               -- warm sill light
local sil = c:mask()                                                -- cat sitting in the window, back-lit
sil:add(c:ellipse(97.5, 41, 3, 2)):add(c:ellipse(97.5, 37.5, 2.5, 2))
sil:add(c:poly({ { 95, 37 }, { 95, 34 }, { 97, 36 } })):add(c:poly({ { 98, 36 }, { 100, 34 }, { 100, 37 } }))
sil:clip(pane)
c:fill(sil, P.ol2)
c:fill(c:line({ { 100, 42 }, { 101, 41 }, { 101, 39 } }, 1):clip(pane), P.ol2)
px(96, 37, P.gold); px(99, 37, P.gold)                              -- eyes catching the light
-- display window with a maneki-neko and a yarn ball
local dw = c:rect(136, 33, 150, 45)
c:part(dw, DARKW, { flat = true })
c:fill(c:rect(138, 35, 148, 43), P.gold)
c:fill(c:rect(138, 41, 148, 43), P.orange)
c:part(c:rect(137, 43, 149, 44), WOOD, { flat = true, outline = false })
local mk = c:mask()
mk:add(c:ellipse(141.5, 40.5, 2.5, 2.5)):add(c:ellipse(141.5, 37.5, 2.5, 2))
mk:add(c:rect(139, 35, 139, 36)):add(c:rect(144, 35, 144, 36))
mk:add(c:rect(144, 35, 145, 38))                                     -- raised paw
c:part(mk, CAT, { cres = 2, deep = 1, gloss = false })
c:fill(c:rect(140, 39, 143, 39), P.red); px(141, 40, P.gold)
px(140, 37, P.ol3); px(142, 37, P.ol3)
c:part(c:ellipse(146, 41.5, 1.6, 1.6), RED, { flat = true })
px(147, 42, P.redD)

-- eave fascia and the tiled roof
local roof = c:poly({ { 73, 27 }, { 69, 20 }, { 77, 22 }, { 94, 12 }, { 147, 12 }, { 164, 22 }, { 172, 20 }, { 168, 27 } })
c:part(roof, ROOF, { cres = 3, deep = 1, gloss = false })
-- tile courses: shade lines and channel ticks
for y = 15, 25, 3 do
  roof:copy():clip(c:rect(0, y, W - 1, y)):each(function(x, yy) px(x, yy, P.roofD) end)
end
for y = 13, 25, 3 do
  for x = 76, 166, 5 do
    local xx = x + ((y // 3) % 2) * 2
    if roof:has(xx, y) and roof:has(xx, y + 1) then px(xx, y, P.roofL); px(xx, y + 1, P.roofL) end
  end
end
c:part(c:rect(73, 26, 167, 27), WOOD, { flat = true })
-- ridge with cat-ear tiles at both ends
local ridge = c:rect(92, 10, 149, 12)
ridge:add(c:poly({ { 88, 13 }, { 89, 6 }, { 94, 10 } })):add(c:poly({ { 147, 10 }, { 152, 6 }, { 153, 13 } }))
c:part(ridge, ROOF, { cres = 2, deep = 1, gloss = false, flat = true })
px(90, 9, P.pinkL); px(90, 10, P.pinkL); px(151, 9, P.pinkL); px(151, 10, P.pinkL)                           -- pink inner ears
c:fill(c:rect(93, 12, 148, 12), P.roofD)

-- sign plaque under the ridge: cat face emblem (no text)
c:part(c:rrect(112, 15, 128, 23, 1), DARKW, { flat = true })
c:fill(c:rect(114, 16, 126, 22), P.wood)
local face = c:ellipse(120, 19.5, 3.5, 2.5)
face:add(c:poly({ { 116, 19 }, { 117, 16 }, { 119, 18 } })):add(c:poly({ { 121, 18 }, { 123, 16 }, { 124, 19 } }))
c:fill(face, P.cream)
px(118, 19, P.ol3); px(122, 19, P.ol3); px(120, 20, P.pink)

-- two red paper lanterns hanging from the eave
local function lantern(x)
  c:fill(c:rect(x, 28, x, 29), P.ol2)
  local m = c:ellipse(x, 33.5, 3, 3.5)
  c:part(m, RED, { cres = 2, deep = 1, gloss = { x - 1, 31 } })
  c:fill(c:rect(x - 1, 30, x + 1, 30), P.band)
  c:fill(c:rect(x - 1, 37, x + 1, 37), P.band)
  px(x - 2, 33, P.gold); px(x + 2, 34, P.goldS)
  px(x, 38, P.gold)
end
lantern(80); lantern(160)

-- tabby cat asleep on the ridge
local tb = c:ellipse(138, 8.5, 6, 2)
local th = c:ellipse(131.5, 8.5, 2.5, 2)
th:add(c:poly({ { 129, 8 }, { 129, 5 }, { 131, 7 } })):add(c:poly({ { 132, 7 }, { 134, 5 }, { 134, 8 } }))
c:part(tb, TABBY, { cres = 2, deep = 1, gloss = false })
c:part(th, TABBY, { cres = 2, deep = 1, gloss = false })
c:fill(c:line({ { 144, 9 }, { 146, 9 }, { 147, 8 } }, 1), P.orange)
px(136, 7, P.wood); px(139, 7, P.wood); px(142, 8, P.wood)          -- stripes
px(130, 9, P.ol3); px(133, 9, P.ol3)                              -- closed eyes

-- potted pine by the door and stepping stones
c:part(c:rrect(76, 45, 81, 49, 1), WOOD, { cres = 1, deep = 0, gloss = false })
local pine = c:ellipse(78.5, 42.5, 4, 2):add(c:ellipse(77, 40, 2.5, 1.5))
c:part(pine, PINE, { cres = 1, deep = 0, gloss = false })
c:part(c:rrect(136, 46, 141, 47, 1), WOOD, { cres = 1, deep = 0, gloss = false })
c:part(c:ellipse(138.5, 44.5, 3, 1.5), BLOS, { flat = true })
for _, s in ipairs({ { 120, 52, 4 }, { 115, 55, 3 }, { 124, 57, 3 } }) do
  c:fill(c:ellipse(s[1], s[2], s[3], 1), P.pathL)
end

-------------------------------------------------------------------- petals, grass tufts, hem
local specks = { { 12, 9 }, { 47, 27 }, { 70, 12 }, { 82, 7 }, { 160, 11 }, { 170, 18 }, { 199, 24 }, { 229, 10 },
  { 20, 47 }, { 66, 52 }, { 160, 54 }, { 196, 51 }, { 230, 56 }, { 40, 56 } }
for _, p in ipairs(specks) do px(p[1], p[2], P.pink) end
for _, t in ipairs({ 8, 30, 74, 168, 200, 232 }) do
  c:paint({ "g.g", ".g." }, t, 48, { g = P.grassD })
end
for x = 0, W - 1 do
  if x % 3 ~= 2 then px(x, 1, P.gold); px(x, H - 2, P.goldS) end
end

local t = c:save(OUT .. "banner-EA-pets.aseprite", OUT .. "banner-EA-pets.png")
print(GV.report(t))
