-- cf_test.lua : Cat Fish test art: plain plushie fish, cat wand rod, kibble + yarn icons (props only).
-- Run: AppRun -b --script cf_test.lua      (Stitched Toy, art-style-guide Part D, via gvlib)
-- The grey cat key frames (idleA, pounce, catch, nap, stalk) that used to live here moved to cf_cats.lua
-- (polish pass 7); this file draws the props only and its outputs are unchanged by the move.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"

-- recolour pixels of `from` inside mask m to `to` (keeps the crescent and contours intact)
local function tint(c, m, from, to)
  m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end)
end

-- ===== props: felt ramps shaded like the cat coat (pass 5) =====
-- felt(hex): gvlib ramp with deep = shade and bounce = base, so a prop has the same 4 felt steps as the cat
-- (rim, base, one crescent shade, gloss comma) instead of the full 7-step enamel ramp.
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end

-- ===== plain plushie fish (48x48 sticker) =====
-- Pass 5: sewn from felt panels like the cat: a light belly panel and a tail panel, each joined by a gold seam
-- (shade gaps so the dashes read on orange), a gold button at the head of the tail-panel seam, a gill seam,
-- one stitched rib on the fin and two on the tail, and the hand-drawn enamel gloss comma. Felt ramps only.
do
  local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
  local f = felt("#dc6f2c", { gloss = "#ffc27a", dot = "#fff1c8" }) -- redder than thread gold so seams show
  local fin = felt("#f2c14e", { gloss = "#fff1c8" })
  local body = c:ellipse(20, 24, 13, 9)
  local tail = c:poly({ {29, 24}, {39, 14}, {41, 19}, {38, 24}, {41, 29}, {39, 34} })
  local finM = c:poly({ {13, 18}, {17, 11}, {24, 11}, {28, 18} })
  local p = c:build{
    { "tail", tail, fin, { cres = 2, gloss = false } },
    { "fin",  finM, fin, { cres = 2, gloss = false } },
    { "body", body, f, { gloss = false } },
  }
  tint(c, c:ellipse(19, 31, 9, 3):clip(body), f.base, "#f2a860")                       -- belly panel
  c:seam({ { 10, 28 }, { 14, 31 }, { 20, 32 }, { 25, 31 } }, { gap = f.shade })        -- belly panel seam
  c:paint({ "s..", ".s.", ".s." }, 19, 13, { s = fin.shade })                           -- fin rib
  c:paint({ "ss...", "..ss." }, 35, 18, { s = fin.shade })                              -- tail ribs
  c:paint({ "..ss.", "ss..." }, 35, 28, { s = fin.shade })
  c:seam({ { 13, 17 }, { 15, 20 }, { 15, 24 }, { 14, 28 } }, { gap = f.shade })        -- gill seam
  c:seam({ { 29, 22 }, { 29, 27 }, { 27, 30 } }, { gap = f.shade })                     -- tail panel seam
  c:button(27, 18)                                                                       -- at its head
  c:paint({
    "...ggddd",
    "..gddd..",
    ".gdd....",
    "gdd...d.",
    "gd......",
  }, 17, 17, { g = f.gloss, d = f.dot })
  c:eye(8, 19)
  c:paint({ "uu", "u." }, 8, 27, { u = "ol2" })                                          -- mouth
  local t = c:save(OUT .. "cf-fish-1.aseprite", OUT .. "cf-fish-1.png")
  print("fish   " .. GV.report(t))
end

