-- roadkinds-2706.lua : road-kind icons toll / beat / weather (96x96, icon mode). Same family as variety-roadkinds.lua.
-- Params: --script-param root=<repo> pngdir=<dir> out=<dir> only=<name>
local P = app.params
local root = P.root or "/home/user/gnome-venture"
local GV = dofile(root .. "/aseprite-source/gvlib/gvlib.lua")
local OUT = P.out or (root .. "/aseprite-source/extras-pixel/aseprite")
local PNG = P.pngdir or (root .. "/art-2706")
local ONLY = P.only or "all"

local PLANK = GV.ramp("#c9a96e")
local CREAM = GV.ramp("#f1ece0")
local DWOOD = GV.ramp("#7a4a1f")
local SKY = GV.ramp("#5fa0d8")
local CLOUD = GV.ramp("#e4ebf2")

local function canvas() return GV.canvas{ w = 96, h = 96, mode = "icon", cres = 6, deep = 2, ol = 2, olx = 1 } end
-- Hearth Pop checks: no pure black/white. gvlib's finish() adds a #000000 border; remap it to warm ink.
local function hearth(c)
  c:finish()
  for k, h in pairs(c.pix) do
    if h == "#000000" then c.pix[k] = "#2b1c26" elseif h == "#ffffff" then c.pix[k] = "#fff4d6" end
  end
end
local function save(c, name)
  hearth(c)
  local t = c:save(OUT .. "/roadkind2706-" .. name .. ".aseprite", PNG .. "/" .. name .. ".png")
  print(name .. " " .. GV.report(t))
