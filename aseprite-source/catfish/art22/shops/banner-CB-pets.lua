-- banner-CB-pets.lua : Cat Fish pet shop front banner for Driftwood & Whisker (Sunsprinkle Isles, CB, Caribbean).
-- Matches the shipped region banners (game/assets/img/scenes/banner-*.png): 240x60 grid written at 2x = 480x120,
-- gvlib "scene" mode, no black border, three-tone umber outline on raised objects, thread-gold hem stitch on the
-- top and bottom edge, <= 24 colours (shipped banners use 15-23). Light from the upper left, warm afternoon.
-- Focal subject: one coral clapboard shop with a red tin roof whose gable is a cat head (two ear points), a cream
-- gingerbread eave trim, turquoise louvre shutters, a striped awning over a warm glowing window with a ginger cat
-- on a cushion, a turquoise door with a cat flap, and a driftwood fish sign. Pastel town houses, palms and a
-- sea strip behind; sandy street, hibiscus pot and a curled cream cat in front. No text.
-- Run: AppRun -b --script banner-CB-pets.lua   Writes ../out/banner-CB-pets.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"

---------------------------------------------------------------- palette (23 colours)
local O1, O2, O3 = "#74462a", "#4a2c1a", "#2a1a10"
local SKY_A, SKY_B = "#a9d6ea", "#c8ecdc"
local SEA, SEA_D = "#3f93b2", "#2f7ca6"
local CREAM, THR, GLD = "#f2e4c0", "#f5cf6a", "#e8a317"
local CORAL, CORAL_S, CORAL_L = "#ef7f66", "#c4584f", "#ffb088"
local TURQ = "#3fb5ad"
local WOOD, WOOD_S, WOOD_L = "#b07a45", "#8a4f2a", "#d9a660"
local LEAF, LEAF_S, LEAF_L = "#58a03e", "#2f6a3a", "#9cc95a"
local SAND = "#ecd09a"
local RED, RED_S = "#dd3a2a", "#ae2a2a"

local function R(base, shade, deep, rim, gloss, dot, bounce, pale)
  return { base = base, shade = shade, deep = deep, rim = rim, gloss = gloss, dot = dot, bounce = bounce or shade, pale = pale or false }
end
local CORALR = R(CORAL, CORAL_S, RED_S, CORAL_L, CORAL_L, CREAM)
local PEACHR = R(CORAL_L, CORAL, CORAL_S, CREAM, CREAM, CREAM)
local REDR   = R(RED, RED_S, O2, CORAL, CORAL_L, THR)
local TURQR  = R(TURQ, SEA_D, SEA_D, SKY_B, SKY_B, CREAM, SEA)
local WOODR  = R(WOOD, WOOD_S, O2, WOOD_L, SAND, CREAM)
local DRIFT  = R(WOOD_L, WOOD, WOOD_S, SAND, CREAM, CREAM)
local LEAFR  = R(LEAF, LEAF_S, LEAF_S, LEAF_L, LEAF_L, THR)
local GOLDR  = R(GLD, WOOD_S, O1, THR, THR, CREAM, WOOD)
local CREAMR = R(CREAM, WOOD_L, WOOD, CREAM, CREAM, CREAM, WOOD_L, true)
local YELR   = R(THR, GLD, WOOD, CREAM, CREAM, CREAM)
local MINTR  = R(SKY_B, TURQ, SEA_D, CREAM, CREAM, CREAM)

local c = GV.canvas{ mode = "scene", w = 240, h = 60, out = 2 }
local function part(m, r, o) return c:part(m, r, o) end
-- small background objects: 1 px outline instead of the 2+1 px pen
local function far(m, r, o)
  o = o or {}; o.outline = false
  local p = c:part(m, r, o)
  c:outline(m, { ol = 1, olx = 0 })
  return p
end

---------------------------------------------------------------- sky, sun, clouds
c:bands(c:rect(0, 0, 239, 27), { SKY_A, SKY_A, SKY_A, SKY_B, SKY_B })
-- sun upper left (light source)
part(c:ellipse(20, 10, 5, 5), GOLDR, { outline = false, flat = true })
c:fill(c:ellipse(19, 9, 3, 3), THR)
local cloud1 = c:ellipse(58, 9, 9, 2.5):add(c:ellipse(54, 7, 4, 2.5)):add(c:ellipse(61, 6.5, 4, 2))
c:fill(cloud1, CREAM); c:fill(c:rect(50, 11, 66, 11), SKY_B)
local cloud2 = c:ellipse(196, 7, 8, 2):add(c:ellipse(193, 5, 3.5, 2)):add(c:ellipse(200, 5, 3, 1.5))
c:fill(cloud2, CREAM)
local cloud3 = c:ellipse(226, 15, 5, 1.5):add(c:ellipse(224, 14, 2.5, 1.5))
c:fill(cloud3, CREAM)

