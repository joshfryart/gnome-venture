-- shops/MENA-items.lua : Cat Fish pet shop MENA "Lantern & Lounge" (Dunewhisper), the 5 room item sprites.
-- Run: AppRun -b --script MENA-items.lua     Writes art22/out/cf-pet-<slug>.png + .aseprite
-- Spec: claude/catfish-shops-art-spec.md (slot sizes), claude/plan-catfish-petshops.md section 3.
-- Each canvas is exactly the slot's max size; sticker mode (1 px #000000 border, like the cats, fish and yarn).
--   brass_lantern  ceiling 48x34   pierced brass lantern on a chain, onion dome, three glowing arch panes, madder tassel
--   kilim_cushion  floor-left 38x28 plump madder floor cushion, kilim band of stepped diamonds, gold corner tassels
--   bell_lure      rod 16x16       brass bell on a madder knot, hung from a 1 px umber string (no border on the string)
--   sand_timer     shelf 20x24     madder lacquer caps with gold seams, brass posts, glass bulbs of saffron sand
--   mirage_mirror  frame 35x31     turquoise horseshoe-arch mirror, brass bead, a shimmering dune mirage in the glass
-- Shared regional set: brass (gold ramp), madder red, turquoise, indigo, saffron sand. Light from the upper left.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local C = GV.C

-- felt(hex): 4 felt steps (rim, base, shade, gloss) like cf_props.lua: deep = shade, bounce = base
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end
local BRASS  = felt("#e8a317", { rim = "#f5cf6a", shade = "#b8661a", deep = "#7a3a14", gloss = "#fff1c8", dot = "#fff8e0" })
local MADDER = felt("#b8352c", { rim = "#dc5a3a", shade = "#82203a", gloss = "#f08a5a", dot = "#ffc27a" })
local TURQ   = felt("#2f9a96", { rim = "#5fc0b0", shade = "#22667a", gloss = "#a8e0c8", dot = "#d8f4e0" })
local INDIGO = felt("#3b4f8f", { rim = "#5a70b0", shade = "#2a3266", gloss = "#a0b0e0", dot = "#c3cff0" })
local SAND   = felt("#e3b064", { rim = "#f0cc84", shade = "#b87a3e", gloss = "#fff1c8", dot = "#fff8e0" })
local GLASS  = { base = "#cfe6ea", rim = "#eef8f2", shade = "#9cc0d0", deep = "#9cc0d0", bounce = "#cfe6ea",
                 gloss = "#f8fcf4", dot = "#f8fcf4", pale = false }
local GLOW   = { hi = "#fff3c8", mid = "#ffd970", lo = "#f0a040" }          -- lantern panes, lit -> shaded facet