end
local function flat(c, m, col) c:part(m, { base = col, rim = col, shade = col, deep = col, bounce = col, gloss = col, dot = col }, { flat = true, contour = false, contact = false }) end
-- rotated rectangle polygon centred cx,cy, w x h, angle in degrees
local function rot(cx, cy, w, h, deg)
  local a = math.rad(deg); local ca, sa = math.cos(a), math.sin(a)
  local pts = {}
  for _, p in ipairs({ { -w / 2, -h / 2 }, { w / 2, -h / 2 }, { w / 2, h / 2 }, { -w / 2, h / 2 } }) do
    pts[#pts + 1] = { cx + p[1] * ca - p[2] * sa, cy + p[1] * sa + p[2] * ca }
  end
  return pts
end

----------------------------------------------------------------- toll: gate bar across a path, coin on top
-- quirk: the drawstring pouch hanging off the bar has a coin peeking out of its mouth
local POUCH = GV.ramp("#8a3f9e", { gloss = "#d9a0e0", dot = "#fff4d6", rim = "#b56cc4" })
local COIN = GV.ramp("gold", { gloss = "#fff1c8", dot = "#fff4d6" })
local function toll(c)
  c:part(c:ellipse(47.5, 84, 38, 5), "moss", { cres = 3, deep = 1, gloss = false })
  -- far post (right, short)
  c:part(c:rrect(74, 42, 86, 84, 2), DWOOD, { gloss = false })
  c:part(c:rect(77, 46, 78, 80), "#9a6b3f", { flat = true, contour = false, contact = false })
  -- left post (tall, with cap)
  c:part(c:rrect(10, 28, 24, 86, 2), DWOOD, { gloss = false })
  c:part(c:rect(13, 33, 14, 82), "#9a6b3f", { flat = true, contour = false, contact = false })
  c:part(c:rrect(8, 24, 26, 32, 2), PLANK, { cres = 3, deep = 1, gloss = false })
  -- barrier bar: red/cream stripes
  c:part(c:rrect(20, 52, 84, 64, 3), CREAM, { cres = 4, deep = 1, gloss = false })
  for x = 28, 76, 16 do
    c:part(c:poly({ { x, 52 }, { x + 8, 52 }, { x + 4, 64 }, { x - 4, 64 } }):clip(c:rrect(21, 52, 83, 64, 3)), "red", { flat = true, contour = false, contact = false })
  end
  c:button(14, 57)
  -- drawstring pouch hanging from the bar: cord, ruffled mouth, cinch, round belly
  c:part(c:rect(47, 64, 48, 67), "#5e2f1e", { flat = true, contour = false })
  c:part(c:ellipse(47.5, 80, 12, 9), POUCH, { cres = 5, deep = 2, gloss = { 42, 75 } })
  c:part(c:poly({ { 40, 66 }, { 55, 66 }, { 52, 71 }, { 43, 71 } }), POUCH, { cres = 3, deep = 1, gloss = false })
  -- coin peeking out of the mouth (quirk)
  c:part(c:ellipse(51, 67, 3, 3), COIN, { cres = 2, deep = 1, gloss = false })
  c:px(50, 66, "#fff1c8")
  -- gold drawstring cinch with a dangling tie
  c:part(c:rrect(41, 70, 54, 73, 1), COIN, { cres = 2, deep = 1, gloss = false })
  c:part(c:line({ { 41, 73 }, { 38, 78 } }, 2), COIN, { flat = true, contact = false })
  c:part(c:ellipse(37.5, 79.5, 1.5, 1.5), COIN, { flat = true, contact = false })
  -- belly patch: stitched gold coin mark
  c:part(c:ellipse(47.5, 81, 4, 4), COIN, { cres = 2, deep = 1, gloss = false })
  c:px(47, 79, "#b8661a"); c:px(47, 80, "#b8661a"); c:px(47, 81, "#b8661a"); c:px(47, 82, "#b8661a")
  -- big coin on top: thick rim, sunken face, embossed acorn, edge ticks
  local cx, cy = 47.5, 27
  c:part(c:ellipse(cx, cy, 15, 15), COIN, { cres = 5, deep = 2, gloss = false })
  local ring = c:ellipse(cx, cy, 11, 11):cut(c:ellipse(cx, cy, 10, 10))
  ring:each(function(x, y) c:px(x, y, ((x - cx) + (y - cy) < 0) and "#b8661a" or "#fff1c8") end)
  c:part(c:ellipse(cx, cy, 9, 9), "#f2b631", { flat = true, rim = false, contour = false, contact = false })
  -- embossed gnome-hat emblem, raised: lit left edge, dark right edge and underside
  c:paint({
    "......dd...",
    ".....dad...",
    ".....dacd..",
    "....dacd...",
    "....daccd..",
    "...daaccd..",
    "...dacccd..",
    "..daacccd..",
    ".daaacccdd.",
    "daaaaaaaaad",
    "dbbbbbbbbbd",
    ".ddddddddd.",
  }, 42, 20, { a = "#ffe38a", c = "#e08422", d = "#8f4a1f", b = "#c96a1c" })
  -- gloss arc on the upper-left of the rim + one cream sparkle on the face
  for _, p in ipairs({ { 36, 23 }, { 36, 22 }, { 37, 20 }, { 37, 21 }, { 38, 19 }, { 39, 18 }, { 40, 17 }, { 41, 16 }, { 36, 24 } }) do c:px(p[1], p[2], "#fff1c8") end
  c:paint({ ".s.", "sss", ".s." }, 39, 21, { s = "#fff4d6" })
  save(c, "toll")
end

----------------------------------------------------------------- beat: three fanned story cards, middle lifted with a quill
-- quirk: a red ribbon bookmark tail dangles out of the lifted card
local BACK = GV.ramp("#5a459e", { gloss = "#c9b2f0", dot = "#fff4d6", rim = "#8a6fd0", shade = "#463585", deep = "#35295f" })
local FRAME = GV.ramp("red")
local PAPER = { base = "#fbecc8", rim = "#fff4d6", gloss = "#fff4d6", dot = "#fff4d6", shade = "#e8cf98", deep = "#c9a96e", bounce = "#efd8a4", pale = true }
local QUILL = GV.ramp("#2f8fc4", { gloss = "#b6f0e0", dot = "#fff4d6", rim = "#7fd0e0", shade = "#2a64a0", deep = "#2a3c7a" })
local function beat(c)
  local function back(cx, cy, deg)
    c:part(c:poly(rot(cx, cy, 30, 44, deg)), BACK, { cres = 4, deep = 2, gloss = false })
    -- inset gold border + gold diamond emblem: reads as a card back, not a book cover
    local inner = c:poly(rot(cx, cy, 22, 36, deg)):cut(c:poly(rot(cx, cy, 20, 34, deg)))
    c:fill(inner, "#d98322")
    local a = math.rad(deg)
    local function at(dx, dy) return { cx + dx * math.cos(a) - dy * math.sin(a), cy + dx * math.sin(a) + dy * math.cos(a) } end
    local o = deg < 0 and -4 or 4
    c:part(c:poly({ at(o, -6), at(o + 5, 3), at(o, 12), at(o - 5, 3) }), "gold", { flat = true, contour = false, contact = false })
  end
  back(25, 60, -22)
  back(71, 60, 22)
  -- lifted story card: red frame, cream page
  c:part(c:rrect(29, 12, 67, 68, 3), FRAME, { cres = 5, deep = 2, gloss = false })
  c:part(c:rrect(33, 16, 63, 64, 1), PAPER, { cres = 3, deep = 1, gloss = false, contour = "#6b1b2c", contact = false })
  -- ribbon bookmark from the top, tail out of the bottom (quirk)
  c:part(c:poly({ { 56, 12 }, { 61, 12 }, { 61, 22 }, { 58.5, 19 }, { 56, 22 } }), "#d98322", { flat = true, contour = false, contact = false })
  c:part(c:poly({ { 54, 67 }, { 60, 67 }, { 61, 80 }, { 58, 77 }, { 55, 81 } }), "gold", { flat = true })
  -- quill emblem: big diagonal feather, nib lower-left
  local A, B = { 37, 60 }, { 60, 22 }
  local ux, uy = B[1] - A[1], B[2] - A[2]
  local L = math.sqrt(ux * ux + uy * uy); ux, uy = ux / L, uy / L
  local nx, ny = -uy, ux
  local left, right = {}, {}
  for i = 0, 12 do
    local t = 0.22 + 0.78 * i / 12
    local w = 7 * math.sin(math.pi * math.min(1, (t - 0.22) / 0.7)) ^ 0.6
    if i == 12 then w = 0 end
    local px, py = A[1] + ux * L * t, A[2] + uy * L * t
    left[#left + 1] = { px + nx * w, py + ny * w }
    table.insert(right, 1, { px - nx * w * 0.8, py - ny * w * 0.8 })
  end
  for _, p in ipairs(right) do left[#left + 1] = p end
  local vane = c:poly(left)
  -- barb notches (feathery edge)
  for _, t in ipairs({ 0.45, 0.68 }) do
    local px, py = A[1] + ux * L * t, A[2] + uy * L * t
    vane:cut(c:line({ { px + nx * 7, py + ny * 7 }, { px + nx * 4 - ux * 2, py + ny * 4 - uy * 2 } }, 1))
  end
  c:part(vane, QUILL, { cres = 3, deep = 1, gloss = false, contact = false })
  -- shaft and nib
  c:fill(c:line({ { A[1] + ux * 7, A[2] + uy * 7 }, { A[1] + ux * L * 0.95, A[2] + uy * L * 0.95 } }, 1), "#2a3c7a")
  c:part(c:line({ { A[1], A[2] }, { A[1] + ux * 9, A[2] + uy * 9 } }, 2), "#3d2a1c", { flat = true, contour = false, contact = false })
  c:px(A[1] + 3, A[2] - 5, "#f5b82e")
  -- ink dot where the nib touches
  c:fill(c:ellipse(35, 61, 1, 1), "#3d2a1c")
  save(c, "beat")
end

----------------------------------------------------------------- weather: sun peeking, rain cloud, fat drops
-- quirk: the sun shoulders up behind the cloud, rays and all
local CLOUDR = { base = "#adc4ec", rim = "#e9f1ff", gloss = "#f2f6ff", dot = "#fff4d6", shade = "#8aa2d8", deep = "#6478b8", bounce = "#9cb0e2", pale = false }
local DROP = GV.ramp("#2f86e0", { gloss = "#b6f0e0", dot = "#e4f6ff", rim = "#7cc4f5", shade = "#2a5fb8", deep = "#2a3c8a" })
local SUN = GV.ramp("#f5b82e", { gloss = "#ffe38a", dot = "#fff4d6", rim = "#ffd45c", shade = "#e08422", deep = "#b5541f" })
local function weather(c)
  -- sun, upper right: chunky triangular rays + disc
  local sx, sy = 64, 26
  for i = 0, 7 do
    local a = math.rad(i * 45 - 22.5)
    local function at(r, da) return { sx + math.cos(a + da) * r, sy + math.sin(a + da) * r } end
    c:part(c:poly({ at(13, -0.28), at(23, 0), at(13, 0.28) }), SUN, { flat = true, contact = false })
  end
  c:part(c:ellipse(sx, sy, 14, 14), SUN, { cres = 5, deep = 2 })
  -- rain cloud: three puffs + flat belly
  local cl = c:ellipse(29, 50, 14, 13)
  cl:add(c:ellipse(49, 41, 18, 17))
  cl:add(c:ellipse(70, 51, 13, 12))
  cl:add(c:rrect(15, 48, 83, 64, 7))
  c:part(cl, CLOUDR, { cres = 7, deep = 3, gloss = { 38, 30 } })
  -- fat teardrop rain
  local function drop(x, y)
    local m = c:ellipse(x, y, 4.5, 4.5)
    m:add(c:poly({ { x - 4, y - 1 }, { x + 1, y - 12 }, { x + 4.5, y - 1 } }))
    c:part(m, DROP, { cres = 2, deep = 1, gloss = false, contact = false })
    c:px(x - 2, y - 2, "#e4f6ff"); c:px(x - 2, y - 1, "#b6f0e0"); c:px(x - 1, y - 4, "#b6f0e0")
  end
  drop(29, 79); drop(49, 85); drop(69, 79)
  save(c, "weather")
end

local fns = { toll = toll, beat = beat, weather = weather }
for _, n in ipairs({ "toll", "beat", "weather" }) do
  if ONLY == "all" or ONLY == n then fns[n](canvas()) end
end
