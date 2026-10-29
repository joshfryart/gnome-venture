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
-- Flat umbrella canopy (the acacia silhouette), scalloped underside, leaf dashes and yellow puff flowers;
-- Y trunk with a third limb; round wooden plinth with the bead band and a gold hem seam.
do
  local c = canvas(30, 26)
  local canopy = c:rrect(2, 4, 27, 8, 2):add(c:ellipse(14.5, 4, 10, 2.5))
  canopy:add(c:ellipse(7, 8.5, 3.5, 1.5)):add(c:ellipse(14.5, 9, 4, 1.5)):add(c:ellipse(22, 8.5, 3.5, 1.5))
  local trunk = c:line({ { 14, 20 }, { 14, 15 }, { 9, 11 } }, 2)
  trunk:add(c:line({ { 15, 16 }, { 20, 11 } }, 2)):add(c:line({ { 14, 14 }, { 14, 11 } }, 2))
  local plinth = c:rrect(5, 19, 24, 23, 2)
  c:build{
    { "trunk", trunk, BARK, { cres = 1, gloss = false, bounce = false } },
    { "canopy", canopy, OLIVE, { cres = 2, gloss = { 5, 3 } } },
    { "plinth", plinth, WOODR, { cres = 2, gloss = false } },
  }
  -- leaf dashes (2 px shade) and yellow puff flowers (lit gold) on the canopy felt
  for _, p in ipairs({ { 10, 5 }, { 18, 4 }, { 23, 6 }, { 6, 7 }, { 14, 7 } }) do
    for i = 0, 1 do
      local k = c:key(p[1] + i, p[2])
      if canopy:has(p[1] + i, p[2]) and not c.gl.s[k] and not c.shd[k] then c:px(p[1] + i, p[2], OLIVE.shade) end
    end
  end
  for _, p in ipairs({ { 9, 3 }, { 15, 3 }, { 21, 3 }, { 12, 6 }, { 20, 6 }, { 25, 5 }, { 4, 6 }, { 17, 8 } }) do
    if canopy:has(p[1], p[2]) then c:px(p[1], p[2], c.shd[c:key(p[1], p[2])] and GOLDR.base or GOLDR.rim) end
  end
  beadrow(c, hrow(7, 22, 21))
  c:seam({ { 7, 19 }, { 22, 19 } }, { gap = WOODR.base })
  save(c, "acacia_perch")
end

-- ===== beaded_rack (shelf, 20x24) =====
-- A round flat bead collar (seen a little from above: red rim, cream ring with blue dots, blue ring, gold
-- inner ring round the neck hole) displayed on a short wooden stand that ends inside the neck hole, two bead
-- dangles under the rim, wide wooden foot with a gold hem seam.
do
  local c = canvas(20, 24)
  local CX, CY, RX, RY = 9.5, 9.5, 8, 5.5
  local post = c:rect(8, 7, 11, 19)
  local collar = c:ellipse(CX, CY, RX, RY)
  local hole = c:ellipse(CX, 8, 3, 1.5)
  collar:cut(hole)
  local strands = c:rect(4, 13, 5, 17):add(c:rect(14, 13, 15, 17))
  local foot = c:rrect(3, 18, 16, 21, 1)
  c:build{
    { "post", post, WOODR, { cres = 2, gloss = false, bounce = false } },
    { "strands", strands, REDR, { flat = true, contact = false } },
    { "collar", collar, REDR, { cres = 2, gloss = false } },
    { "foot", foot, WOODR, { cres = 1, gloss = false } },
  }
  collar:each(function(x, y)
    local k = c:key(x, y)
    local t = math.sqrt(((x - CX) / RX) ^ 2 + ((y - CY) / RY) ^ 2)
    local sh = c.shd[k]
    local col
    if t > 0.8 then col = sh and REDR.shade or (c.pix[k] == REDR.rim and REDR.rim or REDR.base)
    elseif t > 0.6 then col = ((x + y) % 2 == 0) and (sh and WATER.shade or WATER.base) or (sh and CREAM.shade or CREAM.base)
    elseif t > 0.42 then col = sh and WATER.shade or WATER.base
    else col = sh and GOLDR.base or GOLDR.rim end
    if c.pix[k] == C.ol2 or c.pix[k] == C.ol3 then col = c.pix[k] end   -- keep the inner contour round the hole
    c:px(x, y, col)
  end)
  c:px(3, 7, REDR.gloss); c:px(4, 6, REDR.gloss); c:px(5, 5, REDR.gloss); c:px(4, 7, REDR.dot)  -- enamel comma
  -- dangles: beads down each strand
  for _, x in ipairs({ 4, 14 }) do
    for y = 14, 17 do
      local b = BEADS[(y + (x > 9 and 2 or 0)) % 4 + 1]
      c:px(x, y, b[1]); c:px(x + 1, y, b[2])
    end
  end
  c:seam({ { 5, 19 }, { 14, 19 } }, { gap = WOODR.base })
  save(c, "beaded_rack")
