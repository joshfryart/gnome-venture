-- cf_ui.lua : Cat Fish step 6b (claude/catfish-art-brief.md, Small UI): shelter sign banner, games hub tile, Cat Book
-- cell heads. Stitched Toy (art-style-guide Part D, Part E banner rules), via gvlib.
-- Run: AppRun -b --script cf_ui.lua      Writes test/cf-banner.png, cf-tile.png, cf-bookhead-grey.png,
-- cf-bookhead-unknown.png (+ .aseprite).
--   cf-banner          240 x 60 grid, written 480 x 120 (out = 2) like game/assets/img/scenes/banner-*.png: scene mode,
--                      opaque, no border, thread-gold hem stitch (2 on / 1 off) on grid rows 1 and 58, <= 24 colours.
--                      Shelter room strip: dark beam, three-band wall with faint paw-print paper, plank floor; a red felt
--                      sign hangs from a dowel (strings to a gold nail) with a cream paw print appliqué; the grey cat
--                      sits behind the sign's right side, one paw gripping its edge (peeking). Yarn ball left, plush gold
--                      fish right; side thirds stay calm. No text.
--   cf-tile            64 x 64, icon mode, 1 px #000000 border, margin >= 3: same format as
--                      game/assets/img/puzzles/cast/tile-puzzles.png (extras-pixel/scripts/cast-tile-puzzles.lua).
--                      The grey plush cat sits on a round teal felt cushion holding up the orange plushie fish
--                      (cf-fish-1 colours), like Jeff holding up his puzzle piece.
--   cf-bookhead-grey   32 x 32 sticker, 1 px #000000 border, margin 3. One head in the grey template tones of
--                      cf_test.lua (shade #57516f, base #8a859b, light #cdc9d3, gloss #f1ebe3) plus fixed accents
--                      only (pink #e8909e / #c66a80, eye cream #f2e4c0, umber, border), so tools/catfish_recolor.py's
--                      colour map recolours it per coat. Ears are separate parts (base tone), head one tone up (light),
--                      eyes are the miniature eye (3 x 3 cream disc, 2 x 2 umber pupil lower right, gvlib c:eye small)
--                      inside a 1 px umber ring, as the big cat's ringed eyes.
--   cf-bookhead-unknown same silhouette, flat umber-grey felt, cream question mark (locked / unseen coat).
-- Recolour: tools/catfish_recolor.py --glob 'cf-bookhead-grey*.png' writes cf-bookhead-<coat>.png for all 8 coats
-- (11 colours each, nothing unmapped).
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"
local C = GV.C

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local function coat(t) -- body/ear ramp: 4-tone in gvlib's 7 slots (as cf_test.lua)
  return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base }
end
local function coatHi(t) -- head/paw ramp: one tone up
  return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light }
end
-- felt(hex): gvlib ramp with one shade (deep = shade, bounce = base, dot = gloss) to keep colour counts low
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce, n.dot = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base, (ov or {}).dot or n.gloss
  return n
end
local PINK, PINKS = "#e8909e", "#c66a80"
local function tint(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end) end
local function report(name, t) print(string.format("%-20s ", name) .. GV.report(t)) end

-- ===== small cat head (bookhead geometry, 19 px wide felt), shared by the bookheads and the banner =====
-- origin = bookhead canvas; (ox, oy) shifts it. Head felt x 6..24, y 11..24; ears tip at y 6.
local function smallHead(c, ox, oy)
  local head = c:ellipse(15 + ox, 17 + oy, 9.5, 6):add(c:ellipse(15 + ox, 19.5 + oy, 9.5, 4.5))
  local earL = c:poly({ {7 + ox, 15 + oy}, {8 + ox, 7 + oy}, {14 + ox, 12 + oy} }):grow(1)
  local earR = c:poly({ {17 + ox, 12 + oy}, {23 + ox, 7 + oy}, {24 + ox, 15 + oy} }):grow(1)
  return head, earL, earR
end
local function smallRing(c, x, y) -- 1 px umber ring round the 3x3 miniature eye at (x, y)
  c:paint({ ".uuu.", "u...u", "u...u", "u...u", ".uuu." }, x - 1, y - 1, { u = "umber" })