---------------------------------------------------------------- sea strip and a far sailboat
c:fill(c:rect(0, 26, 239, 37), SEA)
c:fill(c:rect(0, 26, 239, 26), SKY_B)
c:fill(c:rect(0, 32, 239, 37), SEA_D)
for _, w in ipairs({ {8, 29}, {40, 30}, {170, 29}, {214, 31}, {28, 34}, {228, 34} }) do
  c:paint({ ".cc.", "c..c" }, w[1], w[2], { c = SKY_B })
end
-- sailboat (far right)
c:fill(c:poly({ {205, 20}, {205, 29}, {213, 29} }), CREAM)
c:fill(c:rect(204, 19, 204, 30), WOOD_S)
c:fill(c:poly({ {199, 30}, {216, 30}, {213, 33}, {202, 33} }), CORAL)

---------------------------------------------------------------- background town houses (lighter, 1 px outline)
local function house(x0, x1, ytop, ybase, wall, roof, roofTop)
  local w = c:rect(x0, ytop, x1, ybase)
  far(w, wall, { gloss = false })
  local r = c:poly({ {x0 - 2, ytop + 1}, {x1 + 3, ytop + 1}, {x1 - 2, roofTop}, {x0 + 3, roofTop} })
  far(r, roof, { gloss = false })
  -- window pair with shutters
  local wy = ytop + 4
  for _, wx in ipairs({ x0 + 3, x1 - 6 }) do
    c:fill(c:rect(wx, wy, wx + 3, wy + 4), SEA_D)
    c:fill(c:rect(wx, wy, wx + 3, wy), CREAM)
    c:fill(c:rect(wx - 1, wy, wx - 1, wy + 4), TURQ); c:fill(c:rect(wx + 4, wy, wx + 4, wy + 4), TURQ)
  end
  return w
end
house(4, 26, 32, 47, YELR, TURQR, 26)
house(32, 52, 34, 47, MINTR, CORALR, 28)
house(186, 206, 34, 47, PEACHR, TURQR, 28)
house(212, 236, 31, 47, YELR, REDR, 25)
-- far doors
c:fill(c:rect(14, 41, 17, 47), WOOD); c:fill(c:rect(41, 42, 44, 47), CORAL_S)
c:fill(c:rect(195, 42, 198, 47), SEA_D); c:fill(c:rect(222, 41, 225, 47), TURQ)

---------------------------------------------------------------- beach strip behind the town, then the sandy street
c:fill(c:rect(0, 38, 239, 46), SAND)
c:fill(c:rect(0, 38, 239, 38), CREAM)
---------------------------------------------------------------- ground: sandy street
c:bands(c:rect(0, 47, 239, 59), { SAND, SAND, SAND })
c:fill(c:rect(0, 47, 239, 47), WOOD_L)
for _, p in ipairs({ {10, 53}, {30, 56}, {52, 51}, {70, 55}, {170, 54}, {188, 51}, {204, 56}, {226, 53}, {62, 58}, {178, 58} }) do
  c:paint({ ".ss", "ss." }, p[1], p[2], { s = WOOD_L })
end

---------------------------------------------------------------- palms flanking the shop
local function palm(pts, fronds, nuts)
  part(c:line(pts, 3), WOODR, { gloss = false })
  for i = 1, #pts - 1 do -- trunk rings
    local a, b = pts[i], pts[i + 1]
    for t = 0.25, 0.99, 0.25 do
      local x, y = math.floor(a[1] + (b[1] - a[1]) * t + 0.5), math.floor(a[2] + (b[2] - a[2]) * t + 0.5)
      c:px(x, y, WOOD_S); c:px(x + 1, y, WOOD_S)
    end
  end
  for _, n in ipairs(nuts) do part(c:rect(n[1], n[2], n[1] + 1, n[2] + 1), WOODR, { flat = true, contact = false, outline = false }) end
  for _, f in ipairs(fronds) do part(c:line(f, 2), LEAFR, { flat = true, contact = false }) end
end
palm({ {66, 47}, {63, 33}, {59, 17} }, {
  { {59, 16}, {53, 13}, {47, 15}, {44, 19} },
  { {59, 16}, {53, 18}, {50, 23} },
  { {59, 16}, {65, 12}, {71, 13}, {74, 16} },
  { {59, 16}, {64, 18}, {67, 23} },
  { {59, 16}, {57, 11}, {53, 8} },
}, { {58, 18}, {60, 19} })
palm({ {176, 47}, {179, 34}, {184, 20} }, {
  { {184, 19}, {178, 16}, {172, 17}, {169, 21} },
  { {184, 19}, {190, 16}, {196, 17}, {199, 21} },
  { {184, 19}, {189, 21}, {192, 26} },
  { {184, 19}, {180, 21}, {177, 26} },
  { {184, 19}, {186, 14}, {190, 11} },
}, { {183, 21} })

