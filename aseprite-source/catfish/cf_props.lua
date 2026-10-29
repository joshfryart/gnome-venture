-- cf_props.lua : Cat Fish props, polish pass 7: plain plushie fish (cf-fish-1), cat wand rod, kibble + yarn icons.
-- Run: AppRun -b --script cf_props.lua      (Stitched Toy, art-style-guide Part D, via gvlib)
-- Moved out of cf_test.lua (which keeps the cat frames) so props and cat can be polished separately. These
-- sections supersede the prop sections still in cf_test.lua; run this script AFTER cf_test.lua.
-- Pass 7 (16 px read):
--   fish-1  gloss comma 2 px thick and longer (the 1 px comma vanished at 16 px)
--   rod     the slanted, stair-stepped gold collar is now a round gold bead ring (matches the tip bead, clean
--           outline), grip wraps kept
--   kibble  the heap is ONE felt part (a smooth 3-bump dome) instead of 4 separately outlined balls, so the
--           outline is a clean bowl + bumps; pieces are split by 1 px umber inner lines with a hole each
--   yarn    loose end is a 3 px felt strand (2 px vanished at 16 px) with a lit top and shade under-edge
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"

-- felt(hex): gvlib ramp with deep = shade and bounce = base, so a prop has the same 4 felt steps as the cat
-- (rim, base, one crescent shade, gloss comma) instead of the full 7-step enamel ramp.
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
local FAILS = {}
local function save(c, name)
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-14s ", name) .. GV.report(t))
  if not (t.semi == 0 and t.margin >= 3 and t.bw == 0) then FAILS[#FAILS + 1] = name end
  return t
end

-- ===== plain plushie fish (48x48 sticker) =====
-- Sewn from felt panels like the cat: a light belly panel and a tail panel, each joined by a gold seam (shade
-- gaps so the dashes read on orange), a gold button at the head of the tail-panel seam, a gill seam, one
-- stitched rib on the fin and two on the tail, and the hand-drawn enamel gloss comma (2 px thick, pass 7).
do
  local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
  local f = felt("#dc6f2c", { gloss = "#ffc27a", dot = "#fff1c8" }) -- redder than thread gold so seams show
  local fin = felt("#f2c14e", { gloss = "#fff1c8" })
  local body = c:ellipse(20, 24, 13, 9)
  local tail = c:poly({ {29, 24}, {39, 14}, {41, 19}, {38, 24}, {41, 29}, {39, 34} })
  local finM = c:poly({ {13, 18}, {17, 11}, {24, 11}, {28, 18} })
  c:build{
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
    "....gggdd",
    "..ggdddd.",
    ".gddd....",
    "gdd....d.",
    "gd.......",
  }, 17, 17, { g = f.gloss, d = f.dot })
  c:eye(8, 19)
  c:paint({ "uu", "u." }, 8, 27, { u = "ol2" })                                          -- mouth
  save(c, "cf-fish-1")
end

-- ===== cat wand rod (48x64 sticker). String is drawn in code from the tip bead. =====
-- Axis runs (35,11) -> (15,51), slope 1:2. Tip bead with its thread hole at (35,9): attach the string there.
-- Round gold tip bead, two clean felt bow loops on a knot, red felt grip wound in a spiral, a round gold bead
-- ring where the stick enters the grip (pass 7: was a slanted ferrule band that stair-stepped), yarn pompom.
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
  local grip   = band(2.5, 13.5, 2.6, 3.6):add(c:ellipse(bx, by, 3.5)):closed(1)
  local rx, ry = at(1, 0)
  local ring   = c:ellipse(math.floor(rx) + 0.5, math.floor(ry) + 0.5, 3, 3)
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
    { "grip",  grip, RED, { cres = 2, gloss = { 17, 39 } } },              -- enamel comma like the cat
    { "ring",  ring, "gold", { cres = 1, deep = 0, bounce = false, gloss = false } },
    { "pom",   pom, BLUE, { cres = 2, gloss = false } },
  }
  c:px(35, 9, GV.C.hole); c:px(33, 7, GV.R.gold.gloss); c:px(34, 7, GV.R.gold.gloss)                              -- bead thread hole + glint
  local rgx, rgy = math.floor(rx) - 1, math.floor(ry) - 1
  c:px(rgx, rgy, GV.R.gold.gloss); c:px(rgx + 1, rgy, GV.R.gold.gloss); c:px(rgx, rgy + 1, GV.R.gold.gloss)       -- ring glint
  -- spiral wrap: the grip slants 1:2, so level rows cross it on a spiral. Each turn is a 1 px shade
  -- under-edge row with a 1 px lit ridge row above it (lit felt only).
  local inner = grip:copy():cut(ring:grow(1)):cut(pom:grow(1)):shrink(1)
  for _, y in ipairs({ 41, 45, 49 }) do
    for x = 0, 47 do
      local k = c:key(x, y)
      if inner:has(x, y) and c.own[k] == p.grip and not c.shd[k] and not c.gl.s[k] then c:px(x, y, RED.shade) end
      local k2 = c:key(x, y - 1)
      if inner:has(x, y - 1) and c.own[k2] == p.grip and not c.shd[k2] and not c.gl.s[k2] then c:px(x, y - 1, RED.rim) end
    end
  end
  c:gloss(pom, BLUE, { 12, 50 })
  c:paint({ "s.", ".s" }, 13, 51, { s = BLUE.shade })                                     -- yarn tufts on the pompom
  save(c, "cf-rod")
