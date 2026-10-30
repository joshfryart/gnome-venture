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
-- Drawn as an ascii plan (too small for shape maths): dark back leaves fanning up, a tall red bract in the
-- middle, light arching side and front leaves, a blue frog peeking out of the leaf cup (two eye bumps), on a
-- mossy bark chunk. 1 px gaps in the plan become umber outline, which splits the leaves.
do
  local c = canvas(20, 24)
  local BARK = felt("#8a5636", { gloss = "#c98a4a", rim = "#b0703e" })
  local MOSS = felt("#7ab55c", { gloss = "#c8d77a", rim = "#a4b86a" })
  local LEAF2 = felt("#3f8a45", { gloss = "#c8d77a", rim = "#5a9e4a", shade = "#2a5a38" })
  local BRACT = felt("#e0405a", { gloss = "#ffc27a", rim = "#f2793a", shade = "#ae2a4a" })
  local FROG = felt("#3f8fb0", { gloss = "#c8ecdc", rim = "#8fcbd8", shade = "#2f6290" })
  local PLAN = {
    "....................", -- 0
    "....................", -- 1
    ".........R..........", -- 2
    "..D.....RRR.....D...", -- 3
    "..DD....RRR....DD...", -- 4
    "...DD...RRR...DD....", -- 5
    "...DD..RRRRR..DD....", -- 6
    "..L.DD.RRRRR.DD.L...", -- 7
    "..LL.DDRRRRRDD.LL...", -- 8
    "...LL.DRRRRRD.LL....", -- 9
    "...LLFEEEFEEEFLL....", -- 10
    "....LFEEEFEEEFL.....", -- 11
    "..L.FFEEEFEEEFF.L...", -- 12
    "..LLFFFFFFFFFFFLL...", -- 13
    "...LLLFFFFFFFLLL....", -- 14
    "....LLLLLLLLLLL.....", -- 15
    "..MMMMLLLLLLLMMMM...", -- 16
    "..BBBBBBBBBBBBBBB...", -- 17
    "..BBBBBBBBBBBBBBB...", -- 18
    "..BBBBBBBBBBBBBBB...", -- 19
    "...BBBBBBBBBBBBB....", -- 20
  }
  local function m(ch) return c:ascii(PLAN, 0, 0, ch) end
  c:build{
    { "back", m("D"), LEAF2, { flat = true, contour = false } },
    { "bract", m("R"), BRACT, { cres = 2, deep = 0, gloss = false, contour = false } },
    { "frog", m("FE"), FROG, { cres = 2, deep = 0, gloss = false, contour = false } },
    { "leaves", m("L"), LEAF, { cres = 2, deep = 0, gloss = false, contour = false } },
    { "bark", m("B"), BARK, { cres = 2, deep = 0, gloss = false } },
    { "moss", m("M"), MOSS, { flat = true } },
  }
  c:paint({ "g", "gd" }, 8, 6, { g = BRACT.gloss, d = "#ffc27a" })       -- enamel gloss on the bract
  c:paint({ "y.y" }, 8, 1, { y = GOLD })                                 -- tiny flowers at the tip
  c:eye(6, 10, true); c:eye(10, 10, true)                                 -- frog eye bumps
  c:paint({ "s...s", ".sss." }, 7, 13, { s = FROG.shade })                -- smile
  c:px(5, 11, FROG.gloss)
  c:paint({ "s.....s", "...s..." }, 5, 18, { s = BARK.shade })            -- bark grain
  save(c, "bromeliad")
end

