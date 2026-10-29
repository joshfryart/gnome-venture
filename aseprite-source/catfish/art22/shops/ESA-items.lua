-- shops/ESA-items.lua : Cat Fish pet shop ESA "Thornacre Trading Den" (Thornacre Savanna, East and Southern
-- Africa): the 5 room item sprites, 1x on the 320 x 200 room (like the cats and cf-yarn-*), Stitched Toy.
-- Run: AppRun -b --script shops/ESA-items.lua     Writes art22/out/cf-pet-<slug>.png + .aseprite
--   acacia_perch       sill     30x26  flat-topped felt acacia (two-tier umbrella canopy, yellow puff flowers)
--                                      on a Y trunk, set in a round wooden plinth with a bead band
--   beaded_rack        shelf    20x24  wooden post stand wearing a round flat bead collar (red, cream with
--                                      blue dots, blue, gold rings) and two short dangling bead strands
--   grass_tuft         floor-l  38x28  tuft of felt savanna grass (straw blades, olive ones behind) in a low
--                                      coiled sisal basket with a bead band
--   rain_cloud_mobile  ceiling  48x34  acacia twig hung from the top edge: a felt rain cloud, three blue felt
--                                      drops on threads, two bead strands at the twig ends
--   coffee_bean_rattle rod      16x16  a glossy roasted coffee-bean shaker with a beaded gold cap, on its thread
-- Shared regional look: savanna straw/ochre + acacia olive + roasted brown felt, and the same bead row
-- (red, cream, blue, gold, 1 px each) on every item. 1 px three-tone umber outline (selective by light) and the
-- 1 px #000000 border last, as the 1x room sprites; hanging threads are 1 px umber with no border, to y 0.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local C = GV.C

local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end

-- shared ramps
local OLIVE = felt("#8f9c3c", { gloss = "#d8d880", rim = "#b4b85a", shade = "#5e6a2c" })   -- acacia leaf
local STRAW = felt("#d9a640", { gloss = "#fff1c8", rim = "#f5cf6a", shade = "#b07428" })   -- dry grass, gold family
local BARK  = felt("#8a5a34", { gloss = "#d9a660", rim = "#b07a45", shade = "#5e2f1e" })   -- acacia bark, wood family
local WOODR = felt("#b07a45", { gloss = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })   -- plinth / stand
local SISAL = felt("#e0c48a", { gloss = "#fff3c8", rim = "#f2dcaa", shade = "#c09a5a", pale = false })
local CLOUD = felt("#b8c7d8", { gloss = "#eef8f2", dot = "#f8fcf4", rim = "#dce8ee", shade = "#8a9cbc", pale = false })
local WATER = felt("#3f8fb0", { gloss = "#c8ecdc", rim = "#8fcbd8", shade = "#2f6290" })
local BEAN  = felt("#8a4a2a", { gloss = "#e8a060", dot = "#ffc27a", rim = "#b0623a", shade = "#5e2a1e" })
local GOLDR = felt("#e8a317", { gloss = "#fff1c8", rim = "#f5cf6a", shade = "#b8661a" })
local REDR  = felt("#dd3a2a", { gloss = "#ff9158", rim = "#f2793a", shade = "#ae2a2a" })
local CREAM = { base = "#f1ece0", shade = "#d8c49a" }
-- bead row colours (lit, shaded)
local BEADS = { { "#dd3a2a", "#ae2a2a" }, { "#f1ece0", "#d8c49a" }, { "#3f8fb0", "#2f6290" }, { "#f5cf6a", "#e8a317" } }
local THREAD = "#4a2c1a"

local function canvas(w, h)
  return GV.canvas{ w = w, h = h, mode = "sticker", ol = 1, olx = 0, margin = 0, cres = 2, deep = 1 }
end
-- bead row along a list of points: cycles red, cream, blue, gold; shaded tone on crescent pixels
local function beadrow(c, pts, start)
  local i = (start or 1) - 1
  for _, p in ipairs(pts) do
    local b = BEADS[i % 4 + 1]
    c:px(p[1], p[2], c.shd[c:key(p[1], p[2])] and b[2] or b[1])
    i = i + 1
  end