local FAILS = {}
-- cords: keys of string pixels whose own black border is removed after finish (the game's strings are bare 1 px)
local function unborder(c, cord)
  c:finish()
  local isCord = {}
  for _, p in ipairs(cord) do isCord[c:key(p[1], p[2])] = true end
  local drop = {}
  for k, v in pairs(c.pix) do
    if v == "#000000" then
      local x, y = c:xy(k)
      local any, onlyCord = false, true
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local kn = c:key(x + d[1], y + d[2])
        local q = c.pix[kn]
        if q and q ~= "#000000" then any = true if not isCord[kn] then onlyCord = false end end
      end
      if any and onlyCord then drop[#drop + 1] = k end
    end
  end
  for _, k in ipairs(drop) do c.pix[k] = nil end
end
local function save(c, slug)
  local name = "cf-pet-" .. slug
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-22s ", name) .. GV.report(t))
  if not (t.semi == 0 and t.bw == 0) then FAILS[#FAILS + 1] = name end
  return t
end

-- ===== brass_lantern : ceiling, 48 x 34 =====
do
  local c = GV.canvas{ w = 48, h = 34, mode = "sticker", ol = 1, olx = 1, cx = 23.5, cy = 17 }
  local knob = c:ellipse(23.5, 5, 1.5, 1.5)
  local dome = c:ellipse(23.5, 10, 5.5, 3):cut(c:rect(0, 12, 47, 33))
  dome:add(c:poly({ { 20, 8 }, { 23, 5 }, { 25, 5 }, { 28, 8 } }))
  local eave = c:rect(15, 12, 32, 13)
  local body = c:rect(17, 14, 30, 23)
  local foot = c:rect(15, 24, 32, 25)
  local cone = c:poly({ { 18, 26 }, { 30, 26 }, { 26, 28 }, { 22, 28 } })
  local bead = c:rect(22, 28, 25, 29)
  local tass = c:poly({ { 22, 29 }, { 26, 29 }, { 26, 31 }, { 22, 31 } })
  c:build{
    { "body", body, BRASS, { cres = 3, gloss = false } },
    { "dome", dome, BRASS, { cres = 2, gloss = { 20, 8 } } },
    { "knob", knob, BRASS, { flat = true } },
    { "eave", eave, BRASS, { cres = 1, deep = 0, gloss = false } },
    { "foot", foot, BRASS, { cres = 1, deep = 0, gloss = false } },
    { "cone", cone, BRASS, { cres = 1, deep = 0, gloss = false } },
    { "tass", tass, MADDER, { flat = true, contact = false } },
    { "bead", bead, TURQ, { flat = true } },
  }
  -- three arch panes: left facet lit, centre bright, right facet shaded; a brass lattice dot in each
  local function pane(x0, lit, mid, dot)
    c:paint({ ".mm.", "mlmm", "mmmm", "mmmm", "mmmm", "mmmm", "mmmm" }, x0, 15, { m = mid, l = lit })
    c:px(x0 + 1, 19, dot); c:px(x0 + 2, 19, dot)
    c:px(x0 + 1, 18, dot == C.goldS and dot or BRASS.base)
  end
  pane(18, GLOW.hi, GLOW.mid, GLOW.mid)
  pane(22, GLOW.hi, GLOW.hi, BRASS.rim)
  pane(26, GLOW.mid, GLOW.lo, GLOW.lo)
  -- tassel threads
  c:px(23, 31, MADDER.shade); c:px(25, 31, MADDER.shade)
  -- chain: 2 px brass links (umber every third row), from the ceiling to the knob
  for y = 0, 3 do
    local a, b = C.gold, C.goldS
    if y % 3 == 2 then a, b = C.ol1, C.ol2 end
    c:px(23, y, a); c:px(24, y, b)
  end
  save(c, "brass_lantern")
end

-- ===== kilim_cushion : floor-left, 38 x 28 (bottom flat) =====
-- A plump pillow: the top edge bulges up, the corners are pulled out into gold tassels, the bottom is flat.
do
  local c = GV.canvas{ w = 38, h = 28, mode = "sticker", ol = 2, olx = 1, cx = 18.5, cy = 15 }
  local body = c:rect(6, 9, 31, 23):add(c:ellipse(18.5, 9, 12.5, 4))
  body:add(c:ellipse(6, 15, 2.5, 6)):add(c:ellipse(31, 15, 2.5, 6))
  body:add(c:poly({ { 3, 6 }, { 9, 8 }, { 7, 12 } })):add(c:poly({ { 35, 6 }, { 29, 8 }, { 31, 12 } }))
  body:add(c:poly({ { 3, 24 }, { 7, 18 }, { 9, 24 } })):add(c:poly({ { 35, 24 }, { 31, 18 }, { 29, 24 } }))
  local tl = c:rect(2, 4, 4, 6)
  local tr = c:rect(33, 4, 35, 6)
  c:build{
    { "tl", tl, BRASS, { flat = true, contact = false } },
    { "tr", tr, BRASS, { flat = true, contact = false } },
    { "body", body, MADDER, { cres = 3, gloss = { 9, 8 } } },
  }
  -- kilim band: indigo stripes above and below, three stepped diamonds (gold edge, turquoise, madder heart)
  for x = 7, 30 do c:px(x, 12, INDIGO.base); c:px(x, 22, INDIGO.shade) end
  local D = { "...g...", "..gtg..", ".gtttg.", "gttmttg", ".gtttg.", "..gtg..", "...g..." }
  for i, dx in ipairs({ 9, 16, 23 }) do
    c:paint(D, dx, 14, { g = (i == 3) and C.goldS or C.gold, t = (i == 3) and TURQ.shade or TURQ.base, m = MADDER.shade })
  end
  c:paint({ "g.g" }, 2, 7, { g = BRASS.shade }); c:paint({ "g.g" }, 33, 7, { g = BRASS.shade })   -- tassel strands
  c:seam({ { 8, 24 }, { 30, 24 } }, { gap = MADDER.shade })                                         -- bottom hem
  c:button(17, 6)                                                                                   -- tuft button
  save(c, "kilim_cushion")
end

-- ===== bell_lure : rod, 16 x 16 (hangs from the string at the top) =====
do
  local c = GV.canvas{ w = 16, h = 16, mode = "sticker", ol = 1, olx = 1, cx = 7.5, cy = 8 }
  local knot = c:rrect(5, 2, 10, 4, 1)
  local bell = c:ellipse(7.5, 8.5, 4, 4):cut(c:rect(0, 10, 15, 15))
  bell:add(c:poly({ { 3, 9 }, { 12, 9 }, { 14, 12 }, { 1, 12 } }))
  local clap = c:rect(6, 13, 9, 13)
  c:build{
    { "clap", clap, MADDER, { flat = true } },
    { "bell", bell, BRASS, { cres = 2, gloss = { 5, 7 } } },
    { "knot", knot, MADDER, { flat = true } },
  }
  for x = 3, 12 do c:px(x, 11, (x < 7) and BRASS.shade or BRASS.deep) end   -- sound slit under the lip
  local cord = {}
  for y = 0, 1 do c:px(7, y, C.ol3); cord[#cord + 1] = { 7, y } end
  unborder(c, cord)
  save(c, "bell_lure")
end

-- ===== sand_timer : shelf, 20 x 24 (bottom flat) =====
-- Wide madder lacquer caps with a gold seam and brass knob feet, a pinched glass between, saffron sand falling.
do
  local c = GV.canvas{ w = 20, h = 24, mode = "sticker", ol = 1, olx = 1, cx = 9.5, cy = 12 }
  local top = c:rrect(2, 2, 17, 4, 1)
  local bot = c:rrect(2, 17, 17, 19, 1)
  local feet = c:rect(3, 20, 5, 21):add(c:rect(14, 20, 16, 21))
  local glass = c:ellipse(9.5, 8, 5, 3.5):add(c:ellipse(9.5, 14, 5, 3.5)):add(c:rect(8, 10, 11, 12))
  glass:clip(c:rect(0, 5, 19, 16))
  c:build{
    { "glass", glass, GLASS, { cres = 2, gloss = false, contact = false } },
    { "feet", feet, BRASS, { flat = true, contact = false } },
    { "top", top, MADDER, { cres = 1, deep = 0, gloss = false } },
    { "bot", bot, MADDER, { cres = 1, deep = 0, gloss = false } },
  }
  -- sand: the top bulb's lower half, the falling stream, the heap below
  c:paint({ "SSssssss", ".Sssss.", "..sss", "...s" }, 6, 8, { s = SAND.base, S = SAND.rim })
  c:px(9, 12, SAND.base); c:px(9, 13, SAND.base)
  c:paint({ "....s....", "..ssssS..", ".sssssSS." }, 5, 14, { s = SAND.base, S = SAND.shade })
  c:px(6, 6, GLASS.gloss); c:px(7, 6, GLASS.gloss); c:px(6, 7, GLASS.gloss)        -- glass gloss comma
  c:seam({ { 3, 3 }, { 16, 3 } }, { gap = MADDER.base }); c:seam({ { 3, 18 }, { 16, 18 } }, { gap = MADDER.shade })
  save(c, "sand_timer")
end

-- ===== mirage_mirror : frame, 35 x 31 (replaces the picture frame) =====
-- A pointed (two-circle) arch in turquoise tile felt with a brass bead and a madder plinth; in the glass a
-- desert mirage: stepped sky, low sun, a palm on the dune and its shimmering upside-down twin.
do
  local c = GV.canvas{ w = 35, h = 31, mode = "sticker", ol = 2, olx = 1, cx = 17, cy = 15 }
  local function arch(r, d, cy, x0, x1, y1)
    local m = c:ellipse(17 - d, cy, r, r):clip(c:ellipse(17 + d, cy, r, r)):clip(c:rect(0, 0, 34, cy))
    return m:add(c:rect(x0, cy, x1, y1))
  end
  local frame = arch(16, 4, 18, 5, 29, 23)
  local plinth = c:rrect(3, 23, 31, 26, 1)
  local bead = arch(13, 4, 18, 8, 26, 22)
  local glassM = arch(12, 4, 18, 9, 25, 21)
  c:build{
    { "frame", frame, TURQ, { cres = 3, gloss = { 10, 8 } } },
    { "plinth", plinth, MADDER, { cres = 2, gloss = false } },
    { "bead", bead, BRASS, { flat = true, contact = false, contour = false } },
    { "glass", glassM, GLASS, { flat = true, rim = false, contact = false, contour = false } },
  }
  c:bands(glassM:copy():clip(c:rect(0, 0, 34, 15)), { "#8fcbd8", "#a8dce0", "#c8ecdc", "#f6e4b0" })
  c:fill(c:ellipse(13.5, 13.5, 1.5, 1.5):clip(glassM), "#fff1c8")              -- low sun
  local dune = glassM:copy():clip(c:rect(0, 16, 34, 30))
  c:fill(dune, SAND.rim)
  c:fill(c:ellipse(24, 25, 9, 6):clip(glassM), SAND.base)                     -- far dune, right
  c:fill(c:rect(19, 20, 25, 21):clip(glassM), SAND.shade)
  -- palm on the dune and its mirage twin hanging upside down in the shimmer
  c:paint({ "ll.ll", ".lll.", "l.t.l", "..t..", "..t.." }, 19, 11, { l = "#4f9a45", t = "#8a4f2a" })
  c:paint({ "..t..", "l.t.l", ".lll." }, 19, 16, { l = "#7ab59a", t = "#b8946a" })
  c:paint({ "ww.ww..www", "...www.w.." }, 11, 15, { w = "#eef8f2" })          -- shimmer over the horizon
  c:stitch(frame, { side = "lit" })
  c:seam({ { 5, 24 }, { 29, 24 } }, { gap = MADDER.base })
  save(c, "mirage_mirror")
end

assert(#FAILS == 0, "check failed: " .. table.concat(FAILS, " "))
