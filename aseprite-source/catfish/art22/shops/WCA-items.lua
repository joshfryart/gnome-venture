-- art22/shops/WCA-items.lua : Cat Fish pet shop WCA "Drum & Den" (Greatcanopy, West & Central Africa), 5 room items.
-- Stitched Toy (Part D) via gvlib, 1x sprites for the 320x200 cf-room.png (same grain as the cats: 2 px 3-tone
-- umber outline + 1 px #000000 border). Sizes = the slot max sizes of claude/catfish-shops-art-spec.md.
-- Shared regional look: kente gold / green / red felt, adire indigo, mahogany wood and a carved zigzag motif.
--   cf-pet-talking_drum      38x28 floor-left  hourglass drum lying on its side, lengthwise tension cords,
--                                              red hide rims, kente sash at the waist, hooked beater in front
--   cf-pet-kente_bunting     48x34 ceiling     cord hung from the top edge (both ends at y 0), 5 woven kente
--                                              pennants (block rows) with a red hem and gold seam
--   cf-pet-calabash_bowl     36x28 floor-right half-gourd bowl with a burnt zigzag band, heaped kibble, on a
--                                              woven raffia ring
--   cf-pet-weaver_bird_nest  30x26 sill        woven grass nest with its entrance tube, hung from a twig on a
--                                              carved stand; a yellow weaver with a dark mask on the twig
--   cf-pet-mask_frame        35x31 frame       carved mahogany frame with zigzag notches and brass studs,
--                                              adire indigo cloth, a friendly carved cat-face mask
-- Run: AppRun -b --script WCA-items.lua     Writes art22/out/cf-pet-<slug>.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local C = GV.C

-- felt(hex): 4 felt steps (rim, base, one crescent shade, gloss) like cf_props.lua
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end
-- recolour a part's felt tones to another ramp per pixel (fam(x,y) returns a ramp or nil = keep);
-- keeps the light: rim -> rim, shade/deep -> shade, anything else (base, bounce) -> base. Gloss is kept.
local function retone(c, P, fam)
  local r = P.r
  P.m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] ~= P or c.gl.s[k] then return end
    local f = fam(x, y)
    if not f then return end
    local v = c:get(x, y)
    if v == r.rim then c:px(x, y, f.rim)
    elseif v == r.shade or v == r.deep then c:px(x, y, f.shade)
    elseif v == r.base or v == r.bounce then c:px(x, y, f.base) end
  end)
end
-- only on own felt (not gloss, not contour)
local function onPart(c, P, x, y)
  local k = c:key(x, y)
  return c.own[k] == P and not c.gl.s[k]
end
local function shaded(c, x, y) return c.shd[c:key(x, y)] end

local KG = felt("#e8a317", { gloss = "#fff1c8", rim = "#f5cf6a" })   -- kente gold
local KN = felt("#3f8a3e", { gloss = "#c8d77a", rim = "#7ab55c" })   -- kente green
local KR = felt("#c8402a", { gloss = "#ff9158", rim = "#f2793a" })   -- kente red
local IND = felt("#3a4a8c", { rim = "#5a6eb0", gloss = "#a8b8e8" })  -- adire indigo
local MAH = felt("#8a4f2a", { rim = "#b07a45", gloss = "#ecc58a" })  -- mahogany
local WOOD = felt("#b07a45", { rim = "#d9a660", gloss = "#ecc58a" }) -- light carving wood
local DK = "#2a1a10"

