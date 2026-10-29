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
-- A small wooden display rack (two uprights, top bar with knob ends, foot) with a woven sisal back panel;
-- a round flat bead collar hangs on it (red rim, cream ring with blue dots, blue ring, gold centre) with a
-- short bead tassel under it.
do
  local c = canvas(20, 24)
  local panel = c:rect(4, 5, 15, 19)
  local frame = c:rect(2, 4, 3, 21):add(c:rect(16, 4, 17, 21))
  local bar = c:rect(2, 3, 17, 4)
  local foot = c:rrect(2, 20, 17, 21, 0)
  local CX, CY, R = 9.5, 11, 5
  local collar = c:ellipse(CX, CY, R, R)
  c:build{
    { "panel", panel, SISAL, { cres = 2, gloss = false, bounce = false } },
    { "frame", frame, WOODR, { cres = 1, gloss = false, bounce = false } },
    { "bar", bar, WOODR, { flat = true } },
    { "foot", foot, WOODR, { cres = 1, gloss = false, bounce = false } },
    { "collar", collar, REDR, { cres = 2, gloss = false } },
  }
  -- weave on the back panel: shade every other row, broken 2 on / 1 off so it reads as woven sisal
  panel:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] and c.pix[k] == SISAL.base and y % 2 == 0 and (x + y) % 3 ~= 0 then c:px(x, y, SISAL.shade) end
  end)
  -- concentric bead rings
  collar:each(function(x, y)
    local k = c:key(x, y)
    local t = math.sqrt((x - CX) ^ 2 + (y - CY) ^ 2) / R
    local sh = c.shd[k]
    local col
    if t > 0.78 then col = sh and REDR.shade or (c.pix[k] == REDR.rim and REDR.rim or REDR.base)
    elseif t > 0.5 then col = ((x + y) % 2 == 0) and (sh and WATER.shade or WATER.base) or (sh and CREAM.shade or CREAM.base)
    elseif t > 0.25 then col = sh and WATER.shade or WATER.base
    else col = GOLDR.rim end
    c:px(x, y, col)
  end)
  c:px(6, 8, REDR.gloss); c:px(7, 7, REDR.gloss); c:px(8, 7, REDR.gloss)   -- enamel comma on the red rim
  c:px(9, 10, GOLDR.gloss)                                                 -- glint on the gold centre
  -- bead tassel under the collar (on the panel)
  beadrow(c, { { 9, 17 }, { 9, 18 } }, 4)
  beadrow(c, { { 10, 17 }, { 10, 18 } }, 2)
  c:seam({ { 3, 20 }, { 16, 20 } }, { gap = WOODR.base })
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
    return c:poly({ { bx - w, 22 }, { mx - w * 0.7, my }, { tx, ty }, { tx + 1, ty }, { mx + w * 0.7 + 1, my }, { bx + w + 1, 22 } })
  end
  local BL = {
    -- bx, tx, ty, bend, back?
    { 11, 4, 8, -1, true }, { 17, 14, 1, 0, true }, { 23, 27, 2, 0, true }, { 27, 34, 9, 1, true },
    { 8, 2, 14, -1 }, { 12, 8, 4, -1 }, { 15, 12, 6, 0 }, { 19, 19, 2, 0 }, { 21, 24, 6, 0 },
    { 25, 30, 4, 1 }, { 29, 35, 14, 1 }, { 18, 16, 9, 0 },
  }
  local back, front = c:mask(), c:mask()
  for _, b in ipairs(BL) do (b[5] and back or front):add(blade(b[1], b[2], b[3], b[4], 1.6)) end
  local basket = c:ellipse(18.5, 22.5, 15.5, 3)
  c:build{
    { "back", back, OLIVE, { cres = 2, gloss = false, bounce = false } },
    { "front", front, STRAW, { cres = 2, gloss = false, bounce = false } },
    { "basket", basket, SISAL, { cres = 2, gloss = { 6, 21 } } },
  }
  -- blade split lines: where one front blade meets the next, 1 px shade so the blades stay apart
  local fronts = {}
  for _, b in ipairs(BL) do if not b[5] then fronts[#fronts + 1] = blade(b[1], b[2], b[3], b[4], 1.6) end end
  for i, m in ipairs(fronts) do
    m:each(function(x, y)
      local k = c:key(x, y)
      if c.own[k] and (c.pix[k] == STRAW.base or c.pix[k] == STRAW.rim) and y < 20 then
        for j = i + 1, #fronts do
          if fronts[j]:has(x + 1, y) and not m:has(x + 1, y) then c:px(x, y, STRAW.shade) end
        end
      end
    end)
  end
  -- coiled sisal groove under the bead band
  basket:each(function(x, y)
    local k = c:key(x, y)
    if y == 24 and not c.gl.s[k] and not c.shd[k] then c:px(x, y, SISAL.shade) end
  end)
  beadrow(c, hrow(4, 33, 22), 1)
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
-- A glossy roasted coffee bean (upright oval, dark S crease with a lit lip) as a felt shaker, with a gold cap
-- banded in beads, tied on its thread (thread runs to the top edge).
do
  local c = canvas(16, 16)
  local bean = c:ellipse(7.5, 9, 3.5, 4.5)
  local cap = c:rrect(5, 3, 10, 5, 1)
  c:build{
    { "bean", bean, BEAN, { cres = 2, gloss = { 5, 7 }, bounce = false } },
    { "cap", cap, GOLDR, { flat = true } },
  }
  local cr = { { 8, 6 }, { 8, 7 }, { 7, 8 }, { 7, 9 }, { 7, 10 }, { 8, 11 }, { 8, 12 } }
  for _, p in ipairs(cr) do c:px(p[1], p[2], C.ol3) end
  for _, p in ipairs({ { 7, 6 }, { 7, 7 }, { 6, 9 }, { 6, 10 }, { 7, 11 } }) do
    if not c.gl.s[c:key(p[1], p[2])] then c:px(p[1], p[2], BEAN.rim) end
  end
  beadrow(c, hrow(6, 9, 4), 1)
  c:finish()
  thread(c, 7, 0, 1)
  save(c, "coffee_bean_rattle")
end

assert(#FAILS == 0, "check failed: " .. table.concat(FAILS, " "))