end

-- ===== kibble icon (32x32, icon mode): wide felt bowl heaped with round kibble =====
-- The bowl is wide and shallow with its lip sticking out past the heap on both sides. Pass 7: the heap is one
-- felt part shaped as three round bumps (clean outline, no outlined-ball clutter); the kibble are told apart
-- by 1 px umber split lines and a glaze dot on each (no holes: dot + hole read as a face).
do
  local c = GV.canvas{ w = 32, h = 32, mode = "icon" }
  local K = felt("#c47a36", { gloss = "#ffd79a", rim = "#e09a58" })
  local B = felt("#3f8fb0", { gloss = "#c8ecdc", rim = "#8fcbd8" })
  local bowl = c:ellipse(15.5, 18, 9, 2):add(c:poly({ {7, 18}, {25, 18}, {22, 25}, {10, 25} })):closed(1)
  local pieces = { {15.5, 10.5}, {10.5, 14.5}, {20.5, 14.5} }   -- top, left, right: bumps show in the outline
  local heap = c:ellipse(15.5, 15, 2.5, 2)
  for _, q in ipairs(pieces) do heap:add(c:ellipse(q[1], q[2], 3.5, 3.5)) end
  c:build{
    { "heap", heap, K, { cres = 2, gloss = false, bounce = false } },
    { "bowl", bowl, B, { cres = 3, gloss = { 9, 20 } } },
  }
  -- split lines: a heap pixel whose right or lower neighbour is nearer another piece's centre gets the
  -- umber inner-contour tone (only on heap felt, never on the bowl)
  local felt_ = { [K.base] = true, [K.rim] = true, [K.shade] = true }
  local function near(x, y)
    local best, bd = 0, 1e9
    for i, q in ipairs(pieces) do local d = (x - q[1]) ^ 2 + (y - q[2]) ^ 2; if d < bd then best, bd = i, d end end
    return best
  end
  heap:each(function(x, y)
    if felt_[c:get(x, y) or ""] then
      local n = near(x, y)
      if (heap:has(x + 1, y) and near(x + 1, y) ~= n) or (heap:has(x, y + 1) and near(x, y + 1) ~= n) then
        c:px(x, y, "#4a2c1a")
      end
    end
  end)
  for _, q in ipairs(pieces) do                                          -- glaze dot on each kibble
    local x, y = math.floor(q[1]) - 1, math.floor(q[2]) - 1
    c:px(x, y, K.gloss); c:px(x + 1, y, K.gloss); c:px(x, y + 1, K.gloss)
  end
  c:seam({ { 9, 21 }, { 22, 21 } }, { gap = B.shade })                                     -- bowl hem
  save(c, "cf-ico-kibble")
end

-- ===== yarn ball icon (32x32, icon mode): wound felt yarn with a loose end trailing along the floor =====
-- The loose end leaves the ball's right side and snakes off along the floor. Wraps are shade grooves with a
-- lit ridge on their upper-left side (the rod grip's wrap language). Pass 7: the strand is 3 px (lit top row,
-- base, shade under-edge) so it survives 16 px.
do
  local c = GV.canvas{ w = 32, h = 32, mode = "icon" }
  local Y = felt("#e46a9b")
  local ball = c:ellipse(13.5, 13.5, 7.5, 7.5)
  local thread = c:line({ { 18, 19 }, { 19, 22 }, { 21, 23 }, { 23, 23 } }, 3) -- trails off along the floor
  local p = c:build{
    { "thread", thread, Y, { cres = 1, deep = 0, bounce = false, gloss = false, contact = false } },
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
  arcs(26.5, 0.5, { 10, 14, 18, 22, 26 })                         -- wraps running lower-left to upper-right
  local cross = c:ellipse(0.5, 27.5, 18):cut(c:ellipse(0.5, 27.5, 11))  -- crossing band wound on top
  strands:cut(cross); ridge:cut(cross)
  arcs(0.5, 27.5, { 14, 18 })
  strands:clip(inner); ridge:clip(inner):cut(strands)
  ridge:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == p.ball and not c.gl.s[k] and not c.shd[k] then c:px(x, y, Y.rim) end
  end)
  strands:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == p.ball and not c.gl.s[k] then c:px(x, y, Y.shade) end
  end)
  save(c, "cf-ico-yarn")
end

assert(#FAILS == 0, "check failed: " .. table.concat(FAILS, " "))
