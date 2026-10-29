-- shops/OC-items.lua : Cat Fish pet shop OC (Reef & Purr, Coralscatter, Oceania), the 5 item sprites.
-- Run: AppRun -b --script OC-items.lua     Writes art22/out/cf-pet-<slug>.png + .aseprite
-- Shown at 1x on the 320x200 room (like the cats and cf-yarn-*): 1 px umber outline (+1 lower right on the
-- bigger pieces), 1 px #000000 border, felt ramps (rim, base, one crescent shade, gloss comma).
-- Shared regional look: sea-glass teal, coral-pink twine, sun-bleached driftwood and sand; every piece carries
-- a coral twine/bead accent and a teal felt or water panel. Light from the upper left.
--   tide_pool_jar          shelf    20x24  glass jar, coral felt lid tied with twine, teal water, sand, weed, starfish
--   driftwood_board        frame    35x31  driftwood plank frame lashed with coral twine, felt sea + wave + scallop
--   southern_cross_mobile  ceiling  48x34  driftwood bar on two strings, five felt stars of the Southern Cross
--   kiwi_plush             floor-l  38x28  round brown felt kiwi, long pale beak, stubby legs, coral bow
--   seashell_lure          rod      16x16  coral scallop shell on a gold bead, hanging from its thread
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local C = GV.C

local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end

-- regional ramps (shared by all five)
local TEAL  = felt("#2fa39a", { gloss = "#c8ecdc", rim = "#6cc9b8", shade = "#22767a" })
local CORAL = felt("#f0705a", { gloss = "#ffc27a", rim = "#ff9a78", shade = "#c04a4a" })
local DRIFT = felt("#b59f80", { gloss = "#f1e4c4", rim = "#d6c4a0", shade = "#8a7660" })
local SAND  = felt("#e8c88a", { gloss = "#fff1c8", rim = "#f5dca8", shade = "#c9a46a", pale = false })
local STAR  = felt("#f5cf6a", { gloss = "#fff1c8", rim = "#fff1c8", shade = "#e8a317", pale = false })
local SEAW  = { base = "#4f9a45", shade = "#2f6a3a", rim = "#7ab55c" }
local THREAD = C.ol1