-- ===== cat wand rod (48x64 sticker). String is drawn in code from the tip bead. =====
-- Axis runs (35,11) -> (15,51), slope 1:2. Tip bead with its thread hole at (35,9): attach the string there.
-- Pass 5: the busy red collar + hem is now one plain gold ferrule, the square eye-loop is a round gold bead,
-- the bow is two clean felt loops on a knot, the grip is red felt wound in a spiral, yarn pompom on the butt.
do
  local c = GV.canvas{ w = 48, h = 64, mode = "sticker" }
  local ax, ay = -1 / math.sqrt(5), 2 / math.sqrt(5)   -- unit vector down the axis
  local nx, ny = 2 / math.sqrt(5), 1 / math.sqrt(5)    -- unit normal (points right/down = shade side)
  local GX, GY = 23, 34                                  -- grip start on the axis
  local function at(t, v) return GX + ax * t + nx * v, GY + ay * t + ny * v end
  local function band(t0, t1, w0, w1) -- tapered band along the axis: t0..t1, half widths w0..w1
    local a1, a2 = at(t0, -w0); local b1, b2 = at(t0, w0); local c1, c2 = at(t1, w1); local d1, d2 = at(t1, -w1)
    return c:poly({ { a1, a2 }, { b1, b2 }, { c1, c2 }, { d1, d2 } })
  end
  local RED, BLUE = felt("#dd3a2a", { gloss = "#ff9158", rim = "#f2793a" }), felt("#3f8fb0", { gloss = "#c8ecdc", rim = "#8fcbd8" })
  local bead   = c:ellipse(35, 9, 3)
  local stick  = c:line({ { 34, 13 }, { 22, 37 } }, 3)
  local bx, by = at(13.5, 0)
  local grip   = band(2, 13.5, 2.6, 3.6):add(c:ellipse(bx, by, 3.5)):closed(1)
  local collar = band(-1.5, 2, 3.2, 3.2):closed(1)
  local px, py = at(19.5, 0)
  local pom    = c:ellipse(px, py, 3.5)
  local bowL   = c:poly({ {31, 19}, {25, 15}, {25, 21} }):grow(1)
  local bowR   = c:poly({ {33, 20}, {39, 18}, {37, 24} }):grow(1)
  local p = c:build{
    { "stick", stick, "wood", { cres = 1, deep = 0, bounce = false, gloss = false } },
    { "bead",  bead, "gold", { cres = 1, deep = 0, bounce = false, gloss = false } },
    { "bowL",  bowL, BLUE, { cres = 2, gloss = false } },
    { "bowR",  bowR, BLUE, { cres = 2, gloss = false } },
    { "knot",  c:rrect(31, 18, 34, 21, 1), BLUE, { flat = true } },
    { "grip",  grip, RED, { cres = 2, gloss = { 17, 38 } } },              -- enamel comma like the cat (pass 6)
    { "collar", collar, "gold", { cres = 1, deep = 0, bounce = false, gloss = false } },
    { "pom",   pom, BLUE, { cres = 2, gloss = false } },
  }
  c:px(35, 9, GV.C.hole); c:px(33, 7, GV.R.gold.gloss); c:px(34, 7, GV.R.gold.gloss)                              -- bead thread hole + glint
  -- spiral wrap: the grip slants 1:2, so level rows cross it on a spiral. Each turn is a 1 px shade
  -- under-edge row with a 1 px lit ridge row above it (lit felt only).
  local inner = grip:copy():cut(collar:grow(1)):cut(pom:grow(1)):shrink(1)
  for _, y in ipairs({ 40, 44, 48 }) do
    for x = 0, 47 do
      local k = c:key(x, y)
      if inner:has(x, y) and c.own[k] == p.grip and not c.shd[k] and not c.gl.s[k] then c:px(x, y, RED.shade) end
      local k2 = c:key(x, y - 1)
      if inner:has(x, y - 1) and c.own[k2] == p.grip and not c.shd[k2] and not c.gl.s[k2] then c:px(x, y - 1, RED.rim) end
    end
  end
  c:gloss(pom, BLUE, { 12, 50 })
  c:paint({ "s.", ".s" }, 13, 51, { s = BLUE.shade })                                     -- yarn tufts on the pompom
  local t = c:save(OUT .. "cf-rod.aseprite", OUT .. "cf-rod.png")
  print("rod    " .. GV.report(t))
end