-- ============ 2. capybara plush (floor-left, 38x28) ============
do
  local c = canvas(38, 28)
  local CAPY = felt("#9a5e38", { gloss = "#e8a060", rim = "#c07d4a", shade = "#6e3e2a" })
  local SNOUT = felt("#6e4030", { rim = "#8a5636" })
  local body = c:ellipse(16, 17, 13, 8):cut(c:rect(0, 24, 37, 27))
  local head = c:rrect(21, 7, 34, 20, 4)
  local ear = c:rrect(22, 4, 25, 8, 1)
  local snout = c:rrect(31, 11, 34, 17, 1)
  local pawF = c:rrect(26, 20, 30, 23, 1)
  local pawB = c:rrect(4, 20, 8, 23, 1)
  local blanket = c:poly({ { 7, 9 }, { 19, 9 }, { 21, 20 }, { 6, 20 } }):clip(c:ellipse(16, 17, 14, 9.5))
  local p = c:build{
    { "ear", ear, CAPY, { flat = true } },
    { "body", body, CAPY, { cres = 3, deep = 0, gloss = false } },
    { "pawB", pawB, SNOUT, { flat = true } },
    { "head", head, CAPY, { cres = 3, deep = 0, gloss = { 23, 9 } } },
    { "snout", snout, SNOUT, { flat = true } },
    { "pawF", pawF, SNOUT, { flat = true } },
    { "blanket", blanket, WEAVE, { cres = 2, deep = 0, gloss = false } },
    { "leaf", c:line({ { 28, 5 }, { 32, 3 } }, 2):add(c:rect(31, 2, 32, 2)), LEAF, { flat = true } },
  }
  -- woven stripes across the blanket (vertical bands as it drapes), lit top row kept red
  local inner = blanket:copy():shrink(1)
  inner:each(function(x, y)
    local m = x % 5
    if m == 1 then c:px(x, y, GOLD) elseif m == 3 then c:px(x, y, TEAL) end
  end)
  for x = 7, 20, 2 do c:px(x, 21, GOLD) end                                -- fringe
  c:eye(28, 10, true)
  c:px(23, 6, CAPY.shade)                                                  -- inner ear
  c:px(33, 12, GV.C.ol3)                                                   -- nostril
  c:paint({ "u", "u" }, 32, 15, { u = "ol2" })                             -- mouth
  c:seam({ { 21, 11 }, { 21, 18 } }, { gap = CAPY.shade })                  -- head seam
  save(c, "capybara_plush")
end

-- ============ 3. toucan feather lure (rod, 16x16) ============
-- Ascii plan: a gold bead knotted on the string, a woven red wrap, then three feathers in toucan colours
-- (yellow, dark with an orange tip, orange-red) fanning down. The string runs from the top edge to the bead.
do
  local c = canvas(16, 16)
  local DARK = felt("#3e2f66", { gloss = "#a894dc", rim = "#7b66b4", shade = "#291d4a" })
  local YEL = felt("#f5c12a", { gloss = "#fff1c8", rim = "#ffe07a", shade = "#d0862a" })
  local ORA = felt("#f0602a", { gloss = "#ffc27a", rim = "#ff9158", shade = "#ae2a2a" })
  local PLAN = {
    "................", -- 0
    "................", -- 1
    "................", -- 2
    "......kk........", -- 3
    ".....WWWW.......", -- 4
    ".....WWWW.......", -- 5
    "....YDDDDO......", -- 6
    "...YYDDDDOO.....", -- 7
    "...YYDDDDOO.....", -- 8
    "..YYY.DD.OOO....", -- 9
    "..YY..DD..OO....", -- 10
    "..Y...TT...O....", -- 11
    "......TT........", -- 12
  }
  local function m(ch) return c:ascii(PLAN, 0, 0, ch) end
  c:build{
    { "fl", m("Y"), YEL, { flat = true, contour = false } },
    { "fr", m("O"), ORA, { flat = true, contour = false } },
    { "fc", m("D"), DARK, { flat = true, contour = false } },
    { "tip", m("T"), ORA, { flat = true, contour = false } },
    { "wrap", m("W"), WEAVE, { flat = true, contour = false } },
    { "bead", m("k"), "gold", { flat = true, contour = false } },
  }
  c:paint({ "gtgt" }, 5, 5, { g = GOLD, t = TEAL })                       -- woven stripe on the wrap
  c:px(6, 3, GV.R.gold.gloss)
  c:paint({ "r", "r" }, 7, 7, { r = "#7b66b4" })                            -- rachis on the dark feather
  c:finish()
  cord(c, 7, 0, 1)
  save(c, "toucan_feather_lure")
