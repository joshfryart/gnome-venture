-- tailor-1/2/3: the Tailor garden building, one picture per level (same house, one step of growth each).
-- L1: timber-and-plaster workshop, plum shingle gable roof, window with a dress-form mannequin,
--     hanging sign with a spool of thread.            quirk: a loose red thread dangling off the sign's spool.
-- L2: + patched striped awning, round gable window, a bolt of cloth leaning by the door.
-- L3: + wooden sign with gold thread lettering, a needle weathervane, a clothes line with tiny garments.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_gw.lua")
local HP, X, K, R, G = W.HP, W.X, W.K, W.R, W.G
local floor, abs = math.floor, math.abs

local plaster = { "#8a6a5e", "#b0917c", "#cfb395", "#e4caa6", "#f0dcb8", "#faecd0" }
local roofR   = { "#2c1f45", "#432f66", "#5b418a", "#7556a6", "#936fc0", "#b898dc" }
local honey   = { "#5e3627", "#865230", "#a8703c", "#c78e4c", "#dcaa62", "#efc882" }
local stoneR  = { "#3e3f58", "#5a5b74", "#74758c", "#9796aa", "#b8b7c6", "#dcdae2" }
local glass   = { "#2a2440", "#3a3456", "#4c4a70", "#5f9ad0", "#8bc4ea", "#d4eef8" }
local fabric  = { "#2a4a7a", "#3a6ea0", "#3a86b0", "#4fa8c4", "#7cc8d6", "#b6f0e0" }

