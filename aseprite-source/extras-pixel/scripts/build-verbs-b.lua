-- build-verbs-b.lua : stage icons vigil / befriend / trial (96x96, icon mode).
-- Params: --script-param root=<repo> pngdir=<dir> out=<dir> only=<name>
local P = app.params
local root = P.root or "/home/user/gnome-venture"
local GV = dofile(root .. "/aseprite-source/gvlib/gvlib.lua")
local OUT = P.out or (root .. "/aseprite-source/extras-pixel/aseprite")
local PNG = P.pngdir or (root .. "/art-2706")
local ONLY = P.only or "all"

local CREAM = GV.ramp("#f1ece0", { shade = "#d8c49a", bounce = "#e6d4ac", deep = "#9a6b3f" })
local DWOOD = GV.ramp("#7a4a1f")
local STEEL = GV.ramp("#a9b0ba")
local IRON = GV.ramp("#6b7078")
local function flatr(h) return { base = h, rim = h, shade = h, deep = h, bounce = h, gloss = h, dot = h } end
local FL = { flat = true, contour = false, contact = false }

local function canvas() return GV.canvas{ w = 96, h = 96, mode = "icon", cres = 6, deep = 2, ol = 2, olx = 1 } end
local function save(c, name)
  local t = c:save(OUT .. "/stage-" .. name .. ".aseprite", PNG .. "/stage-" .. name .. ".png")
  print(name .. " " .. GV.report(t))
end
local function band(a, b, hw)
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L * hw, dx / L * hw
  return { { a[1] + nx, a[2] + ny }, { b[1] + nx, b[2] + ny }, { b[1] - nx, b[2] - ny }, { a[1] - nx, a[2] - ny } }
end
local function star(c, x, y, r)
  c:part(c:rect(x - r, y - 1, x + r, y + 1):add(c:rect(x - 1, y - r, x + 1, y + r)), "gold", { cres = 2, deep = 1, gloss = false })
end

----------------------------------------------------------------- vigil: candle on a stool, moon and stars
local function vigil(c)
  -- crescent moon (upper right)
  local moon = c:ellipse(72, 24, 15, 15):cut(c:ellipse(79, 19, 12, 12))
  c:part(moon, "gold", { cres = 4, deep = 1, gloss = false })
  star(c, 18, 20, 4); star(c, 30, 40, 3); star(c, 82, 52, 3)
  -- stool: legs, rung, seat
  c:part(c:poly({ { 28, 76 }, { 35, 76 }, { 31, 91 }, { 24, 91 } }), DWOOD, { cres = 3, deep = 1, gloss = false })
  c:part(c:poly({ { 61, 76 }, { 68, 76 }, { 72, 91 }, { 65, 91 } }), DWOOD, { cres = 3, deep = 1, gloss = false })
  c:part(c:rect(29, 84, 67, 86), "soil", { cres = 2, deep = 1, gloss = false })
  c:part(c:rrect(20, 70, 76, 79, 3), "wood", { cres = 5, deep = 2 })
  -- holder dish
  c:part(c:ellipse(48, 69, 17, 4), "gold", { cres = 3, deep = 1, gloss = false })
  -- candle
  c:part(c:rrect(41, 40, 55, 68, 3), CREAM, { cres = 5, deep = 2, gloss = false })
  c:part(c:rect(50, 46, 51, 52):add(c:rect(44, 44, 45, 47)), GV.ramp("#d8c49a"), FL)
  -- wick
  c:part(c:rect(47, 35, 48, 40), GV.ramp("#4e2a16"), FL)
  -- flame (teardrop)
  local fl = c:poly({ { 48, 12 }, { 53, 22 }, { 56, 30 }, { 52, 37 }, { 44, 37 }, { 40, 30 }, { 43, 22 } })
  c:part(fl, "flame", { cres = 5, deep = 1 })
  c:part(c:poly({ { 48, 22 }, { 51, 28 }, { 51, 34 }, { 45, 34 }, { 45, 28 } }), "gold", { cres = 2, deep = 1, gloss = false })
  save(c, "vigil")
