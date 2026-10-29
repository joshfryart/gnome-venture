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
  c:paint({ "..o..", "ooooo", ".ooo.", ".o.o." }, 10, 15, { o = "#f08a24" })
  c:px(12, 15, "#ffc27a"); c:px(12, 17, "#e0501f")
  -- two air bubbles
  c:px(12, 12, glass.gloss); c:px(14, 13, glass.gloss)
  -- glass gloss stripe, upper left
  c:paint({ "g", "g", "g", ".", "g" }, 3, 9, { g = glass.gloss })
  -- twine round the neck + bow ends
  for x = 5, 13 do c:px(x, 7, (x % 2 == 0) and DRIFT.rim or DRIFT.shade) end   -- twisted twine at the neck
  c:paint({ "aa", "ab", ".b" }, 14, 7, { a = DRIFT.rim, b = DRIFT.shade })          -- knot and loose end
  c:seam({ { 4, 5 }, { 14, 5 } }, { gap = CORAL.base })                             -- hem of the felt cap
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
  -- felt sea picture (x 7..26, y 7..22): sky, a little sun, a curling wave with a cream crest, sea, sand
  c:paint({
    "kkkkkkkkkkkkkkkkkkkk",
    "kkkkkkkkkkkkkkkkyykk",
    "kkkkcccckkkkkkkyGyyk",
    "kkkcrrttckkkkkkyyyyk",
    "kkcrttddtckkkkkkyykk",
    "kcrtdkkdtdkkkkkkkkkk",
    "kcrtdkkkkkkkkkkkkkkk",
    "crttdkkkkcccckkkkccc",
    "ttttttdtttttttttdttt",
    "tttttttttttdddtttttt",
    "ttdddttttttttttttddt",
    "dddddddddddddddddddd",
    "ssssssssssssssssssss",
    "SSSSSSSSSSSSSSSSSSSS",
    "SSSSSSSSSSSSSSSSSSSS",
    "SSSSSSSSSSSSSSSSSSSS",
  }, 7, 7, { k = "#bfe4dc", c = "#f8f0dc", r = TEAL.rim, t = TEAL.base, d = TEAL.shade,
             y = STAR.base, G = STAR.gloss, s = SAND.rim, S = SAND.base })
  -- scallop shell on the sand
  c:paint({ ".ppp.", "prprp", "prprp", ".sss." }, 20, 19, { p = CORAL.rim, r = CORAL.shade, s = CORAL.base })
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
  local STAR9 = { "....x....", "...xxx...", "...xxx...", "xxxxxxxxx", ".xxxxxxx.", "..xxxxx..", "..xxxxx..",
                  ".xxx.xxx.", ".xx...xx." }
  local STAR7 = { "...x...", "..xxx..", "xxxxxxx", ".xxxxx.", "..xxx..", ".xx.xx.", ".x...x." }
  -- crux: Gacrux top, Acrux bottom, Mimosa left, Delta right, Epsilon small, lower right of centre
  -- {name, x, y, shape, thread x, thread top y}; Acrux hangs on a thread from under Gacrux (a chained mobile)
  local stars = {
    { "gac", 19, 10, STAR9, 23, 8 },
    { "mim", 3,  15, STAR9, 7, 8 },
    { "del", 36, 13, STAR9, 40, 8 },
    { "eps", 29, 22, STAR7, 32, 8 },
    { "acr", 19, 24, STAR9, 23, 17 },
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
  for _, s in ipairs(stars) do
    if #s[4][1] == 9 then c:px(s[2] + 3, s[3] + 3, STAR.gloss); c:px(s[2] + 4, s[3] + 2, STAR.gloss); c:px(s[2] + 2, s[3] + 4, STAR.gloss)
    else c:px(s[2] + 2, s[3] + 2, STAR.gloss) end
  end
  save(c, "southern_cross_mobile", T)
end

-- ===== 4. Kiwi Plush (floor-left, 38x28) =====
do
  local c = GV.canvas{ w = 38, h = 28, mode = "sticker", ol = 1, olx = 1, margin = 0 }
  local KIWI = felt("#8a6440", { gloss = "#e8c48a", rim = "#b08a5a", shade = "#5e4028" })
  local BEAK = felt("#e9c48a", { gloss = "#fff1c8", rim = "#f5dca8", shade = "#c49a62", pale = false })
  local LEG  = felt("#d9a660", { rim = "#ecc58a", shade = "#a8582f" })
  local body = c:ellipse(23, 14.5, 12, 9)
  local head = c:ellipse(10, 10, 5.5, 5)
  local beak = c:line({ { 5, 11 }, { 3, 14 }, { 2, 18 }, { 2, 22 } }, 2)
  local legL = c:rrect(15, 22, 17, 25, 0)
  local legR = c:rrect(23, 22, 25, 25, 0)
  local p = c:build{
    { "legL", legL:add(c:rect(13, 24, 17, 25)), LEG, { flat = true, contact = false } },
    { "legR", legR:add(c:rect(21, 24, 25, 25)), LEG, { flat = true, contact = false } },
    { "body", body, KIWI, { cres = 3, gloss = { 16, 8 }, stitch = { side = "lit" } } },
    { "head", head, KIWI, { cres = 2, gloss = false } },
    { "beak", beak, BEAK, { flat = true } },
  }
  -- feather tufts: short shade dashes over the back
  for _, q in ipairs({ {21, 11}, {27, 12}, {31, 16}, {24, 16}, {18, 18}, {28, 20}, {21, 21} }) do
    c:paint({ "s.", ".s" }, q[1], q[2], { s = KIWI.shade })
  end
  c:seam({ { 20, 7 }, { 26, 6 }, { 32, 9 } }, { gap = KIWI.shade })     -- back seam
  -- coral bow at the neck
  c:paint({ "bb.bb", "bbkbb", "b...b" }, 13, 14, { b = CORAL.base, k = CORAL.shade })
  c:px(13, 14, CORAL.rim); c:px(16, 14, CORAL.rim)
  c:px(8, 6, KIWI.gloss); c:px(9, 6, KIWI.gloss); c:px(7, 7, KIWI.gloss)
  c:eye(8, 8, true)
  c:ground(20, 26, 12, 0.6)
  save(c, "kiwi_plush")
end

-- ===== 5. Seashell Lure (rod, 16x16) =====
do
  local c = GV.canvas{ w = 16, h = 16, mode = "sticker", ol = 1, olx = 0, margin = 0 }
  local T = {}
  -- scallop charm hung from its drilled hinge: ears at the top, ribbed fan opening downward, bumpy rim
  local SH = felt("#f49a7a", { gloss = "#fff1c8", rim = "#ffc8a0", shade = "#d0605a" })
  local rows = {
    "..xxxxxxx..",
    "....xxx....",
    "...xxxxx...",
    "..xxxxxxx..",
    ".xxxxxxxxx.",
    "xxxxxxxxxxx",
    "xxxxxxxxxxx",
    "xxxxxxxxxxx",
    ".xx.xxx.xx.",
  }
  local X0, Y0 = 2, 5
  local shell = c:ascii(rows, X0, Y0)
  c:build{
    { "shell", shell, SH, { cres = 2, gloss = false } },
    { "bead",  c:rect(6, 3, 8, 4), TEAL, { flat = true, contact = false } },
  }
  -- hand-set rib tones (light upper left): two grooves converge on the hinge, deep grooves on the shaded side
  c:paint({
    "..RRRHBBS..",
    "....RBS....",
    "...RSBSB...",
    "..RBSBSBS..",
    ".RGSBBBSBS.",
    "RGBSBBBSBDS",
    "RBBSBBBSBDS",
    "BBBSBBBSSDD",
    ".BB.BBS.SD.",
  }, X0, Y0, { R = SH.rim, B = SH.base, S = SH.shade, D = C.ol1, G = SH.gloss, H = C.hole })
  tline(c, T, 7, 0, 7, 2)
  save(c, "seashell_lure", T)
end

assert(#FAILS == 0, "check failed: " .. table.concat(FAILS, " "))
