-- variety-act-g2.lua : rest-stop activity cards (Do tab), 144x108 = 72x54 grid at out=2, framed like act-hand.png.
-- Slugs: wind_sails tall_tale rainy_stories room_rest night_supper cards make_wish quiet_hour moss_tend star_vigil dawn_bell
-- Look: the existing act-*.png cards (flat felt shapes, 1 grid px outline, wooden frame stamped from act-hand.png).
-- Run: AppRun -b --script-param out=DIR --script-param ase=DIR --script-param only=<slug> --script variety-act-g2.lua
local REPO = "/home/user/gnome-venture/"
local GV = dofile(REPO .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (REPO .. "game/assets/img/acts")
local ASE = app.params.ase or (REPO .. "aseprite-source/extras-pixel/aseprite")
local only = app.params.only
local floor, max, min, sin = math.floor, math.max, math.min, math.sin
local FRAME = Image{ fromFile = REPO .. "game/assets/img/acts/act-hand.png" }

------------------------------------------------------------------ helpers
local function hexof(v)
  local pc = app.pixelColor
  return string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
end
-- the wooden frame, exact copy of act-hand.png (x 0-4 and 68-71, y 0-4 and 50-53); corners stay transparent
local function frame(c)
  for y = 0, 53 do for x = 0, 71 do
    if x < 5 or x > 67 or y < 5 or y > 49 then
      local v = FRAME:getPixel(x * 2, y * 2)
      if app.pixelColor.rgbaA(v) == 0 then c.pix[c:key(x, y)] = nil else c:px(x, y, hexof(v)) end
    end
  end end
end
local function newc() return GV.canvas{ w = 72, h = 54, mode = "scene", out = 2, ol = 1, olx = 0, cres = 2, deep = 1 } end
local function P(c, m, hex, o) o = o or {}; if o.gloss == nil then o.gloss = false end; return c:part(m, type(hex) == "table" and hex or GV.ramp(hex), o) end
local function F(c, m, hex) return c:fill(m, hex) end
local function rect(c, x0, y0, x1, y1, hex) return c:fill(c:rect(x0, y0, x1, y1), hex) end

local LEG = { R = "#c0442e", r = "#8e2e1e", O = "#74462a", D = "#4a2c1a", K = "#2a1a10", S = "#f0c8a0", s = "#d4a27a",
  P = "#e08a7a", W = "#f4eee0", w = "#cfc6b0", B = "#4a6e9a", b = "#34507a", T = "#5a3a22", t = "#74462a", G = "#e8a317", g = "#f5cf6a" }
local function sprite(c, rows, x0, y0, flip, leg)
  leg = leg or LEG
  local w = 0
  for _, r in ipairs(rows) do w = max(w, #r) end
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i)
    local v = leg[ch]
    if v then
      local x = flip and (x0 + w - i) or (x0 + i - 1)
      c:px(x, y0 + j - 1, v)
    end
  end end
end

-- the gnome (12 wide, 19 tall, facing right): same hat, face, beard, coat as act-hand.png
local HEAD = {
  ".......O....",
  ".....OOrD...",
  "....ORRRD...",
  "....ORRRrD..",
  "...ORRRRRD..",
  "...ORRRRRrK.",
  "..ORRRRRRRK.",
  "..ORRRRRRRrK",
  ".OrrrrrrrrrK",
  "..OSSSSKSSSK",
  "..OWWWWWPwKK",
  ".OBWWWWWwBbK",
  ".OBBWWWWwBbK",
  ".OBBWWWWwBbK",
}
local BODY = {
  ".OBBwWwwwBbK",
  ".DBBBBwBBBbK",
}
local LEGS = {
  ".DTTTTbTTTTK",
  ".DTTTTKTTTTK",
  "..DKKK.KKKK.",
}
local function cat(...) local o = {} for _, t in ipairs({ ... }) do for _, r in ipairs(t) do o[#o + 1] = r end end return o end
local STAND = cat(HEAD, BODY, LEGS)
local HEADONLY = cat(HEAD, { ".OBBwWwwwBbK" })
-- sitting on a seat: legs out to the right, boots on the ground
local SIT = cat(HEAD, BODY, { ".DTTTTTTTTTTTTK", "..DKKKKKKKKTTTK", "..........DTTTK", "..........DKKKK." })
local KNEEL = cat(HEAD, BODY, { ".DTTTTbTTTTTTK", "..DKKKKKKKKKKKK" })

local function limb(c, pts, w, col)
  P(c, c:line(pts, w or 2), col or "#4a6e9a", { flat = true })
end
local function hand(c, x, y, r)
  P(c, c:ellipse(x, y, r or 1.5, r or 1.5), "#f0c8a0", { flat = true })
end

-- a hill line: top row per column; returns mask of hill body
local function hillmask(c, x0, x1, ybase, base, amp, ph)
  local m = c:mask()
  for x = x0, x1 do
    local top = ybase - floor(amp * (0.5 + 0.5 * sin((x + (ph or 0)) / 6.5)) + amp * 0.5 * sin((x + (ph or 0)) / 2.9))
    for y = top, base do m:set(x, y) end
  end
  return m
end

local function landscape(c, o)
  o = o or {}
  local sky = o.sky or { "#a8d4e0", "#a8d4e0", "#cfe8e6" }
  c:bands(c:rect(5, 5, 67, 31), sky, { dir = "v" })
  F(c, hillmask(c, 5, 67, o.hy or 28, 40, o.amp or 3, o.ph or 0), o.hill or "#5e8a44")
  rect(c, 5, 40, 67, 40, o.line or "#9cc070")
  c:bands(c:rect(5, 41, 67, 49), o.grass or { "#7ea85a" }, { dir = "v" })
  for _, t in ipairs(o.tufts or { { 12, 45 }, { 24, 47 }, { 60, 44 }, { 54, 47 } }) do
    c:px(t[1], t[2], o.tuft or "#5e8a44"); c:px(t[1] + 1, t[2] - 1, o.tuft or "#5e8a44"); c:px(t[1], t[2] + 1, o.tuft or "#5e8a44")
  end
end

local function cloud(c, x, y, w, hex)
  hex = hex or "#f4eee0"
  F(c, c:ellipse(x, y, w, 2):add(c:ellipse(x - w // 2, y + 1, w // 2 + 1, 2)), hex)
end
local function star(c, x, y, hex) c:px(x, y, hex or "#fff3c8") end
local function sparkle(c, x, y, hex) hex = hex or "#fff3c8"; c:px(x, y, hex); c:px(x - 1, y, hex); c:px(x + 1, y, hex); c:px(x, y - 1, hex); c:px(x, y + 1, hex) end

local SCENES = {}
-- solid flat shape with the 1 px selective outline (matches the sprite look of act-hand.png)
local function SOL(c, m, hex) F(c, m, hex); c:outline(m); return m end
local function arm(c, pts, hx, hy, sleeve)
  SOL(c, c:line(pts, 2), sleeve or "#4a6e9a")
  SOL(c, c:ellipse(hx, hy, 1.5, 1.5), "#f0c8a0")
end
local function rain(c, seed, skip)
  local v = seed
  for gy = 5, 47, 6 do for gx = 5, 66, 8 do
    v = (v * 1103515245 + 12345) % 2147483648
    local x = gx + (v // 7) % 8
    v = (v * 1103515245 + 12345) % 2147483648
    local y = gy + (v // 7) % 6
    if not (skip and skip(x, y)) then
      c:px(x, y, "#eef5f8"); c:px(x - 1, y + 1, "#d2e0e8")
    end
  end end
end

------------------------------------------------------------------ 1 wind_sails (mill, wind)
SCENES.wind_sails = function(c)
  landscape(c, { sky = { "#8fb6cc", "#a6c8d8", "#bfd9e2", "#d6e8ec" }, hill = "#6a9a50", line = "#a4c878", grass = { "#7ea85a" }, hy = 29, amp = 2, ph = 8 })
  -- wind streaks and a flying leaf
  for _, w in ipairs({ { 8, 12, 22, 0 }, { 12, 17, 30, 1 }, { 6, 22, 16, 0 }, { 20, 9, 32, 1 } }) do
    F(c, c:line({ { w[1], w[2] }, { w[3], w[2] } }, 1), "#f4eee0")
    c:px(w[3] + 1, w[2] - 1, "#f4eee0"); c:px(w[3] + 2, w[2] - 1 + w[4], "#f4eee0")
  end
  c:px(30, 20, "#4a8a3e"); c:px(31, 20, "#4a8a3e"); c:px(31, 21, "#2f5a2a")
  -- the mill: plaster tower, wooden cap, door
  P(c, c:poly({ { 46, 27 }, { 60, 27 }, { 62, 42 }, { 44, 42 } }), "#e8d6b2", { cres = 2 })
  P(c, c:poly({ { 45, 27 }, { 61, 27 }, { 53, 18 } }), "#a8582f", { cres = 3 })
  P(c, c:rrect(50, 35, 56, 42, 1), "#7a4a1f", { flat = true })
  c:px(51, 38, "#f5cf6a")
  -- four sails
  local hx, hy = 53, 23
  local blades = c:mask()
  for _, d in ipairs({ { 1, -1 }, { 1, 1 }, { -1, 1 }, { -1, -1 } }) do
    local nx, ny = -d[2], d[1]
    local function pt(r, w) return { floor(hx + d[1] * r + nx * w + 0.5), floor(hy + d[2] * r + ny * w + 0.5) } end
    blades:add(c:poly({ pt(3, 1), pt(13, 2), pt(13, -2), pt(3, -1) }))
  end
  F(c, blades, "#f4eee0"); c:outline(blades)
  for _, d in ipairs({ { 1, -1 }, { 1, 1 }, { -1, 1 }, { -1, -1 } }) do
    F(c, c:line({ { hx + d[1] * 3, hy + d[2] * 3 }, { hx + d[1] * 13, hy + d[2] * 13 } }, 1), "#a06a3a")
  end
  P(c, c:ellipse(hx, hy, 2.5, 2.5), "#e8a317", { flat = true })
  -- gnome hauling a sail rope
  local gx, gy = 15, 24
  F(c, c:line({ { 42, 33 }, { 38, 37 }, { 33, 38 }, { 30, 36 } }, 1), "#5a3a22")
  rect(c, 41, 33, 42, 34, "#5a3a22")
  sprite(c, STAND, gx, gy)
  arm(c, { { gx + 10, gy + 12 }, { gx + 13, gy + 11 } }, gx + 14, gy + 11)
end

------------------------------------------------------------------ 2 tall_tale (inn, dusk)
SCENES.tall_tale = function(c)
  c:bands(c:rect(5, 5, 67, 37), { "#4a3a5e", "#4f3f64", "#55466a" }, { dir = "v" })
  for x = 8, 67, 8 do rect(c, x, 5, x, 37, "#42344f") end
  c:bands(c:rect(5, 38, 67, 49), { "#8a5a3a", "#7a4a2e", "#6c4026" }, { dir = "v" })
  rect(c, 5, 38, 67, 38, "#3a2a40"); rect(c, 5, 42, 67, 42, "#5e3a22"); rect(c, 5, 46, 67, 46, "#5e3a22")
  -- warm glow from the hearth on the floor
  F(c, c:ellipse(55, 45, 14, 3):clip(c:rect(5, 39, 67, 49)), "#a46e44")
  -- window with dusk sky
  P(c, c:rect(8, 9, 19, 24), "#a06a3a", { flat = true })
  c:bands(c:rect(10, 11, 17, 22), { "#2e3a6e", "#3a4a7e", "#6a5a8a", "#c47a6a" }, { dir = "v" })
  rect(c, 13, 11, 14, 22, "#a06a3a"); rect(c, 10, 16, 17, 17, "#a06a3a")
  c:px(11, 12, "#fff3c8"); c:px(16, 14, "#fff3c8")
  -- hearth
  P(c, c:rect(45, 17, 66, 38), "#8b8f96", { cres = 2 })
  rect(c, 45, 17, 66, 17, "#b9bcc0")
  for _, l in ipairs({ 22, 27 }) do rect(c, 45, l, 66, l, "#6e737b") end
  P(c, c:rect(43, 14, 67, 17), "#a06a3a", { flat = true })
  rect(c, 49, 28, 62, 38, "#2a1a10")
  F(c, c:poly({ { 51, 38 }, { 54, 30 }, { 56, 34 }, { 58, 29 }, { 61, 38 } }), "#e0501f")
  F(c, c:poly({ { 53, 38 }, { 55, 33 }, { 57, 36 }, { 58, 32 }, { 59, 38 } }), "#f08a24")
  F(c, c:poly({ { 55, 38 }, { 56, 35 }, { 57, 38 } }), "#f5cf6a")
  P(c, c:rect(50, 37, 61, 38), "#5a3a22", { flat = true, outline = false })
  -- speech bubble with the snail who ran the mail
  local bub = c:rrect(22, 7, 41, 20, 3):add(c:poly({ { 31, 19 }, { 37, 19 }, { 35, 24 } }))
  F(c, bub, "#f4eee0"); c:outline(bub)
  -- snail: green body, spiral shell, feelers, a letter tucked on its back
  F(c, c:rect(25, 16, 37, 17), "#7ab55c"); F(c, c:rect(35, 13, 37, 17), "#7ab55c")
  c:px(37, 11, "#2a1a10"); c:px(36, 12, "#2a1a10"); c:px(38, 11, "#2a1a10"); c:px(38, 12, "#2a1a10")
  c:px(36, 14, "#2a1a10")
  local sh = c:ellipse(30, 13.5, 4, 3.5); SOL(c, sh, "#c98a44")
  c:px(30, 13, "#8a4f2a"); c:px(31, 13, "#8a4f2a"); c:px(31, 12, "#8a4f2a"); c:px(29, 12, "#8a4f2a"); c:px(29, 14, "#8a4f2a"); c:px(30, 15, "#8a4f2a")
  rect(c, 25, 11, 27, 13, "#f4eee0"); rect(c, 25, 11, 27, 11, "#d6322b"); c:outline(c:rect(25, 11, 27, 13))
  -- the gnome on a stool, telling it with a wide gesture
  local gx, gy = 20, 24
  P(c, c:rect(gx + 1, 41, gx + 9, 42), "#b07a45", { flat = true })
  P(c, c:rect(gx + 2, 43, gx + 3, 46), "#74462a", { flat = true }); P(c, c:rect(gx + 7, 43, gx + 8, 46), "#74462a", { flat = true })
  sprite(c, SIT, gx, gy)
  arm(c, { { gx + 10, gy + 12 }, { gx + 15, gy + 8 } }, gx + 16, gy + 7)
end

------------------------------------------------------------------ 3 rainy_stories (inn/camp/shrine, rain)
local LEG2 = {}
for k, v in pairs(LEG) do LEG2[k] = v end
LEG2.R = "#3e8a54"; LEG2.r = "#2a6040"; LEG2.B = "#d0a040"; LEG2.b = "#a07c30"; LEG2.W = "#cfc6b0"; LEG2.w = "#a8a090"
SCENES.rainy_stories = function(c)
  landscape(c, { sky = { "#8f9fae", "#a3b1bc", "#b6c2cb", "#c6d0d6" }, hill = "#58806c", line = "#8fb27a", grass = { "#6f9a64", "#648f5c" }, hy = 29, amp = 3, ph = 14, tuft = "#4f7460" })
  -- clouds, then rain everywhere except under the tarp
  cloud(c, 18, 9, 9, "#7d8c9a"); cloud(c, 52, 8, 10, "#7d8c9a"); cloud(c, 36, 13, 7, "#8f9fae")
  rain(c, 7, function(x, y) return x >= 9 and x <= 60 and y >= 10 and y <= 43 end)
  -- puddles with splash rings
  for _, p in ipairs({ { 9, 46 }, { 62, 45 }, { 38, 48 }, { 22, 47 } }) do
    F(c, c:ellipse(p[1], p[2], 4, 1), "#8cc4dc"); c:px(p[1] - 1, p[2] - 1, "#e6f0f4"); c:px(p[1] + 1, p[2] - 1, "#e6f0f4")
  end
  -- lean-to tarp on two posts, with a lantern
  P(c, c:rect(10, 19, 11, 42), "#a06a3a", { flat = true }); P(c, c:rect(58, 15, 59, 42), "#a06a3a", { flat = true })
  P(c, c:poly({ { 7, 19 }, { 62, 14 }, { 62, 18 }, { 7, 24 } }), "#4a6e9a", { cres = 2 })
  rect(c, 36, 20, 36, 24, "#4a2c1a")
  P(c, c:rect(34, 24, 38, 28), "#f5cf6a", { flat = true })
  c:px(36, 26, "#fff3c8")
  -- log bench
  P(c, c:rrect(14, 41, 55, 44, 1), "#a06a3a", { cres = 1 })
  rect(c, 18, 42, 22, 42, "#74462a"); rect(c, 40, 43, 46, 43, "#74462a")
  -- storyteller (red hat) and listener (green hat)
  local ax, ay = 15, 24
  sprite(c, SIT, ax, ay)
  arm(c, { { ax + 10, ay + 12 }, { ax + 14, ay + 8 } }, ax + 15, ay + 7)
  sprite(c, SIT, 41, ay, true, LEG2)
  -- little drips off the tarp edge
  c:px(8, 26, "#8cc4dc"); c:px(63, 20, "#8cc4dc"); c:px(61, 25, "#8cc4dc")
end

------------------------------------------------------------------ 4 room_rest (inn): hot bath + soft bed
local BATH = {}
for i = 2, 11 do BATH[#BATH + 1] = HEAD[i] end
BATH[#BATH + 1] = ".OWWWWWWWwK"
BATH[#BATH + 1] = "..OWWWWWwwK"
SCENES.room_rest = function(c)
  c:bands(c:rect(5, 5, 67, 37), { "#f1e6c8", "#efe2c2", "#ecdcba", "#e8d6b2" }, { dir = "v" })
  rect(c, 5, 38, 67, 38, "#d9c49a")
  c:bands(c:rect(5, 39, 67, 49), { "#b07a45", "#a8703e", "#9c6638", "#8a4f2a" }, { dir = "v" })
  rect(c, 5, 43, 67, 43, "#8a4f2a"); rect(c, 5, 47, 67, 47, "#8a4f2a")
  -- window
  P(c, c:rect(28, 9, 43, 24), "#b07a45", { flat = true })
  c:bands(c:rect(30, 11, 41, 22), { "#8fcbd8", "#a8d8e2", "#b5dfe6" }, { dir = "v" })
  rect(c, 35, 11, 36, 22, "#b07a45"); rect(c, 30, 16, 41, 17, "#b07a45")
  -- tub
  P(c, c:rrect(8, 33, 34, 45, 3), "#b07a45", { cres = 2 })
  rect(c, 9, 37, 33, 37, "#74462a"); rect(c, 9, 42, 33, 42, "#74462a")
  F(c, c:ellipse(21, 33, 12, 2), "#8fcbd8"); rect(c, 12, 33, 16, 33, "#c8ecdc")
  -- gnome soaking with the hat on
  sprite(c, BATH, 15, 21)
  -- bubbles round the beard, a duck, steam
  for _, b in ipairs({ { 14, 32, 2 }, { 20, 33, 2 }, { 27, 32, 2 }, { 30, 33, 1 } }) do
    F(c, c:ellipse(b[1], b[2], b[3], b[3]), "#f4eee0"); c:outline(c:ellipse(b[1], b[2], b[3], b[3]))
  end
  rect(c, 29, 30, 31, 32, "#f5cf6a"); c:px(32, 30, "#f08a24"); c:px(30, 29, "#f5cf6a"); c:px(30, 30, "#2a1a10")
  for _, s in ipairs({ { 11, 28 }, { 29, 24 }, { 33, 28 } }) do
    for j = 0, 6 do c:px(s[1] + ((j // 2) % 2), s[2] - j, "#fbf6e6") end
  end
  -- bed with a pillow and a stitched quilt
  P(c, c:rect(63, 24, 65, 44), "#8a4f2a", { flat = true })
  P(c, c:rect(40, 40, 64, 44), "#a06a3a", { cres = 2 })
  P(c, c:rrect(41, 33, 63, 41, 2), "#d6322b", { cres = 2 })
  c:seam({ { 43, 37 }, { 61, 37 } }, { free = true })
  P(c, c:rrect(52, 29, 62, 35, 2), "#f4eee0", { cres = 1 })
  rect(c, 54, 31, 59, 31, "#cfc6b0")
  P(c, c:rect(41, 44, 42, 46), "#8a4f2a", { flat = true }); P(c, c:rect(61, 44, 62, 46), "#8a4f2a", { flat = true })
end

------------------------------------------------------------------ 5 night_supper (inn, night): cocoa and bread by lamplight
SCENES.night_supper = function(c)
  c:bands(c:rect(5, 5, 67, 37), { "#2e3a5e", "#323f66", "#36446e" }, { dir = "v" })
  for x = 8, 67, 8 do rect(c, x, 5, x, 37, "#28324f") end
  c:bands(c:rect(5, 38, 67, 49), { "#5a3a22", "#4e3220", "#42291a" }, { dir = "v" })
  rect(c, 5, 38, 67, 38, "#22192c"); rect(c, 5, 43, 67, 43, "#3a2415"); rect(c, 5, 47, 67, 47, "#3a2415")
  -- lamplight: warm hard bands on the wall round the hanging lamp
  c:bands(c:ellipse(52, 18, 22, 20):clip(c:rect(5, 5, 67, 37)), { "#e0b878", "#c49c68", "#9a7e68", "#6a5a72" }, { dir = "radial", cx = 52, cy = 18, r = 22 })
  -- window onto a starry night
  P(c, c:rect(8, 9, 19, 24), "#74462a", { flat = true })
  c:bands(c:rect(10, 11, 17, 22), { "#1c2342", "#26325a", "#33427a" }, { dir = "v" })
  rect(c, 13, 11, 14, 22, "#74462a"); rect(c, 10, 16, 17, 17, "#74462a")
  c:px(11, 12, "#fff3c8"); c:px(16, 13, "#fff3c8"); c:px(11, 20, "#fff3c8"); c:px(16, 21, "#f5cf6a")
  -- hanging lamp
  rect(c, 52, 5, 52, 10, "#5a3a22")
  P(c, c:poly({ { 49, 11 }, { 56, 11 }, { 59, 17 }, { 46, 17 } }), "#e8a317", { cres = 2 })
  F(c, c:ellipse(52, 18, 3, 1.5), "#fff3c8")
  -- table, mug, bread
  P(c, c:rect(31, 38, 66, 40), "#d9a660", { cres = 1 })
  P(c, c:rect(33, 41, 64, 43), "#8a4f2a", { flat = true })
  P(c, c:rect(33, 44, 35, 47), "#74462a", { flat = true }); P(c, c:rect(62, 44, 64, 47), "#74462a", { flat = true })
  P(c, c:rect(37, 33, 41, 38), "#d6322b", { cres = 1 })
  rect(c, 38, 33, 40, 33, "#5a3a22")
  SOL(c, c:rect(42, 34, 43, 36), "#d6322b"); c:px(42, 35, "#e8d6b2")
  for j = 0, 5 do c:px(38 + (j // 2) % 2 + 1, 31 - j, "#f4eee0") end
  F(c, c:ellipse(52, 38, 7, 1), "#f1ece0")
  P(c, c:rrect(47, 33, 56, 37, 2), "#c98a44", { cres = 2 })
  rect(c, 55, 34, 56, 36, "#f0d8a0")
  c:px(49, 34, "#f0c880"); c:px(51, 35, "#f0c880")
  -- the gnome sipping on a stool
  local gx, gy = 17, 24
  P(c, c:rect(gx + 1, 41, gx + 9, 42), "#b07a45", { flat = true })
  P(c, c:rect(gx + 2, 43, gx + 3, 46), "#a06a3a", { flat = true }); P(c, c:rect(gx + 7, 43, gx + 8, 46), "#a06a3a", { flat = true })
  sprite(c, SIT, gx, gy)
  arm(c, { { gx + 10, gy + 12 }, { gx + 15, gy + 13 } }, gx + 17, gy + 12)
end

------------------------------------------------------------------ 6 cards (inn, camp): three face-down cards, one lucky snail
local function cardback(c, x0, y0)
  P(c, c:rrect(x0, y0, x0 + 7, y0 + 10, 1), "#3f8fb0", { cres = 1, contour = false })
  local ring = c:rect(x0 + 1, y0 + 1, x0 + 6, y0 + 9):cut(c:rect(x0 + 2, y0 + 2, x0 + 5, y0 + 8))
  F(c, ring, "#f4eee0")
  c:px(x0 + 3, y0 + 4, "#f5cf6a"); c:px(x0 + 4, y0 + 4, "#f5cf6a"); c:px(x0 + 3, y0 + 5, "#f5cf6a"); c:px(x0 + 4, y0 + 5, "#f5cf6a")
  c:px(x0 + 3, y0 + 6, "#f5cf6a"); c:px(x0 + 4, y0 + 6, "#f5cf6a")
end
SCENES.cards = function(c)
  landscape(c, { hy = 29, amp = 2, ph = 30 })
  cloud(c, 54, 10, 7)
  -- plank table
  P(c, c:rect(28, 38, 66, 40), "#d9a660", { cres = 1 })
  P(c, c:rect(30, 41, 64, 43), "#a06a3a", { flat = true })
  P(c, c:rect(30, 44, 32, 46), "#8a4f2a", { flat = true }); P(c, c:rect(62, 44, 64, 46), "#8a4f2a", { flat = true })
  -- two face-down cards and the middle one turned up: the snail
  cardback(c, 33, 28); cardback(c, 58, 28)
  P(c, c:rrect(44, 23, 54, 37, 1), "#f4eee0", { cres = 1, contour = false })
  F(c, c:rect(46, 33, 52, 34), "#7ab55c"); F(c, c:rect(51, 29, 52, 34), "#7ab55c")
  c:px(52, 28, "#2a1a10"); c:px(53, 27, "#2a1a10"); c:px(51, 27, "#2a1a10"); c:px(51, 31, "#2a1a10")
  F(c, c:ellipse(48, 30.5, 2.5, 2.5), "#c98a44"); c:px(48, 30, "#8a4f2a"); c:px(49, 30, "#8a4f2a"); c:px(48, 31, "#8a4f2a")
  sparkle(c, 57, 20); c:px(43, 20, "#fff3c8"); c:px(55, 14, "#fff3c8"); c:px(38, 22, "#fff3c8")
  -- the gnome has made his pick
  local gx, gy = 13, 24
  sprite(c, STAND, gx, gy)
  arm(c, { { gx + 10, gy + 12 }, { gx + 16, gy + 8 } }, gx + 18, gy + 7)
end

------------------------------------------------------------------ 7 make_wish (shrine): a coin for the wishing pool
SCENES.make_wish = function(c)
  landscape(c, { sky = { "#b8d8e6", "#d0e6ea", "#e6f0e8" }, hill = "#6a9a50", hy = 28, amp = 2, ph = 2 })
  -- stone lantern behind the pool
  P(c, c:rect(59, 36, 63, 38), "#8b8f96", { flat = true })
  P(c, c:rect(60, 30, 62, 36), "#8b8f96", { flat = true })
  P(c, c:rect(58, 26, 64, 30), "#8b8f96", { cres = 2 })
  rect(c, 60, 27, 62, 29, "#f5cf6a")
  P(c, c:poly({ { 56, 26 }, { 66, 26 }, { 63, 22 }, { 59, 22 } }), "#8b8f96", { cres = 2 })
  -- red ribbon on the lantern
  rect(c, 66, 27, 66, 31, "#d6322b")
  -- the wishing pool
  P(c, c:ellipse(46, 43, 18, 5), "#8b8f96", { cres = 2 })
  P(c, c:ellipse(46, 42, 15, 3.5), "#3f8fb0", { cres = 2, outline = false })
  rect(c, 36, 41, 40, 41, "#8fcbd8"); rect(c, 52, 43, 55, 43, "#8fcbd8")
  F(c, c:line({ { 44, 42 }, { 48, 42 } }, 1), "#c8ecdc"); c:px(43, 41, "#c8ecdc"); c:px(49, 41, "#c8ecdc")
  -- coin in the air, trail of dots, sparkles
  for _, d in ipairs({ { 31, 31 }, { 34, 28 }, { 37, 27 }, { 40, 27 }, { 43, 28 } }) do c:px(d[1], d[2], "#f5cf6a") end
  P(c, c:ellipse(46, 31, 2, 2), "#e8a317", { cres = 1 })
  c:px(45, 30, "#fff1c8")
  sparkle(c, 53, 25); c:px(40, 20, "#fff3c8"); c:px(50, 19, "#fff3c8"); c:px(38, 33, "#fff3c8")
  -- the gnome, one hand out
  local gx, gy = 13, 24
  sprite(c, STAND, gx, gy)
  arm(c, { { gx + 10, gy + 12 }, { gx + 15, gy + 8 } }, gx + 17, gy + 6)
end

------------------------------------------------------------------ 8 quiet_hour (shrine, spring, tower): sit in silence
local CROSS = cat(HEAD, BODY, {
  "..DBBBBBBBBbK.",
  ".DTTTTTTTTTTTD",
  "DSTTTTTTTTTTSD",
  "DTTTTTTbTTTTTD",
  "DTTTTKKKKTTTTD",
  ".DDDKKDDKKDDD." })
SCENES.quiet_hour = function(c)
  landscape(c, { sky = { "#d6ebe8", "#e2f0e8", "#eef4e6" }, hill = "#7ab55c", line = "#b4d48a", grass = { "#8fbb68" }, hy = 29, amp = 2, ph = 40, tuft = "#6a9a40" })
  cloud(c, 18, 11, 7); cloud(c, 54, 9, 6)
  -- a small pond with rings
  F(c, c:ellipse(18, 46, 12, 3), "#8fcbd8"); c:outline(c:ellipse(18, 46, 12, 3))
  F(c, c:ellipse(18, 46, 7, 1.5), "#a8d8e2"); rect(c, 14, 46, 21, 46, "#c8ecdc")
  -- soft halo behind the sitting gnome
  F(c, c:ellipse(36, 30, 11, 11), "#f6ecbc")
  F(c, c:ellipse(36, 30, 8, 8), "#fbf3d0")
  -- flat stone seat
  P(c, c:ellipse(36, 44, 12, 3.5), "#a8a8a4", { cres = 2 })
  -- cross-legged gnome, eyes shut
  local gx, gy = 29, 24
  local rows = {}
  for i, r in ipairs(CROSS) do rows[i] = r end
  rows[10] = "..OSSSKKSSSK"   -- closed eye
  sprite(c, rows, gx, gy)
  -- the candle on its own stone, with a calm flame
  P(c, c:rect(50, 42, 58, 44), "#8b8f96", { cres = 2 })
  P(c, c:rect(53, 35, 55, 42), "#f4eee0", { cres = 1 })
  F(c, c:poly({ { 53, 34 }, { 55, 34 }, { 54, 30 } }), "#f08a24"); c:px(54, 33, "#f5cf6a"); c:px(54, 32, "#fff3c8")
  c:px(51, 31, "#fff3c8"); c:px(57, 31, "#fff3c8"); c:px(54, 27, "#fff3c8"); c:px(52, 29, "#fff3c8"); c:px(56, 29, "#fff3c8")
  -- drifting leaf and a ripple
  c:px(26, 38, "#4a8a3e"); c:px(27, 39, "#4a8a3e")
end

------------------------------------------------------------------ 9 moss_tend (shrine, herb): watering the thirsty moss
SCENES.moss_tend = function(c)
  landscape(c, { sky = { "#bcdcdc", "#d2e6e4", "#e4efe6" }, hill = "#5e8a44", hy = 22, amp = 2, ph = 5 })
  -- old stone wall with moss
  local wall = c:rect(5, 19, 67, 38)
  F(c, wall, "#8b8f96"); rect(c, 5, 19, 67, 19, "#c9c5bc")
  for _, y in ipairs({ 25, 31 }) do rect(c, 5, y, 67, y, "#6e737b") end
  for x = 9, 67, 12 do rect(c, x, 20, x, 24, "#6e737b") end
  for x = 15, 67, 12 do rect(c, x, 26, x, 30, "#6e737b") end
  for x = 9, 67, 12 do rect(c, x, 32, x, 37, "#6e737b") end
  rect(c, 5, 38, 67, 38, "#4a4e56")
  for _, m in ipairs({ { 12, 20, 6 }, { 30, 20, 4 }, { 52, 20, 7 }, { 62, 33, 4 } }) do
    F(c, c:ellipse(m[1], m[2], m[3], 2):clip(wall), "#7ab55c"); rect(c, m[1] - 2, m[2] + 2, m[1], m[2] + 3, "#6a9a3a")
  end
  rect(c, 5, 39, 67, 40, "#9cc070")
  -- moss cushions: the tended green one on the left, a parched one to be watered
  local gm = c:ellipse(12, 46, 5, 2.5):add(c:ellipse(8, 45, 3, 2)):add(c:ellipse(15, 45, 3, 2))
  P(c, gm, "#7ab55c", { cres = 2 })
  rect(c, 9, 44, 10, 44, "#a4d07a"); rect(c, 13, 45, 14, 45, "#a4d07a"); rect(c, 11, 47, 12, 47, "#4a8a3e")
  local dm = c:ellipse(55, 46, 6, 2.5):add(c:ellipse(51, 45, 3, 2)):add(c:ellipse(59, 45, 3, 2))
  P(c, dm, "#b8a85a", { cres = 2 })
  rect(c, 52, 44, 53, 44, "#d4c478"); rect(c, 58, 45, 59, 45, "#d4c478"); rect(c, 55, 47, 56, 47, "#8a7a3a"); rect(c, 54, 45, 54, 45, "#8a7a3a")
  -- the gnome, watering can in hand
  local gx, gy = 22, 24
  sprite(c, STAND, gx, gy)
  -- can: body, spout with a rose, handle
  SOL(c, c:line({ { 43, 34 }, { 48, 37 } }, 2), "#5b8fb0")
  SOL(c, c:rect(48, 36, 50, 40), "#3f6f90")
  SOL(c, c:rect(34, 32, 35, 38), "#3f6f90")
  P(c, c:rect(36, 31, 43, 39), "#5b8fb0", { cres = 2 })
  rect(c, 37, 33, 38, 33, "#a9d6ea")
  arm(c, { { gx + 10, gy + 12 }, { gx + 11, gy + 12 } }, gx + 13, gy + 12)
  -- drops falling onto the parched moss
  for _, d in ipairs({ { 49, 41 }, { 51, 42 }, { 50, 43 }, { 52, 44 }, { 48, 43 } }) do c:px(d[1], d[2], "#8fcbd8"); c:px(d[1], d[2] + 1, "#c8ecdc") end
end

------------------------------------------------------------------ 10 star_vigil (shrine, tower, night): naming the constellations
SCENES.star_vigil = function(c)
  c:bands(c:rect(5, 5, 67, 37), { "#1a2040", "#222c52", "#2c3a68", "#36467a" }, { dir = "v" })
  -- far hills
  F(c, hillmask(c, 5, 67, 33, 38, 2, 12), "#26385a")
  -- stars
  for _, p in ipairs({ { 9, 8 }, { 14, 21 }, { 20, 12 }, { 26, 27 }, { 61, 24 }, { 64, 12 }, { 57, 8 }, { 34, 9 }, { 10, 30 }, { 40, 28 }, { 63, 31 }, { 22, 18 } }) do c:px(p[1], p[2], "#e8e4d0") end
  sparkle(c, 15, 12); sparkle(c, 60, 17)
  -- crescent moon
  F(c, c:ellipse(11, 9, 3, 3):cut(c:ellipse(12.5, 8.5, 3, 3)), "#f6e8a0")
  -- the Great Beetle: stars joined by fine lines
  local st = { { 38, 14 }, { 44, 12 }, { 50, 14 }, { 52, 20 }, { 46, 24 }, { 40, 21 }, { 56, 12 }, { 34, 19 } }
  local seq = { 1, 2, 3, 4, 5, 6, 1 }
  for i = 1, #seq - 1 do F(c, c:line({ st[seq[i]], st[seq[i + 1]] }, 1), "#5a6ea0") end
  F(c, c:line({ st[2], st[7] }, 1), "#5a6ea0"); F(c, c:line({ st[6], st[8] }, 1), "#5a6ea0")
  for _, p in ipairs(st) do
    c:px(p[1], p[2], "#fff3c8"); c:px(p[1] + 1, p[2], "#f5cf6a"); c:px(p[1], p[2] + 1, "#f5cf6a"); c:px(p[1] - 1, p[2], "#f5cf6a"); c:px(p[1], p[2] - 1, "#f5cf6a")
  end
  -- tower parapet
  local wall = c:rect(5, 38, 67, 49)
  F(c, wall, "#8b8f96"); rect(c, 5, 38, 67, 38, "#c9c5bc")
  for _, y in ipairs({ 42, 46 }) do rect(c, 5, y, 67, y, "#6e737b") end
  for x = 10, 67, 12 do rect(c, x, 39, x, 41, "#6e737b") end
  for x = 16, 67, 12 do rect(c, x, 43, x, 45, "#6e737b") end
  for x = 10, 67, 12 do rect(c, x, 47, x, 49, "#6e737b") end
  for _, x in ipairs({ 8, 26, 44, 60 }) do
    P(c, c:rect(x, 33, x + 6, 38), "#8b8f96", { cres = 2 }); rect(c, x, 33, x + 6, 33, "#c9c5bc")
  end
  -- a lantern glowing on the wall
  P(c, c:rect(46, 33, 50, 38), "#e8a317", { flat = true }); rect(c, 47, 34, 49, 36, "#fff3c8")
  -- the gnome, one arm up, naming a star
  local gx, gy = 22, 20
  sprite(c, STAND, gx, gy)
  arm(c, { { gx + 10, gy + 12 }, { gx + 14, gy + 5 } }, gx + 15, gy + 3)
end

------------------------------------------------------------------ 11 dawn_bell (shrine, dawn): ringing the bell
SCENES.dawn_bell = function(c)
  landscape(c, { sky = { "#6e5c9c", "#a8649c", "#d9808c", "#ee9f80", "#f6c38a", "#f9dda0" }, hill = "#5f7a58", line = "#7fa468",
    grass = { "#6c9a58", "#6c9a58", "#628e50" }, tuft = "#4d7a45", hy = 29, amp = 2, ph = 20 })
  -- the sun coming up behind the hills
  F(c, c:ellipse(17, 30, 9, 9):clip(c:rect(5, 5, 67, 31)), "#f6e08a")
  F(c, c:ellipse(17, 30, 7, 7):clip(c:rect(5, 5, 67, 31)), "#f8d060")
  F(c, hillmask(c, 5, 34, 32, 40, 2, 5), "#5f7a58")
  rect(c, 5, 40, 34, 40, "#7fa468")
  -- birds lifting off the trees
  for _, b in ipairs({ { 22, 12 }, { 29, 8 }, { 26, 18 }, { 34, 14 } }) do
    c:px(b[1], b[2], "#2a1a10"); c:px(b[1] + 1, b[2] + 1, "#2a1a10"); c:px(b[1] + 2, b[2], "#2a1a10")
  end
  -- bell frame: two posts, a roofed beam
  P(c, c:rect(46, 17, 48, 41), "#b07a45", { flat = true })
  P(c, c:rect(62, 17, 64, 41), "#b07a45", { flat = true })
  P(c, c:poly({ { 44, 18 }, { 66, 18 }, { 63, 11 }, { 47, 11 } }), "#d6322b", { cres = 2 })
  c:seam({ { 46, 16 }, { 64, 16 } }, { free = true })
  -- bell, swinging, with a clapper
  P(c, c:rect(54, 19, 56, 21), "#74462a", { flat = true })
  P(c, c:poly({ { 52, 23 }, { 59, 23 }, { 61, 33 }, { 50, 33 } }):add(c:ellipse(55.5, 24.5, 3.5, 2.5)), "#e8a317", { cres = 3, gloss = { 53, 24 } })
  P(c, c:rect(49, 32, 62, 34), "#e8a317", { flat = true })
  P(c, c:ellipse(55.5, 36, 1.5, 1.5), "#7a3a14", { flat = true })
  -- ring of sound
  F(c, c:line({ { 44, 24 }, { 42, 28 }, { 44, 32 } }, 1), "#fff3c8")
  F(c, c:line({ { 40, 22 }, { 38, 28 }, { 40, 34 } }, 1), "#fff3c8")
  F(c, c:line({ { 66, 24 }, { 68, 28 } }, 1), "#fff3c8")
  -- the gnome hauling the rope with both arms
  local gx, gy = 29, 24
  F(c, c:line({ { 44, 21 }, { 53, 21 } }, 1), "#74462a")
  F(c, c:line({ { 44, 22 }, { 44, 31 } }, 1), "#e8d6b2")
  sprite(c, STAND, gx, gy)
  arm(c, { { gx + 10, gy + 12 }, { gx + 13, gy + 8 } }, gx + 14, gy + 7)
end

--SCENES--
------------------------------------------------------------------ build
-- scenes drawn facing right are mirrored (interior only) for variety of composition
local FLIP = { wind_sails = true, make_wish = true, dawn_bell = true, moss_tend = true }
local function mirror(c)
  for y = 5, 49 do
    local row = {}
    for x = 5, 67 do row[x] = c.pix[c:key(x, y)] end
    for x = 5, 67 do c.pix[c:key(x, y)] = row[72 - x] end
  end
end
local order = { "wind_sails", "tall_tale", "rainy_stories", "room_rest", "night_supper", "cards", "make_wish", "quiet_hour", "moss_tend", "star_vigil", "dawn_bell" }
for _, slug in ipairs(order) do
  local fn = SCENES[slug]
  if fn and (not only or only == slug) then
    local c = newc()
    fn(c)
    if FLIP[slug] then mirror(c) end
    frame(c)
    local t = c:save(ASE .. "/variety-act-" .. slug .. ".aseprite", OUT .. "/act-" .. slug .. ".png")
    print(slug, GV.report(t))
    assert(t.semi == 0)
  end
end
