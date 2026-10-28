-- variety-act-g4.lua : Do-tab act cards (144x108 = 72x54 grid at out=2) for 11 rest-stop activities:
-- twist_rope shake_tree pie_contest blossom_walk oar_ferry toll_talk lantern_boats scan_horizon signal_fire
-- storm_watch soak.  Scene mode, ol=1. The wood frame ring is copied from act-hand.png so the card matches the others.
-- Families: sky/ground = water/moss/soil tints used by the existing act cards; props = wood/stone/red/gold presets.
-- run: AppRun -b --script-param out=DIR [--script-param only=slug] --script variety-act-g4.lua
local ROOT = "/home/user/gnome-venture/"
local GV = dofile(ROOT .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or "/tmp"
local ASE = ROOT .. "aseprite-source/extras-pixel/aseprite/"
local only = app.params.only
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local INK = "#2a1a10"
local frameImg = Image{ fromFile = ROOT .. "game/assets/img/acts/act-hand.png" }
local pc = app.pixelColor

local function hex(r, g, b) return string.format("#%02x%02x%02x", r, g, b) end

---------------------------------------------------------------- scene helpers
local function new() return GV.canvas{ w = 72, h = 54, mode = "scene", out = 2, ol = 1, olx = 1, cres = 3, deep = 1 } end

local function rect(c, x0, y0, x1, y1, col) c:fill(c:rect(x0, y0, x1, y1), col) end

-- the wood frame ring (x<5, x>=67, y<5, y>=49) copied from the existing cards, last
local function frame(c)
  for gy = 0, 53 do for gx = 0, 71 do
    if gx < 5 or gx >= 68 or gy < 5 or gy >= 50 then
      local v = frameImg:getPixel(gx * 2, gy * 2)
      if pc.rgbaA(v) > 0 then c:px(gx, gy, hex(pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))) end
    end
  end end
end

local SKY = {
  day   = { "#a8d4e0", "#cfe8e6" },
  dusk  = { "#e8a87a", "#f4cf98" },
  night = { "#3a4a6e", "#566690" },
  storm = { "#4a5468", "#6a7488" },
  fog   = { "#b8c4c8", "#d4dcdc" },
  spring = { "#a8d4e0", "#d8ecea" },
}
-- sky: two bands (top 12 rows, then the rest down to the horizon)
local function sky(c, kind, split)
  local s = SKY[kind]
  rect(c, 5, 5, 67, 49, s[2])
  rect(c, 5, 5, 67, split or 16, s[1])
end
local function cloud(c, x, y, w, col)
  col = col or "#f4eee0"
  rect(c, x + 2, y, x + w - 3, y, col); rect(c, x, y + 1, x + w - 1, y + 1, col); rect(c, x + 1, y + 2, x + w - 2, y + 2, col)
end
-- a hill band: top edge from f(x), filled to y1
local function hills(c, col, y1, f)
  for x = 5, 67 do local t = floor(f(x) + 0.5); if t <= y1 then rect(c, x, t, x, y1, col) end end
end
local function tuft(c, x, y, col)
  col = col or "#5e8a44"
  c:px(x, y, col); c:px(x + 1, y + 1, col); c:px(x, y + 1, col); c:px(x + 1, y - 1, col)
end
-- ground: light lip at y0, base below to the frame; tufts for grain
local function ground(c, y0, lip, base, tc)
  rect(c, 5, y0, 67, y0, lip); rect(c, 5, y0 + 1, 67, 49, base)
  for _, p in ipairs({ { 8, 3 }, { 17, 6 }, { 24, 2 }, { 50, 5 }, { 60, 2 }, { 63, 6 }, { 40, 7 }, { 33, 4 } }) do
    if y0 + p[2] <= 47 then tuft(c, p[1], y0 + p[2], tc) end
  end
