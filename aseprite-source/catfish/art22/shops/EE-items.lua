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
  local GRN = felt("#5a86b8", { gloss = "#c8ecdc", rim = "#8fcbd8" })
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
  c:paint({ ".rr.", "rggr", ".rr.", "l..l" }, 5, 16, { r = RED.base, g = GOLD.base, l = GREEN.base })
  c:seam({ { 3, 13 }, { 11, 13 } }, { gap = RED.shade })                         -- scarf hem
  -- small face
  c:fill(c:rect(13, 14, 15, 15), CREAM.base); c:px(13, 14, C.ol3); c:px(15, 14, C.ol3)
  c:px(14, 19, GOLD.base); c:px(13, 20, GOLD.base); c:px(15, 20, GOLD.base); c:px(14, 20, RED.base)
  save(c, "matryoshka_mice")
end

-- ===== rug_runner (floor-right, 36x28) =====
-- A woven runner lying flat on the floor, long side to the front: shallow top (floor perspective), its felt
-- thickness as a front edge, cream fringe on both short ends, cream border band, folk stepped diamonds.
do
  local c = canvas(36, 28)
  local top   = c:poly({ { 7, 13 }, { 29, 13 }, { 31, 23 }, { 5, 23 } })
  local edge  = c:rect(5, 23, 30, 25)
  local fringeL, fringeR = c:mask(), c:mask()
  for y = 14, 25 do
    local xl = (y < 23) and math.floor(7 - (y - 13) * 0.2) or 5
    local xr = (y < 23) and math.ceil(28 + (y - 13) * 0.2) or 30
    fringeL:add(c:rect(xl - 3, y, xl - 1, y)); fringeR:add(c:rect(xr + 1, y, xr + 3, y))
  end
  c:build{
    { "fringeL", fringeL, CREAM, { flat = true } },
    { "fringeR", fringeR, CREAM, { flat = true } },
    { "rug", top:add(edge), RED, { cres = 2, gloss = { 9, 14 } } },
  }
  c:fill(c:rect(5, 24, 30, 25), RED.shade); c:fill(c:rect(5, 25, 30, 25), RED.deep)  -- felt thickness
  for y = 15, 25, 2 do                                                            -- fringe: separate tassels
    fringeL:each(function(x, yy) if yy == y then c:px(x, yy, C.ol2) end end)
    fringeR:each(function(x, yy) if yy == y then c:px(x, yy, C.ol2) end end)
  end
  local band = top:copy():clip(c:rect(0, 0, 35, 22)):shrink(1):edge()
  band:each(function(x, y) c:px(x, y, CREAM.base) end)
  for i, x in ipairs({ 9, 15, 21 }) do
    local g = (i == 2) and GOLD.base or GREEN.base
    c:paint({ "..g..", ".gcg.", "gcrcg", ".gcg.", "..g.." }, x, 16, { g = g, c = CREAM.base, r = GOLD.base })
  end
  c:paint({ ".g.", "g.g", ".g." }, 27, 17, { g = GOLD.base })
  c:seam({ { 6, 24 }, { 29, 24 } }, { gap = RED.shade })
  save(c, "rug_runner")
end

-- ===== felt_boot_bed (floor-left, 38x28) =====
-- A giant valenki (felt boot) standing up: tall shaft, rounded toe, rubber galosh band, turned-down cream cuff
-- with a red stepped band, and a red cushion bulging out of the opening (the bed). Embroidered flower on the shaft.
do
  local c = canvas(38, 28)
  local BOOT = felt("#8b8f96", { gloss = "#e6e2d6", rim = "#b4b4b4" })
  local SOLE = felt("#6b3a2a", { gloss = "#a8582f", rim = "#8a4f2a" })
  local shaft = c:rrect(5, 8, 18, 26, 3)
  local foot  = c:rrect(13, 15, 30, 26, 4):add(c:ellipse(29, 21.5, 5, 5)):cut(c:rect(0, 27, 40, 40))
  local boot  = shaft:add(foot):closed(2)
  local sole  = boot:copy():clip(c:rect(0, 24, 40, 26))
  local cuff  = c:rrect(4, 6, 19, 11, 2)
  local pillow = c:ellipse(11.5, 5, 5.5, 2.5)
  c:build{
    { "boot", boot, BOOT, { cres = 3, gloss = { 22, 16 } } },
    { "sole", sole, SOLE, { cres = 1, deep = 0, gloss = false } },
    { "pillow", pillow, RED, { cres = 2, gloss = false } },
    { "cuff", cuff, CREAM, { cres = 2, gloss = false } },
  }
  c:px(8, 4, RED.gloss); c:px(9, 3, RED.gloss); c:px(10, 3, RED.gloss)                 -- pillow glint
  c:px(13, 4, C.gold); c:px(12, 4, C.goldS)                                         -- pillow tuft
  for x = 6, 16, 4 do c:paint({ ".r.", "rrr" }, x, 8, { r = RED.base }) end      -- stepped band on the cuff
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
  -- seed lattice: light seeds on the brown disc, a few pecked out (dark) by the birds
  for _, q in ipairs({ { 12, 7 }, { 15, 7 }, { 11, 9 }, { 14, 9 }, { 17, 9 }, { 12, 11 }, { 15, 11 }, { 13, 13 } }) do c:px(q[1], q[2], DISC.rim) end
  for _, q in ipairs({ { 16, 12 }, { 13, 10 } }) do c:px(q[1], q[2], DARK) end
  for _, d in ipairs({ { 9, 20, 11 }, { 14, 19, 15 }, { 17, 21, 19 }, { 11, 22, 13 }, { 15, 23, 16 } }) do c:fill(c:rect(d[1], d[2], d[3], d[2]), DARK) end
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
