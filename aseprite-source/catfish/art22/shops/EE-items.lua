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
do
  local c = canvas(36, 28)
  local rug  = c:poly({ { 5, 12 }, { 31, 12 }, { 33, 24 }, { 2, 24 } })
  local roll = c:rrect(4, 6, 31, 13, 3)
  local fringe = c:rect(3, 24, 32, 26)
  local p = c:build{
    { "fringe", fringe, CREAM, { flat = true } },
    { "rug", rug, RED, { cres = 3, gloss = false } },
    { "roll", roll, RED, { cres = 3, gloss = { 9, 7 } } },
  }
  for x = 4, 32, 2 do c:px(x, 26, C.ol2) end                                     -- fringe notches
  -- cream border band on the rug top
  local band = c:poly({ { 6, 14 }, { 30, 14 }, { 32, 23 }, { 3, 23 } }):edge()
  tint(c, band, RED.base, CREAM.base); tint(c, band, RED.shade, CREAM.shade)
  -- stepped diamonds along the middle
  for i, x in ipairs({ 8, 14, 20, 26 }) do
    local col = (i % 2 == 1) and GOLD.base or GREEN.base
    c:paint({ "..g..", ".ggg.", "gg.gg", ".ggg.", "..g.." }, x - 1, 16, { g = col })
  end
  -- rolled end: spiral on the left face
  c:paint({ ".cc.", "c..c", "c.c.", ".c.." }, 5, 8, { c = CREAM.base })
  c:seam({ { 8, 13 }, { 30, 13 } }, { gap = RED.shade })
  save(c, "rug_runner")
end

-- ===== felt_boot_bed (floor-left, 38x28) =====
do
  local c = canvas(38, 28)
  local BOOT = felt("#8b8f96", { gloss = "#e6e2d6", rim = "#b4b4b4" })
  local SOLE = felt("#5e3a2a", { gloss = "#a8582f", rim = "#8a4f2a" })
  local shaft = c:rrect(4, 6, 19, 25, 2)
  local foot  = c:rrect(14, 14, 33, 25, 5):add(c:rect(14, 20, 33, 25))
  local sole  = c:rrect(4, 24, 34, 26, 1)
  local cuff  = c:rrect(2, 3, 21, 9, 2)
  local p = c:build{
    { "boot", shaft:add(foot), BOOT, { cres = 3, gloss = { 21, 16 } } },
    { "sole", sole, SOLE, { flat = true } },
    { "cuff", cuff, CREAM, { cres = 2, gloss = false } },
  }
  -- opening with a red cushion inside
  local hole = c:ellipse(11.5, 4, 7, 1.5)
  c:fill(hole, C.ol3)
  c:fill(c:ellipse(11.5, 5, 5, 1):cut(c:rect(0, 0, 37, 4)), RED.base)
  -- red stepped band on the cuff
  for x = 4, 19, 3 do c:paint({ ".r.", "rrr" }, x, 6, { r = RED.base }) end
  -- embroidered flower on the shaft
  c:paint({ ".r.", "rgr", ".r." }, 9, 14, { r = RED.base, g = GOLD.base })
  c:paint({ "l.l", ".l." }, 9, 17, { l = GREEN.base })
  c:seam({ { 20, 15 }, { 20, 23 } }, { gap = BOOT.shade })
  save(c, "felt_boot_bed")
end

-- ===== sunflower_head (sill, 30x26) =====
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
  local p = c:build{
    { "leafL", leafL, GREEN, { flat = true } },
    { "leafR", leafR, GREEN, { flat = true } },
    { "petals", petals, PET, { cres = 2, gloss = { 7, 4 } } },
    { "disc", c:ellipse(14, 10, 4.5, 4.5), DISC, { cres = 2, gloss = false } },
    { "pot", pot, BIRCH, { cres = 2, gloss = false } },
  }
  -- seed diamonds
  for _, q in ipairs({ { 12, 8 }, { 15, 8 }, { 13, 11 }, { 16, 11 }, { 11, 11 } }) do c:px(q[1], q[2], DARK) end
  -- birch lenticels and a lacing seam on the rim
  for _, q in ipairs({ { 10, 20 }, { 11, 20 }, { 15, 21 }, { 16, 21 }, { 13, 23 }, { 18, 22 } }) do c:px(q[1], q[2], DARK) end
  c:seam({ { 8, 18 }, { 20, 18 } }, { gap = BIRCH.shade })
  save(c, "sunflower_head")
end

-- ===== painted_egg_charm (rod, 16x16) =====
do
  local c = canvas(16, 16)
  local egg = c:ellipse(7, 6, 3, 3.5)
  local p = c:build{
    { "tassel", c:rect(6, 11, 8, 12), RED, { flat = true } },
    { "knot", c:rect(6, 10, 8, 10), GOLD, { flat = true } },
    { "egg", egg, RED, { cres = 2, gloss = false } },
  }
  c:fill(c:rect(4, 6, 10, 7):clip(egg), CREAM.base)
  c:px(5, 6, RED.base); c:px(7, 7, RED.base); c:px(9, 6, RED.base)
  c:px(5, 4, RED.gloss); c:px(5, 3, RED.gloss)
  c:px(7, 0, C.ol2); c:px(7, 1, C.ol2)
  save(c, "painted_egg_charm", { { 7, 0 }, { 7, 1 } })
end
