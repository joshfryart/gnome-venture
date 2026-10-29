-- cf_icons.lua : Cat Fish step 5a (claude/catfish-art-brief.md): the 16 upgrade icons, 64x64, gvlib "icon" mode,
-- Stitched Toy (art-style-guide Part D: chunky parts >= 3 px, 1 px #000000 border last, margin >= 3, 16 px read).
-- Run: AppRun -b --script cf_icons.lua        Writes test/cf-up-<key>.png + .aseprite.
-- House look from cf_test.lua / cf_fish2.lua: felt ramps (rim, base, one crescent shade, gloss comma), gold
-- thread seams (2 on / 1 off), locked eyes, umber contours. Each icon is its own silhouette and main colour;
-- the branch shows as a shared accent:
--   fish (orange/rose): fish = orange plushie fish (cf-fish-1 look), silk = pale silk bow with rose knot,
--                       catnip = green catnip sprig with a rose flower spike, glitter = crimson sequin fish
--                       facing right with a gold 4-point sparkle
--   rod (blue/violet):  string = spool wound with blue string and a curling loose end, spring = violet coil
--                       spring on a red grip, motor = steel gear reel with a red button and a rod, double =
--                       two crossed wands tied with a blue bow
--   room (yellow/green): sunbeam = sun, rays and a window-shaped light patch on a floor, rug = round green rug with a stitched
--                       border and fringe, scratch = sisal post on a green base, window = green frame, sky
--                       panes, bird outside
--   cat (brown/pink):   bowl = pink pedestal bowl with a gold fish on the rim and kibble, toybox = open wooden
--                       box with a yarn ball and fish tail, cattree = two pink platforms on brown posts,
--                       catflap = mauve door with a cat-head flap
-- Pass 2 (32/16 px review): glitter is one round scale patch (three round sequins read as cherries), spring is
-- a helix of light front / dark back strands with gaps over the stick (it read as a solid barrel), sunbeam patch
-- is bigger, felt() keeps one shade (deep followed the un-overridden shade and cost a colour).
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"
local C = GV.C

-- felt(hex): gvlib ramp with deep = shade and bounce = base (4 felt steps + gloss, like the cat props)
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base -- after overrides (one shade only)
  return n
end
local function tint(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end) end
local function set(...) local s = {} for _, v in ipairs({ ... }) do s[v] = true end return s end
-- paint 1 px polyline with hex where the pixel is one of `on` (skip(n) can break it)
local function trace(c, pts, hex, on, skip)
  local seen, n = {}, 0
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local s = math.max(1, math.ceil(math.max(math.abs(x1 - x0), math.abs(y1 - y0))))
    for t = 0, s do
      local x, y = math.floor(x0 + (x1 - x0) * t / s + 0.5), math.floor(y0 + (y1 - y0) * t / s + 0.5)
      local k = y * 100 + x
      if not seen[k] then
        seen[k] = true; n = n + 1
        if (on == nil or on[c:get(x, y) or ""]) and not (skip and skip(n)) then c:px(x, y, hex) end
      end
    end
  end
end
-- rotated ellipse mask, angle a in radians (screen coords, y down)
local function rell(c, cx, cy, rx, ry, a)
  local m, ca, sa, R = c:mask(), math.cos(a), math.sin(a), math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do
    for x = math.floor(cx - R), math.ceil(cx + R) do
      local dx, dy = x - cx, y - cy
      local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
      if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
    end
  end
  return m
end
-- 4-point star: long arms R, waist r, rotated by a
local function star(c, cx, cy, R, r, a)
  local pts = {}
  for i = 0, 7 do
    local ang = (a or 0) + i * math.pi / 4 - math.pi / 2
    local d = (i % 2 == 0) and R or r
    pts[#pts + 1] = { cx + 0.5 + math.cos(ang) * d, cy + 0.5 + math.sin(ang) * d }
  end
  return c:poly(pts)
end
-- paint only on pixels owned by part P (not gloss, optionally lit felt only)
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

local FAILS, REPORT = {}, {}
local function save(c, key)
  local name = "cf-up-" .. key
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-8s ", key) .. GV.report(t))
  REPORT[#REPORT + 1] = key .. "=" .. t.colours
  if not (t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0) then FAILS[#FAILS + 1] = key end
  return t
end
local function canvas() return GV.canvas{ w = 64, h = 64, mode = "icon" } end

-- shared ramps
local ORANGE = felt("#dc6f2c", { gloss = "#ffc27a", dot = "#fff1c8", rim = "#f2a860" })
local FINGOLD = felt("#f2c14e", { gloss = "#fff1c8", dot = "#fff1c8" })
local ROSE = felt("#d2507e", { gloss = "#ffb8c8", dot = "#ffb8c8", rim = "#ec86a6" })
local WOOD = felt("#b07a45", { gloss = "#ecc58a", dot = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })
local RED = felt("#dd3a2a", { gloss = "#ff9158", dot = "#ff9158", rim = "#f2793a", shade = "#ae2a2a" })
local BLUE = felt("#3f8fb0", { gloss = "#c8ecdc", dot = "#c8ecdc", rim = "#8fcbd8", shade = "#2f6290" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local PINK = felt("#e46a9b", { gloss = "#ffc8dc", dot = "#ffc8dc", rim = "#f29abb" })
local MOSS = felt("#5f9e48", { gloss = "#c8e08a", dot = "#c8e08a", rim = "#8cc064", shade = "#3f7a3a" })

-------------------------------------------------------------------------------- FISH
-- fish: the plain plushie fish (cf-fish-1) scaled up: orange felt, gold fan tail and fin, belly panel,
-- gill seam, tail-panel seam with a button, enamel comma, locked eye
do
  local c = canvas()
  local f, fin = ORANGE, FINGOLD
  local body = c:ellipse(26, 33, 17, 12)
  local tail = c:poly({ {40, 33}, {53, 19}, {56, 26}, {51, 33}, {56, 40}, {53, 47} })
  local finM = c:poly({ {16, 25}, {21, 15}, {31, 15}, {37, 25} })
  local pelv = c:poly({ {22, 43}, {30, 43}, {26, 51} })
  c:build{
    { "tail", tail, fin, { cres = 3, gloss = false } },
    { "fin",  finM, fin, { cres = 3, gloss = false } },
    { "pelv", pelv, fin, { cres = 2, gloss = false } },
    { "body", body, f, { gloss = false } },
  }
  tint(c, c:ellipse(25, 43, 13, 3.5):clip(body), f.base, f.rim)                         -- belly panel
  c:seam({ { 12, 38 }, { 18, 42 }, { 26, 43 }, { 34, 42 } }, { gap = f.shade })
  c:paint({ "s...", ".s..", ".s..", "..s." }, 24, 17, { s = fin.shade })                 -- fin rib
  c:paint({ "sss...", "...ss." }, 47, 24, { s = fin.shade })                             -- tail ribs
  c:paint({ "...ss.", "sss..." }, 47, 40, { s = fin.shade })
  c:seam({ { 16, 24 }, { 19, 29 }, { 19, 35 }, { 17, 40 } }, { gap = f.shade })          -- gill seam
  c:seam({ { 39, 28 }, { 40, 34 }, { 38, 39 } }, { gap = f.shade })                      -- tail panel seam
  c:button(37, 23)
  c:paint({
    "....gggdd",
    "..ggddd..",
    ".gdd.....",
    "gdd......",
    "gd.......",
    "g........",
  }, 22, 24, { g = f.gloss, d = f.dot })
  c:eye(11, 27)
  c:paint({ "uuu", "u.." }, 10, 37, { u = "ol2" })
  save(c, "fish")
end

-- silk: a pale silk bow, two loops and two notched tails, on a rose knot; satin sheen bands, edge stitches
do
  local c = canvas()
  local S = felt("#e9a0c4", { gloss = "#fff0f4", dot = "#fff0f4", rim = "#fbd2e2", shade = "#c46a98" })
  local loopL = c:poly({ {29, 25}, {15, 11}, {8, 14}, {7, 26}, {10, 34}, {29, 31} }):closed(2)
  local loopR = c:poly({ {35, 25}, {48, 11}, {55, 14}, {56, 26}, {53, 34}, {35, 31} }):closed(2)
  local tailL = c:poly({ {27, 30}, {33, 33}, {22, 56}, {18, 51}, {12, 53} })
  local tailR = c:poly({ {31, 33}, {37, 30}, {52, 52}, {46, 51}, {43, 56} })
  local knot = c:rrect(26, 22, 37, 34, 3)
  local p = c:build{
    { "tailL", tailL, S, { cres = 3, gloss = false } },
    { "tailR", tailR, S, { cres = 3, gloss = false } },
    { "loopL", loopL, S, { cres = 4, gloss = false } },
    { "loopR", loopR, S, { cres = 4, gloss = false } },
    { "knot", knot, ROSE, { cres = 3, gloss = { 28, 24 } } },
  }
  -- fold: the inside of each loop near the knot is in shadow
  c:fill(c:poly({ {25, 25}, {17, 20}, {16, 28}, {25, 30} }):clip(loopL), S.shade)
  c:fill(c:poly({ {38, 25}, {47, 20}, {48, 28}, {38, 30} }):clip(loopR), S.shade)
  local on = set(S.base, S.rim)
  local brk = function(n) return n % 6 == 0 end
  trace(c, { {12, 16}, {16, 14}, {22, 18} }, S.gloss, on, brk)                            -- satin sheen
  trace(c, { {42, 18}, {47, 14}, {51, 16} }, S.gloss, on, brk)
  trace(c, { {27, 36}, {22, 46} }, S.gloss, on); trace(c, { {37, 36}, {42, 44} }, S.gloss, on)
  c:seam({ { 10, 20 }, { 10, 28 }, { 13, 32 } }, { gap = S.shade })                       -- edge stitches
  c:seam({ { 53, 19 }, { 53, 28 }, { 50, 31 } }, { gap = S.shade })
  c:seam({ { 29, 27 }, { 34, 27 } }, { gap = ROSE.shade })                                -- knot wrap
  c:seam({ { 29, 30 }, { 34, 30 } }, { gap = ROSE.shade })
  save(c, "silk")
end

-- catnip: a catnip sprig, two pairs of toothed leaves on a stem, rose flower spike, gold midrib seams
do
  local c = canvas()
  local L = felt("#5aa83c", { gloss = "#d4ec8a", dot = "#d4ec8a", rim = "#8ccc5a", shade = "#2f7a3a" })
  local stem = c:line({ {31, 53}, {31, 20} }, 3)
  local l1 = rell(c, 19, 41, 12, 7, -0.45)                                                -- lower pair
  local l2 = rell(c, 44, 41, 12, 7, 0.45)
  local l3 = rell(c, 21, 27, 9, 5.5, -0.6)                                                -- upper pair
  local l4 = rell(c, 42, 27, 9, 5.5, 0.6)
  -- toothed edges: notch the outer rim every 4th px
  for _, lf in ipairs({ l1, l2, l3, l4 }) do
    local e = lf:edge()
    local i = 0
    e:each(function(x, y) i = i + 1 end)
    local n = 0
    local x0, y0, x1, y1 = lf:bbox()
    local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    e:each(function(x, y)
      if ((x + 2 * y) % 5 == 0) and y < cy + 2 then lf:del(x, y) end
    end)
  end
  local spike = c:ellipse(31.5, 13, 4, 7)
  c:build{
    { "stem", stem, L, { flat = true, contact = false } },
    { "l3", l3, L, { cres = 3, gloss = false } },
    { "l4", l4, L, { cres = 3, gloss = false } },
    { "l1", l1, L, { cres = 3, gloss = false } },
    { "l2", l2, L, { cres = 3, gloss = false } },
    { "spike", spike, ROSE, { cres = 3, gloss = false } },
  }
  c:paint({ "g.", "gd" }, 29, 8, { g = ROSE.gloss, d = "#fff0f4" })
  c:paint({ "g", ".", ".", "g" }, 33, 12, { g = ROSE.gloss })                             -- flower dots
  c:seam({ { 29, 44 }, { 20, 41 }, { 10, 36 } }, { gap = L.shade })                       -- midribs
  c:seam({ { 34, 44 }, { 43, 41 }, { 53, 36 } }, { gap = L.shade })
  c:seam({ { 29, 30 }, { 22, 27 }, { 15, 22 } }, { gap = L.shade })
  c:seam({ { 34, 30 }, { 41, 27 }, { 48, 22 } }, { gap = L.shade })
  c:paint({ "ggg.", "g..." }, 11, 38, { g = L.gloss }); c:paint({ "gg", "g." }, 16, 24, { g = L.gloss })
  save(c, "catnip")
end

-- glitter: a crimson sequin fish facing right (the plain fish faces left and is orange), every scale a
-- scallop, gold fan tail and fin, gold glitter specks, a big gold 4-point sparkle top right and a small one
-- top left. (Pass 2's round scale patch read as a Christmas bauble; pass 3 makes it a fish again.)
do
  local c = canvas()
  local Q = felt("#d43a5a", { gloss = "#ffb0b8", dot = "#ffe0e0", rim = "#f06a80", shade = "#9a2448" })
  local body = c:ellipse(33, 37, 17, 13)
  local tail = c:poly({ {20, 37}, {10, 24}, {8, 31}, {12, 37}, {8, 43}, {10, 51} })
  local finM = c:poly({ {25, 27}, {29, 17}, {38, 18}, {42, 27} })
  local big = star(c, 48, 15, 8, 2.6, 0)
  local small = star(c, 13, 12, 5, 1.8, 0)
  local p = c:build{
    { "tail", tail, GOLD, { cres = 3, gloss = false } },
    { "fin", finM, GOLD, { cres = 2, gloss = false } },
    { "body", body, Q, { cres = 4, gloss = false } },
    { "small", small, GOLD, { flat = true, contact = false } },
    { "big", big, GOLD, { cres = 2, gloss = false, bounce = false, contact = false } },
  }
  -- scallop rows: each scale is the lower arc of a radius-4 ring (shade), lit just inside (rim)
  local inner = body:shrink(2)
  for row = 0, 4 do
    local y = 23 + row * 6
    for col = -1, 5 do
      local x = 12 + col * 9 + (row % 2) * 4
      for dy = 0, 5 do for dx = -5, 5 do
        local d = math.sqrt(dx * dx + dy * dy)
        local px, py = x + dx, y + dy
        local k = c:key(px, py)
        if inner:has(px, py) and c.own[k] == p.body and px < 42 then
          if d >= 3.6 and d < 4.7 then c:px(px, py, Q.shade)
          elseif d >= 2.6 and d < 3.6 and dy >= 1 and not c.shd[k] then c:px(px, py, Q.rim) end
        end
      end end
    end
  end
  c:seam({ { 41, 27 }, { 43, 33 }, { 43, 40 }, { 41, 46 } }, { gap = Q.shade })        -- gill seam
  c:paint({ ".ggg", "g...", "g..." }, 21, 28, { g = Q.gloss })                         -- enamel comma
  c:paint({ "sss.", "...s" }, 11, 30, { s = GOLD.shade })                              -- tail ribs
  c:paint({ "...s", "sss." }, 11, 43, { s = GOLD.shade })
  for _, q in ipairs({ { 27, 33 }, { 35, 38 }, { 24, 43 } }) do                        -- gold glitter specks
    c:paint({ ".d.", "dgd", ".d." }, q[1] - 1, q[2] - 1, { d = C.gold, g = GOLD.gloss })
  end
  c:eye(43, 31)
  c:paint({ "..u", "uu." }, 47, 41, { u = "ol2" })                                    -- smile
  c:px(48, 15, GOLD.gloss); c:px(47, 14, GOLD.gloss)                                  -- star glint
  save(c, "glitter")
end

-------------------------------------------------------------------------------- ROD
-- string: a wooden spool wound with blue string, the loose end curling off to the right with a gold bead
do
  local c = canvas()
  local top = c:ellipse(24, 15, 14, 5)
  local bot = c:ellipse(24, 49, 14, 5)
  local barrel = c:rect(14, 15, 34, 49)
  local loose = c:line({ {34, 34}, {41, 32}, {47, 34}, {50, 39}, {48, 44}, {43, 45}, {41, 41}, {44, 38} }, 3)
  local tailS = c:line({ {48, 44}, {52, 49}, {52, 53} }, 3)
  local bead = c:ellipse(52, 53, 3.5)
  local p = c:build{
    { "bot", bot, WOOD, { cres = 3, gloss = false } },
    { "barrel", barrel, BLUE, { cres = 5, gloss = false } },
    { "top", top, WOOD, { cres = 3, gloss = false } },
    { "loose", loose:add(tailS), BLUE, { cres = 1, deep = 0, gloss = false } },
    { "bead", bead, GOLD, { cres = 2, gloss = false, bounce = false } },
  }
  -- wraps: shade grooves with a lit ridge row above, slightly curved (front of a cylinder)
  for _, y0 in ipairs({ 22, 26, 30, 34, 38, 42 }) do
    for x = 14, 34 do
      local dy = math.floor(((x - 24) / 10) ^ 2 * 1.5 + 0.5)
      local y = y0 + 2 - dy
      local k = c:key(x, y)
      if c.own[k] == p.barrel then c:px(x, y, BLUE.shade) end
      local k2 = c:key(x, y - 1)
      if c.own[k2] == p.barrel and not c.shd[k2] then c:px(x, y - 1, BLUE.rim) end
    end
  end
  c:fill(c:ellipse(24, 15, 4, 1.5), WOOD.shade)                                           -- spool hole
  c:paint({ "gggg", "g..." }, 17, 23, { g = BLUE.gloss })
  c:paint({ "ggg", "g.." }, 15, 12, { g = WOOD.gloss })
  c:px(51, 52, GOLD.gloss)
  save(c, "string")
end

-- spring: a chunky violet coil spring on a red felt grip, wand stick and gold bead on top
do
  local c = canvas()
  local V = felt("#7a5cc0", { gloss = "#d8c8ff", dot = "#d8c8ff", rim = "#a890e0", shade = "#4e3a8a" })
  local list = {}
  -- pass 2: the coil is drawn as a helix of strands (light front "\\" over dark back "/") with gaps, the wand
  -- stick showing through it, so it reads as a spring and not a solid violet barrel
  local stick = c:line({ {31, 47}, {31, 13} }, 4)
  list[#list + 1] = { "stick", stick, WOOD, { cres = 2, deep = 0, gloss = false } }
  list[#list + 1] = { "bead", c:ellipse(31.5, 10, 4), GOLD, { cres = 2, gloss = false, bounce = false } }
  local VB = { gloss = V.rim, dot = V.rim, rim = V.rim, base = V.shade, shade = "#38286a" }
  VB.deep, VB.bounce = VB.shade, VB.base
  local ys = { 15, 25, 35 }
  for i, y in ipairs(ys) do                                                               -- back strands first
    list[#list + 1] = { "b" .. i, c:line({ {44, y + 5}, {19, y + 10} }, 3), VB, { flat = true, contact = false } }
  end
  for i, y in ipairs(ys) do                                                               -- front strands on top
    list[#list + 1] = { "f" .. i, c:line({ {19, y}, {44, y + 5} }, 4), V, { cres = 2, deep = 0, gloss = false } }
  end
  list[#list + 1] = { "f4", c:line({ {19, 45}, {30, 47} }, 4), V, { cres = 2, deep = 0, gloss = false } }
  local grip = c:rrect(24, 46, 39, 56, 3)
  list[#list + 1] = { "grip", grip, RED, { cres = 3, gloss = { 26, 48 } } }
  local p = c:build(list)
  for _, y in ipairs({ 51, 54 }) do                                                       -- grip wraps
    for x = 25, 38 do
      local k = c:key(x, y)
      if c.own[k] == p.grip and not c.gl.s[k] and not c.shd[k] then c:px(x, y, RED.shade) end
    end
  end
  for i, y in ipairs(ys) do c:paint({ "ggg" }, 21, y, { g = V.gloss }) end                -- coil glints
  c:px(29, 8, GOLD.gloss); c:px(30, 8, GOLD.gloss)
  save(c, "spring")
end

-- motor: a steel gear reel with a red push button, the wand stick rising out of it to a gold bead
do
  local c = canvas()
  local ST = felt("#8a96ae", { gloss = "#e8eef8", dot = "#e8eef8", rim = "#b8c4d8", shade = "#5a6488" })
  local cx, cy = 25, 38
  local gear = c:ellipse(cx, cy, 13)
  for i = 0, 7 do                                                                         -- 8 teeth
    local a = i * math.pi / 4 + math.pi / 8
    local ux, uy = math.cos(a), math.sin(a)
    local vx, vy = -uy, ux
    local function P(t, s) return { cx + 0.5 + ux * t + vx * s, cy + 0.5 + uy * t + vy * s } end
    gear:add(c:poly({ P(10, -3.5), P(17.5, -2.8), P(17.5, 2.8), P(10, 3.5) }))
  end
  local stick = c:line({ {33, 30}, {49, 14} }, 4)
  local bead = c:ellipse(50, 12, 4)
  local hub = c:ellipse(cx, cy, 7)
  local p = c:build{
    { "stick", stick, WOOD, { cres = 2, deep = 0, gloss = false } },
    { "bead", bead, GOLD, { cres = 2, gloss = false, bounce = false } },
    { "gear", gear, ST, { cres = 4, gloss = { 15, 30 } } },
    { "hub", hub, RED, { cres = 3, gloss = { 22, 34 } } },
  }
  c:seam({ { cx - 10, cy }, { cx - 9, cy + 5 }, { cx - 5, cy + 9 }, { cx, cy + 10 }, { cx + 5, cy + 9 },
           { cx + 9, cy + 5 }, { cx + 10, cy } }, { gap = ST.shade })
  c:px(48, 10, GOLD.gloss); c:px(49, 10, GOLD.gloss)
  save(c, "motor")
end

-- double: two crossed wands (cf-rod look) tied together with a blue bow
do
  local c = canvas()
  local stA = c:line({ {16, 48}, {47, 14} }, 4)
  local stB = c:line({ {47, 48}, {16, 14} }, 4)
  local gripA = c:line({ {11, 53}, {19, 44} }, 7)
  local gripB = c:line({ {51, 52}, {44, 44} }, 7)
  local beadA = c:ellipse(49, 11, 4)
  local beadB = c:ellipse(14, 11, 4)
  local bowL = c:poly({ {30, 30}, {20, 24}, {20, 36} }):grow(1)
  local bowR = c:poly({ {33, 30}, {43, 24}, {43, 36} }):grow(1)
  local knot = c:rrect(28, 27, 35, 34, 2)
  local p = c:build{
    { "stB", stB, WOOD, { cres = 2, deep = 0, gloss = false } },
    { "stA", stA, WOOD, { cres = 2, deep = 0, gloss = false } },
    { "beadA", beadA, GOLD, { cres = 2, gloss = false, bounce = false } },
    { "beadB", beadB, GOLD, { cres = 2, gloss = false, bounce = false } },
    { "gripA", gripA, RED, { cres = 3, gloss = false } },
    { "gripB", gripB, RED, { cres = 3, gloss = false } },
    { "bowL", bowL, BLUE, { cres = 3, gloss = false } },
    { "bowR", bowR, BLUE, { cres = 3, gloss = false } },
    { "knot", knot, BLUE, { cres = 2, gloss = false } },
  }
  c:paint({ "gg", "g." }, 12, 9, { g = GOLD.gloss }); c:paint({ "gg", "g." }, 47, 9, { g = GOLD.gloss })
  c:paint({ "..g", ".g.", "g.." }, 12, 48, { g = RED.rim }); c:paint({ "g..", ".g.", "..g" }, 45, 46, { g = RED.rim })
  c:paint({ "gg", "g." }, 21, 27, { g = BLUE.gloss }); c:paint({ "gg", "g." }, 39, 27, { g = BLUE.gloss })
  c:seam({ { 12, 49 }, { 17, 54 } }, { gap = RED.shade }); c:seam({ { 46, 49 }, { 50, 46 } }, { gap = RED.shade })
  save(c, "double")
end

-------------------------------------------------------------------------------- ROOM
-- sunbeam: a little sun top left throwing three chunky rays down onto a wooden floor, where they land as a
-- bright window-shaped patch. (Pass 3: the sun and the patch were not joined, so it read as sun + yellow tile.)
do
  local c = canvas()
  local LIGHT = felt("#f5d470", { gloss = "#fff4c0", dot = "#fff4c0", rim = "#fff0a0", shade = "#e0a83a" })
  local BEAM = { gloss = "#fff4c0", dot = "#fff4c0", rim = "#fff4c0", base = "#fff0a0", shade = LIGHT.base }
  BEAM.deep, BEAM.bounce = BEAM.shade, BEAM.base
  local sun = c:ellipse(18, 18, 7)
  local rays = c:mask()
  for i = 0, 7 do
    if i ~= 0 and i ~= 1 and i ~= 2 then                                                 -- beams take the lower right
      local a = i * math.pi / 4
      local ux, uy = math.cos(a), math.sin(a)
      local vx, vy = -uy, ux
      local function P(t, s) return { 18.5 + ux * t + vx * s, 18.5 + uy * t + vy * s } end
      rays:add(c:poly({ P(7, -3), P(11.5, 0), P(7, 3) }))
    end
  end
  local floor = c:rrect(8, 45, 55, 55, 2)
  local patch = c:poly({ {25, 45}, {48, 45}, {55, 56}, {32, 56} }):clip(floor:shrink(1))
  local beams = {
    c:poly({ {14, 23}, {20, 24}, {31, 48}, {25, 48} }),
    c:poly({ {21, 23}, {25, 20}, {40, 48}, {34, 48} }),
    c:poly({ {24, 14}, {26, 19}, {49, 48}, {43, 48} }),
  }
  local list = { { "floor", floor, WOOD, { cres = 3, gloss = false } } }
  list[#list + 1] = { "patch", patch, BEAM, { cres = 2, gloss = false, contact = false } }
  for i, m in ipairs(beams) do list[#list + 1] = { "b" .. i, m, BEAM, { flat = true, contact = false, solid = false } } end
  list[#list + 1] = { "rays", rays, GOLD, { cres = 2, gloss = false, bounce = false, contact = false } }
  list[#list + 1] = { "sun", sun, GOLD, { cres = 3, gloss = { 14, 14 } } }
  local p = c:build(list)
  -- window bars in the light patch, plank seams on the floor
  local bars = c:line({ {40, 45}, {46, 55} }, 2):add(c:line({ {29, 50}, {52, 50} }, 2))
  onPart(c, bars, p.patch, LIGHT.base)
  for _, x in ipairs({ 14, 20 }) do onPart(c, c:rect(x, 47, x, 54), p.floor, WOOD.shade) end
  c:seam({ { 10, 51 }, { 22, 51 } }, { gap = WOOD.shade })
  save(c, "sunbeam")
end

-- rug: a round cosy rug seen from above at a slant, green with a gold ring, stitched border, fringe
do
  local c = canvas()
  local outer = c:ellipse(31.5, 36, 21, 15)
  local ring = c:ellipse(31.5, 36, 16, 10)
  local mid = c:ellipse(31.5, 36, 10, 6)
  local fr = c:mask()
  for _, y in ipairs({ 31, 36, 41 }) do
    fr:add(c:rect(7, y - 1, 11, y + 1)); fr:add(c:rect(52, y - 1, 56, y + 1))
  end
  local p = c:build{
    { "fringe", fr, GOLD, { flat = true, contact = false } },
    { "outer", outer, MOSS, { cres = 4, gloss = { 16, 27 } } },
    { "ring", ring, GOLD, { cres = 3, gloss = false, contact = false } },
    { "mid", mid, MOSS, { cres = 3, gloss = false, contact = false } },
  }
  c:stitch(outer)                                                                         -- stitched border
  c:seam({ { 22, 36 }, { 26, 33 }, { 32, 32 }, { 38, 33 }, { 42, 36 } }, { gap = GOLD.shade })
  c:paint({ "gg", "g." }, 24, 32, { g = MOSS.gloss })
  save(c, "rug")
end

-- scratch: a sisal-wrapped scratch post on a green felt base with a green cap and a dangling pompom
do
  local c = canvas()
  local SI = felt("#d9b46a", { gloss = "#fff0c0", dot = "#fff0c0", rim = "#f0d08a", shade = "#a8783a" })
  local base = c:rrect(8, 47, 55, 56, 4)
  local post = c:rect(22, 14, 39, 48)
  local cap = c:rrect(15, 8, 46, 15, 3)
  local cord = c:line({ {44, 16}, {47, 25} }, 2)
  local pom = c:ellipse(47.5, 29, 4)
  local p = c:build{
    { "base", base, MOSS, { cres = 4, gloss = { 12, 49 } } },
    { "post", post, SI, { cres = 4, gloss = false } },
    { "cap", cap, MOSS, { cres = 3, gloss = { 18, 10 } } },
    { "cord", cord, SI, { flat = true, contact = false } },
    { "pom", pom, PINK, { cres = 2, gloss = false } },
  }
  -- rope wraps: diagonal grooves round the post with a lit ridge above
  for y0 = 17, 47, 4 do
    for x = 22, 39 do
      local y = y0 + math.floor((x - 22) / 6)
      local k = c:key(x, y)
      if c.own[k] == p.post then c:px(x, y, SI.shade) end
      local k2 = c:key(x, y - 1)
      if c.own[k2] == p.post and not c.shd[k2] then c:px(x, y - 1, SI.rim) end
    end
  end
  c:paint({ "g", "g", "g" }, 24, 18, { g = SI.gloss })
  c:seam({ { 11, 52 }, { 52, 52 } }, { gap = MOSS.shade })
  c:px(46, 27, PINK.gloss)
  save(c, "scratch")
end

-- window: a green-framed window, sky panes, a little bird perched outside, cream sill
do
  local c = canvas()
  local SKY = felt("#9ccfe8", { gloss = "#eef8f2", dot = "#eef8f2", rim = "#c8e8f4", shade = "#6f98c4" })
  local SILL = felt("#e8d0a0", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#fff0c8", shade = "#c49a60" })
  local frame = c:rrect(10, 8, 53, 50, 4)
  local panes = {
    c:rect(15, 13, 29, 27), c:rect(34, 13, 48, 27), c:rect(15, 32, 29, 46), c:rect(34, 32, 48, 46),
  }
  local sill = c:rrect(7, 48, 56, 55, 2)
  local list = { { "frame", frame, MOSS, { cres = 4, gloss = { 13, 11 } } } }
  for i, m in ipairs(panes) do list[#list + 1] = { "p" .. i, m, SKY, { cres = 3, gloss = false, contact = false } } end
  list[#list + 1] = { "sill", sill, SILL, { cres = 3, gloss = false } }
  c:build(list)
  for _, q in ipairs({ { 16, 14 }, { 35, 14 }, { 16, 33 }, { 35, 33 } }) do               -- glass glints
    c:paint({ "ggg", "g..", "g.." }, q[1], q[2], { g = SKY.gloss })
  end
  -- bird silhouette on the lower right pane: round body, head, beak, tail
  c:paint({
    "....uuu...",
    "...uuuuu..",
    "...uuuuuoo",
    "..uuuuuu..",
    "uuuuuuuu..",
    "uuuuuuu...",
    ".uuuuu....",
    "...u.u....",
  }, 36, 37, { u = "ol2", o = "#e8a317" })
  c:px(40, 38, SKY.rim)                                                                   -- bird's eye
  c:seam({ { 12, 51 }, { 51, 51 } }, { gap = SILL.shade })
  save(c, "window")
end

-------------------------------------------------------------------------------- CAT
-- bowl: a pink pedestal bowl heaped with kibble, gold rim seam and a gold fish on the front
do
  local c = canvas()
  local K = felt("#a8642a", { gloss = "#ffd79a", dot = "#ffd79a", rim = "#d08a48", shade = "#7a4220" })
  local bowl = c:ellipse(31.5, 30, 23, 5):add(c:poly({ {9, 30}, {55, 30}, {48, 44}, {15, 44} })):closed(2)
  local foot = c:rrect(24, 43, 39, 49, 2):add(c:rrect(18, 48, 45, 55, 3))
  local list = {}
  local pieces = { {24, 19}, {32, 16}, {40, 19}, {18, 24}, {28, 23}, {37, 24}, {46, 24} }
  for i, q in ipairs(pieces) do
    list[#list + 1] = { "k" .. i, c:ellipse(q[1], q[2], 4, 3.5), K, { cres = 2, gloss = false, bounce = false } }
  end
  list[#list + 1] = { "foot", foot, PINK, { cres = 3, gloss = false } }
  list[#list + 1] = { "bowl", bowl, PINK, { cres = 4, gloss = { 13, 33 } } }
  c:build(list)
  for _, q in ipairs(pieces) do c:px(q[1] - 2, q[2] - 2, K.gloss); c:px(q[1], q[2], K.shade) end
  c:seam({ { 11, 30 }, { 52, 30 } }, { gap = PINK.shade })                                -- rim band
  c:paint({                                                                                -- gold fish emblem
    "....ggg...g",
    "..ggggggggg",
    ".gugggggg.g",
    "gggggggg...",
    ".ggsssss.gg",
    "...sss...ss",
  }, 26, 34, { g = C.gold, s = C.goldS, u = "ol3" })
  c:seam({ { 21, 51 }, { 42, 51 } }, { gap = PINK.shade })
  save(c, "bowl")
end

-- toybox: an open wooden toy box with a pink yarn ball and an orange plush fish tail sticking out
do
  local c = canvas()
  local box = c:rrect(9, 30, 54, 55, 3)
  local lid = c:poly({ {11, 31}, {15, 10}, {49, 10}, {53, 31} })
  local inside = c:rect(12, 26, 51, 32)
  local yarn = c:ellipse(23, 26, 9)
  local fishTail = c:poly({ {37, 31}, {41, 20}, {35, 12}, {44, 15}, {49, 10}, {47, 21}, {45, 31} })
  local p = c:build{
    { "lid", lid, WOOD, { cres = 3, gloss = false } },
    { "inside", inside, WOOD, { flat = true, rim = false, contact = false } },
    { "fish", fishTail, ORANGE, { cres = 2, gloss = false } },
    { "yarn", yarn, PINK, { cres = 3, gloss = { 19, 20 } } },
    { "box", box, WOOD, { cres = 4, gloss = { 13, 34 } } },
  }
  tint(c, c:rect(12, 26, 51, 32), WOOD.base, WOOD.shade)
  tint(c, lid:shrink(3), WOOD.base, WOOD.shade)                                           -- lid's inner face
  for _, r in ipairs({ 5, 8 }) do                                                         -- yarn wraps
    local m = c:ellipse(31, 16, r + 7):cut(c:ellipse(31, 16, r + 6))
    onPart(c, m, p.yarn, PINK.shade)
  end
  c:paint({ "s..", ".s.", ".s." }, 41, 13, { s = ORANGE.shade })
  c:seam({ { 13, 34 }, { 50, 34 } }, { gap = WOOD.shade })                                -- box hem
  c:seam({ { 13, 51 }, { 50, 51 } }, { gap = WOOD.shade })
  -- stitched heart on the front
  c:paint({ ".gg.gg.", "ggggggg", "ggggggg", ".ggggg.", "..ggg..", "...g..." }, 28, 39, { g = PINK.base })
  c:paint({ ".rr.rr.", "r..r..r" }, 28, 39, { r = PINK.rim })
  save(c, "toybox")
end

-- cattree: two pink cushioned platforms on brown posts, stepped left-high / right-low, wide base
do
  local c = canvas()
  local base = c:rrect(8, 48, 55, 56, 3)
  local postA = c:rect(15, 14, 21, 48)
  local postB = c:rect(40, 34, 46, 48)
  local top = c:rrect(7, 8, 31, 15, 3)
  local mid = c:rrect(30, 27, 56, 34, 3)
  local cord = c:line({ {28, 16}, {28, 23} }, 2)
  local pom = c:ellipse(28, 26, 3)
  local p = c:build{
    { "postA", postA, WOOD, { cres = 3, gloss = false } },
    { "postB", postB, WOOD, { cres = 3, gloss = false } },
    { "base", base, PINK, { cres = 4, gloss = { 11, 49 } } },
    { "cord", cord, WOOD, { flat = true, contact = false } },
    { "pom", pom, GOLD, { cres = 2, gloss = false } },
    { "top", top, PINK, { cres = 3, gloss = { 10, 9 } } },
    { "mid", mid, PINK, { cres = 3, gloss = { 33, 28 } } },
  }
  for _, y in ipairs({ 20, 26, 32, 38, 44 }) do onPart(c, c:rect(15, y, 21, y), p.postA, WOOD.shade) end
  for _, y in ipairs({ 39, 44 }) do onPart(c, c:rect(40, y, 46, y), p.postB, WOOD.shade) end
  c:seam({ { 10, 12 }, { 28, 12 } }, { gap = PINK.shade })
  c:seam({ { 33, 31 }, { 53, 31 } }, { gap = PINK.shade })
  c:seam({ { 11, 53 }, { 52, 53 } }, { gap = PINK.shade })
  save(c, "cattree")
end

-- catflap: a mauve arched door with a cream cat-head flap at the bottom and a gold knob
do
  local c = canvas()
  local DOOR = felt("#a8506a", { gloss = "#f0a8b8", dot = "#f0a8b8", rim = "#c87088", shade = "#7a3450" })
  local FLAP = felt("#e8d0a0", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#fff0c8", shade = "#c49a60" })
  local door = c:rect(12, 22, 51, 56):add(c:ellipse(31.5, 22, 19.5, 14)):clip(c:rect(0, 7, 63, 56))
  local head = c:ellipse(31.5, 44, 11, 8):add(c:poly({ {21, 42}, {22, 31}, {29, 37} })):add(c:poly({ {34, 37}, {41, 31}, {42, 42} }))
  head:clip(c:rect(0, 0, 63, 52))
  local p = c:build{
    { "door", door, DOOR, { cres = 4, gloss = { 18, 14 } } },
    { "flap", head, FLAP, { cres = 3, gloss = false } },
  }
  -- door panels: two stitched rectangles above the flap
  c:seam({ { 17, 18 }, { 17, 28 } }, { gap = DOOR.shade }); c:seam({ { 46, 18 }, { 46, 28 } }, { gap = DOOR.shade })
  c:seam({ { 21, 12 }, { 31, 10 }, { 42, 12 } }, { gap = DOOR.shade })
  c:button(44, 34)
  -- flap hinge seam across the top of the cat head and the bottom sill
  c:seam({ { 22, 43 }, { 41, 43 } }, { gap = FLAP.shade })
  c:paint({ "gg", "g." }, 24, 39, { g = FLAP.gloss })
  save(c, "catflap")
end

print("colours: " .. table.concat(REPORT, " "))
assert(#FAILS == 0, "check failed: " .. table.concat(FAILS, " "))
