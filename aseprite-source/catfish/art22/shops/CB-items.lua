-- art22/shops/CB-items.lua : Cat Fish pet shop CB "Driftwood & Whisker" (Sunsprinkle Isles, Caribbean), 5 item sprites.
-- Run: AppRun -b --script CB-items.lua     Writes art22/out/cf-pet-<slug>.png + .aseprite
-- Spec: claude/catfish-shops-art-spec.md (slot sizes), claude/plan-catfish-petshops.md section 2/3 (what/where).
--   conch_shell        shelf        20x24  pink queen conch resting on a little sea-turquoise felt cushion
--   hammock_net        floor-left   38x28  striped island hammock slung between two driftwood posts, rope net fringe
--   flying_fish_charm  rod          16x16  blue flying fish with sunny wing fins, gold jump ring at the top (string)
--   steel_pan_chime    ceiling      48x34  silver steel pan with a coral skirt, hung on two threads from the top edge,
--                                         two pan sticks and a sea-glass bead dangling under it as chimes
--   parrot_perch       sill         30x26  green island parrot plush (blue face, red throat) on a driftwood T-perch
--                                         with a coconut cup
-- Regional look shared by all 5: the same felt ramps (sea turquoise, coral, sun yellow, driftwood, palm green),
-- gold thread seams, a turquoise accent on each piece. 1x sprites like the cats: 1 px three-tone umber outline
-- (+1 lower right), 1 px #000000 border. Flat-bottom items (shelf, sill, floor) end in a flat border row;
-- the ceiling chime and rod charm leave the top row open where their thread runs on.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"

-- felt ramp (as cf_props.lua): deep = shade, bounce = base, so items have the same 4 felt steps as the cat
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  if n.dot == "#ffffff" then n.dot = "#fff3c8" end
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end
-- recolour one ramp's tones to another ramp's on a mask (stripes, panels)
local function retint(c, m, from, to)
  local map = {}
  for _, k in ipairs({ "gloss", "dot", "rim", "base", "shade", "deep", "bounce" }) do
    if from[k] and to[k] and not map[from[k]] then map[from[k]] = to[k] end
  end
  m:each(function(x, y) local v = c:get(x, y) if v and map[v] then c:px(x, y, map[v]) end end)
end

-- shared island palette
local TURQ  = felt("#2fb2a6", { gloss = "#c8f0dc", rim = "#7fd8c4" })
local CORAL = felt("#ec6a4c", { gloss = "#ffc29a", rim = "#f79a72" })
local SUN   = felt("#f4bf3a", { gloss = "#fff1c8", rim = "#ffd970" })
local DRIFT = felt("#b0957a", { gloss = "#eedcc0", rim = "#d2b896" })
local PALM  = felt("#5bb04a", { gloss = "#d6ee9a", rim = "#94d06a" })
local ROPE  = "#e6cf9c"