---------------------------------------------------------------- the shop (focal)
-- porch deck and steps
part(c:rect(80, 46, 160, 50), WOODR, { gloss = false })
for x = 86, 158, 8 do c:fill(c:rect(x, 47, x, 49), WOOD_S) end
far(c:rect(112, 51, 128, 52), DRIFT, { gloss = false, contact = false })
far(c:rect(109, 54, 131, 55), DRIFT, { gloss = false, contact = false })
-- walls: coral clapboard
local wall = c:rect(88, 22, 152, 45)
part(wall, CORALR, { gloss = { 92, 27 } })
for y = 29, 44, 4 do
  wall:copy():clip(c:rect(90, y, 150, y)):each(function(x, yy)
    local cur = c:get(x, yy)
    if cur == CORAL then c:px(x, yy, CORAL_S) end
  end)
end
-- roof: red tin with a cat-head gable (two ear points)
local roof = c:poly({ {80, 25}, {161, 25}, {148, 13}, {93, 13} })
local earL = c:poly({ {96, 15}, {104, 4}, {113, 14} })
local earR = c:poly({ {128, 14}, {137, 4}, {145, 15} })
local gable = c:poly({ {100, 25}, {141, 25}, {138, 11}, {103, 11} })
roof:add(earL):add(earR):add(gable)
part(roof, REDR, { gloss = { 99, 14 } })
-- tin ridges
for x = 84, 157, 4 do
  roof:copy():clip(c:rect(x, 14, x, 24)):each(function(xx, yy)
    local cur = c:get(xx, yy)
    if cur == RED then c:px(xx, yy, RED_S) end
  end)
end
-- inner ears
c:fill(c:poly({ {101, 13}, {104, 8}, {108, 13} }), CORAL_L)
c:fill(c:poly({ {133, 13}, {137, 8}, {140, 13} }), CORAL_L)
-- whisker-ish gable window: round attic window glowing, with a driftwood fish plaque below
part(c:ellipse(120.5, 16.5, 4, 3.5), CREAMR, { gloss = false, contact = false })
c:fill(c:ellipse(120.5, 16.5, 2.5, 2), THR)
c:fill(c:rect(120, 14, 121, 19), CREAM); c:fill(c:rect(118, 16, 123, 17), CREAM)
-- gingerbread eave trim (cream scallops under the roof edge)
for x = 84, 156, 4 do
  c:fill(c:rect(x, 26, x + 2, 26), CREAM)
  c:px(x + 1, 27, CREAM)
end
c:fill(c:rect(82, 26, 158, 26), CREAM)
-- shutters + big shop window
local winX0, winX1, winY0, winY1 = 97, 118, 34, 43
far(c:rect(91, 33, 94, 44), TURQR, { gloss = false, contact = false })
far(c:rect(121, 33, 124, 44), TURQR, { gloss = false, contact = false })
for y = 35, 43, 2 do c:fill(c:rect(92, y, 93, y), SEA_D); c:fill(c:rect(122, y, 123, y), SEA_D) end
far(c:rect(winX0 - 1, winY0 - 1, winX1 + 1, winY1 + 1), CREAMR, { gloss = false, contact = false })
c:fill(c:rect(winX0, winY0, winX1, winY1), THR)
c:fill(c:rect(winX0, winY1 - 3, winX1, winY1), GLD)                   -- warm sill shelf glow
-- ginger cat sitting on a turquoise cushion in the window (back view, tail curl), plus a red yarn ball
c:fill(c:ellipse(103.5, 41.5, 6, 1.5), TURQ); c:fill(c:rect(98, 42, 109, 42), SEA_D)
local catb = c:ellipse(103, 37.5, 4, 3.5):add(c:ellipse(103, 33.5, 3, 2.5))
catb:add(c:poly({ {100, 33}, {101, 29}, {103, 32} })):add(c:poly({ {104, 32}, {106, 29}, {107, 33} }))
catb:clip(c:rect(winX0, winY0, winX1, winY1))
c:fill(catb, GLD); c:fill(catb:edge(), WOOD_S)
c:fill(c:rect(101, 35, 105, 35), WOOD_S); c:fill(c:rect(101, 38, 105, 38), WOOD_S)
c:fill(c:line({ {107, 40}, {110, 39}, {111, 37} }, 2), GLD); c:px(111, 37, WOOD_S)
c:fill(c:ellipse(115, 40.5, 2, 2), RED); c:px(114, 39, CORAL_L); c:px(116, 42, RED_S)
c:fill(c:rect(winX0 + 12, winY0, winX0 + 12, winY1), CREAM)            -- mullion
-- striped awning over the window, scalloped hem
local aw = c:poly({ {92, 28}, {124, 28}, {127, 32}, {89, 32} })
far(aw, TURQR, { gloss = false })
for x = 89, 125, 6 do
  c:fill(c:poly({ {x, 28}, {x + 3, 28}, {x + 3, 32}, {x, 32} }):clip(aw), CREAM)