end
local function hrow(x0, x1, y, step)
  local t = {} for x = x0, x1, step or 1 do t[#t + 1] = { x, y } end return t
end
-- 1 px thread painted after finish() (no outline, no border)
local function thread(c, x, y0, y1)
  for y = y0, y1 do
    local k = c:key(x, y)
    local v = c.pix[k]
    if v == nil or v == "#000000" then c.pix[k] = THREAD end
  end
end
local FAILS, RES = {}, {}
local function save(c, slug)
  local t = c:save(OUT .. "cf-pet-" .. slug .. ".aseprite", OUT .. "cf-pet-" .. slug .. ".png")
  print(string.format("%-20s ", slug) .. GV.report(t))
  if t.semi ~= 0 or t.bw ~= 0 then FAILS[#FAILS + 1] = slug end
  return t
end

-- ===== acacia_perch (sill, 30x26) =====
do
  local c = canvas(30, 26)
  local canopy = c:ellipse(14.5, 6.5, 12.5, 3)
  canopy:add(c:ellipse(9, 4.5, 6, 2.5)):add(c:ellipse(19.5, 4, 6, 2.5))
  local trunk = c:line({ { 14, 20 }, { 14, 15 }, { 9, 10 } }, 2)
  trunk:add(c:line({ { 15, 16 }, { 20, 10 } }, 2)):add(c:line({ { 14, 14 }, { 14, 10 } }, 2))
  local plinth = c:rrect(5, 19, 24, 23, 2)
  c:build{
    { "trunk", trunk, BARK, { cres = 1, gloss = false, bounce = false } },
    { "canopy", canopy, OLIVE, { cres = 2, gloss = { 6, 3 } } },
    { "plinth", plinth, WOODR, { cres = 2, gloss = false } },
  }
  -- lower canopy tier: a lit ridge row with a shade row under it (two felt layers)
  for x = 4, 25 do
    if canopy:has(x, 6) and not c.gl.s[c:key(x, 6)] and not c.shd[c:key(x, 6)] then c:px(x, 6, OLIVE.rim) end
    if canopy:has(x, 5) and not c.gl.s[c:key(x, 5)] and not c.shd[c:key(x, 5)] then c:px(x, 5, OLIVE.shade) end
  end
  -- yellow puff flowers
  for _, p in ipairs({ { 8, 3 }, { 15, 4 }, { 22, 3 }, { 11, 7 }, { 19, 7 }, { 25, 6 }, { 4, 6 } }) do
    if canopy:has(p[1], p[2]) then c:px(p[1], p[2], GOLDR.rim) end
  end
  beadrow(c, hrow(7, 22, 21))
  c:seam({ { 7, 19 }, { 22, 19 } }, { gap = WOODR.base })
  save(c, "acacia_perch")
end

-- ===== beaded_rack (shelf, 20x24) =====
do
  local c = canvas(20, 24)
  local post = c:rect(9, 4, 10, 19):add(c:ellipse(9.5, 3, 1.5, 1.5))
  local CX, CY, RX, RY = 9.5, 10.5, 8, 5.5
  local collar = c:ellipse(CX, CY, RX, RY)
  local hole = c:ellipse(CX, 8.5, 3, 1.5)
  collar:cut(hole)
  local foot = c:rrect(4, 19, 15, 21, 1)
  local strands = c:rect(6, 15, 7, 18):add(c:rect(12, 15, 13, 18))
  c:build{
    { "post", post, WOODR, { cres = 1, gloss = false, bounce = false } },
    { "strands", strands, REDR, { flat = true, contact = false } },
    { "collar", collar, REDR, { cres = 2, gloss = false } },
    { "foot", foot, WOODR, { cres = 1, gloss = false } },
  }
  -- concentric bead rings (normalised radius): red rim, cream with blue dots, blue, gold inner
  collar:each(function(x, y)
    local k = c:key(x, y)
    local t = math.sqrt(((x - CX) / RX) ^ 2 + ((y - CY) / RY) ^ 2)
    local sh = c.shd[k]
    local col
    if t > 0.8 then col = sh and REDR.shade or (c.pix[k] == REDR.rim and REDR.rim or REDR.base)
    elseif t > 0.6 then col = ((x + y) % 2 == 0) and (sh and WATER.shade or WATER.base) or (sh and CREAM.shade or CREAM.base)
    elseif t > 0.42 then col = sh and WATER.shade or WATER.base
    else col = sh and GOLDR.shade or GOLDR.rim end
    c:px(x, y, col)
  end)
  c:paint({ ".gg", "g.." }, 4, 6, { g = REDR.gloss })     -- enamel comma on the lit outer ring
  -- dangling bead strands
  beadrow(c, { { 6, 15 }, { 6, 16 }, { 6, 17 }, { 6, 18 } }, 2)
  beadrow(c, { { 13, 15 }, { 13, 16 }, { 13, 17 }, { 13, 18 } }, 4)
  for y = 15, 18 do c:px(7, y, c:get(6, y) == "#f1ece0" and CREAM.shade or BEADS[(y - 15 + 1) % 4 + 1][2]) end
  for y = 15, 18 do c:px(12, y, BEADS[(y - 15 + 3) % 4 + 1][1]) end
  c:seam({ { 6, 20 }, { 13, 20 } }, { gap = WOODR.base })
  save(c, "beaded_rack")
end

-- ===== grass_tuft (floor-left, 38x28) =====
do
  local c = canvas(38, 28)
  local function blade(bx, tx, ty, w)
    return c:poly({ { bx - w, 21 }, { tx, ty }, { tx + 1, ty }, { bx + w + 1, 21 } })
  end
  local back = c:mask()
  for _, b in ipairs({ { 9, 6, 6, 2 }, { 18, 17, 3, 2 }, { 27, 31, 5, 2 } }) do back:add(blade(b[1], b[2], b[3], b[4])) end
  local front = c:mask()
  for _, b in ipairs({ { 7, 3, 9, 2 }, { 12, 10, 4, 2 }, { 15, 13, 7, 2 }, { 21, 22, 2, 2 }, { 24, 26, 6, 2 },
                       { 30, 34, 10, 2 }, { 19, 20, 8, 2 }, { 11, 7, 12, 2 }, { 27, 29, 11, 2 } }) do
    front:add(blade(b[1], b[2], b[3], b[4]))
  end
  local basket = c:ellipse(18.5, 21.5, 15.5, 4)
  c:build{
    { "back", back, OLIVE, { cres = 2, gloss = false, bounce = false } },
    { "front", front, STRAW, { cres = 2, gloss = false, bounce = false } },
    { "basket", basket, SISAL, { cres = 2, gloss = { 6, 19 } } },
  }
  -- blade midribs: 1 px shade line down the middle of each straw blade (felt rib)
  for _, b in ipairs({ { 15, 13, 7 }, { 24, 26, 6 }, { 7, 3, 9 }, { 21, 22, 2 } }) do
    local bx, tx, ty = b[1], b[2], b[3]
    for y = ty + 3, 16 do
      local x = math.floor(tx + (bx - tx) * (y - ty) / (21 - ty) + 0.5)
      local k = c:key(x, y)
      if c.own[k] and c.pix[k] == STRAW.base then c:px(x, y, STRAW.rim) end
    end
  end
  -- coiled sisal rows: shade grooves on the basket
  basket:each(function(x, y)
    local k = c:key(x, y)
    if y == 23 and not c.gl.s[k] then c:px(x, y, c.shd[k] and "#a07a44" or SISAL.shade) end
  end)
  beadrow(c, hrow(5, 32, 21), 1)
  save(c, "grass_tuft")
end

-- ===== rain_cloud_mobile (ceiling, 48x34) =====
do
  local c = canvas(48, 34)
  local twig = c:line({ { 4, 5 }, { 43, 4 } }, 2)
  local cloud = c:ellipse(17, 16, 5.5, 4.5):add(c:ellipse(24, 13, 6.5, 6)):add(c:ellipse(31, 15.5, 5, 4.5))
  cloud:add(c:rrect(12, 15, 36, 21, 2))
  local function drop(cx, cy)
    return c:ellipse(cx, cy + 1, 2.5, 2.5):add(c:poly({ { cx - 2, cy }, { cx + 0.5, cy - 4 }, { cx + 3, cy } }))
  end
  local drops = { drop(15.5, 27), drop(24.5, 29), drop(32.5, 26) }
  local goldDrops = { c:ellipse(6.5, 15.5, 2, 2), c:ellipse(41.5, 15.5, 2, 2) }
  local list = { { "twig", twig, BARK, { cres = 1, gloss = false, bounce = false } },
                 { "cloud", cloud, CLOUD, { cres = 2, gloss = { 19, 9 }, stitch = { side = "lit" } } } }
  for i, d in ipairs(drops) do list[#list + 1] = { "d" .. i, d, WATER, { cres = 1, gloss = false, bounce = false } } end
  for i, d in ipairs(goldDrops) do list[#list + 1] = { "g" .. i, d, GOLDR, { cres = 1, gloss = false, bounce = false } } end
  c:build(list)
  for i, d in ipairs(drops) do   -- 1 px glaze glint on each drop
    local x0, y0 = d:bbox(); local cx = ({ 15, 24, 32 })[i]
    c:px(cx - 1, y0 + 3, WATER.gloss)
  end
  for _, g in ipairs({ { 6, 14 }, { 41, 14 } }) do c:px(g[1], g[2], GOLDR.gloss) end
  c:seam({ { 13, 19 }, { 35, 19 } }, { gap = CLOUD.base })
  c:finish()
  thread(c, 23, 0, 3)                                      -- hanger to the top edge
  thread(c, 24, 6, 6)                                      -- twig to cloud
  for _, x in ipairs({ 15, 24, 32 }) do                    -- cloud to drops
    local _, _, _, cy1 = cloud:bbox()
    local y = cy1 + 2
    while c.pix[c:key(x, y)] == nil or c.pix[c:key(x, y)] == "#000000" do
      if c.pix[c:key(x, y + 1)] and c.pix[c:key(x, y + 1)] ~= "#000000" then break end
      c.pix[c:key(x, y)] = THREAD; y = y + 1
      if y > 33 then break end
    end
  end
  -- bead strands at the twig ends: 2 px beads stacked on the thread, gold drop at the end
  for _, x in ipairs({ 6, 41 }) do
    thread(c, x, 7, 7)
    local i = 0
    for y = 8, 12, 2 do
      local b = BEADS[(i + (x == 41 and 2 or 0)) % 4 + 1]
      c.pix[c:key(x, y)] = b[1]; c.pix[c:key(x + 1, y)] = b[2]
      c.pix[c:key(x, y + 1)] = b[2]; c.pix[c:key(x + 1, y + 1)] = b[2]
      i = i + 1
    end
  end
  save(c, "rain_cloud_mobile")
end

-- ===== coffee_bean_rattle (rod, 16x16) =====
do
  local c = canvas(16, 16)
  local bean = c:ellipse(7.5, 9.5, 4, 4)
  local cap = c:rrect(5, 3, 10, 5, 1)
  c:build{
    { "bean", bean, BEAN, { cres = 2, gloss = { 5, 7 }, bounce = false } },
    { "cap", cap, GOLDR, { flat = true } },
  }
  -- the bean's S crease, dark down the middle with a lit lip on its left
  local cr = { { 8, 6 }, { 8, 7 }, { 7, 8 }, { 7, 9 }, { 7, 10 }, { 8, 11 }, { 8, 12 } }
  for _, p in ipairs(cr) do c:px(p[1], p[2], C.ol3) end
  for _, p in ipairs({ { 7, 7 }, { 6, 9 }, { 7, 11 } }) do
    if not c.gl.s[c:key(p[1], p[2])] then c:px(p[1], p[2], BEAN.rim) end
  end
  beadrow(c, hrow(6, 9, 4), 1)
  c:finish()
  thread(c, 7, 0, 1)
  save(c, "coffee_bean_rattle")
end

assert(#FAILS == 0, "check failed: " .. table.concat(FAILS, " "))
