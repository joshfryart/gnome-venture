-- shops/EE-items.lua : Cat Fish pet shop EE "Birch Hut Pets" (Birchbramble Steppe), the 5 item sprites.
-- Run: AppRun -b --script EE-items.lua      Writes art22/out/cf-pet-<slug>.png + .aseprite
-- Stitched Toy via gvlib, 1x sprites on the 320x200 room (like the cats and the yarn ball): sticker mode, 1 px
-- umber outline +1 lower right, 1 px #000000 border. Flat-bottom items are cropped so their last row is the
-- outline row (they sit on the shelf / sill / floor with no black line under them).
-- Regional set (folk felt): one shared palette of folk red, linen cream, thread gold, birch bark and meadow green;
-- each piece adds one own colour (mouse grey, boot grey, sunflower yellow, cornflower blue) so they stay apart.
--   matryoshka_mice   shelf 20x24     two nesting dolls painted as mice (round ears through the headscarf)
--   rug_runner        floor-r 36x28   woven runner, far end rolled up, stepped-diamond band, cream fringe
--   felt_boot_bed     floor-l 38x28   giant valenki felt boot, cream cuff, red cushion in the opening
--   sunflower_head    sill 30x26      sunflower head in a birch-bark tuesok pot, two leaves
--   painted_egg_charm rod 16x16       pysanka egg on a thread, gold knot and red tassel
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local C = GV.C

-- felt ramp like cf_props.lua: 4 felt steps (rim, base, one shade crescent, gloss comma)
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end
local RED   = felt("#dd3a2a", { gloss = "#ff9158", rim = "#f2793a" })
local CREAM = felt("#f1ece0")
local GOLD  = felt("#e8a317", { gloss = "#fff1c8", rim = "#f5cf6a" })
local GREEN = felt("#5f9e48", { gloss = "#c8d77a", rim = "#8cc064" })
local BIRCH = felt("#e8dcc0")
local DARK  = "#3d2a1c"                                     -- birch lenticels, seed spots (soil)

local function canvas(w, h) return GV.canvas{ w = w, h = h, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 1 } end
local function tint(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end) end