end

-- ===== grass_tuft (floor-left, 38x28) =====
-- A fountain of felt savanna grass: 12 tapered blades fanning out of a low coiled sisal basket, tall in the
-- middle and arching outward at the sides; straw blades in front, olive blades behind; bead band on the rim.
do
  local c = canvas(38, 28)
  local function blade(bx, tx, ty, bend, w)
    local my = (22 + ty) / 2
    local mx = (bx + tx) / 2 + bend
    return c:poly({ { bx - w, 21 }, { mx - w * 0.7, my }, { tx, ty }, { tx + 1, ty }, { mx + w * 0.7 + 1, my }, { bx + w + 1, 21 } })
  end
  local BL = {
    -- bx, tx, ty, bend, back?
    { 11, 4, 8, -1, true }, { 17, 14, 1, 0, true }, { 23, 27, 2, 0, true }, { 27, 34, 9, 1, true },
    { 8, 2, 14, -1 }, { 12, 8, 4, -1 }, { 15, 12, 6, 0 }, { 19, 19, 2, 0 }, { 21, 24, 6, 0 },
    { 25, 30, 4, 1 }, { 29, 35, 14, 1 }, { 18, 16, 9, 0 },
  }
  -- every blade is its own felt part (back to front: olive blades, then straw blades from the sides in),
  -- so each keeps its rim, crescent and an umber contour against its neighbour
  local SAGE = felt("#a4ac4a", { gloss = "#e6e6a0", rim = "#c8c870", shade = "#6e7a30" })
  local STRAW2 = felt("#e6b850", { gloss = "#fff1c8", rim = "#f8dc84", shade = "#b8822e" })
  local list, order = {}, {}
  for _, b in ipairs(BL) do if b[5] then order[#order + 1] = b end end
  local fr = {}
  for _, b in ipairs(BL) do if not b[5] then fr[#fr + 1] = b end end
  table.sort(fr, function(p, q) return math.abs(p[1] - 18.5) > math.abs(q[1] - 18.5) end)
  for _, b in ipairs(fr) do order[#order + 1] = b end
  for i, b in ipairs(order) do
    local ramp = b[5] and OLIVE or ((i % 3 == 0) and SAGE or ((i % 2 == 0) and STRAW or STRAW2))
    list[#list + 1] = { "b" .. i, blade(b[1], b[2], b[3], b[4], 1.6), ramp, { cres = 1, gloss = false, bounce = false, contact = false } }
  end
  -- low coiled sisal basket: a rim ellipse over a short tapered bowl
  local basket = c:ellipse(18.5, 19.5, 14.5, 2):add(c:poly({ { 4, 19 }, { 34, 19 }, { 31, 26 }, { 7, 26 } })):closed(1)
  list[#list + 1] = { "basket", basket, SISAL, { cres = 2, gloss = { 6, 21 } } }
  c:build(list)
  -- coiled sisal groove under the bead band
  basket:each(function(x, y)
    local k = c:key(x, y)
    if (y == 20 or y == 24) and not c.gl.s[k] then c:px(x, y, c.shd[k] and "#9a7440" or SISAL.shade) end
  end)
  local x0, _, x1 = basket:bbox()
  local row = {}
  for x = x0 + 1, x1 - 1 do if basket:has(x - 1, 22) and basket:has(x + 1, 22) then row[#row + 1] = { x, 22 } end end
  beadrow(c, row, 1)
  save(c, "grass_tuft")
end

-- ===== rain_cloud_mobile (ceiling, 48x34) =====
-- An arched acacia twig on one thread from the top edge; a felt rain cloud (gold edge stitch, hem seam)
-- hangs from its middle, three blue felt drops on threads under the cloud, and a bead strand ending in a
-- small blue drop at each twig end.
do
  local c = canvas(48, 34)
  local twig = c:line({ { 5, 6 }, { 12, 4 }, { 23, 3 }, { 35, 4 }, { 42, 6 } }, 2)
  local cloud = c:ellipse(17, 16, 5.5, 4.5):add(c:ellipse(24, 13, 6.5, 6)):add(c:ellipse(31, 15.5, 5, 4.5))
  cloud:add(c:rrect(12, 15, 36, 21, 2))
  local function drop(cx, cy, r)
    r = r or 2.5
    return c:ellipse(cx, cy + 1, r, r):add(c:poly({ { cx - r + 0.5, cy }, { cx + 0.5, cy - r - 1.5 }, { cx + r + 0.5, cy } }))
  end
  local DX = { { 15.5, 27 }, { 24.5, 29 }, { 32.5, 26 } }
  local SX = { { 6.5, 18 }, { 41.5, 18 } }
  local list = { { "twig", twig, BARK, { cres = 1, gloss = false, bounce = false } },
                 { "cloud", cloud, CLOUD, { cres = 2, gloss = { 19, 9 }, stitch = { side = "lit" } } } }
  for i, d in ipairs(DX) do list[#list + 1] = { "d" .. i, drop(d[1], d[2]), WATER, { cres = 1, gloss = false, bounce = false } } end
  for i, d in ipairs(SX) do list[#list + 1] = { "s" .. i, drop(d[1], d[2], 2), WATER, { cres = 1, gloss = false, bounce = false } } end
  c:build(list)
  for _, d in ipairs(DX) do c:px(math.floor(d[1]) - 1, d[2], WATER.gloss) end      -- glaze glint on each drop
  for _, d in ipairs(SX) do c:px(math.floor(d[1]) - 1, d[2], WATER.gloss) end
  c:seam({ { 13, 19 }, { 35, 19 } }, { gap = CLOUD.base })
  c:finish()
  thread(c, 23, 0, 1)                                      -- hanger to the top edge
  local function hang(x, y)                                -- thread down to the next art pixel
    while y < 34 do
      local nxt = c.pix[c:key(x, y + 1)]
      local v = c.pix[c:key(x, y)]
      if v ~= nil and v ~= "#000000" then break end
      c.pix[c:key(x, y)] = THREAD
      if nxt and nxt ~= "#000000" then break end
      y = y + 1
    end
  end
  hang(24, 6)
  for _, d in ipairs(DX) do hang(math.floor(d[1]), 22) end
  -- bead strands at the twig ends: three 2 px beads on the thread, then the small drop
  for _, d in ipairs(SX) do
    local x = math.floor(d[1])
    c.pix[c:key(x, 8)] = THREAD
    for i = 0, 2 do
      local b = BEADS[(i + (x > 20 and 2 or 0)) % 4 + 1]
      local y = 9 + i * 2
      c.pix[c:key(x - 1, y)] = b[1]; c.pix[c:key(x, y)] = b[1]
      c.pix[c:key(x - 1, y + 1)] = b[2]; c.pix[c:key(x, y + 1)] = b[2]
    end
  end
  save(c, "rain_cloud_mobile")
end

-- ===== coffee_bean_rattle (rod, 16x16) =====
-- A glossy roasted coffee bean (oval tilted a little, dark S crease along its long axis with a lit lip) as a
-- felt shaker, with a gold cap banded in beads, tied on its thread (thread runs to the top edge).
do
  local c = canvas(16, 16)
  local ANG = math.rad(-25)                       -- long axis leans: top to the right
  local ux, uy = math.sin(-ANG), -math.cos(-ANG)  -- unit vector up the long axis
  local nx, ny = -uy, ux                          -- normal
  local CX, CY, A, B = 7.5, 9.5, 4.6, 3.4
  local bean = c:mask()
  for y = 0, 15 do for x = 0, 15 do
    local dx, dy = x - CX, y - CY
    local u, v = dx * ux + dy * uy, dx * nx + dy * ny
    if (u / A) ^ 2 + (v / B) ^ 2 <= 1 then bean:set(x, y) end
  end end
  local cap = c:rrect(6, 3, 11, 5, 1)
  c:build{
    { "bean", bean, BEAN, { cres = 2, gloss = { 4, 8 }, bounce = false } },
    { "cap", cap, GOLDR, { flat = true } },
  }
  -- S crease along the long axis, lit lip on its upper-left side
  local seen = {}
  for i = -9, 9 do
    local t = i / 9 * 0.8
    local off = math.sin(t * math.pi) * 1.2
    local px = math.floor(CX + ux * t * A + nx * off + 0.5)
    local py = math.floor(CY + uy * t * A + ny * off + 0.5)
    local k = py * 16 + px
    if not seen[k] and bean:has(px, py) and not cap:has(px, py) then
      seen[k] = true
      c:px(px, py, C.ol3)
      local lx, ly = px - 1, py
      if bean:has(lx, ly) and not c.gl.s[c:key(lx, ly)] and c:get(lx, ly) ~= C.ol3 then c:px(lx, ly, BEAN.rim) end
    end
  end
  beadrow(c, hrow(7, 10, 4), 1)
  c:finish()
  thread(c, 8, 0, 1)
  save(c, "coffee_bean_rattle")
end

assert(#FAILS == 0, "check failed: " .. table.concat(FAILS, " "))