-- ===== kibble icon (32x32, icon mode): wide felt bowl heaped with round kibble =====
-- Pass 6: the bowl is wide and shallow with its lip sticking out past the heap on both sides, so the silhouette
-- is a bowl with a bumpy top instead of an egg. Five darker brown kibble, each its own part with an umber
-- contour, so they read as separate pieces; the bumps show in the outline. No paw print (it read as teeth).
do
  local c = GV.canvas{ w = 32, h = 32, mode = "icon" }
  local K = felt("#c47a36", { gloss = "#ffd79a", rim = "#e09a58" })
  local B = felt("#3f8fb0", { gloss = "#c8ecdc", rim = "#8fcbd8" })
  local bowl = c:ellipse(15.5, 18, 9, 2):add(c:poly({ {7, 18}, {25, 18}, {22, 25}, {10, 25} })):closed(1)
  local list = {}
  local pieces = { {15.5, 11.5}, {11, 15}, {20, 15}, {15.5, 15.5} }  -- back to front: one on top, three in front
  for i, q in ipairs(pieces) do
    list[#list + 1] = { "k" .. i, c:ellipse(q[1], q[2], 2.5, 2.5), K, { cres = 2, gloss = false, bounce = false } }
  end
  list[#list + 1] = { "bowl", bowl, B, { cres = 3, gloss = { 9, 20 } } }
  c:build(list)
  for _, q in ipairs(pieces) do                                          -- glaze dot + the kibble's hole
    c:px(math.floor(q[1]) - 1, math.floor(q[2]) - 1, K.gloss); c:px(math.floor(q[1]), math.floor(q[2]), K.shade)
  end
  c:seam({ { 9, 21 }, { 22, 21 } }, { gap = B.shade })                                     -- bowl hem
  local t = c:save(OUT .. "cf-ico-kibble.aseprite", OUT .. "cf-ico-kibble.png")
  print("kibble " .. GV.report(t))
end

-- ===== yarn ball icon (32x32, icon mode): wound felt yarn with a loose end trailing along the floor =====
-- Pass 6: the loose end leaves the ball's right side and snakes off along the floor (a hanging string read as a
-- balloon). Wraps are shade grooves with a lit ridge on their upper-left side (the rod grip's wrap language).
do
  local c = GV.canvas{ w = 32, h = 32, mode = "icon" }
  local Y = felt("#e46a9b")
  local ball = c:ellipse(14, 14, 8, 8)
  local thread = c:line({ { 20, 21 }, { 22, 23 }, { 24, 24 }, { 26, 23 }, { 26, 21 } }, 2) -- lies on the floor
  local p = c:build{
    { "thread", thread, Y, { flat = true, solid = false, contact = false } },
    { "ball", ball, Y, { cres = 3, gloss = { 10, 9 } } },
  }
  local inner = ball:shrink(1)
  local strands, ridge = c:mask(), c:mask()
  local function arcs(cx, cy, list)
    for _, r in ipairs(list) do
      strands:add(c:ellipse(cx, cy, r):cut(c:ellipse(cx, cy, r - 1)))
      ridge:add(c:ellipse(cx, cy, r - 1):cut(c:ellipse(cx, cy, r - 2)))
    end
  end
  arcs(27, 1, { 10, 14, 18, 22, 26 })                             -- wraps running lower-left to upper-right
  local cross = c:ellipse(1, 28, 19):cut(c:ellipse(1, 28, 11.5))  -- crossing band wound on top
  strands:cut(cross); ridge:cut(cross)
  arcs(1, 28, { 15, 19 })
  strands:clip(inner); ridge:clip(inner):cut(strands)
  ridge:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == p.ball and not c.gl.s[k] and not c.shd[k] then c:px(x, y, Y.rim) end
  end)
  strands:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == p.ball and not c.gl.s[k] then c:px(x, y, Y.shade) end
  end)
  local t = c:save(OUT .. "cf-ico-yarn.aseprite", OUT .. "cf-ico-yarn.png")
  print("yarn   " .. GV.report(t))
end