end
local function smallFace(c, ox, oy, head)
  -- inner ears (pink), only where the head does not cover them
  c:fill(c:poly({ {9 + ox, 13 + oy}, {9 + ox, 9 + oy}, {12 + ox, 12 + oy} }):cut(head), PINK)
  c:fill(c:poly({ {19 + ox, 12 + oy}, {22 + ox, 9 + oy}, {22 + ox, 13 + oy} }):cut(head), PINK)
  c:paint({ ".mmm." }, 13 + ox, 21 + oy, { m = GREY.gloss })                  -- muzzle: one row under the nose
  c:paint({ "ppp", ".q." }, 14 + ox, 19 + oy, { p = PINK, q = PINKS })       -- nose
  c:paint({ "u.u" }, 14 + ox, 21 + oy, { u = "ol2" })                        -- mouth corners
  smallRing(c, 8 + ox, 16 + oy); c:eye(8 + ox, 16 + oy, true)
  smallRing(c, 20 + ox, 16 + oy); c:eye(20 + ox, 16 + oy, true)
end

-- ===================================================================================== bookheads (32 x 32)
do
  local c = GV.canvas{ w = 32, h = 32, mode = "sticker" }
  local head, earL, earR = smallHead(c, 0, 0)
  c:build{
    { "earL", earL, coat(GREY), { cres = 2, gloss = false } },
    { "earR", earR, coat(GREY), { cres = 2, gloss = false } },
    { "head", head, coatHi(GREY), { cres = 2, gloss = { 10, 12 } } },
  }
  smallFace(c, 0, 0, head)
  local t = c:save(OUT .. "cf-bookhead-grey.aseprite", OUT .. "cf-bookhead-grey.png")
  report("cf-bookhead-grey", t)
  assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
end
do
  local c = GV.canvas{ w = 32, h = 32, mode = "sticker" }
  local head, earL, earR = smallHead(c, 0, 0)
  local U = "#6e6260" -- umber-grey felt (soil 900 toward stone 500), flat: no crescent, rim or gloss
  local sil = head:copy():add(earL):add(earR)
  c:part(sil, { gloss = U, dot = U, rim = U, base = U, shade = U, deep = U, bounce = U }, { flat = true, rim = false })
  c:paint({                                                                   -- bold question mark, cream
    ".cccc.",
    "cc..cc",
    "....cc",
    "...cc.",
    "..cc..",
    "......",
    "..cc..",
  }, 13, 12, { c = C.halo })
  local t = c:save(OUT .. "cf-bookhead-unknown.aseprite", OUT .. "cf-bookhead-unknown.png")
  report("cf-bookhead-unknown", t)
  assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
end