end

-- ============ 4. rain stick (sill, 30x26) ============
-- A cane rain stick with woven red end caps and two woven bands, lying on the sill with its right end
-- raised on a little carved wooden block; spine pins spiral round the cane.
do
  local c = canvas(30, 26)
  local WOOD = felt("#b07a45", { gloss = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })
  local function band(x0, y0, x1, y1, w)
    local dx, dy = x1 - x0, y1 - y0
    local L = math.sqrt(dx * dx + dy * dy)
    local nx, ny = -dy / L * w, dx / L * w
    return c:poly({ { x0 + nx, y0 + ny }, { x1 + nx, y1 + ny }, { x1 - nx, y1 - ny }, { x0 - nx, y0 - ny } })
  end
  local A, B = { 5, 19 }, { 24, 13 }
  local tube = band(A[1], A[2], B[1], B[2], 3.5)
  local capL = band(3, 19.5, 6, 18.6, 3.8)
  local capR = band(23, 13.6, 26, 12.7, 3.8)
  local block = c:rrect(17, 18, 25, 22, 1)
  c:build{
    { "block", block, WOOD, { cres = 2, deep = 0, gloss = false } },
    { "tube", tube, CANE, { cres = 2, deep = 0, gloss = { 8, 15 } } },
    { "capR", capR, WEAVE, { cres = 2, deep = 0, gloss = false } },
    { "capL", capL, WEAVE, { cres = 2, deep = 0, gloss = false } },
  }
  local function at(t, v) -- point along the axis (t 0..1) and across it (v px, + = lower side)
    local dx, dy = B[1] - A[1], B[2] - A[2]
    local L = math.sqrt(dx * dx + dy * dy)
    return math.floor(A[1] + dx * t - dy / L * v + 0.5), math.floor(A[2] + dy * t + dx / L * v + 0.5)
  end
  for _, t in ipairs({ 0.3, 0.7 }) do                                      -- woven bands
    for v = -3, 3 do
      local x, y = at(t, v)
      if tube:has(x, y) then c:px(x, y, WEAVE.base); c:px(x + 1, y, (v % 2 == 0) and GOLD or TEAL) end
      if tube:has(x + 2, y) and v ~= -3 then c:px(x + 2, y, WEAVE.shade) end
    end
  end
  for i = 0, 9 do                                                          -- spine pins, spiral
    local t = 0.1 + i * 0.09
    local x, y = at(t, ((i % 3) - 1) * 2)
    if tube:has(x, y) and c:get(x, y) ~= WEAVE.base then c:px(x, y, CANE.shade) end
  end
  c:paint({ "s.s" }, 19, 21, { s = WOOD.shade })                          -- carved notches
  for _, t in ipairs({ 0.06, 0.94 }) do                                    -- gold cap ties
    for v = -3, 3, 2 do local x, y = at(t, v) if c:get(x, y) then c:px(x, y, GOLD) end end
  end
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
    for y = 12, 30 do if tubes:has(x, y) and tubes:has(x + 1, y) then c:px(x, y, GV.C.ol2) end end
  end
  for i = 0, N - 1 do
    local x = X0 + i * 4
    c:px(x + 1, 12, CANE.gloss)                                         -- lit nodes
    local bottom = 30 - math.floor(i * 1.8 + 0.5)
    c:paint({ "ss" }, x + 1, bottom - 2, { s = CANE.shade })            -- bamboo node ring near the end
  end
  for y = 13, 18 do c:px(10, y, CANE.gloss) end                             -- enamel gloss on the long tube
  c:px(10, 19, "#fff8e0")
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