local function draw(level)
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tailor-" .. level }
  c:groundShadow(31, 57, 28, 3)

  ------------------------------------------------------------------ walls + gable
  local wall = c:rect(11, 33, 43, 53)
  local gable = c:poly{ {27,13}, {44.5,35}, {9.5,35} }
  -- plaster wall, lit from the upper left, darker toward the right and under the eaves
  local wb = {}
  wall:each(function(x, y) wb[K(x, y)] = (x > 38 and -1 or 0) + (y <= 35 and -1 or 0) end)
  local wi = W.lit(c, wall, plaster, { R = 3, bias = wb, cuts = { .2, .36, .5, .66, .84 } })
  W.speckle(c, wall, wi, plaster, 0.05, level + 4)
  -- gable: honey vertical boards
  local gi = W.lit(c, gable, honey, { R = 2, cuts = { .2, .38, .54, .7, .88 } })
  gable:each(function(x, y) if (x - 9) % 4 == 0 then c:put(x, y, honey[2]) elseif (x - 9) % 4 == 1 and y % 7 == 0 then c:put(x, y, honey[5]) end end)
  W.hline(c, 11, 43, 32, honey[1])
  -- timber frame: corner posts + sill beam
  for _, px in ipairs({ 11, 42 }) do
    local post = c:rect(px, 33, px + 1, 53)
    W.vcyl(c, post, R.wood, px, px + 1)
    W.vline(c, px, 33, 53, px == 11 and R.wood[5] or R.wood[3])
  end
  local beam = c:rect(11, 33, 43, 34)
  c:fillMask(beam, R.wood[4]) W.hline(c, 11, 43, 33, R.wood[5]) W.hline(c, 11, 43, 34, R.wood[2])
  W.hline(c, 13, 41, 35, plaster[2]) -- contact shadow under the beam

  ------------------------------------------------------------------ foundation
  local found = c:rect(10, 54, 44, 56)
  W.lit(c, found, stoneR, { R = 1 })
  W.hline(c, 10, 44, 54, stoneR[5])
  for x = 10, 44 do if (x - 10) % 6 == 5 then c:put(x, 55, stoneR[2]) end if (x - 13) % 6 == 5 then c:put(x, 56, stoneR[2]) end end

  ------------------------------------------------------------------ door
  local door = c:rrect(15, 39, 22, 53, 3)
  local di = W.lit(c, door, R.wood, { R = 2 })
  for y = 40, 53 do c:put(18, y, R.wood[2]) end
  W.hline(c, 15, 22, 44, R.wood[2]) W.hline(c, 15, 22, 49, R.wood[2])
  c:put(16, 41, R.wood[6]) c:put(16, 42, R.wood[6])
  c:put(21, 47, R.brass[5]) c:put(21, 48, R.brass[3])
  door:grow(1):cut(door):clip(c:rect(14, 38, 23, 53)):each(function(x, y) c:put(x, y, R.wood[1]) end)
  -- step
  local step = c:rect(14, 54, 23, 55) W.lit(c, step, stoneR, { R = 1 }) W.hline(c, 14, 23, 54, stoneR[6])

  ------------------------------------------------------------------ front window with mannequin
  local wx0, wy0, wx1, wy1 = 26, 38, 38, 48
  local frame = c:rect(wx0 - 1, wy0 - 1, wx1 + 1, wy1 + 1)
  c:fillMask(frame, R.wood[2])
  W.hline(c, wx0 - 1, wx1 + 1, wy0 - 1, R.wood[4]) W.vline(c, wx0 - 1, wy0 - 1, wy1 + 1, R.wood[4])
  local pane = c:rect(wx0, wy0, wx1, wy1)
  pane:each(function(x, y) c:put(x, y, (y < wy0 + 3) and glass[3] or glass[2]) end)
  -- warm lamp glow lower-left inside
  W.put(c, { {wx0,wy1}, {wx0+1,wy1}, {wx0,wy1-1} }, "#6a4a4a")
  -- dress form: linen torso on a stand with a half-pinned pink dress, tape measure round the neck
  local linen = { "#7a6458", "#a08a76", "#c4ae94", "#dcc8aa", "#ecdcc0", "#f8eed8" }
  local torso = c:poly{ {29,40}, {35,40}, {34.5,42}, {33.5,44}, {34.5,46}, {29.5,46}, {30.5,44}, {29.5,42} }
  W.lit(c, torso, linen, { R = 2 })
  local dress = c:poly{ {29.5,43}, {34.5,43}, {35.5,47}, {28.5,47} }
  W.lit(c, dress, { "#7d2c5e", "#a33c6a", "#c94f84", "#e06e96", "#f5809f", "#ffc4d8" }, { R = 1 })
  W.hline(c, 29, 35, 43, "#ffc4d8")
  c:fillMask(c:rect(31, 38, 33, 39), linen[3]) c:put(31, 38, linen[6]) c:put(32, 38, linen[5])
  W.put(c, { {30,40}, {31,41}, {33,41}, {34,40} }, "#f5b82e") c:put(32, 41, "#d98322") -- tape measure
  c:put(30, 41, linen[6])
  W.vline(c, 32, 48, 48, R.wood[3])
  -- glass glint
  W.put(c, { {wx1-1,wy0+1}, {wx1,wy0+1}, {wx1,wy0+2} }, glass[6])
  -- sill
  local sill = c:rect(wx0 - 2, wy1 + 2, wx1 + 2, wy1 + 3)
  W.lit(c, sill, R.wood, { R = 1 }) W.hline(c, wx0 - 2, wx1 + 2, wy1 + 2, R.wood[6])
  W.hline(c, wx0 - 1, wx1 + 1, wy1 + 4, plaster[2])

  ------------------------------------------------------------------ gable vent / round window
  if level == 1 then
    local vent = c:rect(25, 22, 29, 25)
    c:fillMask(vent, honey[1])
    W.hline(c, 25, 29, 23, honey[4]) W.hline(c, 25, 29, 25, honey[4])
  else
    local ring = c:ellipse(27, 23, 3.4, 3.4)
    c:fillMask(ring, R.wood[2])
    ring:each(function(x, y) if x + y < 27 + 23 - 1 then c:put(x, y, R.wood[4]) end end)
    local gl = c:ellipse(27, 23, 2.2, 2.2)
    gl:each(function(x, y) c:put(x, y, (x + y < 50) and glass[4] or glass[2]) end)
    W.vline(c, 27, 21, 25, R.wood[2]) W.hline(c, 25, 29, 23, R.wood[2])
    c:put(26, 22, glass[6])
  end

  ------------------------------------------------------------------ roof (plum shingles), drawn over the gable edge
  local outer = c:poly{ {27,7}, {51.5,36}, {2.5,36} }
  local inner = c:poly{ {27,14}, {44.5,36}, {9.5,36} }
  local roof = outer:copy():cut(inner)
  local rb = {}
  roof:each(function(x, y) if x > 27 then rb[K(x, y)] = -1 end end)
  local ri = W.lit(c, roof, roofR, { R = 3, bias = rb, cuts = { .2, .36, .52, .7, .86 } })
  -- shingle courses: rows parallel to each slope, staggered seams
  roof:each(function(x, y)
    local side = x <= 27 and -1 or 1
    -- distance below the outer slope (in px, measured vertically)
    local yo = 7 + abs(x - 27) * (29 / 24.5)
    local v = y - yo
    local u = abs(x - 27)
    local row = floor(v / 2.5)
    local k = K(x, y)
    if v - row * 2.5 < 0.9 and v > 1 then c:put(x, y, roofR[math.max(1, ri[k] - 2)])
    elseif (floor(u + row * 2) % 5) == 0 and v > 1 then c:put(x, y, roofR[math.max(1, ri[k] - 1)]) end
  end)
  -- ridge cap highlight along the left (lit) slope edge
  for x = 3, 27 do local y = floor(7 + (27 - x) * (29 / 24.5) + 0.5) if roof:has(x, y) then c:put(x, y, roofR[6]) end if roof:has(x, y + 1) then c:put(x, y + 1, roofR[5]) end end
  -- eave underside shadow on the gable
  inner:edge():each(function(x, y) if y < 35 then c:put(x, y, honey[1]) end end)
  c:put(26, 9, "#fff4d6") c:put(25, 10, roofR[6])

  ------------------------------------------------------------------ hanging sign with a spool (right side)
  -- iron bracket with a brace
  W.hline(c, 44, 53, 36, R.steel[2]) W.hline(c, 44, 53, 35, R.steel[4])
  W.put(c, { {44,40}, {45,39}, {46,38}, {47,37} }, R.steel[2])
  c:put(53, 34, R.steel[3])
  -- chains
  W.vline(c, 46, 37, 38, R.steel[3]) W.vline(c, 52, 37, 38, R.steel[3])
  local sign = c:rrect(44, 39, 54, 49, 1)
  W.lit(c, sign, R.wood, { R = 2 })
  sign:edge():each(function(x, y) c:put(x, y, (x + y < 44 + 39 + 6) and R.wood[5] or R.wood[1]) end)
  -- spool: pale flanges + red thread wound across
  W.hline(c, 46, 52, 41, "#f6dca6") W.hline(c, 46, 52, 42, "#cf9b5c")
  W.hline(c, 46, 52, 46, "#f6dca6") W.hline(c, 46, 52, 47, "#b07a46")
  c:fillMask(c:rect(47, 43, 51, 45), R.ember[5])
  W.vline(c, 47, 43, 45, R.ember[6]) W.vline(c, 51, 43, 45, R.ember[2])
  W.hline(c, 48, 50, 44, R.ember[3]) c:put(48, 43, "#ffc4a0")
  -- quirk: loose thread dangling below the sign
  W.put(c, { {51,50}, {51,51}, {52,52}, {52,53}, {51,54} }, R.ember[3])
  c:put(51, 49, R.ember[3])

  ------------------------------------------------------------------ level 2: patched awning + bolt of cloth
  if level >= 2 then
    local aw = c:poly{ {24,33}, {40,33}, {42,37}, {22,37} }
    local awb = {}
    aw:each(function(x, y) awb[K(x, y)] = 0 end)
    aw:each(function(x, y)
      local stripe = floor((x - 22) / 3) % 2 == 0
      local base = stripe and R.ember or { "#9a8070", "#c8b49c", "#e2d2b4", "#f2e6cc", "#fbf2dc", "#fff4d6" }
      local t = (y == 33) and 6 or (y == 37) and 2 or (x > 37 and 3 or 4)
      c:put(x, y, base[t])
    end)
    -- scalloped edge
    for x = 22, 42 do if (x - 22) % 3 == 1 then c:put(x, 38, ((floor((x - 22) / 3) % 2 == 0) and R.ember[2] or "#c8b49c")) end end
    -- the patch: blue square with cream tack stitches
    c:fillMask(c:rect(35, 34, 38, 36), fabric[4])
    W.hline(c, 35, 38, 34, fabric[5]) c:put(38, 36, fabric[2])
    c:put(35, 34, "#fff4d6") c:put(38, 36, "#fff4d6")
    -- bolt of cloth leaning by the door (left): gingham roll with a spiral end on top
    local bolt, bn, BT, BS = X.cyl(7, 54, 10, 38, function() return 3.2 end)
    local bi = W.toneN(c, bolt, bn, fabric, { cuts = { .2, .36, .52, .7, .88 } })
    bolt:each(function(x, y)
      local k = K(x, y)
      local i = bi[k]
      local cy, cx = (y % 4 < 2), ((x + floor(y / 6)) % 4 < 2)
      if cy and cx then c:put(x, y, fabric[math.max(1, i - 2)])
      elseif cy or cx then c:put(x, y, fabric[math.max(1, i - 1)]) end
    end)
    -- the top end: rolled layers around a wooden core
    local endm = c:ellipse(10, 38, 3, 1.6)
    c:fillMask(endm, fabric[5])
    W.put(c, { {8,38}, {12,38}, {10,37}, {10,39} }, fabric[3])
    c:put(10, 38, R.wood[2]) c:put(9, 37, fabric[6])
  end

  ------------------------------------------------------------------ level 3: board sign, needle weathervane, clothes line
  if level >= 3 then
    -- wooden sign board on the gable with gold thread lettering
    local board = c:rrect(16, 27, 38, 32, 1)
    W.lit(c, board, R.wood, { R = 2 })
    board:edge():each(function(x, y) c:put(x, y, (y == 27 or x == 16) and R.wood[5] or R.wood[1]) end)
    -- gold thread "lettering": little looped strokes (no real text)
    local gold, goldS = "#f5b82e", "#d98322"
    local strokes = {
      {18,29},{18,30},{19,29}, {21,29},{21,30},{22,30},{22,29}, {24,30},{25,29},{25,30},
      {27,29},{28,29},{28,30}, {30,30},{30,29},{31,30}, {33,29},{33,30},{34,29},{35,30},
    }
    W.put(c, strokes, gold)
    W.put(c, { {19,30}, {25,31}, {31,29}, {35,29} }, goldS)
    -- the thread runs on past the last letter and curls off the board edge
    W.put(c, { {36,30}, {37,29} }, gold)
    -- weathervane: pole on the roof apex, a sewing needle (eye on the left, point on the right) + trailing thread
    W.vline(c, 27, 4, 7, R.steel[2]) c:put(27, 4, R.steel[4])
    local nd = c:poly{ {18.5,0.5}, {30,1}, {37.5,2.5}, {30,4}, {18.5,4.5} }
    c:fillMask(nd, R.steel[4])
    W.hline(c, 19, 30, 1, R.steel[6]) W.hline(c, 31, 35, 2, R.steel[5]) W.hline(c, 19, 31, 3, R.steel[3])
    W.hline(c, 19, 29, 4, R.steel[2])
    c:put(20, 2, W.ink) c:put(21, 2, W.ink) c:put(22, 2, R.steel[2]) -- the eye
    c:put(24, 1, "#fff4d6") c:put(25, 1, "#fff4d6")
    W.put(c, { {21,3}, {20,4}, {19,5}, {18,6}, {17,6}, {16,7} }, R.ember[4])
    -- clothes line from the roof slope to a little pole on the right
    local pole = c:rect(58, 19, 59, 55)
    W.vcyl(c, pole, R.wood, 58, 59) W.vline(c, 58, 19, 55, R.wood[5])
    c:put(58, 19, R.wood[6])
    local pts = {}
    for x = 42, 57 do local t = (x - 42) / 15 local y = floor(22 + t * (-1) + 3 * 4 * t * (1 - t) * 0.6 + 0.5) pts[#pts + 1] = { x, y } c:put(x, y, "#e2d2b4") end
    local function lineY(x) for _, p in ipairs(pts) do if p[1] == x then return p[2] end end return 22 end
    -- tiny garments: shirt, sock, shorts, with pegs
    local y0 = lineY(44)
    c:paint({ "aa.aa", "aabaa", ".aaa.", ".aaa." }, 42, y0 + 1, { a = "#5fc4c8", b = "#3a86b0" })
    c:put(43, y0 + 1, "#b6f0e0") c:put(45, y0 + 2, "#3a86b0") c:put(46, y0 + 1, "#3a86b0")
    y0 = lineY(49)
    c:paint({ "aa", "ab", "ab", "bbb" }, 48, y0 + 1, { a = "#f5b82e", b = "#e8493b" })
    y0 = lineY(53)
    c:paint({ "aaaa", "abba", "a..a" }, 52, y0 + 1, { a = "#8a6fd0", b = "#5a459e" })
    c:put(52, y0 + 1, "#c9b2f0")
    for _, x in ipairs({ 43, 46, 48, 52, 55 }) do c:put(x, lineY(x), R.wood[2]) end
  end

  W.save(c, "tailor-" .. level, { centre = false })
end

for level = 1, 3 do draw(level) end