-- ===================================================================================== hub tile (64 x 64)
do
  local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
  local g, h = coat(GREY), coatHi(GREY)
  local FISH = felt("#dc6f2c", { gloss = "#ffc27a", rim = "#f2a860" })      -- cf-fish-1 orange felt
  local FIN = "#f2c14e"
  local TEAL = felt("#3f8fb0")                                               -- water 500 felt cushion

  local cushion = c:rrect(8, 45, 55, 56, 4)                                 -- felt floor cushion (the "tile")
  local tail = c:line({ {15, 47}, {9, 45}, {7, 40}, {8, 35}, {11, 32} }, 4)
  local body = c:ellipse(23.5, 41, 11.5, 8):add(c:ellipse(23.5, 37, 9.5, 7))
  local OX, OY = -1, 0
  local head = c:ellipse(24 + OX, 22.5 + OY, 13, 8.5):add(c:ellipse(24 + OX, 26 + OY, 13.5, 6.5))
  local earL = c:poly({ {10 + OX, 21 + OY}, {12 + OX, 8 + OY}, {21 + OX, 13 + OY} }):grow(1)
  local earR = c:poly({ {27 + OX, 13 + OY}, {36 + OX, 8 + OY}, {38 + OX, 21 + OY} }):grow(1)
  -- the fish, held up at the top right (head left, tail right), fins gold
  local fish = c:ellipse(46.5, 15.5, 8, 6)
  local ftail = c:poly({ {52, 15}, {57, 8}, {57, 24} }):cut(c:poly({ {54, 16}, {58, 12}, {58, 21} }))
  local finT = c:poly({ {42, 11}, {46, 7}, {51, 11} })
  -- stubby plush arm: round capsule (shoulder -> bent elbow -> wrist), tapering, not a square-pen stick
  local arm = c:mask()
  local AP = { {31, 37, 4.5}, {36.5, 33.5, 4}, {39.5, 28, 3.5} }
  for i = 1, #AP - 1 do
    local a, b = AP[i], AP[i + 1]
    for s = 0, 8 do
      local t = s / 8
      local r = a[3] + (b[3] - a[3]) * t
      arm:add(c:ellipse(a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, r, r))
    end
  end

  c:build{
    { "cushion", cushion, TEAL, { gloss = { 12, 47 } } },
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = false } },
    { "earL", earL, g, { cres = 2, gloss = false } },
    { "earR", earR, g, { cres = 2, gloss = false } },
    { "head", head, h, { gloss = { 14, 16 } } },
    { "finT", finT, felt(FIN, { shade = "#e38111" }), { flat = true } },
    { "ftail", ftail, felt(FIN, { shade = "#e38111" }), { cres = 2, gloss = false } },
    { "fish", fish, FISH, { gloss = { 42, 12 } } },
    { "arm", arm, g, { cres = 2, gloss = false } },
  }
  c:part(c:ellipse(41, 23.5, 4, 3), h, { flat = true })                     -- mitten paw holding the fish's belly
  c:paint({ "s.s", "s.s" }, 40, 24, { s = GREY.base })
  c:seam({ {33, 31}, {35, 33}, {36, 36} })                                   -- shoulder seam (arm sewn on)
  c:part(c:ellipse(18.5, 48.5, 4.5, 2.5), h, { flat = true })               -- front paw on the cushion
  c:paint({ "s.s", "s.s" }, 18, 49, { s = GREY.base })
  tint(c, tail:copy():clip(c:rect(5, 28, 14, 34)), GREY.base, GREY.light)          -- light tail tip + seam
  c:seam({ {6, 35}, {11, 35} })
  -- fish face and gill seam
  c:eye(41, 13, true)
  c:seam({ {45, 10}, {46, 12}, {46, 18}, {45, 20} })
  c:seam({ {10, 51}, {53, 51} })                                             -- cushion side seam (real join)
  c:button(42, 46)
  -- cat face (64-scale cat: inner ears, muzzle, nose, ringed locked eyes)
  c:fill(c:poly({ {13 + OX, 18}, {13 + OX, 10}, {20 + OX, 14} }):cut(head), PINK)
  c:fill(c:poly({ {28 + OX, 14}, {35 + OX, 10}, {35 + OX, 18} }):cut(head), PINK)
  c:fill(c:ellipse(24 + OX, 28, 3, 1.5), GREY.gloss)
  c:paint({ "ppp", ".q." }, 23 + OX, 26, { p = PINK, q = PINKS })
  c:paint({ "u.u" }, 23 + OX, 28, { u = "ol2" })
  for _, ex in ipairs({ 14 + OX, 30 + OX }) do
    c:paint({ "..uuu..", ".u...u.", "u.....u", "u.....u", "u.....u", ".u...u.", "..uuu.." }, ex - 1, 19, { u = "umber" })
    c:eye(ex, 20)
  end
  -- edge stitch on the lit half of the body (crescent side clean)
  c:stitch(body:cut(head:grow(1)), { side = "lit" })
  local t = c:save(OUT .. "cf-tile.aseprite", OUT .. "cf-tile.png")
  report("cf-tile", t)
  assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
end