end

----------------------------------------------------------------- befriend: open hand offering an apple, heart above
local function befriend(c)
  -- sleeve (left)
  c:part(c:poly({ { 6, 60 }, { 22, 62 }, { 22, 86 }, { 6, 84 } }), "leaf", { cres = 4, deep = 1, gloss = false })
  -- palm
  c:part(c:rrect(18, 66, 86, 84, 7), "skin", { cres = 6, deep = 2 })
  -- thumb
  c:part(c:rrect(26, 58, 44, 74, 5), "skin", { cres = 4, deep = 1, gloss = false })
  -- finger creases
  for _, x in ipairs({ 62, 71, 80 }) do for y = 72, 82 do c:px(x, y, "#c47a52") end end
  -- apple
  c:part(c:ellipse(53, 52, 17, 16), "red", { cres = 5, deep = 2 })
  c:part(c:rect(52, 30, 54, 37), DWOOD, FL)
  c:part(c:poly({ { 55, 33 }, { 66, 28 }, { 68, 35 }, { 58, 38 } }), "leaf", { cres = 3, deep = 1, gloss = false })
  -- heart (upper right)
  local h = c:ellipse(71, 15, 7, 7):add(c:ellipse(83, 15, 7, 7)):add(c:poly({ { 63, 18 }, { 91, 18 }, { 77, 33 } }))
  c:part(h, "petal", { cres = 4, deep = 1 })
  -- small heart-less sparkles
  star(c, 16, 30, 3); star(c, 22, 14, 2)
  save(c, "befriend")
end

----------------------------------------------------------------- trial: notched shield over crossed swords
local function trial(c)
  local function sword(x0, y0, x1, y1)
    -- tip at (x0,y0), pommel at (x1,y1)
    local function lerp(t) return { x0 + (x1 - x0) * t, y0 + (y1 - y0) * t } end
    c:part(c:poly(band(lerp(0.02), lerp(0.62), 4)), STEEL, { cres = 3, deep = 1, gloss = false })
    c:part(c:poly(band(lerp(0.60), lerp(0.67), 9)), "gold", { cres = 3, deep = 1, gloss = false })
    c:part(c:poly(band(lerp(0.66), lerp(0.88), 3)), DWOOD, { cres = 2, deep = 1, gloss = false })
    c:part(c:ellipse(lerp(0.92)[1], lerp(0.92)[2], 4, 4), "gold", { cres = 2, deep = 1, gloss = false })
  end
  sword(10, 6, 80, 86)
  sword(86, 6, 16, 86)
  -- shield
  local sh = c:poly({ { 22, 18 }, { 74, 18 }, { 76, 46 }, { 66, 68 }, { 48, 88 }, { 30, 68 }, { 20, 46 } })
  sh:cut(c:poly({ { 70, 14 }, { 80, 14 }, { 80, 38 }, { 68, 30 } }))
  c:part(sh, IRON, { cres = 6, deep = 2 })
  local face = c:poly({ { 27, 24 }, { 69, 24 }, { 70, 45 }, { 62, 64 }, { 48, 80 }, { 34, 64 }, { 26, 45 } })
  face:cut(c:poly({ { 62, 22 }, { 76, 22 }, { 76, 40 }, { 64, 32 } }))
  c:part(face, "red", { cres = 6, deep = 2 })
  -- cross band
  c:part(c:rect(45, 24, 51, 80):clip(face), "wood", { cres = 3, deep = 1, gloss = false })
  c:part(c:rect(26, 42, 70, 48):clip(face), "wood", { cres = 3, deep = 1, gloss = false })
  -- boss
  c:part(c:ellipse(48, 45, 8, 8), "gold", { cres = 4, deep = 1 })
  save(c, "trial")
end

local fns = { vigil = vigil, befriend = befriend, trial = trial }
for _, n in ipairs({ "vigil", "befriend", "trial" }) do
  if ONLY == "all" or ONLY == n then fns[n](canvas()) end
end
