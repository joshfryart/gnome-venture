-- art22/shops/CB-items.lua : Cat Fish pet shop CB "Driftwood & Whisker" (Sunsprinkle Isles, Caribbean), 5 item sprites.
-- Run: AppRun -b --script CB-items.lua     Writes art22/out/cf-pet-<slug>.png + .aseprite
-- Spec: claude/catfish-shops-art-spec.md (slot sizes), claude/plan-catfish-petshops.md section 2/3 (what/where).
--   conch_shell        shelf        20x24  pink queen conch resting on a little sea-turquoise felt cushion
--   hammock_net        floor-left   38x28  striped island hammock slung between two driftwood posts, rope net fringe
--   flying_fish_charm  rod          16x16  blue flying fish with sunny wing fins, hangs on its own string + gold knot
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
-- Queen conch: knobbed spire pointing up-left, flared pink lip wing at the upper right, the glossy aperture slit
-- between them, resting on a small sea-turquoise felt cushion (flat bottom on the shelf).
do
  local W, H = 20, 24
  local c = canvas(W, H)
  local SHELL = felt("#f3c08c", { gloss = "#fff3c8", rim = "#ffdcae", shade = "#d49468", deep = "#d49468" })
  local LIP   = felt("#ef7f96", { gloss = "#ffd2dc", rim = "#f8a8b8" })
  local G = {
    ".o..............",
    ".oo.........pp..",
    "oooo.......ppp..",
    "ooooo.o...pppp..",
    ".ooooooo.ooppppp",
    ".ooooooooopppppp",
    "oooooooooopppppp",
    "ooooooooooppppp.",
    ".oooooooooopppp.",
    "..ooooooooopppp.",
    "...oooooooopppp.",
    "....ooooooopp...",
    ".....ooooooop...",
    "......ooooo.....",
    ".......ooo......",
  }
  local shell = c:ascii(G, 2, 2)                    -- one felt body: exterior + lip, no inner contour
  local lip = c:ascii(G, 2, 2, "p")
  local cushion = c:rrect(2, 16, 16, 20, 2)
  c:build{
    { "cushion", cushion, TURQ, { gloss = false } },
    { "shell", shell, SHELL, { gloss = { 4, 5 } } },
  }
  retint(c, lip, SHELL, LIP)
  c:paint({ "gg", "g." }, 13, 6, { g = LIP.gloss })
  -- two spire whorl steps, two bean markings
  c:paint({ "...s", "..s.", "ss.." }, 2, 5, { s = SHELL.shade })                -- shoulder whorl step
  c:paint({ "mm" }, 7, 12, { m = "#c98a5a" })
  c:paint({ "m", "m" }, 10, 10, { m = "#c98a5a" })
  -- aperture: the deep glossy slit just inside the lip
  c:paint({ "a", "a", "a", ".a", ".a", ".a", ".a" }, 12, 7, { a = "#b8385a" })
  c:seam({ { 4, 19 }, { 15, 19 } }, { gap = TURQ.shade })                        -- cushion hem
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
-- Blue felt flying fish, its big sun-yellow wing fin raised like a sail, a forked tail, a silver belly panel;
-- hanging from its own short string with a gold knot (top of the sprite at x 6, y 0: tie the rod string there).
-- Outline 1 px with no lower-right extra here: at 16 px the extra ate the fish.
do
  local W, H = 16, 16
  local c = GV.canvas{ w = W, h = H, mode = "sticker", ol = 1, olx = 0, cres = 2, deep = 1 }
  local BLUE = felt("#3a7ccc", { gloss = "#c8ecff", rim = "#7ab4ee" })
  local G = {
    ".......www..",
    "......wwww..",
    "......wwwww.",
    ".......wwww.",
    "..bbbbbbbww.",
    ".bbbbbbbbb..",
    "bbbbbbbbbb.t",
    "bbbbbbbbbbtt",
    "bbbbbbbbbbbt",
    "bbbbbbbbbbtt",
    ".bbbbbbbb..t",
  }
  local wing = c:ascii(G, 2, 2, "w")
  local tail = c:ascii(G, 2, 2, "t")
  local body = c:ascii(G, 2, 2, "b")
  c:build{
    { "tail", tail, SUN, { flat = true } },
    { "wing", wing, SUN, { flat = true } },
    { "body", body, BLUE, { gloss = false } },
  }
  c:paint({ "r.", ".r", "..r" }, 9, 3, { r = SUN.shade })                       -- wing ribs
  c:paint({ "cccccc", ".cccc." }, 5, 11, { c = "#d8e8f0" })                     -- silver belly panel
  c:paint({ "gg", "g" }, 7, 7, { g = BLUE.gloss })                               -- gloss comma
  c:eye(3, 7, true)
  for y = 0, 5 do c:px(6, y, "#4a2c1a") end                                       -- the string it hangs on
  c:px(6, 6, GV.C.gold)                                                           -- gold knot on its back
  save(c, "flying_fish_charm", W, H)
end