local FAILS = {}
local function save(c, slug, W, H)
  local t = c:save(OUT .. "cf-pet-" .. slug .. ".aseprite", OUT .. "cf-pet-" .. slug .. ".png")
  print(string.format("%-20s ", slug) .. GV.report(t))
  if not (t.semi == 0 and t.bw == 0 and t.w == W and t.h == H) then FAILS[#FAILS + 1] = slug end
  return t
end
local function canvas(w, h) return GV.canvas{ w = w, h = h, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 1 } end

-- ===== conch_shell (shelf, 20x24) =====
do
  local W, H = 20, 24
  local c = canvas(W, H)
  local SHELL = felt("#f3c08c", { gloss = "#fff3c8", rim = "#ffdcae" })
  local LIP   = felt("#ef7f96", { gloss = "#ffd2dc", rim = "#f8a8b8" })
  local shell = c:ascii({
    "......oo.......",
    ".....oooo......",
    "...oooooooo....",
    "..ooooooooooo..",
    ".oooooooooooooo",
    "ooooooooooooooo",
    "ooooooooooooooo",
    ".oooooooooooooo",
    ".ooooooooooooo.",
    "..oooooooooooo.",
    "..ooooooooooo..",
    "...oooooooooo..",
    "....oooooooo...",
    ".....ooooo.....",
    "......ooo......",
  }, 2, 2)
  local lip = c:ascii({
    ".........pp....",
    "........pppp...",
    ".......pppppp..",
    ".......ppppppp.",
    "......pppppppp.",
    "......pppppppp.",
    ".......pppppp..",
    "........ppppp..",
    "........pppp...",
    ".........pp....",
  }, 2, 6)
  local cushion = c:rrect(2, 16, 16, 20, 2)
  c:build{
    { "cushion", cushion, TURQ, { gloss = false } },
    { "shell", shell, SHELL, { gloss = { 5, 5 } } },
    { "lip", lip, LIP, { gloss = { 11, 8 } } },
  }
  -- spire whorls (shade grooves) and two bean markings on the shell
  c:paint({ ".....ss", "...ss..", "", "......s", "..sss.." }, 3, 5, { s = SHELL.shade })
  c:paint({ "m.", "mm" }, 4, 11, { m = "#c98a5a" })
  c:paint({ "mm" }, 7, 13, { m = "#c98a5a" })
  -- aperture: the deep glossy slit inside the lip
  c:paint({ "a", "aa", ".a", ".a" }, 11, 9, { a = "#a8324f" })
  c:seam({ { 4, 18 }, { 15, 18 } }, { gap = TURQ.shade })                        -- cushion hem
  save(c, "conch_shell", W, H)
end

-- ===== hammock_net (floor-left, 38x28) =====
do
  local W, H = 38, 28
  local c = canvas(W, H)
  local postL = c:rrect(2, 3, 4, 24, 1)
  local postR = c:rrect(31, 3, 33, 24, 1)
  local cloth = c:ellipse(17.5, 8, 11, 10):cut(c:ellipse(17.5, 2, 13, 9)):clip(c:rect(7, 0, 28, 27))
  local p = c:build{
    { "postL", postL, DRIFT, { gloss = false } },
    { "postR", postR, DRIFT, { gloss = false } },
    { "cloth", cloth, TURQ, { gloss = false } },
  }
  -- lengthwise stripes: turquoise / sun / coral bands across the hammock
  for x = 7, 28 do
    local b = math.floor((x - 7) / 3) % 3
    if b == 1 then retint(c, c:rect(x, 0, x, 27):clip(cloth), TURQ, SUN)
    elseif b == 2 then retint(c, c:rect(x, 0, x, 27):clip(cloth), TURQ, CORAL) end
  end
  -- ropes from the post tops to the hammock ends, and the net fringe under it
  local function rope(pts) c:seam(pts, { on = 1, off = 0, free = true }) end
  for _, q in ipairs({ { { 5, 4 }, { 8, 11 } }, { { 30, 4 }, { 27, 11 } } }) do
    local a, b = q[1], q[2]
    local s = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2]))
    for t = 0, s do c:px(math.floor(a[1] + (b[1] - a[1]) * t / s + 0.5), math.floor(a[2] + (b[2] - a[2]) * t / s + 0.5), ROPE) end
  end
  for x = 10, 26, 2 do
    local y0 = 0
    for y = 27, 0, -1 do if cloth:has(x, y) then y0 = y break end end
    c:px(x, y0 + 1, ROPE); c:px(x, y0 + 2, ROPE)
  end
  c:seam({ { 8, 12 }, { 12, 15 }, { 17, 16 }, { 23, 15 }, { 27, 12 } })        -- hem stitch along the top edge
  c:px(3, 4, DRIFT.gloss); c:px(32, 4, DRIFT.gloss)
  save(c, "hammock_net", W, H)
end

-- ===== flying_fish_charm (rod, 16x16) =====
do
  local W, H = 16, 16
  local c = canvas(W, H)
  local BLUE = felt("#3a7ccc", { gloss = "#c8ecff", rim = "#7ab4ee" })
  local ring = c:ellipse(7.5, 2, 1.5, 1.5)
  local wing = c:poly({ { 4, 8 }, { 8, 6 }, { 13, 3 }, { 11, 8 } })
  local body = c:ellipse(6.5, 9.5, 4.5, 2.5)
  local tail = c:poly({ { 10, 9 }, { 14, 6 }, { 13, 10 }, { 14, 13 } })
  c:build{
    { "ring", ring, "gold", { flat = true } },
    { "tail", tail, SUN, { flat = true } },
    { "wing", wing, SUN, { flat = true } },
    { "body", body, BLUE, { gloss = false } },
  }
  c:px(7, 2, GV.C.hole); c:px(8, 2, GV.C.hole)
  c:px(4, 8, BLUE.gloss); c:px(5, 8, BLUE.gloss)
  c:paint({ "ccccc" }, 4, 11, { c = "#d8e8f0" })                                 -- silver belly
  c:eye(2, 8, true)
  save(c, "flying_fish_charm", W, H)
end