end
for x = 88, 126, 3 do c:px(x, 33, (math.floor((x - 88) / 3) % 2 == 0) and CREAM or TURQ) end
-- door: turquoise, arched top, round porthole, cat flap
local door = c:rect(130, 29, 143, 45):cut(c:rect(130, 29, 130, 30)):cut(c:rect(143, 29, 143, 30)):cut(c:rect(131, 29, 131, 29)):cut(c:rect(142, 29, 142, 29))
far(door, TURQR, { gloss = false })
c:fill(c:ellipse(136.5, 33.5, 2.5, 2), THR); c:px(135, 32, CREAM)
c:fill(c:rect(133, 37, 140, 37), SEA_D)
-- cat flap: arch with two little ears
c:fill(c:rect(134, 41, 139, 45), SEA_D); c:px(134, 40, SEA_D); c:px(139, 40, SEA_D)
c:fill(c:rect(135, 42, 138, 45), CORAL_S)
c:px(141, 39, THR); c:px(141, 40, GLD)                                  -- knob
-- driftwood fish sign on a bracket at the right corner
c:fill(c:rect(152, 28, 162, 28), WOOD_S); c:fill(c:rect(161, 28, 161, 29), WOOD_S)
c:px(155, 29, O2); c:px(160, 29, O2)
local fish = c:ellipse(157, 33.5, 5, 3):add(c:poly({ {161, 33}, {165, 30}, {165, 37} }))
far(fish, DRIFT, { gloss = false, contact = false })
c:px(154, 32, O3); c:fill(c:rect(156, 33, 159, 33), WOOD); c:fill(c:rect(157, 32, 157, 35), WOOD)
-- warm lamps by the door
c:fill(c:rect(127, 33, 128, 35), GLD); c:px(127, 33, THR); c:fill(c:rect(127, 32, 128, 32), O2)

---------------------------------------------------------------- foreground props
-- hibiscus pot left of the steps
local bush = c:ellipse(86.5, 40, 6, 4.5)
far(bush, LEAFR, { gloss = false })
far(c:poly({ {82, 44}, {92, 44}, {91, 51}, {83, 51} }), CORALR, { gloss = false, contact = false })
for _, f in ipairs({ {82, 38}, {87, 36}, {89, 40} }) do
  c:fill(c:rect(f[1], f[2], f[1] + 2, f[2] + 2), RED); c:px(f[1] + 1, f[2] + 1, THR); c:px(f[1], f[2], CORAL)
end
-- curled cream cat napping on the porch right
local cat2 = c:ellipse(150, 43.5, 6, 3):add(c:poly({ {143, 42}, {144, 38}, {146, 41} })):add(c:poly({ {147, 41}, {149, 38}, {150, 42} }))
local cat2b = c:ellipse(146.5, 42.5, 3.5, 3)
far(cat2:copy():add(cat2b), CREAMR, { gloss = false, contact = false })
c:paint({ "u.u" }, 145, 42, { u = O3 })
c:fill(c:line({ {152, 46}, {156, 45}, {157, 43} }, 2), CREAM)
c:px(144, 40, CORAL_L); c:px(148, 40, CORAL_L)
-- conch shells on the step corner and in the sand
local function conch(x, y)
  local m = c:ellipse(x + 2.5, y + 2, 3, 2):add(c:poly({ {x + 4, y}, {x + 8, y + 2}, {x + 4, y + 4} }))
  far(m, PEACHR, { gloss = false, contact = false })
  c:px(x + 2, y + 1, CREAM); c:px(x + 5, y + 2, CORAL)
end
conch(98, 51); conch(140, 52)
-- grass tufts at the street edge
for _, t in ipairs({ {2, 55}, {76, 52}, {165, 52}, {233, 56} }) do
  c:paint({ "g.g.g", ".ggg." }, t[1], t[2], { g = LEAF })
  c:paint({ ".l..." }, t[1], t[2], { l = LEAF_L })
end

---------------------------------------------------------------- hem stitch top and bottom
c:seam({ {0, 1}, {239, 1} }, { free = true })
c:seam({ {0, 58}, {239, 58} }, { free = true })

local t = c:save(OUT .. "banner-CB-pets.aseprite", OUT .. "banner-CB-pets.png")
print(GV.report(t))