local RES = {}
local function save(c, slug, nobd)
  c:finish()
  for _, p in ipairs(nobd or {}) do -- clear the black border next to a free-hanging thread
    for _, d in ipairs({ { 1, 0 }, { -1, 0 } }) do
      local k = c:key(p[1] + d[1], p[2])
      if c.pix[k] == "#000000" then c.pix[k] = nil end
    end
  end
  local t = c:save(OUT .. "cf-pet-" .. slug .. ".aseprite", OUT .. "cf-pet-" .. slug .. ".png")
  print(string.format("%-18s ", slug) .. GV.report(t))
  RES[#RES + 1] = { slug, t }
  return t
end

-- ===== matryoshka_mice (shelf, 20x24) =====
do
  local c = canvas(20, 24)
  local MOUSE = felt("#a89cae", { gloss = "#e8e0f0", rim = "#c8bccc" })
  local GRN = GREEN
  -- big doll (red), x 2..12
  local bigHead = c:ellipse(7, 9, 4.5, 4)
  local bigBody = c:ellipse(7, 17.5, 5.5, 6):cut(c:rect(0, 23, 19, 30)):add(c:rrect(3, 12, 11, 16, 2))
  local earL, earR = c:ellipse(3.5, 4.5, 1.5, 1.5), c:ellipse(10.5, 4.5, 1.5, 1.5)
  -- small doll (green), x 12..16
  local smHead = c:ellipse(14, 14.5, 2.5, 2.5)
  local smBody = c:ellipse(14, 19.5, 3, 3.5):cut(c:rect(0, 23, 19, 30))
  local smEarL, smEarR = c:rect(11, 11, 12, 12), c:rect(16, 11, 17, 12)
  c:build{
    { "earL", earL, MOUSE, { flat = true } },
    { "earR", earR, MOUSE, { flat = true } },
    { "body", bigBody:add(bigHead), RED, { gloss = { 3, 6 } } },
    { "smEarL", smEarL, MOUSE, { flat = true } },
    { "smEarR", smEarR, MOUSE, { flat = true } },
    { "sm", smBody:add(smHead), GRN, { gloss = false } },
  }
  -- inner ears (pink felt)
  c:px(3, 4, "#f6b8cf"); c:px(10, 4, "#f6b8cf")
  -- big face: cream oval in the scarf, mouse muzzle
  local face = c:ellipse(7, 9.5, 3, 2.5)
  c:fill(face, CREAM.base); tint(c, face:copy():clip(c:rect(0, 0, 6, 8)), CREAM.base, CREAM.rim)
  c:px(5, 9, C.ol3); c:px(9, 9, C.ol3); c:px(7, 10, "#e46a9b")
  -- big apron: gold flower on a cream bib
  local bib = c:ellipse(7, 17.5, 3, 3)
  c:fill(bib, CREAM.base)
  c:paint({ ".g.", "gdg", ".g." }, 6, 16, { g = GOLD.base, d = RED.base })
  c:seam({ { 3, 13 }, { 11, 13 } }, { gap = RED.shade })                         -- scarf hem
  -- small face
  c:fill(c:rect(13, 14, 15, 15), CREAM.base); c:px(13, 14, C.ol3); c:px(15, 14, C.ol3)
  c:px(14, 19, GOLD.base); c:px(13, 20, GOLD.base); c:px(15, 20, GOLD.base)
  save(c, "matryoshka_mice")
end

-- ===== rug_runner (floor-right, 36x28) =====
-- A runner lying on the floor and running back into the room: a long trapezoid (front end wide), its felt
-- thickness showing as a front edge, cream fringe on both short ends, folk stepped diamonds down the middle.
do
  local c = canvas(36, 28)
  local top   = c:poly({ { 10, 6 }, { 25, 6 }, { 31, 23 }, { 4, 23 } })
  local edge  = c:rect(4, 23, 30, 24)
  local front = c:rect(4, 25, 30, 26)
  local back  = c:rect(10, 4, 24, 5)
  c:build{
    { "back", back, CREAM, { flat = true } },
    { "rug", top:add(edge), RED, { cres = 2, gloss = { 9, 8 } } },
    { "front", front, CREAM, { flat = true } },
  }
  for x = 5, 29, 2 do c:px(x, 26, C.ol2) end                                     -- front fringe notches
  for x = 11, 23, 2 do c:px(x, 4, C.ol2) end                                     -- back fringe notches
  c:fill(edge, RED.shade)                                                         -- felt thickness
  -- cream border band, 1 px in from the edge of the top
  local band = c:poly({ { 10, 6 }, { 25, 6 }, { 31, 23 }, { 4, 23 } }):shrink(1):edge()
  band:each(function(x, y) if y < 22 then c:px(x, y, CREAM.base) end end)
  -- stepped diamonds down the middle (smaller toward the back)
  c:paint({ ".g.", "g.g", ".g." }, 16, 9, { g = GOLD.base })
  c:paint({ "..g..", ".g.g.", "g.r.g", ".g.g.", "..g.." }, 15, 12, { g = GREEN.base, r = GOLD.base })
  c:paint({ "...g...", "..g.g..", ".g.r.g.", "g.rrr.g", ".g.r.g.", "..g.g..", "...g..." }, 14, 16,
    { g = GOLD.base, r = CREAM.base })
  c:seam({ { 5, 24 }, { 29, 24 } }, { gap = RED.deep })
  save(c, "rug_runner")
end

-- ===== felt_boot_bed (floor-left, 38x28) =====
-- A giant valenki (felt boot) standing up: tall shaft, rounded toe, rubber galosh band, turned-down cream cuff
-- with a red stepped band, and a red cushion bulging out of the opening (the bed). Embroidered flower on the shaft.
do
  local c = canvas(38, 28)
  local BOOT = felt("#8b8f96", { gloss = "#e6e2d6", rim = "#b4b4b4" })
  local SOLE = felt("#6b3a2a", { gloss = "#a8582f", rim = "#8a4f2a" })
  local shaft = c:rrect(5, 6, 18, 26, 3)
  local foot  = c:rrect(13, 15, 30, 26, 4):add(c:ellipse(29, 21.5, 5, 5)):cut(c:rect(0, 27, 40, 40))
  local boot  = shaft:add(foot):closed(2)
  local sole  = boot:copy():clip(c:rect(0, 24, 40, 26))
  local cuff  = c:rrect(3, 4, 20, 10, 2)
  local pillow = c:ellipse(11.5, 4, 6, 2.5)
  c:build{
    { "boot", boot, BOOT, { cres = 3, gloss = { 22, 16 } } },
    { "sole", sole, SOLE, { cres = 1, deep = 0, gloss = false } },
    { "pillow", pillow, RED, { cres = 2, gloss = false } },
    { "cuff", cuff, CREAM, { cres = 2, gloss = false } },
  }
  c:px(9, 3, RED.gloss); c:px(10, 3, RED.gloss)                                    -- pillow glint
  c:button(10, 2)
  for x = 4, 18, 4 do c:paint({ ".r.", "rrr" }, x, 6, { r = RED.base }) end      -- stepped band on the cuff
  -- embroidered flower on the shaft (red petals, gold heart, green leaves)
  c:paint({ ".rr.", "rggr", "rggr", ".rr." }, 9, 14, { r = RED.base, g = GOLD.base })
  c:paint({ "l....l", ".l..l.", "..ll.." }, 8, 18, { l = GREEN.base })
  c:seam({ { 19, 16 }, { 22, 15 }, { 26, 16 } }, { gap = BOOT.shade })            -- instep seam
  save(c, "felt_boot_bed")
end

-- ===== sunflower_head (sill, 30x26) =====
-- A sunflower head in a birch-bark tuesok pot: yellow petal ring, seed disc with diamond seeds, two leaves,
-- cream bark with dark lenticel dashes and a gold lacing seam on the rim.
do
  local c = canvas(30, 26)
  local PET = felt("#f2c14e", { gloss = "#fff1c8", rim = "#ffe08a" })
  local DISC = felt("#7a4a1f", { gloss = "#c9a96e", rim = "#9a6b3f" })
  local petals = c:ellipse(14, 10, 4, 4)
  for i = 0, 11 do
    local a = i * math.pi / 6
    petals:add(c:ellipse(14 + math.cos(a) * 6, 10 + math.sin(a) * 6, 2.2, 2.2))
  end
  local leafL = c:poly({ { 9, 19 }, { 3, 14 }, { 2, 18 }, { 6, 21 } })
  local leafR = c:poly({ { 19, 19 }, { 25, 14 }, { 26, 18 }, { 22, 21 } })
  local pot = c:rrect(8, 17, 20, 24, 1)
  c:build{
    { "leafL", leafL, GREEN, { flat = true } },
    { "leafR", leafR, GREEN, { flat = true } },
    { "petals", petals, PET, { cres = 2, gloss = { 7, 4 } } },
    { "disc", c:ellipse(14, 10, 4.5, 4.5), DISC, { cres = 2, gloss = false } },
    { "pot", pot, BIRCH, { cres = 2, gloss = false } },
  }
  for _, q in ipairs({ { 12, 8 }, { 15, 8 }, { 13, 11 }, { 16, 11 }, { 11, 11 } }) do c:px(q[1], q[2], DARK) end
  c:fill(c:rect(10, 21, 12, 21), DARK); c:fill(c:rect(16, 20, 17, 20), DARK); c:fill(c:rect(14, 23, 15, 23), DARK)
  c:seam({ { 8, 18 }, { 20, 18 } }, { gap = BIRCH.shade })
  save(c, "sunflower_head")
end

-- ===== painted_egg_charm (rod, 16x16) =====
-- A pysanka egg on a thread: red ends, a cream band with a red zigzag, gold knot and a short red tassel below.
do
  local c = GV.canvas{ w = 16, h = 16, mode = "sticker", ol = 1, olx = 0, cres = 2, deep = 1 }
  local egg = c:ellipse(7.5, 6.5, 3.5, 4.5)
  c:build{
    { "tassel", c:poly({ { 6, 12 }, { 10, 12 }, { 11, 14 }, { 5, 14 } }), RED, { flat = true } },
    { "egg", egg, RED, { cres = 2, gloss = false } },
    { "knot", c:rect(6, 11, 9, 11), GOLD, { flat = true } },
  }
  local bandM = c:rect(0, 5, 15, 8):clip(egg)
  bandM:each(function(x, y) if c:get(x, y) == RED.base or c:get(x, y) == RED.rim then c:px(x, y, CREAM.base) end
    if c:get(x, y) == RED.shade then c:px(x, y, CREAM.shade) end end)
  c:paint({ "r.r.r.", ".r.r.r" }, 5, 6, { r = RED.base })                         -- zigzag
  c:px(7, 3, GOLD.base); c:px(8, 3, GOLD.base)                                     -- gold dots on the cap
  c:px(5, 3, RED.gloss); c:px(5, 4, RED.gloss); c:px(6, 2, RED.gloss)              -- gloss comma
  c:px(7, 13, RED.shade); c:px(9, 13, RED.shade)                                   -- tassel threads
  c:px(7, 0, C.ol2); c:px(7, 1, C.ol2)                                             -- thread up to the rod string
  save(c, "painted_egg_charm", { { 7, 0 }, { 7, 1 } })
end