local FAILS = {}
local function save(c, slug, threads)
  c:finish()
  -- strings stay 1 px umber lines like the rod strings: drop the black border that sits only beside them
  if threads then
    local isT = {}
    for _, p in ipairs(threads) do isT[c:key(p[1], p[2])] = true end
    local drop = {}
    for k, h in pairs(c.pix) do
      if h == "#000000" then
        local x, y = c:xy(k)
        local other = false
        for _, d in ipairs({ {1,0},{-1,0},{0,1},{0,-1} }) do
          local kn = c:key(x + d[1], y + d[2])
          local v = c.pix[kn]
          if v and v ~= "#000000" and not isT[kn] then other = true end
        end
        if not other then drop[#drop + 1] = k end
      end
    end
    for _, k in ipairs(drop) do c.pix[k] = nil end
  end
  local name = "cf-pet-" .. slug
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-28s ", name) .. GV.report(t))
  if not (t.semi == 0 and t.bw == 0) then FAILS[#FAILS + 1] = slug end
  return t
end
local function tline(c, list, x0, y0, x1, y1)  -- 1 px thread, recorded so save() keeps it borderless
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do
    local x = math.floor(x0 + (x1 - x0) * i / math.max(1, n) + 0.5)
    local y = math.floor(y0 + (y1 - y0) * i / math.max(1, n) + 0.5)
    c:px(x, y, THREAD); list[#list + 1] = { x, y }
  end
end

-- ===== 1. Tide-pool Jar (shelf, 20x24) =====
do
  local c = GV.canvas{ w = 20, h = 24, mode = "sticker", ol = 1, olx = 1, margin = 0 }
  local body = c:rrect(2, 8, 16, 21, 3)
  local neck = c:rect(5, 6, 13, 8)
  local lid  = c:rrect(3, 1, 15, 6, 2)
  local glass = felt("#b8e2dc", { gloss = "#f8fcf4", rim = "#e4f4ee", shade = "#7fb8b8", pale = false })
  c:build{
    { "body", body:copy():add(neck), glass, { cres = 2, gloss = false } },
    { "lid",  lid, CORAL, { cres = 2, gloss = { 5, 2 } } },
  }
  -- water panel inside the glass (1 px glass wall left, right and bottom)
  local water = c:rrect(3, 11, 15, 20, 2)
  water:each(function(x, y)
    local col = TEAL.base
    if y == 11 then col = TEAL.rim end
    if (x - 9) + (y - 15) > 6 then col = TEAL.shade end
    c:px(x, y, col)
  end)
  for x = 3, 15 do if water:has(x, 19) then c:px(x, 19, SAND.base) end if water:has(x, 20) then c:px(x, 20, SAND.shade) end end
  c:px(4, 18, SAND.base); c:px(14, 18, SAND.base)
  -- seaweed strands
  c:paint({ ".w", "w.", "w.", ".w", ".w", "w." }, 5, 13, { w = SEAW.base })
  c:paint({ "w", "w", "w" }, 7, 16, { w = SEAW.shade })
  -- starfish on the sand
  c:paint({ ".o.", "ooo", "o.o" }, 11, 16, { o = "#f08a24" })
  c:px(12, 16, "#ffc27a")
  -- glass gloss stripe, upper left
  c:paint({ "g", "g", "g", ".", "g" }, 3, 9, { g = glass.gloss })
  -- twine round the neck + bow ends
  for x = 4, 14 do c:px(x, 6, (x % 3 == 0) and CORAL.shade or CORAL.rim) end
  c:seam({ { 4, 4 }, { 14, 4 } }, { gap = CORAL.base })
  save(c, "tide_pool_jar")
end

-- ===== 2. Driftwood Board (frame, 35x31) =====
do
  local c = GV.canvas{ w = 35, h = 31, mode = "sticker", ol = 1, olx = 1, margin = 0 }
  local panel = c:rect(6, 6, 27, 23)
  local top  = c:poly({ {1, 2}, {33, 1}, {33, 6}, {2, 7} })
  local bot  = c:poly({ {2, 23}, {32, 23}, {33, 28}, {1, 29} })
  local left = c:rrect(2, 2, 6, 28, 1)
  local right = c:rrect(27, 1, 31, 28, 1)
  c:build{
    { "panel", panel, TEAL, { cres = 2, gloss = false, rim = false, bounce = false } },
    { "left",  left,  DRIFT, { cres = 2, gloss = false } },
    { "right", right, DRIFT, { cres = 2, gloss = false } },
    { "top",   top,   DRIFT, { cres = 2, gloss = { 9, 3 } } },
    { "bot",   bot,   DRIFT, { cres = 2, gloss = false } },
  }
  -- felt sea picture: sky band, sea, a curling cream wave, sand
  for y = 7, 22 do for x = 7, 26 do
    local col
    if y <= 11 then col = "#bfe4dc"
    elseif y >= 20 then col = (y == 20) and SAND.rim or SAND.base
    else col = (y == 12) and TEAL.rim or TEAL.base end
    c:px(x, y, col)
  end end
  -- curling wave: cream crest breaking to the right, a dark hollow under the curl
  c:paint({
    "......cccc.....",
    "....cc....c....",
    "...c...tt..c...",
    "..c...t..c.....",
    ".c...t..........",
    "cccccccccccccccc",
  }, 7, 13, { c = "#f8f0dc", t = TEAL.shade })
  for x = 7, 26 do c:px(x, 19, TEAL.shade) end
  -- scallop shell on the sand
  c:paint({ ".ppp.", "prprp", "prprp", ".sss." }, 20, 18, { p = CORAL.rim, r = CORAL.shade, s = CORAL.base })
  -- wood grain
  c:paint({ "ss...sss", }, 14, 4, { s = DRIFT.shade })
  c:paint({ "sss....ss", }, 10, 26, { s = DRIFT.shade })
  c:paint({ "s", "s", ".", "s" }, 4, 12, { s = DRIFT.shade })
  c:paint({ "s", ".", "s", "s" }, 29, 15, { s = DRIFT.shade })
  -- coral twine lashings at the four corners
  for _, p in ipairs({ {3, 3}, {28, 2}, {3, 24}, {28, 24} }) do
    c:paint({ "a..a", ".bb.", ".bb.", "a..a" }, p[1], p[2], { a = CORAL.shade, b = CORAL.rim })
  end
  save(c, "driftwood_board")
end

-- ===== 3. Southern Cross Mobile (ceiling, 48x34) =====
do
  local c = GV.canvas{ w = 48, h = 34, mode = "sticker", ol = 1, olx = 1, margin = 0 }
  local T = {}
  local bar = c:rrect(4, 5, 43, 7, 1)
  local STAR7 = { "...x...", "..xxx..", "xxxxxxx", ".xxxxx.", "..xxx..", ".xx.xx.", "xx...xx" }
  local STAR5 = { "..x..", ".xxx.", "xxxxx", ".x.x.", "x...x" }
  -- crux: Gacrux top, Acrux bottom, Mimosa left, Delta right, Epsilon small, lower right of centre
  -- {name, x, y, shape, thread x, thread top y}; Acrux hangs on a thread from under Gacrux (a chained mobile)
  local stars = {
    { "gac", 20, 11, STAR7, 23, 8 },
    { "mim", 5,  17, STAR7, 8, 8 },
    { "del", 35, 14, STAR7, 38, 8 },
    { "eps", 29, 22, STAR5, 31, 8 },
    { "acr", 20, 26, STAR7, 23, 16 },
  }
  local parts = { { "bar", bar, DRIFT, { cres = 1, gloss = false } } }
  for _, s in ipairs(stars) do
    parts[#parts + 1] = { s[1], c:ascii(s[4], s[2], s[3]), STAR, { cres = 2, gloss = false, contact = false } }
  end
  c:build(parts)
  -- coral twine wraps on the bar ends
  for _, x in ipairs({ 5, 6, 41, 42 }) do for y = 5, 7 do c:px(x, y, (y == 5) and CORAL.rim or CORAL.base) end end
  -- hanging strings from the top edge to the bar
  tline(c, T, 13, 0, 13, 4); tline(c, T, 34, 0, 34, 4)
  -- threads to the star tips, each with a teal bead
  for _, s in ipairs(stars) do tline(c, T, s[5], s[6], s[5], s[3] - 1) end
  for _, s in ipairs(stars) do
    local tx, by = s[5], math.floor((s[6] + s[3]) / 2) - 1
    if s[3] - s[6] >= 5 then c:px(tx, by, TEAL.rim); c:px(tx, by + 1, TEAL.shade) end
  end
  -- star glints
  for _, s in ipairs(stars) do c:px(s[2] + (#s[4][1] == 7 and 2 or 1), s[3] + 2, STAR.gloss) end
  save(c, "southern_cross_mobile", T)
end

-- ===== 4. Kiwi Plush (floor-left, 38x28) =====
do
  local c = GV.canvas{ w = 38, h = 28, mode = "sticker", ol = 1, olx = 1, margin = 0 }
  local KIWI = felt("#8a6440", { gloss = "#e8c48a", rim = "#b08a5a", shade = "#5e4028" })
  local BEAK = felt("#e9c48a", { gloss = "#fff1c8", rim = "#f5dca8", shade = "#c49a62", pale = false })
  local LEG  = felt("#d9a660", { rim = "#ecc58a", shade = "#a8582f" })
  local body = c:ellipse(22, 14.5, 12.5, 9.5):add(c:ellipse(10, 10.5, 5.5, 5)):closed(2)
  local beak = c:line({ { 5, 12 }, { 3, 15 }, { 2, 19 }, { 2, 23 } }, 2)
  local legL = c:rrect(15, 22, 17, 25, 0)
  local legR = c:rrect(23, 22, 25, 25, 0)
  local p = c:build{
    { "legL", legL:add(c:rect(13, 24, 17, 25)), LEG, { flat = true, contact = false } },
    { "legR", legR:add(c:rect(21, 24, 25, 25)), LEG, { flat = true, contact = false } },
    { "body", body, KIWI, { cres = 3, gloss = { 9, 7 }, stitch = { side = "lit" } } },
    { "beak", beak, BEAK, { flat = true } },
  }
  -- feather tufts: short shade dashes over the back
  for _, q in ipairs({ {20, 10}, {26, 12}, {30, 16}, {22, 15}, {16, 17}, {27, 19}, {13, 15} }) do
    c:paint({ "s.", ".s" }, q[1], q[2], { s = KIWI.shade })
  end
  c:seam({ { 17, 7 }, { 24, 6 }, { 30, 8 } }, { gap = KIWI.shade })     -- back seam
  -- coral bow at the neck
  c:paint({ "bb.bb", "bbkbb", "b...b" }, 12, 14, { b = CORAL.base, k = CORAL.shade })
  c:px(12, 14, CORAL.rim); c:px(15, 14, CORAL.rim)
  c:eye(7, 8, true)
  c:ground(20, 26, 12, 0.6)
  save(c, "kiwi_plush")
end

-- ===== 5. Seashell Lure (rod, 16x16) =====
do
  local c = GV.canvas{ w = 16, h = 16, mode = "sticker", ol = 1, olx = 0, margin = 0 }
  local T = {}
  -- scallop: a ribbed fan with a wavy top edge, hinge ears at the bottom; hung by a drilled hole at the top
  local SH = felt("#f49a7a", { gloss = "#fff1c8", rim = "#ffc8a0", shade = "#d0605a" })
  local rows = {
    "..xx.x.xx..",
    ".xxxxxxxxx.",
    "xxxxxxxxxxx",
    "xxxxxxxxxxx",
    "xxxxxxxxxxx",
    ".xxxxxxxxx.",
    "..xxxxxxx..",
    "...xxxxx...",
    ".xxxxxxxxx.",
  }
  local X0, Y0 = 2, 5
  local shell = c:ascii(rows, X0, Y0)
  c:build{
    { "shell", shell, SH, { cres = 2, gloss = false } },
    { "bead",  c:rect(7, 3, 8, 4), TEAL, { flat = true, contact = false } },
  }
  -- ribs: grooves radiating from the hinge (7.5, 13), shade on the grooves, deep on the lower right
  shell:each(function(x, y)
    if y >= Y0 + 8 then return end
    local a = math.atan(x - 7, 13.5 - y)
    local f = (a / 0.30 + 0.5) % 1
    if f < 0.28 and y >= Y0 + 1 then
      c:px(x, y, ((x - 7) + (y - 9) > 3) and C.ol1 or SH.shade)
    end
  end)
  for x = X0 + 1, X0 + 9 do if shell:has(x, Y0 + 8) then c:px(x, Y0 + 8, (x < 6) and SH.rim or SH.shade) end end
  c:px(7, 5, C.hole)                                       -- drilled hole the thread runs through
  c:px(4, 7, SH.gloss); c:px(5, 6, SH.gloss); c:px(4, 8, SH.gloss)
  tline(c, T, 7, 0, 7, 2)
  save(c, "seashell_lure", T)
end

assert(#FAILS == 0, "check failed: " .. table.concat(FAILS, " "))
