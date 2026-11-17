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
local function save(c, name)
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
  -- hanging pouch from the bar
  c:part(c:rect(47, 64, 49, 68), DWOOD, { flat = true })
  c:part(c:ellipse(48, 76, 9, 9), "red", { cres = 5, deep = 2 })
  c:part(c:rrect(41, 66, 55, 70, 2), "gold", { cres = 2, deep = 1, gloss = false })
  -- big coin on top
  c:part(c:ellipse(47.5, 28, 14, 14), "gold", { cres = 5, deep = 2 })
  c:part(c:ellipse(47.5, 28, 9, 9):cut(c:ellipse(47.5, 28, 6, 6)), "gold", { flat = true, contour = false, contact = false })
  flat(c, c:rect(46, 22, 49, 34), "#b8661a")
  save(c, "toll")
end

----------------------------------------------------------------- beat: three fanned story cards, middle lifted, star
local function beat(c)
  local function card(cx, cy, deg, ramp)
    c:part(c:poly(rot(cx, cy, 30, 46, deg)), ramp, { cres = 5, deep = 2, gloss = false })
  end
  -- left card (cream, red band), right card (leaf green), middle (gold paper) lifted
  card(28, 62, -20, CREAM)
  card(68, 62, 20, GV.R.leaf)
  card(48, 38, 0, GV.ramp("#f2d48a"))
  -- left card marks
  flat(c, c:poly(rot(26, 72, 20, 4, -20)), "#ae2a2a")
  flat(c, c:poly(rot(23, 62, 16, 2, -20)), "#7a4a1f")
  -- right card marks
  flat(c, c:poly(rot(70, 72, 20, 4, 20)), "#f1ece0")
  flat(c, c:poly(rot(72, 62, 16, 2, 20)), "#f1ece0")
  -- middle card border and star
  c:seam({ { 38, 20 }, { 58, 20 } }, { free = true })
  c:seam({ { 38, 56 }, { 58, 56 } }, { free = true })
  c:paint({
    "....a....",
    "....a....",
    "...aaa...",
    "aaaaaaaaa",
    ".aaaaaaa.",
    "..aaaaa..",
    "..aa.aa..",
    ".aa...aa.",
  }, 43, 28, { a = "#c0392b" })
  save(c, "beat")
end

----------------------------------------------------------------- weather: sun peeking, cloud, rain
local function weather(c)
  -- sun, upper right
  for _, a in ipairs({ 0, 45, 90, 135, 180, 225, 270, 315 }) do
    local r = math.rad(a)
    local x, y = 62 + math.cos(r) * 18, 28 + math.sin(r) * 18
    c:part(c:ellipse(x, y, 3, 3), "gold", { flat = true })
  end
  c:part(c:ellipse(62, 28, 13, 13), "gold", { cres = 5, deep = 2 })
  -- cloud
  local cl = c:ellipse(30, 52, 14, 13)
  cl:add(c:ellipse(50, 44, 18, 17))
  cl:add(c:ellipse(68, 54, 13, 12))
  cl:add(c:rrect(20, 52, 76, 64, 6))
  c:part(cl, CLOUD, { cres = 8, deep = 2, gloss = false })
  -- rain drops (slanted)
  for _, p in ipairs({ { 26, 72 }, { 42, 76 }, { 58, 72 }, { 74, 76 } }) do
    c:part(c:line({ { p[1] + 3, p[2] }, { p[1], p[2] + 9 } }, 3), SKY, { flat = true })
  end
  save(c, "weather")
end

local fns = { toll = toll, beat = beat, weather = weather }
for _, n in ipairs({ "toll", "beat", "weather" }) do
  if ONLY == "all" or ONLY == n then fns[n](canvas()) end
end