local RES = {}
local function save(c, slug)
  local name = "cf-pet-" .. slug
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-26s ", name) .. GV.report(t))
  assert(t.semi == 0 and t.bw == 0, name .. " check failed")
  RES[#RES + 1] = t
  return t
end

-- ========== 1. Talking Drum (floor-left, 38x28) ==========
do
  local c = GV.canvas{ w = 38, h = 28, mode = "sticker", margin = 0 }
  local CY = 14
  local function hh(x) -- half height of the hourglass at column x (ends 9, waist 3.5)
    local t = (x - 19) / 13
    return 3.5 + 5.5 * t * t
  end
  local body = c:mask()
  for x = 6, 32 do local h = hh(x) for y = math.floor(CY - h + 0.5), math.floor(CY + h + 0.5) do body:set(x, y) end end
  local rimL = body:copy():clip(c:rect(6, 0, 8, 27))
  local rimR = body:copy():clip(c:rect(30, 0, 32, 27))
  local head = c:ellipse(5, CY, 3, 9.5)                            -- left drum head, seen 3/4 on
  local sash = body:copy():clip(c:rect(17, 0, 21, 27))
  local stick = c:line({ { 9, 3 }, { 12, 4 }, { 24, 9 }, { 26, 11 }, { 26, 14 } }, 2) -- hooked beater laid across
  local pad = c:rrect(9, 19, 29, 23, 1)                            -- folded kente cloth the drum rests on
  local p = c:build{
    { "pad", pad, KG, { cres = 2, gloss = false } },
    { "body", body, MAH, { cres = 3, gloss = false } },
    { "rimR", rimR, KR, { cres = 2, gloss = false } },
    { "rimL", rimL, KR, { cres = 2, gloss = false } },
    { "head", head, felt("#efd9a6", { gloss = "#fff3c8", rim = "#fff3c8", dot = "#fff1c8" }), { cres = 2, gloss = { 4, 6 } } },
    { "sash", sash, KG, { cres = 2, gloss = false } },
    { "stick", stick, felt("#efd9a6", { rim = "#fff3c8" }), { flat = true } },
  }
  -- tension cords: 4 lengthwise cords following the hourglass, between the rims (tan on lit, wood in shade)
  for _, t in ipairs({ -0.8, -0.35, 0.35, 0.8 }) do
    for x = 9, 29 do
      local y = math.floor(CY + t * hh(x) + 0.5)
      if onPart(c, p.body, x, y) then c:px(x, y, shaded(c, x, y) and "#5e2f1e" or "#b07a45") end
    end
  end
  -- kente sash: green and red block rows across the gold
  retone(c, p.sash, function(x, y)
    local r = (y + 1) % 5
    if r == 0 then return KR elseif r == 2 or r == 3 then return KN end
  end)
  c:seam({ { 7, 8 }, { 7, 21 } }, { gap = KR.shade })               -- hide lacing seam on the left rim
  c:seam({ { 31, 8 }, { 31, 21 } }, { gap = KR.shade })
  c:paint({ "ss", "s." }, 3, 10, { s = "#c9a96e" })                  -- worn tone ring on the head
  retone(c, p.pad, function(x, y)                                  -- warp blocks: green / gold / red
    local b = x % 6
    if b < 2 then return KN elseif b == 3 or b == 4 then return KR end
  end)
  c:seam({ { 10, 22 }, { 28, 22 } }, { gap = KG.shade })            -- pad hem
  c:ground(19, 25, 15, 1.5)
  save(c, "talking_drum")
end

-- ========== 2. Kente Bunting (ceiling, 48x34) ==========
do
  local c = GV.canvas{ w = 48, h = 34, mode = "sticker", margin = 0, ol = 1, olx = 1 }
  local function cy(x) local t = (x - 23.5) / 22.5 return 2 + 4 * (1 - t * t) end
  local flags = { { 3, 15 }, { 12, 20 }, { 21, 24 }, { 30, 20 }, { 39, 15 } } -- left x, length
  local fams = { KG, KN, KG, KR, KG }
  local parts = {}
  for i, f in ipairs(flags) do
    local x0, len = f[1], f[2]
    local top = math.floor(cy(x0 + 3) + 0.5) + 1
    local m = c:rect(x0, top, x0 + 6, top + len - 4)
    m:add(c:poly({ { x0, top + len - 4 }, { x0 + 7, top + len - 4 }, { x0 + 3.5, top + len } }))
    parts[i] = c:part(m, fams[i], { cres = 2, gloss = false, contact = false })
    parts[i].top = top
  end
  -- weave: block rows down each pennant, with dark weft lines between blocks; a red hem at the top
  for i, P in ipairs(parts) do
    local top, base = P.top, fams[i]
    local alt = (base == KG) and { KN, KR } or { KG, KG }
    retone(c, P, function(x, y)
      local r = y - top
      if r < 2 then return KR end
      local b = (r - 2) % 6
      if b == 2 or b == 3 then
        local a = alt[((r - 2) // 6) % 2 + 1]
        return a
      end
    end)
    P.m:each(function(x, y)
      local r = y - top
      if r >= 2 and ((r - 2) % 6 == 4) and (x % 2 == 0) and onPart(c, P, x, y) then c:px(x, y, DK) end -- weft ticks
    end)
    c:seam({ { flags[i][1] + 1, top + 1 }, { flags[i][1] + 5, top + 1 } }, { gap = KR.shade })
  end
  -- cord on top, ends running up to the top edge
  for x = 1, 46 do c:px(x, math.floor(cy(x) + 0.5), C.ol1) end
  for y = 0, 2 do c:px(1, y, C.ol1); c:px(46, y, C.ol1) end
  c:button(0, 1); c:button(44, 1)
  save(c, "kente_bunting")
end

-- ========== 3. Calabash Bowl (floor-right, 36x28) ==========
do
  local c = GV.canvas{ w = 36, h = 28, mode = "sticker", margin = 0 }
  local CAL = felt("#e9b04a", { gloss = "#fff1c8", rim = "#f5cf6a" })
  local KIB = felt("#a8582f", { gloss = "#ecc58a", rim = "#c47a36" })
  local RAF = felt("#c9a96e", { gloss = "#fff3c8" })
  local FISH = felt("#3f8fb0", { gloss = "#c8ecdc", rim = "#8fcbd8" })
  local bowl = c:ellipse(17.5, 9, 13.5, 12):cut(c:rect(0, 0, 35, 8))
  bowl:add(c:ellipse(17.5, 9, 13.5, 2.5))
  local inner = c:ellipse(17.5, 8.5, 11.5, 1.5)
  local pieces = { { 10.5, 6.5 }, { 14.5, 5 }, { 19, 5.5 }, { 23.5, 6.5 } }
  local heap = c:ellipse(17, 7.5, 9, 1.5)
  for _, q in ipairs(pieces) do heap:add(c:ellipse(q[1], q[2], 2.5, 2.5)) end
  heap:clip(c:rect(0, 0, 35, 8))
  local fish = c:ellipse(25.5, 3.5, 3, 1.5):add(c:poly({ { 28, 3 }, { 31, 1 }, { 31, 6 } }))
  local ring = c:rrect(9, 20, 26, 23, 2)
  local p = c:build{
    { "ring", ring, RAF, { cres = 2, gloss = false } },
    { "bowl", bowl, CAL, { cres = 4, gloss = { 8, 11 } } },
    { "fish", fish, FISH, { flat = true } },
    { "heap", heap, KIB, { cres = 2, gloss = false, contact = false } },
  }
  c:fill(inner:copy():cut(heap):cut(fish), "#f1dcae")                -- pale gourd lining at the lip
  -- kibble split lines (nearest-centre) + a glaze dot on each piece
  local function near(x, y)
    local b, bd = 0, 1e9
    for i, q in ipairs(pieces) do local d = (x - q[1]) ^ 2 + (y - q[2]) ^ 2 if d < bd then b, bd = i, d end end
    return b
  end
  p.heap.m:each(function(x, y)
    if onPart(c, p.heap, x, y) and y < 8 then
      local n = near(x, y)
      if (p.heap.m:has(x + 1, y) and near(x + 1, y) ~= n) then c:px(x, y, C.ol2) end
    end
  end)
  for _, q in ipairs(pieces) do c:px(math.floor(q[1]) - 1, math.floor(q[2]) - 1, KIB.gloss) end
  c:px(24, 3, C.ol3)                                                  -- fish treat eye
  -- burnt band: a line, then a row of dark triangles (pyrography), then dots
  local BURN = "#7a3a14"
  for x = 4, 31 do
    if onPart(c, p.bowl, x, 12) then c:px(x, 12, BURN) end
    for y = 13, 15 do
      if (y - 13) < 3 - math.abs((x % 6) - 3) and onPart(c, p.bowl, x, y) then c:px(x, y, BURN) end
    end
    if x % 3 == 0 and onPart(c, p.bowl, x, 18) then c:px(x, 18, BURN) end
  end
  -- raffia ring: green and red wraps
  p.ring.m:each(function(x, y)
    if onPart(c, p.ring, x, y) and y >= 21 then
      local r = x % 4
      if r == 0 then c:px(x, y, shaded(c, x, y) and KN.shade or KN.base) elseif r == 2 then c:px(x, y, shaded(c, x, y) and KR.shade or KR.base) end
    end
  end)
  save(c, "calabash_bowl")
end

-- ========== 4. Weaver-bird Nest (sill, 30x26) ==========
-- A carved perch stand (foot + post + arm) with the woven nest hanging from the arm and the yellow weaver
-- clinging to its side by the nest, the way weavers hang on their nests.
do
  local c = GV.canvas{ w = 30, h = 26, mode = "sticker", margin = 0 }
  local GRASS = felt("#8fae4a", { gloss = "#e0e8a0", rim = "#c8d77a" })
  local BIRD = felt("#f2c418", { gloss = "#fff1c8", rim = "#ffe27a" })
  local foot = c:rrect(2, 19, 9, 21, 1)
  local post = c:line({ { 5, 18 }, { 5, 10 }, { 6, 8 }, { 9, 6 }, { 16, 5 } }, 2)  -- bent twig
  local nest = c:ellipse(12.5, 12, 5, 5.5):add(c:rrect(12, 15, 15, 21, 1))
  local tail = c:poly({ { 20, 14 }, { 24, 14 }, { 25, 20 }, { 22, 19 } })
  local body = c:ellipse(21.5, 11.5, 3, 3.5)
  local head = c:ellipse(20.5, 7, 2.5, 2.5)
  local p = c:build{
    { "foot", foot, MAH, { cres = 2, gloss = false } },
    { "post", post, WOOD, { flat = true } },
    { "nest", nest, GRASS, { cres = 3, gloss = { 11, 9 } } },
    { "tail", tail, felt("#b8961a", { rim = "#d9b52a" }), { flat = true } },
    { "body", body, BIRD, { cres = 2, gloss = { 20, 10 } } },
    { "head", head, BIRD, { flat = true } },
  }
  -- woven grass: short over-under strands, a few straw-gold strands woven in
  p.nest.m:each(function(x, y)
    if onPart(c, p.nest, x, y) then
      if y % 2 == 0 and (x + ((y // 2) % 2) * 2) % 4 < 2 then        -- basket weave: offset 2-px dashes
        c:px(x, y, shaded(c, x, y) and "#3e5a22" or GRASS.shade)
      elseif y % 2 == 1 and (x + y) % 8 == 0 and not shaded(c, x, y) then c:px(x, y, "#d9c46a") end
    end
  end)
  c:px(13, 21, DK); c:px(14, 21, DK); c:px(13, 20, DK)                -- entrance at the tube's foot
  c:px(10, 7, GRASS.rim); c:px(15, 7, GRASS.rim)                      -- grass ends at the hanging knot
  -- weaver face (looking at the nest): dark mask, red eye in it, pale beak; wing bars; foot on the nest
  c:paint({ "mm..", "mmm.", ".mm." }, 18, 5, { m = DK })
  c:px(19, 6, "#e0501f")
  c:px(17, 7, "#c9a96e"); c:px(17, 8, "#c9a96e")
  c:paint({ "s..", ".s.", "s.." }, 22, 10, { s = BIRD.shade })
  c:px(18, 13, DK); c:px(18, 14, DK)
  -- carved zigzag on the foot
  for x = 3, 8 do
    local y = 20 + (x % 2)
    if onPart(c, p.foot, x, y) then c:px(x, y, MAH.rim) end
  end
  save(c, "weaver_bird_nest")
end

-- ========== 5. Mask Frame (frame, 35x31) ==========
do
  local c = GV.canvas{ w = 35, h = 31, mode = "sticker", margin = 0 }
  local MASK = felt("#c98a4a", { gloss = "#ffe2a8", rim = "#ecc58a" })
  local frame = c:rect(3, 3, 30, 26)
  local cloth = c:rect(7, 7, 26, 22)
  local face = c:ellipse(16.5, 15.5, 5.5, 6.5)
  face:add(c:poly({ { 11, 12 }, { 12, 6 }, { 15, 10 } })):add(c:poly({ { 18, 10 }, { 21, 6 }, { 22, 12 } }))
  local p = c:build{
    { "frame", frame, MAH, { cres = 3, gloss = { 5, 5 } } },
    { "cloth", cloth, IND, { cres = 3, gloss = false, rim = false } },
    { "face", face, MASK, { cres = 3, gloss = { 13, 11 } } },
  }
  -- adire dots on the cloth
  p.cloth.m:each(function(x, y)
    if onPart(c, p.cloth, x, y) and (x % 4 == 1) and (y % 4 == (x % 8 == 1 and 1 or 3)) then c:px(x, y, "#8a9ad0") end
  end)
  -- carved zigzag notches round the frame border
  p.frame.m:each(function(x, y)
    if onPart(c, p.frame, x, y) and not p.cloth.m:has(x, y) then
      local d = math.min(x - 3, y - 3, 30 - x, 26 - y)
      if d == 1 or d == 2 then
        local along = (d == math.min(x - 3, 30 - x)) and y or x
        if (along + d) % 3 == 0 then c:px(x, y, shaded(c, x, y) and C.ol2 or MAH.rim) end
      end
    end
  end)
  for _, q in ipairs({ { 3, 3 }, { 29, 3 }, { 3, 25 }, { 29, 25 } }) do
    c:px(q[1], q[2], C.gold); c:px(q[1] + 1, q[2], C.gold); c:px(q[1], q[2] + 1, C.gold); c:px(q[1] + 1, q[2] + 1, C.goldS)
  end
  -- mask features: almond slit eyes, nose ridge, gold brow diamond, whisker grooves, little mouth
  c:paint({ "uuu", ".u." }, 12, 14, { u = DK }); c:paint({ "uuu", ".u." }, 18, 14, { u = DK })
  c:paint({ ".g.", "ggg", ".g." }, 15, 10, { g = C.gold })
  c:paint({ "r", "r", "r" }, 16, 15, { r = MASK.rim })
  c:paint({ "u.u", ".u." }, 15, 19, { u = C.ol2 })
  for _, y in ipairs({ 17, 19 }) do
    c:px(11, y, "#f1dcae"); c:px(12, y, "#f1dcae"); c:px(20, y, "#f1dcae"); c:px(21, y, "#f1dcae")
  end
  save(c, "mask_frame")
end
