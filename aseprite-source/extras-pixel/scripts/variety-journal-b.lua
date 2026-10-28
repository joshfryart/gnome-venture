-- variety-journal-b.lua : Road Journal region pictures (96x96, shown at 48px beside a region's page), set B:
-- mena wca esa csa ea sea oc.  Each is a small sketch of one typical thing, taped on a cream journal page.
-- Run: Aseprite -b --script-param only=<code> --script variety-journal-b.lua   (no only = all seven)
-- Params: root=<repo> only=<code> png=<dir> ase=<dir>
local P = app.params
local root = P.root or "/home/user/gnome-venture"
local GV = dofile(root .. "/aseprite-source/gvlib/gvlib.lua")
local PNG = P.png or (root .. "/game/assets/img/journal")
local ASE = P.ase or (root .. "/aseprite-source/extras-pixel/aseprite")
local ONLY = P.only or ""

local PAPER = GV.ramp("#f1ece0")
local TAPE = GV.ramp("#ecd48a")
local INK = "#4a2c1a"

local function canvas() return GV.canvas{ w = 96, h = 96, mode = "icon", cres = 6, deep = 2, ol = 2, olx = 1 } end

-- the journal page every picture sits on (same card as variety-journal-a.lua): cream, stitched edge, faint ruled lines
local function page(c)
  c:part(c:rrect(9, 9, 86, 86, 3), PAPER, { stitch = { side = "lit" }, gloss = false, cres = 4, deep = 1 })
  for _, y in ipairs({ 22, 31, 40, 49, 58, 67, 76 }) do
    for x = 15, 80 do if c:get(x, y) then c:px(x, y, "#e6d9b4") end end
  end
  return { x0 = 9, y0 = 9, x1 = 86, y1 = 86 }
end
local function tape(c) end   -- (the first draft taped the page at the top; dropped to match set A)

-- bresenham pixel line (only onto pixels that are already painted when `only` is set)
local function dline(c, x0, y0, x1, y1, hex, only)
  x0, y0, x1, y1 = math.floor(x0 + 0.5), math.floor(y0 + 0.5), math.floor(x1 + 0.5), math.floor(y1 + 0.5)
  local dx, dy = math.abs(x1 - x0), -math.abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    if not only or c:get(x0, y0) then c:px(x0, y0, hex) end
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy; x0 = x0 + sx end
    if e2 <= dx then err = err + dx; y0 = y0 + sy end
  end
end
local function box(c, x0, y0, x1, y1, hex) for y = y0, y1 do for x = x0, x1 do c:px(x, y, hex) end end end

local R = {}
------------------------------------------------------------------ MENA: date palm on dunes
R.mena = function()
  local c = canvas(); local pg = page(c); local card = c:rect(pg.x0, pg.y0, pg.x1, pg.y1)
  local SAND = GV.ramp("#e8c47c")
  local SAND2 = GV.ramp("#d6a65c")
  local LEAF = GV.ramp("#5f9a3c")
  local TRUNK = GV.ramp("#a8744a")
  -- sun
  c:part(c:ellipse(71, 66, 8, 8), "gold", { cres = 4, deep = 1 })
  -- far dune, near dune
  c:part(c:ellipse(30, 90, 36, 22):clip(card), SAND, { gloss = false, cres = 5, deep = 1 })
  c:part(c:ellipse(66, 96, 36, 22):clip(card), SAND2, { gloss = false, cres = 5, deep = 1 })
  -- trunk (leans a little)
  c:part(c:line({ { 40, 72 }, { 41, 62 }, { 43, 52 }, { 46, 42 }, { 48, 36 } }, 5), TRUNK, { gloss = false })
  for _, p in ipairs({ { 41, 68 }, { 43, 60 }, { 45, 52 }, { 47, 44 } }) do dline(c, p[1] - 1, p[2], p[1] + 2, p[2] + 1, "#8a4f2a", true) end
  -- fronds: five arching leaves from the crown (49, 34)
  local fr = {
    { { 49, 33 }, { 40, 22 }, { 27, 20 }, { 15, 30 }, { 12, 44 }, { 21, 34 }, { 33, 33 }, { 44, 40 } },
    { { 49, 33 }, { 58, 22 }, { 71, 20 }, { 83, 30 }, { 86, 44 }, { 77, 34 }, { 65, 33 }, { 54, 40 } },
    { { 48, 33 }, { 37, 22 }, { 39, 16 }, { 48, 19 }, { 52, 28 } },
    { { 50, 33 }, { 59, 22 }, { 57, 16 }, { 50, 19 }, { 47, 28 } },
  }
  for _, f in ipairs(fr) do local pts = {}; for i, q in ipairs(f) do pts[i] = { q[1], q[2] } end c:part(c:poly(pts), LEAF, { gloss = false, cres = 3, deep = 1 }) end
  dline(c, 48, 33, 15, 30, "#3f6a2a", true); dline(c, 50, 33, 83, 30, "#3f6a2a", true)
  -- date cluster
  c:part(c:ellipse(46, 40, 3, 3), "wood", { cres = 2, deep = 1, gloss = false })
  c:part(c:ellipse(52, 40, 3, 3), "wood", { cres = 2, deep = 1, gloss = false })
  -- a little lantern on the sand, right
  c:part(c:rect(25, 52, 26, 56), "gold", { flat = true })
  c:part(c:rrect(22, 56, 29, 68, 2), "gold", { cres = 3, deep = 1, gloss = false })
  box(c, 24, 59, 27, 65, "#fff1c8")
  c:part(c:rect(21, 69, 30, 71), "wood", { flat = true })
  tape(c)
  return c
end

------------------------------------------------------------------ WCA: djembe drum with kente band
R.wca = function()
  local c = canvas(); page(c)
  local BODY = GV.ramp("#a5552a")
  local HEAD = GV.ramp("#eadab0")
  local LEAF = GV.ramp("#4f9a3c")
  -- big leaves behind
  c:part(c:ellipse(19, 52, 6, 17), LEAF, { gloss = false, cres = 3, deep = 1 })
  c:part(c:ellipse(77, 50, 6, 17), LEAF, { gloss = false, cres = 3, deep = 1 })
    dline(c, 19, 38, 19, 66, "#2f5a2a", true); dline(c, 77, 36, 77, 64, "#2f5a2a", true)
  -- goblet body
  local body = c:poly({ { 29, 36 }, { 67, 36 }, { 62, 50 }, { 56, 60 }, { 56, 66 }, { 66, 80 }, { 30, 80 }, { 40, 66 }, { 40, 60 }, { 34, 50 } })
  c:part(body, BODY, { gloss = false, cres = 6, deep = 2 })
  -- kente bands on the foot
  box(c, 33, 74, 63, 74, "#e8a317"); box(c, 34, 76, 62, 76, "#2f5a2a"); box(c, 32, 78, 64, 78, "#e8a317")
  -- rope lacing: ropes run from the rim down to a metal ring at the waist
  for x = 33, 63, 5 do dline(c, x, 43, 48 + math.floor((x - 48) * 0.55), 58, "#f5e4b0", true) end
  box(c, 39, 59, 56, 60, "#8b8f96")
  -- drumhead and its metal ring
  c:part(c:ellipse(47.5, 36, 21, 7), "stone", { cres = 3, deep = 1, gloss = false })
  c:part(c:ellipse(47.5, 36, 18, 5), HEAD, { cres = 3, deep = 1, gloss = false, contour = false })
  for _, p in ipairs({ { 38, 36 }, { 46, 38 }, { 55, 35 }, { 60, 37 } }) do c:px(p[1], p[2], "#c9a96e") end
  tape(c)
  return c
end

------------------------------------------------------------------ ESA: flat-topped acacia on the savanna
R.esa = function()
  local c = canvas(); local pg = page(c); local card = c:rect(pg.x0, pg.y0, pg.x1, pg.y1)
  local GRASS = GV.ramp("#d6b25a")
  local TOP = GV.ramp("#5f8a3a")
  c:part(c:ellipse(74, 68, 8, 8), GV.ramp("#f0793a"), { cres = 4, deep = 1 })
  c:part(c:ellipse(48, 100, 52, 28):clip(card), GRASS, { gloss = false, cres = 6, deep = 1 })
  -- trunk with a fork
  c:part(c:line({ { 46, 78 }, { 47, 66 }, { 48, 56 } }, 5), "wood", { gloss = false })
  c:part(c:line({ { 48, 58 }, { 38, 48 }, { 32, 44 } }, 3), "wood", { gloss = false, flat = true })
  c:part(c:line({ { 48, 58 }, { 58, 48 }, { 66, 44 } }, 3), "wood", { gloss = false, flat = true })
  -- flat canopy
  c:part(c:ellipse(48, 38, 30, 8), TOP, { cres = 4, deep = 2, gloss = false })
  c:part(c:ellipse(40, 30, 16, 6), TOP, { cres = 3, deep = 1, gloss = false })
  c:part(c:ellipse(58, 29, 14, 5), TOP, { cres = 3, deep = 1, gloss = false })
  -- grass tufts
  for _, p in ipairs({ { 22, 76 }, { 34, 72 }, { 56, 76 }, { 82, 78 } }) do dline(c, p[1], p[2], p[1] - 1, p[2] - 4, "#8a6a2a"); dline(c, p[1] + 2, p[2], p[1] + 3, p[2] - 4, "#8a6a2a") end
  tape(c)
  return c
end

------------------------------------------------------------------ CSA: snow peak with prayer flags
R.csa = function()
  local c = canvas(); local pg = page(c); local card = c:rect(pg.x0, pg.y0, pg.x1, pg.y1)
  local ROCK = GV.ramp("#6f86b0")
  local ROCK2 = GV.ramp("#a0b0cc")
  local SNOW = GV.ramp("#e2ebf6")
  c:part(c:poly({ { 28, 30 }, { 46, 76 }, { 8, 76 } }):clip(card), ROCK2, { gloss = false, cres = 6, deep = 1 })
  local big = c:poly({ { 56, 20 }, { 88, 80 }, { 26, 80 } }):clip(card)
  c:part(big, ROCK, { gloss = false, cres = 8, deep = 2 })
  local snow = c:poly({ { 56, 20 }, { 74, 54 }, { 68, 48 }, { 62, 56 }, { 56, 48 }, { 50, 56 }, { 44, 48 }, { 38, 54 } }):clip(big)
  c:part(snow, SNOW, { gloss = false, cres = 3, deep = 1 })
  -- foreground hill
  c:part(c:ellipse(48, 96, 48, 20):clip(card), GV.ramp("#6a9a3a"), { gloss = false, cres = 4, deep = 1 })
  -- two poles and a string of flags
  c:part(c:rect(14, 40, 16, 76), "wood", { flat = true })
  c:part(c:rect(79, 40, 81, 76), "wood", { flat = true })
  local cols = { "#3f8fb0", "#f1ece0", "#dd3a2a", "#4a8a3e", "#e8a317" }
  local function sag(x) return 44 + math.floor(math.sin((x - 16) / 64 * math.pi) * 8 + 0.5) end
  for x = 17, 78 do c:px(x, sag(x), "#4a2c1a") end
  for i = 0, 4 do
    local x = 21 + i * 11
    local y = sag(x + 3) + 1
    box(c, x, y, x + 6, y + 8, cols[i + 1])
    box(c, x, y + 8, x + 6, y + 8, "#4a2c1a")
    for yy = y, y + 8 do c:px(x, yy, "#4a2c1a"); c:px(x + 6, yy, "#4a2c1a") end
    for xx = x, x + 6 do c:px(xx, y, "#4a2c1a") end
  end
  tape(c)
  return c
end

------------------------------------------------------------------ EA: torii gate and cherry blossom
R.ea = function()
  local c = canvas(); local pg = page(c); local card = c:rect(pg.x0, pg.y0, pg.x1, pg.y1)
  local PINK = GV.ramp("#f2a6b8")
  c:part(c:ellipse(48, 98, 46, 20):clip(card), GV.ramp("#a4b86a"), { gloss = false, cres = 4, deep = 1 })
  -- blossom branch behind
  c:part(c:line({ { 12, 22 }, { 24, 26 }, { 38, 22 } }, 3), "wood", { flat = true })
  c:part(c:line({ { 84, 18 }, { 72, 22 }, { 60, 20 } }, 3), "wood", { flat = true })
  for _, p in ipairs({ { 20, 20 }, { 30, 24 }, { 38, 19 }, { 80, 16 }, { 70, 20 }, { 60, 17 } }) do c:part(c:ellipse(p[1], p[2], 5, 4), PINK, { cres = 3, deep = 1, gloss = false }) end
  -- pillars and beams
  c:part(c:rect(24, 40, 31, 80), "red", { cres = 4, deep = 1, gloss = false })
  c:part(c:rect(65, 40, 72, 80), "red", { cres = 4, deep = 1, gloss = false })
  c:part(c:rect(20, 76, 35, 82), GV.ramp("#8b8f96"), { flat = true })
  c:part(c:rect(61, 76, 76, 82), GV.ramp("#8b8f96"), { flat = true })
  c:part(c:rect(29, 50, 67, 55), "red", { cres = 3, deep = 1, gloss = false })
  local top = c:poly({ { 14, 32 }, { 82, 32 }, { 78, 42 }, { 18, 42 } })
  top:add(c:poly({ { 12, 28 }, { 18, 32 }, { 14, 32 } })):add(c:poly({ { 84, 28 }, { 82, 32 }, { 78, 32 } }))
  c:part(top, GV.ramp("#3d2a1c"), { gloss = false, cres = 4, deep = 1 })
  c:part(c:rect(18, 30, 78, 33), "red", { flat = true, contour = false })
  -- falling petals
  for _, p in ipairs({ { 44, 66 }, { 52, 72 }, { 56, 62 }, { 40, 60 } }) do c:part(c:rect(p[1], p[2], p[1] + 2, p[2] + 1), PINK, { flat = true, rim = false, contour = false, contact = false }) end
  tape(c)
  return c
end

------------------------------------------------------------------ SEA: conical straw hat on a paddy
R.sea = function()
  local c = canvas(); local pg = page(c); local card = c:rect(pg.x0, pg.y0, pg.x1, pg.y1)
  local STRAW = GV.ramp("#d9b86a")
  local PADDY = GV.ramp("#7ab55c")
  c:part(c:ellipse(48, 94, 52, 20):clip(card), PADDY, { gloss = false, cres = 4, deep = 1 })
  for _, x in ipairs({ 18, 26, 70, 78 }) do dline(c, x, 78, x - 2, 68, "#2f5a2a"); dline(c, x, 78, x + 2, 68, "#2f5a2a"); dline(c, x + 1, 78, x + 1, 66, "#4a8a3e") end
  local hat = c:poly({ { 48, 24 }, { 82, 64 }, { 14, 64 } })
  hat:add(c:ellipse(47.5, 64, 34, 8))
  c:part(hat, STRAW, { cres = 8, deep = 2, gloss = { 43, 36 } })
  -- weave rings and spokes (only on the hat)
  for _, y in ipairs({ 38, 48, 58 }) do for x = 10, 86 do if hat:has(x, y) and (x + y) % 3 ~= 0 and c:get(x, y) == STRAW.base then c:px(x, y, "#b8944a") end end end
  for _, t in ipairs({ -24, -12, 0, 12, 24 }) do dline(c, 48, 28, 48 + t * 1.4, 66, "#b8944a", true) end
  c:button(46, 22)
  tape(c)
  return c
end

------------------------------------------------------------------ OC: kiwi in the fern
R.oc = function()
  local c = canvas(); local pg = page(c); local card = c:rect(pg.x0, pg.y0, pg.x1, pg.y1)
  local FERN = GV.ramp("#4f9a3c")
  local FUR = GV.ramp("#9a7248")
  local BEAK = GV.ramp("#e8d29a")
  c:part(c:ellipse(48, 98, 50, 20):clip(card), GV.ramp("#a4b86a"), { gloss = false, cres = 4, deep = 1 })
  -- fern leaves behind
  c:part(c:poly({ { 66, 16 }, { 78, 24 }, { 84, 38 }, { 74, 46 }, { 68, 32 } }), FERN, { gloss = false, cres = 3, deep = 1 })
  c:part(c:poly({ { 24, 16 }, { 36, 22 }, { 34, 36 }, { 22, 40 }, { 18, 28 } }), FERN, { gloss = false, cres = 3, deep = 1 })
  dline(c, 67, 18, 78, 42, "#2f5a2a", true); dline(c, 25, 18, 24, 38, "#2f5a2a", true)
  -- legs
  c:part(c:rect(44, 68, 47, 76), GV.ramp("#e07a2a"), { flat = true })
  c:part(c:rect(56, 68, 59, 76), GV.ramp("#e07a2a"), { flat = true })
  c:part(c:rect(41, 76, 49, 78), GV.ramp("#e07a2a"), { flat = true })
  c:part(c:rect(53, 76, 61, 78), GV.ramp("#e07a2a"), { flat = true })
  -- round body, head, long beak
  c:part(c:ellipse(54, 54, 22, 19), FUR, { cres = 7, deep = 2 })
  c:part(c:ellipse(32, 48, 9, 8), FUR, { cres = 4, deep = 1, gloss = false })
  c:part(c:line({ { 25, 50 }, { 19, 57 }, { 13, 66 } }, 3), BEAK, { flat = true })
  c:eye(30, 42, true)
  -- feather flecks
  for _, p in ipairs({ { 50, 46 }, { 58, 44 }, { 64, 52 }, { 52, 58 }, { 60, 62 }, { 46, 54 }, { 68, 60 } }) do dline(c, p[1], p[2], p[1] + 2, p[2] + 2, "#c9a06a", true) end
  tape(c)
  return c
end

local order = { "mena", "wca", "esa", "csa", "ea", "sea", "oc" }
for _, code in ipairs(order) do
  if ONLY == "" or ONLY == code then
    local c = R[code]()
    local t = c:save(ASE .. "/variety-journal-" .. code .. ".aseprite", PNG .. "/" .. code .. ".png")
    print(code .. " " .. GV.report(t))
  end
end