-- ===== steel_pan_chime (ceiling, 48x34) =====
-- Silver steel pan (dimpled note face), coral skirt with a turquoise band and gold seam, hung on two threads
-- from the top edge; three chime drops of different lengths under it: coral shell, sea-glass bead, sun shell.
do
  local W, H = 48, 34
  local c = canvas(W, H)
  local STEEL = felt("#b9bfcc", { gloss = "#fff3c8", rim = "#dfe4ec", shade = "#8a8ea8" })
  local skirt = c:rect(10, 10, 37, 15):add(c:ellipse(23.5, 15, 13.5, 2.5))
  local face = c:ellipse(23.5, 10, 14, 4.5)
  local function shell(cx, cy) -- little scallop: fan with a hinge nub
    return c:ellipse(cx, cy, 2.5, 2):clip(c:rect(0, cy - 2, 47, cy + 1)):add(c:rect(cx - 0.5, cy + 1, cx + 0.5, cy + 2))
  end
  local shL = shell(14.5, 26)
  local shR = shell(33.5, 23)
  local bead = c:ellipse(23.5, 22, 1.5, 2)
  c:build{
    { "skirt", skirt, CORAL, { gloss = false } },
    { "face", face, STEEL, { gloss = { 14, 8 } } },
    { "shL", shL, CORAL, { flat = true } },
    { "shR", shR, SUN, { flat = true } },
    { "bead", bead, TURQ, { flat = true } },
  }
  c:paint({
    ".....ss.ss.....",
    "..ss..sss..ss..",
    "....s.....s....",
  }, 16, 8, { s = STEEL.shade })                                                 -- note dimples
  retint(c, c:rect(10, 15, 37, 17):clip(skirt), CORAL, TURQ)                     -- turquoise band
  c:seam({ { 11, 14 }, { 36, 14 } }, { gap = CORAL.shade })
  c:paint({ "r.r", ".r." }, 13, 25, { r = CORAL.shade })                          -- shell ribs
  c:paint({ "r.r", ".r." }, 32, 22, { r = SUN.shade })
  local T = "#4a2c1a"
  for y = 0, 5 do c:px(12, y, T); c:px(35, y, T) end                             -- hanging threads
  for y = 19, 23 do c:px(14, y, T) end
  for y = 19, 19 do c:px(23, y, T) end
  for y = 19, 20 do c:px(33, y, T) end
  save(c, "steel_pan_chime", W, H)
end

-- ===== parrot_perch (sill, 30x26) =====
-- Island parrot plush (green felt, blue face, red throat, turquoise tail) on a driftwood T-perch with a
-- coconut cup of mango at the bar's end; the stand's foot is flat on the sill.
do
  local W, H = 30, 26
  local c = canvas(W, H)
  local FACE = "#3f86d8"
  local WING = felt("#3a9440", { gloss = "#c8e88a", rim = "#5cb84a" })
  local BEAK = felt("#e9d6a8", { gloss = "#fff3c8", rim = "#f5e6c0" })
  local NUT  = felt("#8a5a36", { gloss = "#ecc58a", rim = "#b07a45" })
  local base = c:rrect(9, 21, 18, 22, 1)
  local post = c:rect(13, 18, 14, 21)
  local tail = c:poly({ { 8, 12 }, { 12, 14 }, { 9, 21 }, { 6, 20 } })
  local bird = c:ellipse(12, 11, 5, 5):add(c:ellipse(15.5, 6.5, 4, 4)):closed(1)
  local wing = c:ellipse(10.5, 12, 2.5, 3.5)
  local beak = c:ascii({ "bb.", "bbb", ".bb", "..b" }, 19, 5)
  local bar  = c:rect(4, 16, 25, 17)
  local cup  = c:ellipse(22.5, 13, 3, 2):clip(c:rect(19, 13, 26, 15))
  c:build{
    { "base", base, DRIFT, { gloss = false } },
    { "post", post, DRIFT, { flat = true } },
    { "tail", tail, TURQ, { gloss = false } },
    { "bird", bird, PALM, { gloss = { 13, 4 } } },
    { "wing", wing, WING, { gloss = false } },
    { "beak", beak, BEAK, { flat = true } },
    { "bar", bar, DRIFT, { flat = true } },
    { "cup", cup, NUT, { flat = true } },
  }
  c:paint({ "..ff", ".fff", "ffff", ".ff." }, 16, 5, { f = FACE })               -- blue face
  c:paint({ ".rr", "rrr" }, 15, 10, { r = "#dd3a2a" })                            -- red throat
  c:seam({ { 9, 10 }, { 9, 14 } }, { gap = WING.shade })                         -- wing seam
  c:eye(16, 5, true)
  c:paint({ "ff.ff" }, 11, 15, { f = "#7b66b4" })                                 -- toes over the bar
  c:paint({ ".yy.", "yyyy" }, 21, 11, { y = SUN.base })                           -- mango in the cup
  c:px(21, 11, SUN.gloss)
  save(c, "parrot_perch", W, H)
end

if #FAILS > 0 then print("FAIL: " .. table.concat(FAILS, ", ")) else print("all OK") end