end
local DAY = { hill = "#5e8a44", hill2 = "#4e8a3c", lip = "#9cc070", base = "#7ea85a", tuft = "#5e8a44" }
local function daybg(c, y0, hillTop)
  sky(c, "day", 16)
  cloud(c, 6, 5, 12); cloud(c, 48, 8, 9)
  local ht = hillTop or (y0 - 8)
  hills(c, DAY.hill, y0, function(x) return ht + (x - 5) * 0.12 + ((x // 9) % 2) end)
  ground(c, y0, DAY.lip, DAY.base, DAY.tuft)
end

local function ellipseM(c, cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function part(c, m, hexcol, o) return c:part(m, GV.ramp(hexcol), o or { flat = true }) end
local function line(c, pts, w, col, o) return c:part(c:line(pts, w), GV.ramp(col), o or { flat = true }) end
local function px(c, x, y, col) c:px(x, y, col) end

---------------------------------------------------------------- the gnome
local HAT, HATS, FACE, NOSE, BEARD, BEARDS = "#c0442e", "#8e2e1e", "#f0c8a0", "#e08a7a", "#f4eee0", "#cfc6b0"
local COAT, COATS, BOOT = "#4a6e9a", "#34507a", "#5a3a22"
local LEG = {
  H = HAT, r = HATS, n = FACE, p = NOSE, E = INK, h = BEARD, q = BEARDS, s = COAT, u = COATS, v = BOOT,
}
-- 13 wide. rows 0-11 head (hat, face, beard), rows 12-15 coat, 16-17 boots.
local HEAD = {
  ".....HH......",
  "....HHHr.....",
  "....HHHHr....",
  "...HHHHHr....",
  "...HHHHHHr...",
  "..HHHHHHHr...",
  "..HHHHHHHHr..",
  ".HHHHHHHHHHr.",
  "..nnEnnEnn...",
  "..nnnnnnnpp..",
  ".hhhhhhhhhhh.",
  ".hhhhhhhhhhq.",
}
local BODY = {
  "..hhhhhhhhq..",
  "..shhhhhhqs..",
  "..ssshhhqsu..",
  "..sssshqsuu..",
}
local FEET = { "..vvvv.vvvv.." , "..vvvv.vvvv.." }
local FEET_WALK = { "..vvv.....vvv", "..vvv.....vvv" }

-- G(c, fx, fy, o): gnome standing with feet bottom at fy, centred on fx.
-- o.dir = 1 right / -1 left, o.hat colour, o.arms = { {sx,sy, hx,hy}, ... } shoulder->hand offsets (dx rel. fx, dy rel. fy)
-- o.cut = rows of the figure hidden from the bottom (sitting behind things), o.feet = "walk"|"none"
local function G(c, fx, fy, o)
  o = o or {}
  local s = o.dir or 1
  local rows = {}
  for _, r in ipairs(HEAD) do rows[#rows + 1] = r end
  for _, r in ipairs(BODY) do rows[#rows + 1] = r end
  if o.feet ~= "none" then
    for _, r in ipairs(o.feet == "walk" and FEET_WALK or FEET) do rows[#rows + 1] = r end
  end
  local x0 = fx - 6
  local y0 = fy - 17
  local leg = {}
  for k, v in pairs(LEG) do leg[k] = v end
  if o.hat then leg.H = o.hat; leg.r = o.hats or HATS end
  if o.coat then leg.s = o.coat[1]; leg.u = o.coat[2] end
  local sil = c:mask()
  local function put(i, j, ch)
    local x = (s == 1) and (x0 + i) or (x0 + 12 - i)
    local y = y0 + j
    if ch ~= "." then
      px(c, x, y, leg[ch]); sil:set(x, y)
      if ch == "E" and o.closed then px(c, x + s, y, INK); sil:set(x + s, y) end
    end
  end
  for j, row in ipairs(rows) do
    if not o.cut or j <= #rows - o.cut then
      for i = 1, #row do put(i - 1, j - 1, row:sub(i, i)) end
    end
  end
  -- arms: 2 px sleeves with a 2x2 hand
  for _, a in ipairs(o.arms or {}) do
    local sx, sy, hx, hy = fx + s * a[1], fy + a[2], fx + s * a[3], fy + a[4]
    local m = c:line({ { sx, sy }, { hx, hy } }, 2)
    c:fill(m, COATS); sil:add(m)
    local hm = c:rect(hx, hy, hx + 1, hy + 1)
    c:fill(hm, a[5] or FACE); sil:add(hm)
  end
  c:outline(sil)
  return { x = fx, y = fy, sil = sil, s = s }
end


---------------------------------------------------------------- scenes
local S = {}
local WOOD, WOODL, WOODD = "#b07a45", "#d9a660", "#8a5a30"
local function ball(c, cx, cy, rx, ry, col, o) return c:part(c:ellipse(cx, cy, rx, ry), GV.ramp(col), o or { gloss = false }) end

-- ROPE WALK: crank at one end, three strands twisting down a dark open shed to a post
function S.twist_rope()
  local c = new()
  sky(c, "day", 16); cloud(c, 44, 6, 11)
  hills(c, DAY.hill, 33, function(x) return 28 + (x - 5) * 0.06 end)
  ground(c, 39, DAY.lip, DAY.base, DAY.tuft)
  -- the long open shed: dark inside, red roof
  rect(c, 6, 21, 65, 38, "#4a2c1a")
  rect(c, 6, 26, 65, 26, "#5a3820"); rect(c, 6, 31, 65, 31, "#5a3820")
  rect(c, 6, 36, 65, 38, "#6a4426")
  part(c, c:rect(6, 21, 8, 38), WOOD, { flat = true })
  part(c, c:rect(63, 21, 65, 38), WOOD, { flat = true })
  part(c, c:poly({ { 3, 22 }, { 8, 14 }, { 64, 14 }, { 69, 22 } }), "#c0442e", { flat = true })
  rect(c, 6, 20, 65, 20, "#8e2e1e")
  for x = 12, 60, 8 do px(c, x, 16, "#d8603e") end
  -- three strands run from hooks on the far post and twist into one rope at the wheel
  local function strand(y0, col)
    for x = 40, 55 do
      local t = (55 - x) / 15
      px(c, x, math.floor(y0 + (32 - y0) * (1 - t) + 0.5), col)
    end
  end
  strand(27, "#f4d89a"); strand(32, "#e0a850"); strand(37, "#c89040")
  for x = 31, 40 do for k = 0, 2 do px(c, x, 31 + k, (((x + k) % 4) < 2) and "#f4d89a" or "#b07a38") end end
  for x = 31, 40 do px(c, x, 30, INK); px(c, x, 34, INK) end
  px(c, 41, 31, INK); px(c, 41, 33, INK)
  part(c, c:rect(57, 24, 60, 38), WOODD, { flat = true })
  for _, y in ipairs({ 27, 32, 37 }) do rect(c, 55, y, 56, y, "#cfd4d8") end
  -- crank wheel on a stand, the gnome turning it
  part(c, c:rect(25, 32, 28, 42), WOODD, { flat = true })
  ball(c, 26, 29, 5, 5, "#d9a660", { gloss = false, flat = true })
  rect(c, 22, 29, 30, 29, INK); rect(c, 26, 25, 26, 33, INK)
  part(c, c:rect(21, 24, 22, 27), WOODD, { flat = true })
  G(c, 12, 42, { dir = 1, arms = { { 4, -4, 8, -14 } } })
  -- finished rope coiled in front
  ball(c, 52, 44, 7, 4, "#e8c070", { gloss = false })
  c:fill(c:ellipse(52, 44, 4, 2), "#a8783a"); c:fill(c:ellipse(52, 44, 2, 1), "#7ea85a")
  for _, a in ipairs({ { 47, 42 }, { 52, 41 }, { 57, 43 } }) do px(c, a[1], a[2], "#a8783a") end
  return c
end

-- SHAKE THE TREE: both hands on the trunk, apples drop
function S.shake_tree()
  local c = new()
  daybg(c, 40, 30)
  for _, x in ipairs({ 11, 24 }) do
    part(c, c:rect(x - 1, 31, x, 38), WOODD, { flat = true })
    ball(c, x, 28, 5, 4, "#4e8a3c", { gloss = false })
    px(c, x - 2, 28, "#d03a2a"); px(c, x + 2, 27, "#d03a2a")
  end
  part(c, c:rect(46, 16, 53, 41), WOOD, { gloss = false })
  part(c, c:rect(44, 38, 55, 41), WOOD, { gloss = false })
  ball(c, 50, 13, 17, 11, "#4e9a40", { gloss = false })
  ball(c, 40, 17, 7, 5, "#5ea84a", { gloss = false, flat = true })
  ball(c, 62, 18, 6, 5, "#5ea84a", { gloss = false, flat = true })
  for _, a in ipairs({ { 42, 11 }, { 50, 8 }, { 58, 14 }, { 47, 19 }, { 55, 20 }, { 39, 17 } }) do
    c:fill(c:rect(a[1], a[2], a[1] + 1, a[2] + 1), "#d03a2a"); px(c, a[1], a[2], "#f07a58")
  end
  for _, a in ipairs({ { 40, 24 }, { 43, 31 }, { 57, 27 } }) do
    part(c, c:rect(a[1], a[2], a[1] + 2, a[2] + 2), "#d03a2a", { flat = true })
    px(c, a[1] + 1, a[2] - 2, "#f4eee0"); px(c, a[1] + 1, a[2] - 4, "#cfe8e6")
  end
  for _, a in ipairs({ { 38, 21 }, { 58, 33 }, { 62, 25 } }) do px(c, a[1], a[2], "#7ab55c"); px(c, a[1] + 1, a[2] + 1, "#5ea84a") end
  for _, a in ipairs({ { 19, 44 }, { 58, 42 }, { 61, 45 }, { 28, 46 } }) do
    part(c, c:rect(a[1], a[2], a[1] + 2, a[2] + 2), "#d03a2a", { flat = true }); px(c, a[1] + 1, a[2] - 1, "#4a8a3e")
  end
  G(c, 36, 42, { dir = 1, arms = { { 4, -4, 8, -9 }, { 4, -5, 8, -14 } } })
  for _, y in ipairs({ 28, 33 }) do rect(c, 44, y, 44, y + 1, "#f4eee0") end
  return c
end

-- HARVEST PIE CONTEST: judge behind a checked table of pies, autumn trees
function S.pie_contest()
  local c = new()
  sky(c, "day", 16); cloud(c, 8, 6, 10)
  hills(c, "#7a8a48", 38, function(x) return 28 + (x - 5) * 0.04 end)
  ground(c, 38, "#c8b868", "#a89a58", "#8a7a40")
  -- autumn trees: left behind the judge, right behind the pies
  for i, x in ipairs({ 38, 52, 64 }) do
    local col = ({ "#e8a317", "#c0502e", "#d9783a" })[i]
    part(c, c:rect(x - 1, 27, x + 1, 38), WOODD, { flat = true })
    ball(c, x, 20 + (i % 2) * 2, 7, 6, col, { gloss = false })
  end
  for _, a in ipairs({ { 10, 12 }, { 20, 12 }, { 28, 20 }, { 25, 28 }, { 44, 13 }, { 58, 12 }, { 30, 34 }, { 12, 30 } }) do
    px(c, a[1], a[2], "#d9783a"); px(c, a[1] + 1, a[2], "#e8a317")
  end
  -- table with a gingham cloth, starting right of the judge
  part(c, c:rect(27, 37, 67, 38), "#e8c88a", { flat = true })
  rect(c, 27, 39, 67, 49, "#f4eee0")
  for y = 39, 49, 3 do for x = 27, 67, 3 do
    if ((x - 27) / 3 + (y - 39) / 3) % 2 == 0 then rect(c, x, y, min(x + 2, 67), min(y + 2, 49), "#d8604a") end
  end end
  rect(c, 27, 39, 27, 49, INK)
  -- three pies: cherry lattice, pumpkin with cream, berry winner
  local function pie(cx, filling, crust)
    part(c, c:ellipse(cx, 35, 7, 3), crust, { flat = true })
    c:fill(c:ellipse(cx, 34, 5, 2), filling)
  end
  pie(36, "#c0302a", "#e0a850")
  for x = 32, 40, 2 do px(c, x, 34, "#e0a850") end; for _, y in ipairs({ 33, 35 }) do px(c, 35, y, "#e0a850"); px(c, 37, y, "#e0a850") end
  pie(50, "#e08a2a", "#e0a850")
  ball(c, 50, 33, 2, 1, "#f4eee0", { gloss = false, flat = true })
  pie(63, "#6a4aa0", "#e0a850")
  px(c, 61, 34, "#8a6ac0"); px(c, 65, 33, "#8a6ac0"); px(c, 63, 35, "#8a6ac0")
  -- blue rosette on the winner
  rect(c, 61, 30, 62, 33, "#3f6fb0"); rect(c, 64, 30, 65, 33, "#3f6fb0")
  ball(c, 63, 29, 3, 3, "#3f6fb0", { gloss = false, flat = true })
  c:fill(c:rect(62, 28, 64, 30), "#e8a317"); px(c, 62, 28, "#fff1c8")
  -- the judge, full figure, a forkful at his mouth
  G(c, 15, 42, { dir = 1, arms = { { 4, -4, 9, -10 } } })
  rect(c, 24, 33, 24, 36, "#cfd4d8"); rect(c, 23, 31, 23, 33, "#cfd4d8"); rect(c, 25, 31, 25, 33, "#cfd4d8"); rect(c, 24, 31, 24, 32, "#cfd4d8")
  return c
end

-- BLOSSOM WALK: strolling along a petal-drifted path between blossom trees, following a bee
function S.blossom_walk()
  local c = new()
  sky(c, "spring", 16); cloud(c, 36, 6, 12, "#fff8f0")
  hills(c, "#7ab55c", 33, function(x) return 26 + math.abs(x - 40) * 0.08 end)
  rect(c, 5, 30, 67, 49, "#7ea85a")
  rect(c, 5, 30, 67, 30, "#9cc070")
  for y = 31, 49 do
    local half = 1 + (y - 31) * 0.95
    local cx = 44 - (y - 31) * 0.55
    rect(c, floor(cx - half), y, floor(cx + half), y, "#e8d4a0")
    c:px(floor(cx - half) - 1, y, "#c8b078"); c:px(floor(cx + half) + 1, y, "#c8b078")
  end
  for _, a in ipairs({ { 52, 34 }, { 54, 37 }, { 12, 44 }, { 62, 42 } }) do tuft(c, a[1], a[2], "#5e8a44") end
  part(c, c:rect(10, 20, 13, 38), WOODD, { flat = true })
  ball(c, 12, 15, 11, 9, "#e46a9b", { gloss = false })
  ball(c, 7, 20, 6, 4, "#f2a0c0", { gloss = false, flat = true })
  for _, a in ipairs({ { 8, 12 }, { 16, 9 }, { 13, 17 }, { 5, 17 } }) do px(c, a[1], a[2], "#fff0f4"); px(c, a[1] + 1, a[2], "#fff0f4") end
  part(c, c:rect(58, 24, 60, 37), WOODD, { flat = true })
  ball(c, 59, 20, 8, 6, "#e46a9b", { gloss = false })
  for _, a in ipairs({ { 55, 18 }, { 61, 16 }, { 58, 22 } }) do px(c, a[1], a[2], "#fff0f4"); px(c, a[1] + 1, a[2], "#fff0f4") end
  for _, a in ipairs({ { 22, 12 }, { 30, 20 }, { 44, 12 }, { 50, 24 }, { 36, 30 }, { 24, 36 }, { 20, 42 }, { 48, 46 }, { 54, 30 }, { 15, 30 }, { 62, 34 }, { 38, 40 } }) do
    px(c, a[1], a[2], "#f6b8cf"); px(c, a[1] + 1, a[2] + 1, "#e46a9b")
  end
  -- the bee: striped body, pale wings, dotted trail
  rect(c, 49, 22, 52, 23, "#f4c84a"); px(c, 50, 22, INK); px(c, 50, 23, INK); px(c, 52, 22, INK); px(c, 52, 23, INK)
  px(c, 48, 22, INK); px(c, 53, 22, "#f4c84a")
  rect(c, 49, 20, 50, 21, "#f4eee0"); rect(c, 51, 20, 52, 21, "#cfe8e6")
  px(c, 46, 25, "#f4eee0"); px(c, 43, 26, "#f4eee0"); px(c, 41, 28, "#f4eee0")
  G(c, 34, 46, { dir = 1, feet = "walk", arms = { { 4, -4, 9, -11 } } })
  return c
end

-- TAKE AN OAR: rowing a ferry boat across the river, dock and far bank behind
function S.oar_ferry()
  local c = new()
  sky(c, "day", 15); cloud(c, 40, 6, 12)
  hills(c, "#6a9a58", 28, function(x) return 24 + ((x // 7) % 3) * 0.7 end)
  -- river with stepped ripples
  rect(c, 5, 28, 67, 49, "#4a88b0")
  rect(c, 5, 28, 67, 29, "#6aa6c8")
  for _, a in ipairs({ { 8, 33 }, { 30, 31 }, { 52, 35 }, { 12, 44 }, { 58, 44 }, { 38, 47 } }) do rect(c, a[1], a[2], a[1] + 4, a[2], "#8cc4dc") end
  for _, a in ipairs({ { 9, 38 }, { 56, 40 }, { 24, 46 } }) do rect(c, a[1], a[2], a[1] + 3, a[2], "#3a6e98") end
  -- ferry dock at the left: planks, posts, a bell post
  part(c, c:rect(5, 29, 17, 31), WOODL, { flat = true })
  part(c, c:rect(7, 31, 8, 40), WOODD, { flat = true })
  part(c, c:rect(14, 31, 15, 40), WOODD, { flat = true })
  part(c, c:rect(15, 20, 16, 29), WOODD, { flat = true })
  ball(c, 18, 21, 2, 2, "#e8a317", { gloss = false, flat = true })
  px(c, 17, 22, "#f5cf6a")
  -- far oar (behind), then the boat
  local function oar(x0, y0, x1, y1, bx, by)
    line(c, { { x0, y0 }, { x1, y1 } }, 2, "#b07a45")
    part(c, c:ellipse(bx, by, 3, 2), "#d9a660", { flat = true })
  end
  oar(52, 26, 28, 37, 25, 38)
  -- boat hull
  part(c, c:poly({ { 24, 35 }, { 60, 35 }, { 56, 43 }, { 29, 43 } }), "#b07a45", { gloss = false, cres = 3 })
  rect(c, 25, 36, 59, 36, "#c0442e"); rect(c, 27, 38, 57, 38, "#8a5a30")
  -- gnome rowing
  G(c, 42, 36, { dir = 1, feet = "none", arms = { { 4, -4, 9, -7 } } })
  -- near oar crossing him, in the oarlock
  oar(52, 25, 30, 46, 27, 47)
  part(c, c:rect(38, 34, 40, 36), "#8b8f96", { flat = true })
  -- foam and splashes around the blade and the stern
  for _, a in ipairs({ { 21, 44 }, { 24, 49 }, { 31, 44 }, { 19, 41 } }) do rect(c, a[1], min(a[2], 47), a[1] + 1, min(a[2], 47), "#f4eee0") end
  rect(c, 60, 41, 64, 41, "#f4eee0"); rect(c, 62, 44, 66, 44, "#cfe8e6")
  rect(c, 26, 44, 55, 44, "#6aa6c8")
  return c
end

-- CHAT WITH THE TOLL-KEEPER: booth window, coins on the counter, striped barrier
function S.toll_talk()
  local c = new()
  daybg(c, 40, 30)
  rect(c, 5, 31, 34, 34, "#4a88b0"); rect(c, 5, 31, 34, 31, "#8cc4dc")
  -- barrier pole on a post
  local pole = c:line({ { 33, 36 }, { 28, 26 } }, 2)
  part(c, pole, "#f4eee0", { flat = true })
  for _, a in ipairs({ { 32, 34 }, { 30, 30 } }) do rect(c, a[1], a[2], a[1] + 1, a[2] + 1, "#c0442e") end
  part(c, c:rect(31, 35, 35, 41), WOODD, { flat = true })
  -- booth
  part(c, c:rect(38, 19, 64, 41), "#c89a5e", { flat = true })
  part(c, c:poly({ { 36, 20 }, { 51, 11 }, { 66, 20 } }), "#c0442e", { flat = true })
  rect(c, 40, 22, 62, 22, "#8e2e1e")
  rect(c, 42, 25, 60, 33, "#4a2c1a")
  -- keeper in the window
  G(c, 51, 35, { dir = -1, feet = "none", hat = "#4a8a3e", hats = "#2f5a2a", coat = { "#8a5a9a", "#5e3a72" } })
  -- window frame and sill counter
  rect(c, 41, 24, 61, 24, WOODD); rect(c, 41, 24, 41, 34, WOODD); rect(c, 61, 24, 61, 34, WOODD)
  part(c, c:rect(38, 34, 64, 36), WOODL, { flat = true })
  rect(c, 38, 37, 64, 37, WOODD)
  -- coin stacks
  for i, x in ipairs({ 44, 48, 55 }) do
    for k = 0, i do rect(c, x, 33 - k, x + 2, 33 - k, (k % 2 == 0) and "#e8a317" or "#f5cf6a") end
  end
  -- visitor, hand out
  G(c, 15, 42, { dir = 1, arms = { { 4, -4, 8, -12 } } })
  -- speech bubble with a coin
  part(c, c:ellipse(30, 14, 6, 4), "#f4eee0", { flat = true })
  part(c, c:poly({ { 25, 17 }, { 28, 17 }, { 24, 22 } }), "#f4eee0", { flat = true, rim = false })
  ball(c, 30, 14, 2, 2, "#e8a317", { gloss = false, flat = true }); px(c, 29, 13, "#fff1c8")
  return c
end

-- LANTERN BOATS: dusk river, launching little lantern boats from the jetty
function S.lantern_boats()
  local c = new()
  rect(c, 5, 5, 67, 49, "#566690")
  rect(c, 5, 5, 67, 11, "#2a3658"); rect(c, 5, 12, 67, 17, "#3a4a6e"); rect(c, 5, 18, 67, 23, "#4a5a84")
  for _, a in ipairs({ { 12, 8 }, { 24, 14 }, { 40, 7 }, { 55, 12 }, { 62, 18 }, { 32, 20 }, { 18, 21 } }) do px(c, a[1], a[2], "#f4eee0") end
  px(c, 48, 15, "#f4c84a")
  -- moon
  ball(c, 52, 11, 4, 4, "#f1e4a8", { gloss = false, flat = true })
  px(c, 54, 10, "#d8c880"); px(c, 53, 12, "#d8c880")
  -- far bank
  hills(c, "#2a3a50", 28, function(x) return 24 + ((x // 6) % 3) * 0.8 end)
  -- water
  rect(c, 5, 27, 67, 49, "#2f4a78")
  rect(c, 5, 27, 67, 28, "#4a6a98")
  for _, a in ipairs({ { 8, 31 }, { 40, 29 }, { 24, 35 }, { 56, 46 }, { 14, 46 }, { 44, 41 } }) do rect(c, a[1], a[2], a[1] + 4, a[2], "#4a6a98") end
  -- jetty with posts
  part(c, c:rect(5, 33, 25, 35), "#b07a45", { flat = true })
  part(c, c:rect(8, 36, 9, 45), "#6a4426", { flat = true })
  part(c, c:rect(20, 36, 21, 45), "#6a4426", { flat = true })
  -- gnome, bending to float a boat
  G(c, 14, 33, { dir = 1, arms = { { 4, -4, 10, 0 } } })
  -- boats and their glow trails
  local function boat(x, y, big)
    local w = big and 7 or 5
    -- glow reflection on the water
    for k = 2, big and 7 or 5 do rect(c, x + 2, y + 2 + k, x + w - 3, y + 2 + k, (k % 2 == 0) and "#e8a850" or "#8a6a60") end
    part(c, c:poly({ { x, y + 2 }, { x + w, y + 2 }, { x + w - 1, y + 4 }, { x + 1, y + 4 } }), "#b07a45", { flat = true })
    c:fill(c:rect(x + 1, y - 1, x + w - 2, y + 1), "#f4c84a")
    rect(c, x + 2, y, x + w - 3, y, "#fff1c8")
    rect(c, x + 1, y - 2, x + w - 2, y - 2, "#c0442e")
  end
  boat(28, 36, true); boat(43, 33, false); boat(56, 30, false)
  return c
end

-- SCAN THE HORIZON: tower top, spyglass, layered mountains, a far plume of smoke
function S.scan_horizon()
  local c = new()
  sky(c, "day", 18); cloud(c, 8, 7, 13); cloud(c, 30, 12, 9)
  hills(c, "#a8bcd0", 40, function(x) return 22 + math.abs((x - 18) % 26 - 13) * 0.55 end)
  hills(c, "#8aa6bc", 40, function(x) return 27 + math.abs((x - 44) % 22 - 11) * 0.45 end)
  hills(c, "#6a9a78", 40, function(x) return 31 + math.abs((x - 8) % 18 - 9) * 0.3 end)
  -- a thin plume of smoke rising from a far fold in the hills
  for i = 0, 9 do
    local xx = 56 + floor(1.2 * math.sin(i * 0.9) + 0.5)
    rect(c, xx, 25 - i, xx + 1, 25 - i, (i % 3 == 2) and "#8a8a98" or "#c8ccd4")
  end
  px(c, 56, 26, "#f08a24")
  -- tower platform: back rail, planked floor
  part(c, c:rect(5, 33, 67, 34), "#d9a660", { flat = true })
  for x = 9, 67, 14 do part(c, c:rect(x, 34, x + 1, 40), "#8a5a30", { flat = true }) end
  rect(c, 5, 40, 67, 49, "#c89a5e"); rect(c, 5, 40, 67, 40, "#a8703a")
  for y = 43, 49, 3 do rect(c, 5, y, 67, y, "#a8703a") end
  for _, a in ipairs({ { 20, 41 }, { 44, 44 }, { 58, 41 }, { 12, 47 }, { 36, 47 } }) do rect(c, a[1], a[2], a[1], a[2] + 1, "#a8703a") end
  -- gnome with a brass spyglass aimed at the plume
  G(c, 24, 46, { dir = 1, arms = { { 4, -4, 9, -10 } } })
  part(c, c:line({ { 31, 38 }, { 45, 28 } }, 2), "#d0862a", { flat = true })
  rect(c, 38, 33, 38, 34, "#8a4a1c")
  part(c, c:rect(45, 26, 47, 29), "#e8a317", { flat = true })
  px(c, 48, 26, "#8fd0e8"); px(c, 48, 27, "#8fd0e8")
  return c
end

-- LIGHT THE BEACON: dusk, tower top, the roaring brazier and a far tower answering
function S.signal_fire()
  local c = new()
  rect(c, 5, 5, 67, 49, "#f0a878")
  rect(c, 5, 5, 67, 12, "#5a4a8a"); rect(c, 5, 13, 67, 19, "#9a5a8a"); rect(c, 5, 20, 67, 26, "#d9708a")
  for _, a in ipairs({ { 10, 7 }, { 28, 9 }, { 60, 8 }, { 50, 14 }, { 18, 15 } }) do px(c, a[1], a[2], "#f4eee0") end
  hills(c, "#6a4a7a", 36, function(x) return 28 + math.abs((x - 22) % 30 - 15) * 0.4 end)
  hills(c, "#3e3a64", 38, function(x) return 32 + math.abs((x - 52) % 24 - 12) * 0.3 end)
  -- distant tower, its own small flame answering
  rect(c, 10, 28, 15, 34, "#2a2a4a"); rect(c, 9, 26, 16, 28, "#2a2a4a")
  rect(c, 11, 24, 14, 25, "#2a2a4a")
  rect(c, 12, 22, 13, 23, "#f08a24"); px(c, 12, 21, "#ffd25a"); px(c, 13, 20, "#f4c84a")
  -- tower top: back wall with merlons, floor
  rect(c, 5, 36, 67, 40, "#8b8f96"); rect(c, 5, 36, 67, 36, "#c9c5bc")
  for x = 5, 67, 8 do part(c, c:rect(x, 33, x + 4, 36), "#8b8f96", { flat = true }) end
  for x = 9, 67, 8 do rect(c, x, 37, x, 40, "#6a7078") end
  rect(c, 5, 41, 67, 49, "#a4a8ae"); rect(c, 5, 41, 67, 41, "#6a7078")
  for y = 45, 49, 4 do rect(c, 5, y, 67, y, "#8b8f96") end
  for _, a in ipairs({ { 14, 42 }, { 30, 46 }, { 46, 42 }, { 62, 46 } }) do rect(c, a[1], a[2], a[1], a[2] + 2, "#8b8f96") end
  -- the beacon: stone plinth, iron post, bowl, roaring flame
  part(c, c:rect(44, 38, 53, 43), "#9a9ea6", { gloss = false })
  rect(c, 44, 41, 53, 41, "#6a7078"); rect(c, 48, 38, 48, 40, "#6a7078")
  part(c, c:rect(47, 29, 50, 38), "#4a4458", { flat = true })
  part(c, c:poly({ { 40, 23 }, { 57, 23 }, { 53, 30 }, { 44, 30 } }), "#6a6478", { gloss = false })
  rect(c, 41, 24, 56, 24, "#e8a317")
  part(c, c:poly({ { 43, 24 }, { 44, 14 }, { 47, 18 }, { 48, 5 }, { 51, 16 }, { 54, 12 }, { 55, 24 } }), "#e0501f", { gloss = false, flat = true })
  c:fill(c:poly({ { 45, 24 }, { 47, 17 }, { 49, 11 }, { 51, 20 }, { 53, 24 } }), "#f08a24")
  c:fill(c:poly({ { 46, 24 }, { 48, 19 }, { 50, 19 }, { 52, 24 } }), "#ffd25a")
  px(c, 38, 16, "#f08a24"); px(c, 58, 14, "#f4c84a"); px(c, 57, 20, "#f08a24"); px(c, 41, 10, "#f4c84a")
  -- gnome with a torch, reaching in
  G(c, 29, 47, { dir = 1, arms = { { 4, -4, 10, -12 } } })
  part(c, c:line({ { 39, 33 }, { 41, 27 } }, 2), "#8a5a30", { flat = true })
  px(c, 40, 26, "#f08a24"); px(c, 41, 25, "#ffd25a")
  -- stacked logs for later
  part(c, c:rect(60, 44, 66, 46), "#8a4f2a", { flat = true })
  return c
end

-- STORM WATCH: wet tower rail, lightning over the sea, a boat to warn
function S.storm_watch()
  local c = new()
  rect(c, 5, 5, 67, 49, "#6a7488")
  rect(c, 5, 5, 67, 12, "#3a4258"); rect(c, 5, 13, 67, 19, "#4a5468"); rect(c, 5, 20, 67, 27, "#5e6a80")
  local o = { gloss = false, flat = true, rim = false, outline = false }
  ball(c, 20, 10, 15, 7, "#2a3040", o)
  ball(c, 54, 11, 15, 8, "#2a3040", o)
  ball(c, 36, 17, 11, 4, "#363e52", o)
  -- sea
  rect(c, 5, 28, 67, 49, "#3e5a7e"); rect(c, 5, 28, 67, 29, "#5a7a9e")
  for _, a in ipairs({ { 8, 32 }, { 30, 31 }, { 40, 34 }, { 16, 38 }, { 44, 33 }, { 60, 38 }, { 8, 42 } }) do rect(c, a[1], a[2], a[1] + 3, a[2], "#aab8c8") end
  -- a small boat far below
  part(c, c:poly({ { 54, 32 }, { 62, 32 }, { 60, 34 }, { 56, 34 } }), "#8a5a30", { flat = true })
  rect(c, 58, 25, 58, 31, INK); part(c, c:poly({ { 59, 25 }, { 62, 31 }, { 59, 31 } }), "#f4eee0", { flat = true, rim = false })
  -- lightning
  local bolt = { { 52, 12 }, { 48, 19 }, { 52, 19 }, { 45, 30 } }
  line(c, bolt, 2, "#f4e8a0", { flat = true, rim = false })
  for i = 1, #bolt - 1 do c:fill(c:line({ bolt[i], bolt[i + 1] }, 1), "#fffbe0") end
  -- rain streaks, slanted
  local rain = { { 8, 17 }, { 16, 25 }, { 26, 15 }, { 36, 24 }, { 40, 15 }, { 62, 24 }, { 64, 15 }, { 12, 31 }, { 58, 31 }, { 20, 38 }, { 36, 42 }, { 64, 38 }, { 46, 27 }, { 30, 31 }, { 5, 24 }, { 50, 38 }, { 24, 22 }, { 12, 40 } }
  for _, a in ipairs(rain) do
    px(c, a[1], a[2], "#c8d8ec"); px(c, a[1] - 1, a[2] + 1, "#9ab0cc"); px(c, a[1] - 2, a[2] + 2, "#9ab0cc")
  end
  -- rail, wet floor
  rect(c, 5, 44, 67, 49, "#6a5a4a"); rect(c, 5, 44, 67, 44, "#4a3a2c"); rect(c, 5, 47, 67, 47, "#4a3a2c")
  for x = 8, 67, 12 do part(c, c:rect(x, 37, x + 1, 44), "#7a5a3a", { flat = true }) end
  part(c, c:rect(5, 36, 67, 37), "#9a7a50", { flat = true })
  -- gnome in a yellow slicker: one hand on the rail, one pointing at the bolt
  G(c, 24, 48, { dir = 1, coat = { "#e8b030", "#b8841c" }, arms = { { 4, -4, 9, -14 }, { -4, -4, -8, -10 } } })
  return c
end

-- A LONG SOAK: steaming spring, only the hat and beard above the water
function S.soak()
  local c = new()
  rect(c, 5, 5, 67, 49, "#8cc0d8"); rect(c, 5, 5, 67, 15, "#6aa8c8"); rect(c, 5, 30, 67, 30, "#8cc0d8")
  hills(c, "#6a9a78", 30, function(x) return 22 + math.abs((x - 28) % 26 - 13) * 0.35 end)
  rect(c, 5, 30, 67, 49, "#7ea85a")
  -- rocks round the pool
  ball(c, 12, 32, 9, 6, "#8b8f96", { gloss = false })
  ball(c, 60, 30, 10, 7, "#8b8f96", { gloss = false })
  rect(c, 7, 26, 14, 27, "#7ab55c"); rect(c, 56, 23, 64, 24, "#7ab55c")
  -- the pool: stone lip, milky blue water
  part(c, c:ellipse(36, 42, 29, 9), "#c9c5bc", { gloss = false })
  c:fill(c:ellipse(36, 42, 26, 7), "#7ac8d0")
  c:fill(c:ellipse(36, 42, 21, 5), "#8fd8dc")
  -- the gnome, eyes shut, arms spread along the rim, water to his chest
  G(c, 36, 45, { dir = 1, feet = "none", cut = 3, closed = true, arms = { { 4, -4, 12, -6 }, { -4, -4, -12, -6 } } })
  local clip = c:rect(5, 42, 67, 49)
  c:fill(c:ellipse(36, 42, 26, 7):clip(clip), "#7ac8d0")
  c:fill(c:ellipse(36, 42, 21, 5):clip(clip), "#8fd8dc")
  rect(c, 30, 42, 42, 42, "#c8ecdc")
  rect(c, 26, 44, 46, 44, "#c8ecdc")
  for _, a in ipairs({ { 14, 43 }, { 56, 44 }, { 20, 46 }, { 44, 47 } }) do rect(c, a[1], a[2], a[1] + 2, a[2], "#c8ecdc") end
  -- steam: soft puffs rising in the gaps between the rocks
  local function wisp(x, y0, n, ph)
    for i = 0, n do
      local xx = x + floor(2 * math.sin(i * 0.6 + ph) + 0.5)
      local w = (i % 3 == 0) and 4 or 3
      rect(c, xx, y0 - i, xx + w - 1, y0 - i, (i % 4 == 3) and "#e0ece8" or "#f4eee0")
    end
  end
  wisp(25, 39, 14, 0); wisp(46, 39, 16, 2); wisp(30, 30, 5, 1)
  -- rubber duck
  part(c, c:ellipse(52, 46, 3, 2), "#f4c84a", { flat = true })
  rect(c, 54, 43, 55, 44, "#f4c84a"); px(c, 56, 44, "#e0501f")
  px(c, 8, 46, "#e46a9b"); px(c, 9, 46, "#f6b8cf")
  return c
end

-- ==RUN==
local order = { "twist_rope", "shake_tree", "pie_contest", "blossom_walk", "oar_ferry", "toll_talk",
  "lantern_boats", "scan_horizon", "signal_fire", "storm_watch", "soak" }
for _, n in ipairs(order) do
  if S[n] and (not only or only == n) then
    local c = S[n]()
    frame(c)
    local t = c:save(ASE .. "variety-act-" .. n .. ".aseprite", OUT .. "/act-" .. n .. ".png")
    print(n, GV.report(t))
  end
end
