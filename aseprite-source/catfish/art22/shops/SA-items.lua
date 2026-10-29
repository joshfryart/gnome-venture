-- art22/shops/SA-items.lua : Canopy Critter Co. (Rainroot Reaches, South America) pet-shop item sprites.
-- Five 1x room sprites for cf-room.png (320x200), Stitched Toy (art-style-guide Part D) via gvlib:
--   cf-pet-bromeliad            shelf        20x24  red-bract bromeliad on a mossy bark chunk, a blue frog peeks
--   cf-pet-capybara_plush       floor-left   38x28  loaf capybara plush with a woven saddle blanket, leaf on head
--   cf-pet-toucan_feather_lure  rod          16x16  toucan-colour feather lure on a gold bead, tied to the string
--   cf-pet-rain_stick           sill         30x26  cane rain stick with woven end caps, resting on a little stand
--   cf-pet-panpipe_chime        ceiling      48x34  bamboo panpipes bound in a woven band, two tassels, hung on cords
-- Shared regional look: canopy leaf green, cane/bamboo tan, and one woven band (red felt with gold and teal
-- stripes) on every item. Small sprites: 1 px umber outline (+1 lower right) inside the 1 px black border, so
-- they sit at the weight of the room's 2x outlines. Hanging cords are drawn after the border (1 px umber, like
-- the code-drawn rod string) so they stay thin.
-- Run: AppRun -b --script SA-items.lua     Writes ../out/cf-pet-<slug>.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"

-- felt(hex): 4 felt steps (rim, base, one crescent shade, gloss) like cf_props.lua
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end
local function tint(c, m, from, to)
  m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end)