-- ===================================================================================== banner (240 x 60 -> 480 x 120)
do
  local W, H = 240, 60
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  local function at(x, y) c.cx, c.cy = x, y end -- selective outline / light measured from each object's centre
  local BEAM = "#3d2a1c"
  local W1, W2, W3 = "#efdcb2", "#e6cea0", "#dbc08b"                       -- wall bands (soil 300 toward cream)
  local FL, FLS = "#c9a96e", "#9a6b3f"                                       -- floor planks (soil 300 / 500)
  local RED = felt("#d6322b")                                                -- ember 500 felt
  local WOOD = { gloss = FL, dot = FL, rim = FL, base = FLS, shade = C.ol1, deep = C.ol1, bounce = FLS }
  local GOLDF = { gloss = C.gold, dot = C.gold, rim = C.gold, base = C.goldS, shade = "#b07a10", deep = "#b07a10", bounce = C.goldS }

  -- room: beam, wall bands, skirting, floor planks
  c:fill(c:rect(0, 0, W - 1, 4), BEAM)
  c:fill(c:rect(0, 5, W - 1, 19), W1); c:fill(c:rect(0, 20, W - 1, 33), W2); c:fill(c:rect(0, 34, W - 1, 45), W3)
  c:fill(c:rect(0, 5, W - 1, 5), W3)                                         -- beam shadow line
  c:fill(c:rect(0, 46, W - 1, 46), C.ol1)
  c:fill(c:rect(0, 47, W - 1, H - 1), FL)
  for _, y in ipairs({ 51, 55 }) do c:fill(c:rect(0, y, W - 1, y), FLS) end
  for i = 0, 9 do                                                            -- staggered plank joints
    local x = (i * 29 + 11) % W; c:px(x, 48, FLS); c:px(x, 49, FLS); c:px(x, 50, FLS)
    local x2 = (i * 29 + 25) % W; c:px(x2, 52, FLS); c:px(x2, 53, FLS); c:px(x2, 54, FLS)
  end
  -- faint paw-print paper (one band darker than the band it sits on)
  local PAW = { ".o.o.", "o...o", ".ooo.", ".ooo." }
  for row, y in ipairs({ 9, 24, 38 }) do
    local col = (y < 20) and W2 or ((y < 34) and W3 or W2)
    for x = (row % 2 == 0) and 6 or 18, W - 6, 24 do c:paint(PAW, x, y, { o = col }) end
  end

  -- nail and hanging strings
  local NX = 110
  c:line({ {78, 12}, {NX, 6} }, 1):each(function(x, y) c:px(x, y, C.ol2) end)
  c:line({ {142, 12}, {NX + 1, 6} }, 1):each(function(x, y) c:px(x, y, C.ol2) end)
  c:paint({ ".g.", "gGG", ".G." }, NX - 1, 4, { g = C.gold, G = C.goldS })

  -- the cat, sitting behind the sign's right side. Parts carry no outline of their own (1 px inner contours
  -- only); one 3-tone outline goes round the whole cat, so the small figure keeps its felt.
  local OX, OY = 139, 11                                                     -- head felt x 145..163, y 22..35
  at(154, 34)
  local tail = c:line({ {160, 44}, {166, 44}, {169, 41}, {170, 36} }, 4)
  local body = c:ellipse(153.5, 40, 8.5, 6)
  local head, earL, earR = smallHead(c, OX, OY)
  local pawA, pawB = c:ellipse(149.5, 45.5, 2.5, 1.5), c:ellipse(156.5, 45.5, 2.5, 1.5)
  local NO = { outline = false }
  c:part(tail, coat(GREY), { cres = 2, gloss = false, outline = false })
  tint(c, tail:copy():clip(c:rect(166, 30, 175, 37)), GREY.base, GREY.light)
  c:part(body, coat(GREY), { gloss = false, outline = false })
  c:part(earL, coat(GREY), { cres = 2, gloss = false, outline = false })
  c:part(earR, coat(GREY), { cres = 2, gloss = false, outline = false })
  c:part(head, coatHi(GREY), { cres = 2, gloss = { 10 + OX, 12 + OY }, outline = false })
  c:part(pawA, coatHi(GREY), { flat = true, outline = false })
  c:part(pawB, coatHi(GREY), { flat = true, outline = false })
  smallFace(c, OX, OY, head)
  c:seam({ {168, 38}, {172, 38} })
  c:outline(tail:copy():add(body):add(head):add(earL):add(earR):add(pawA):add(pawB))

  -- the sign: dowel, cloth with a swallowtail notch, paw appliqué, hem seam, edge stitch
  at(110, 28)
  local cloth = c:poly({ {78, 13}, {143, 13}, {143, 43}, {110.5, 37}, {78, 43} })
  c:part(cloth, RED, { stitch = true, gloss = { 82, 18 } })
  local pad = c:ellipse(110.5, 29.5, 6.5, 5):add(c:ellipse(110.5, 32, 7.5, 3.5))
  local toes = c:ellipse(101, 23, 2, 2.5):add(c:ellipse(106.5, 19.5, 2, 2.5)):add(c:ellipse(114.5, 19.5, 2, 2.5)):add(c:ellipse(120, 23, 2, 2.5))
  local print_ = pad:copy():add(toes)
  c:fill(print_, C.halo)
  print_:each(function(x, y)                                                 -- felt appliqué: lower-right edge in shade
    if not print_:has(x + 1, y) or not print_:has(x, y + 1) then c:px(x, y, RED.shade) end
  end)
  c:seam({ {80, 17}, {141, 17} })
  c:part(c:rect(74, 11, 146, 13), WOOD, { flat = true })                     -- dowel over the cloth fold
  c:part(c:ellipse(72.5, 12, 2, 2), GOLDF, { flat = true })                   -- dowel knobs
  c:part(c:ellipse(148.5, 12, 2, 2), GOLDF, { flat = true })
  -- the cat's paw gripping the sign's right edge (drawn over the sign)
  at(150, 30)
  local grip = c:ellipse(143.5, 36, 2.5, 2)
  c:part(grip, coatHi(GREY), { flat = true, outline = false })
  c:paint({ "s.s" }, 142, 37, { s = GREY.base })
  c:outline(grip, { ol = 1, olx = 0 })

  -- left third (existing colours only, banner is at the cap): a small framed fish picture on the wall and a
  -- woven cat basket with a cream felt cushion on the floor; yarn ball beside it.
  at(30, 19)
  c:line({ {24, 11}, {30, 6} }, 1):each(function(x, y) c:px(x, y, C.ol2) end)  -- picture string to a gold nail
  c:line({ {36, 11}, {31, 6} }, 1):each(function(x, y) c:px(x, y, C.ol2) end)
  c:paint({ ".g.", "gGG", ".G." }, 29, 4, { g = C.gold, G = C.goldS })
  local frame = c:rect(20, 11, 40, 27)
  c:part(frame, WOOD, { flat = true })
  c:fill(c:rect(23, 14, 37, 24), C.halo)                                     -- cream mat
  c:fill(c:rect(23, 14, 37, 14), W3)                                         -- frame's inner shadow
  c:fill(c:rect(23, 14, 23, 24), W3)
  local pfish = c:ellipse(29, 19.5, 4, 2.5)
  c:fill(c:poly({ {32, 19.5}, {36, 16}, {36, 24} }):cut(c:poly({ {34.5, 19.5}, {37, 18}, {37, 21} })), C.goldS)
  c:fill(pfish, C.gold)
  pfish:each(function(x, y) if not pfish:has(x + 1, y) or not pfish:has(x, y + 1) then c:px(x, y, C.goldS) end end)
  c:px(27, 19, C.ol3)

  at(34, 44)
  local basket = c:rrect(14, 39, 54, 50, 4)
  c:part(basket, WOOD, { cres = 2, gloss = false })
  for _, y in ipairs({ 43, 47 }) do                                          -- weave: rows and staggered ribs
    c:line({ {16, y}, {52, y} }, 1):each(function(x, yy) if basket:has(x, yy) and c:get(x, yy) == FLS then c:px(x, yy, FL) end end)
  end
  for x = 18, 50, 4 do
    local o = ((x / 4) % 2 == 0) and 0 or 4
    for yy = 44 + o - 4, 46 + o - 4 do if basket:has(x, yy) and c:get(x, yy) == FLS then c:px(x, yy, C.ol1) end end
  end
  local CREAM = { gloss = C.halo, dot = C.halo, rim = C.halo, base = W1, shade = W3, deep = FLS, bounce = W2 }
  local cushion = c:ellipse(34, 37.5, 17, 4.5)
  c:part(cushion, CREAM, { cres = 2, gloss = { 23, 36 } })
  c:seam({ {20, 39}, {48, 39} })                                             -- cushion piping seam

  -- yarn ball beside the basket, loose end across the floor
  at(64, 51)
  local yarn = c:ellipse(64, 51, 5.5, 5)
  c:part(yarn, RED, { cres = 3, gloss = { 61, 48 } })
  c:line({ {61, 48}, {67, 54} }, 1):each(function(x, y) if yarn:has(x, y) then c:px(x, y, RED.shade) end end)
  c:line({ {60, 51}, {64, 55} }, 1):each(function(x, y) if yarn:has(x, y) then c:px(x, y, RED.shade) end end)
  for _, p in ipairs({ {70, 55}, {71, 56}, {72, 56}, {73, 56}, {74, 55}, {75, 55}, {76, 56}, {77, 57}, {78, 57} }) do
    c:px(p[1], p[2], RED.base)
  end

  -- plush gold fish, right third, lying on the floor
  at(203, 51)
  local fbody = c:ellipse(201.5, 51, 6.5, 3.5)
  local ftail = c:poly({ {206, 51}, {213, 45}, {213, 58} }):cut(c:poly({ {210, 51}, {214, 48}, {214, 55} }))
  c:part(ftail, GOLDF, { flat = true })
  c:part(fbody, GOLDF, { cres = 2, gloss = { 198, 49 } })
  c:eye(197, 50, true)

  -- hem stitches (Part E: banners only, rows 1 and H - 2)
  c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
  c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })
  local t = c:save(OUT .. "cf-banner.aseprite", OUT .. "cf-banner.png")
  report("cf-banner", t)
  assert(t.semi == 0 and t.bw == 0 and t.w == 480 and t.h == 120 and t.colours <= 24)
end