-- ===== steel_pan_chime (ceiling, 48x34) =====
do
  local W, H = 48, 34
  local c = canvas(W, H)
  local STEEL = felt("#b9bfcc", { gloss = "#fff3c8", rim = "#dfe4ec", shade = "#8a8ea8" })
  local skirt = c:rect(11, 12, 36, 18):add(c:ellipse(23.5, 18, 12.5, 3))
  local face = c:ellipse(23.5, 11, 13, 4)
  local stickL = c:rect(15, 25, 16, 28)
  local stickR = c:rect(31, 25, 32, 28)
  local tipL = c:ellipse(15.5, 30, 2, 1.5)
  local tipR = c:ellipse(31.5, 30, 2, 1.5)
  local bead = c:ellipse(23.5, 26, 2, 2)
  c:build{
    { "skirt", skirt, CORAL, { gloss = false } },
    { "face", face, STEEL, { gloss = { 14, 9 } } },
    { "stickL", stickL, DRIFT, { flat = true } },
    { "stickR", stickR, DRIFT, { flat = true } },
    { "tipL", tipL, CORAL, { flat = true } },
    { "tipR", tipR, CORAL, { flat = true } },
    { "bead", bead, TURQ, { gloss = false } },
  }
  -- note dimples on the playing face
  c:paint({
    "....ss.ss....",
    "..s..sss..s..",
    "...s.....s...",
  }, 17, 9, { s = STEEL.shade })
  -- turquoise band round the skirt with a gold seam
  retint(c, c:rect(11, 17, 36, 18):clip(skirt), CORAL, TURQ)
  c:seam({ { 12, 16 }, { 35, 16 } }, { gap = CORAL.shade })
  -- threads: two from the top edge to the rim, three drops under the pan
  for y = 0, 7 do c:px(13, y, "#4a2c1a"); c:px(34, y, "#4a2c1a") end
  for y = 22, 24 do c:px(15, y, "#4a2c1a"); c:px(32, y, "#4a2c1a") end
  for y = 22, 23 do c:px(23, y, "#4a2c1a") end
  save(c, "steel_pan_chime", W, H)
end

-- ===== parrot_perch (sill, 30x26) =====
do
  local W, H = 30, 26
  local c = canvas(W, H)
  local HEAD = felt("#3f86d8", { gloss = "#c8ecff", rim = "#7ab8f0" })
  local BEAK = felt("#e9d6a8", { gloss = "#fff3c8", rim = "#f5e6c0" })
  local NUT  = felt("#8a5a36", { gloss = "#ecc58a", rim = "#b07a45" })
  local base = c:rrect(8, 20, 19, 22, 1)
  local post = c:rect(12, 15, 14, 20)
  local tail = c:poly({ { 8, 11 }, { 13, 12 }, { 9, 21 }, { 5, 19 } })
  local body = c:ellipse(11.5, 9.5, 4.5, 5)
  local head = c:ellipse(15, 5.5, 3.5, 3.5)
  local beak = c:ascii({ "bb.", "bbb", "bbb", ".b." }, 18, 4)
  local bar  = c:rrect(3, 14, 25, 15, 0)
  local cup  = c:ellipse(22.5, 12, 3, 2):clip(c:rect(19, 12, 26, 14))
  c:build{
    { "base", base, DRIFT, { gloss = false } },
    { "post", post, DRIFT, { flat = true } },
    { "tail", tail, TURQ, { gloss = false } },
    { "body", body, PALM, { gloss = { 9, 6 } } },
    { "head", head, HEAD, { gloss = { 13, 3 } } },
    { "beak", beak, BEAK, { flat = true } },
    { "bar", bar, DRIFT, { flat = true } },
    { "cup", cup, NUT, { flat = true } },
  }
  c:paint({ "rr", "rrr" }, 15, 9, { r = "#dd3a2a" })                             -- red throat
  c:paint({ "w.", "ww", ".w" }, 12, 9, { w = "#2f8a3e" })                        -- wing edge
  c:paint({ "y" }, 13, 12, { y = SUN.base })
  c:eye(14, 4, true)
  c:paint({ "ff.ff" }, 10, 13, { f = "#7b66b4" })                                 -- toes on the bar
  c:paint({ "yyy" }, 21, 11, { y = SUN.base })                                    -- mango in the cup
  c:seam({ { 9, 21 }, { 18, 21 } }, { gap = DRIFT.shade })
  save(c, "parrot_perch", W, H)
end

if #FAILS > 0 then print("FAIL: " .. table.concat(FAILS, ", ")) else print("all OK") end