end
local function canvas(w, h) return GV.canvas{ w = w, h = h, mode = "sticker", ol = 1, olx = 1, margin = 0 } end
local FAILS = {}
local function save(c, slug)
  local name = "cf-pet-" .. slug
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-28s ", name) .. GV.report(t))
  if not (t.semi == 0 and t.bw == 0) then FAILS[#FAILS + 1] = name end
  return t
end
local function cord(c, x, y0, y1, hex) for y = y0, y1 do c:px(x, y, hex or GV.C.ol2) end end

-- shared regional ramps
local WEAVE = felt("#dd3a2a", { gloss = "#ff9158", rim = "#f2793a", shade = "#ae2a2a" }) -- red felt band
local TEAL  = "#2f9a8a"                                                                 -- water/moss stripe
local TEALD = "#1f6a6a"
local GOLD, GOLDS = GV.C.gold, GV.C.goldS
local CANE  = felt("#cfa862", { gloss = "#fff1c8", rim = "#ecc98a" })                   -- soil 300 family
local LEAF  = felt("#4f9a45", { gloss = "#c8d77a", rim = "#7ab55c", shade = "#2f6a3a" }) -- leaf preset, felt
-- woven stripe pattern on a mask: rows (or cols) cycling through the band colours, lit pixels kept
local function weave(c, m, dir, seq)
  m:each(function(x, y)
    local v = (dir == "v") and x or y
    local col = seq[(v % #seq) + 1]
    if col then c:px(x, y, col) end
  end)
end

-- ============ 1. bromeliad (shelf, 20x24) ============
do
  local c = canvas(20, 24)
  local BARK = felt("#8a5636", { gloss = "#c98a4a", rim = "#b0703e" })
  local MOSS = felt("#7ab55c", { gloss = "#c8d77a", rim = "#a4b86a" })
  local BRACT = felt("#e0405a", { gloss = "#ffc27a", rim = "#f2793a", shade = "#ae2a4a" })
  local FROG = felt("#3f8fb0", { gloss = "#c8ecdc", rim = "#8fcbd8", shade = "#2f6290" })
  local bark = c:rrect(3, 16, 16, 20, 2)
  local moss = c:ellipse(6, 16, 3, 1.5):add(c:ellipse(13, 16, 2.5, 1.5))
  local leaves = c:mask()
  leaves:add(c:line({ { 9, 15 }, { 5, 11 }, { 2, 9 } }, 3))     -- left arch
  leaves:add(c:line({ { 10, 15 }, { 14, 11 }, { 17, 8 } }, 3))  -- right arch
  leaves:add(c:line({ { 9, 14 }, { 7, 8 }, { 6, 4 } }, 3))      -- back left
  leaves:add(c:line({ { 11, 14 }, { 13, 8 } }, 3))              -- back right
  leaves:add(c:ellipse(9.5, 14, 4, 2))
  local bract = c:ellipse(11, 7, 2, 4)
  local frog = c:rrect(3, 11, 8, 14, 1)
  c:build{
    { "leaves", leaves, LEAF, { cres = 2, deep = 0, gloss = false } },
    { "bract", bract, BRACT, { cres = 2, deep = 0, gloss = false } },
    { "frog", frog, FROG, { flat = true } },
    { "bark", bark, BARK, { cres = 2, deep = 0, gloss = false } },
    { "moss", moss, MOSS, { flat = true } },
  }
  c:paint({ "g", "gd" }, 10, 4, { g = BRACT.gloss, d = "#ffc27a" })      -- enamel gloss on the bract
  c:paint({ "y.y", ".y." }, 10, 2, { y = GOLD })                          -- tiny flowers at the tip
  c:eye(3, 9, true); c:eye(6, 9, true)                                    -- frog peeking eyes
  c:paint({ "ss" }, 5, 13, { s = FROG.shade })                            -- frog mouth
  c:paint({ "s....s", "..s..." }, 7, 18, { s = BARK.shade })              -- bark grain
  save(c, "bromeliad")
end

-- ============ 2. capybara plush (floor-left, 38x28) ============
do
  local c = canvas(38, 28)
  local CAPY = felt("#9a5e38", { gloss = "#e8a060", rim = "#c07d4a", shade = "#6e3e2a" })
  local SNOUT = felt("#6e4030", { rim = "#8a5636" })
  local body = c:ellipse(16, 17, 13, 8):cut(c:rect(0, 24, 37, 27))
  local head = c:rrect(21, 7, 34, 20, 4)
  local ear = c:ellipse(25, 6, 1.5, 1.5)
  local snout = c:rrect(31, 11, 34, 17, 1)
  local pawF = c:rrect(26, 20, 30, 23, 1)
  local pawB = c:rrect(4, 20, 8, 23, 1)
  local blanket = c:poly({ { 7, 9 }, { 19, 9 }, { 21, 20 }, { 6, 20 } }):clip(c:ellipse(16, 17, 14, 9.5))
  local leafM = c:poly({ { 26, 3 }, { 31, 1 }, { 30, 5 } }):grow(0)
  local p = c:build{
    { "ear", ear, CAPY, { flat = true } },
    { "body", body, CAPY, { cres = 3, deep = 0, gloss = false } },
    { "pawB", pawB, SNOUT, { flat = true } },
    { "head", head, CAPY, { cres = 3, deep = 0, gloss = { 23, 9 } } },
    { "snout", snout, SNOUT, { flat = true } },
    { "pawF", pawF, SNOUT, { flat = true } },
    { "blanket", blanket, WEAVE, { cres = 2, deep = 0, gloss = false } },
    { "leaf", c:line({ { 26, 4 }, { 30, 2 } }, 2), LEAF, { flat = true } },
  }
  -- woven stripes across the blanket (vertical bands as it drapes), lit top row kept red
  local inner = blanket:copy():shrink(1)
  inner:each(function(x, y)
    local m = x % 5
    if m == 1 then c:px(x, y, GOLD) elseif m == 3 then c:px(x, y, TEAL) end
  end)
  for x = 7, 20, 2 do c:px(x, 21, GOLD) end                                -- fringe
  c:eye(28, 10, true)
  c:px(33, 12, GV.C.ol3)                                                   -- nostril
  c:paint({ "u", "u" }, 32, 15, { u = "ol2" })                             -- mouth
  c:seam({ { 21, 11 }, { 21, 18 } }, { gap = CAPY.shade })                  -- head seam
  c:ground(17, 25, 14, 1)
  save(c, "capybara_plush")
end

-- ============ 3. toucan feather lure (rod, 16x16) ============
do
  local c = canvas(16, 16)
  local DARK = felt("#3e2f66", { gloss = "#a894dc", rim = "#7b66b4", shade = "#291d4a" })
  local YEL = felt("#f5c12a", { gloss = "#fff1c8", rim = "#ffe07a", shade = "#d0862a" })
  local ORA = felt("#f08a24", { gloss = "#ffc27a", rim = "#ffb25a", shade = "#c0501f" })
  local fl = c:line({ { 6, 8 }, { 4, 11 }, { 3, 13 } }, 2):add(c:ellipse(4, 11, 1.5, 1.5))
  local fr = c:line({ { 9, 8 }, { 11, 11 }, { 12, 13 } }, 2):add(c:ellipse(11, 11, 1.5, 1.5))
  local fc = c:rrect(6, 7, 9, 13, 1)
  local bead = c:rrect(6, 3, 9, 6, 1)
  c:build{
    { "fl", fl, YEL, { flat = true } },
    { "fr", fr, ORA, { flat = true } },
    { "fc", fc, DARK, { cres = 2, deep = 0, gloss = false } },
    { "bead", bead, WEAVE, { flat = true } },
  }
  c:paint({ "gt" }, 7, 5, { g = GOLD, t = TEAL })                          -- woven wrap on the bead
  c:px(6, 3, WEAVE.gloss)
  c:paint({ "s", "s", "s" }, 7, 9, { s = "#7b66b4" })                       -- rachis on the dark feather
  c:px(8, 12, ORA.base)                                                     -- orange tip like the beak
  c:finish()
  cord(c, 7, 0, 1)
  save(c, "toucan_feather_lure")
end

-- ============ 4. rain stick (sill, 30x26) ============
do
  local c = canvas(30, 26)
  local WOOD = felt("#b07a45", { gloss = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })
  local function band(x0, y0, x1, y1, w)
    local dx, dy = x1 - x0, y1 - y0
    local L = math.sqrt(dx * dx + dy * dy)
    local nx, ny = -dy / L * w, dx / L * w
    return c:poly({ { x0 + nx, y0 + ny }, { x1 + nx, y1 + ny }, { x1 - nx, y1 - ny }, { x0 - nx, y0 - ny } })
  end
  local tube = band(5, 18, 24, 7, 3.2)
  local capL = c:ellipse(5, 18.5, 3, 3)
  local capR = c:ellipse(24.5, 7, 3, 3)
  local legA = c:line({ { 15, 22 }, { 20, 13 } }, 2)
  local legB = c:line({ { 23, 22 }, { 19, 13 } }, 2)
  local p = c:build{
    { "legB", legB, WOOD, { flat = true } },
    { "tube", tube, CANE, { cres = 2, deep = 0, gloss = { 9, 13 } } },
    { "capR", capR, WEAVE, { cres = 2, deep = 0, gloss = false } },
    { "capL", capL, WEAVE, { cres = 2, deep = 0, gloss = false } },
    { "legA", legA, WOOD, { flat = true } },
  }
  -- spine dots in a spiral along the cane
  for i = 0, 6 do
    local t = (i + 0.5) / 7
    local x, y = 7 + (22 - 7) * t, 16 - (16 - 8) * t
    local off = (i % 2 == 0) and 1 or -1
    c:px(math.floor(x + 0.5), math.floor(y + off + 0.5), CANE.shade)
  end
  -- woven middle band across the tube
  local mid = band(14, 12.5, 15.5, 11.6, 3.2):clip(tube)
  mid:each(function(x, y) c:px(x, y, ((x + y) % 2 == 0) and TEAL or GOLD) end)
  c:paint({ "g" }, 4, 17, { g = GOLD }); c:paint({ "g" }, 23, 6, { g = GOLD })  -- cap ties
  save(c, "rain_stick")
end

-- ============ 5. panpipe chime (ceiling, 48x34) ============
do
  local c = canvas(48, 34)
  local tubes, N = c:mask(), 8
  local X0 = 9
  for i = 0, N - 1 do
    local x = X0 + i * 4
    local bottom = 30 - math.floor(i * 1.8 + 0.5)
    tubes:add(c:rrect(x, 8, x + 3, bottom, 1))
  end
  local bandM = c:rrect(6, 7, 42, 11, 1)
  local tasL = c:line({ { 6, 12 }, { 6, 17 } }, 2):add(c:ellipse(6, 19.5, 2, 2.5))
  local tasR = c:line({ { 42, 12 }, { 42, 22 } }, 2):add(c:ellipse(42, 24.5, 2, 2.5))
  local p = c:build{
    { "tasL", tasL, felt("#2f9a8a", { rim = "#5ac0a8", shade = TEALD }), { flat = true } },
    { "tasR", tasR, felt("#2f9a8a", { rim = "#5ac0a8", shade = TEALD }), { flat = true } },
    { "tubes", tubes, CANE, { cres = 2, deep = 0, gloss = false, light = c:rect(9, 8, 40, 31) } },
    { "band", bandM, WEAVE, { cres = 2, deep = 0, gloss = false } },
  }
  -- separations between tubes + bottom holes
  for i = 1, N - 1 do
    local x = X0 + i * 4 - 1
    for y = 12, 30 do if tubes:has(x, y) and tubes:has(x + 1, y) then c:px(x, y, CANE.shade) end end
  end
  for i = 0, N - 1 do
    local x = X0 + i * 4
    c:px(x + 1, 12, CANE.gloss)                                         -- lit nodes
    local bottom = 30 - math.floor(i * 1.8 + 0.5)
    c:paint({ "ss" }, x + 1, bottom - 2, { s = CANE.shade })            -- bamboo node ring near the end
  end
  -- woven zigzag on the band
  for x = 7, 41 do
    local y = 9 + ((x % 4 < 2) and 0 or -1)
    c:px(x, y, GOLD)
    if x % 4 == 1 then c:px(x, 10, TEAL) end
  end
  c:finish()
  cord(c, 13, 0, 5); cord(c, 35, 0, 5)
  save(c, "panpipe_chime")
end

if #FAILS > 0 then print("FAILS: " .. table.concat(FAILS, ", ")) end
