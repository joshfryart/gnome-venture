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
  c:finish() -- then: 1 px #000000 border -> ink, any #ffffff -> cream (Hearth Pop: no pure B/W)
  for k, v in pairs(c.pix) do
    if v == "#000000" then c.pix[k] = "#2b1c26" elseif v == "#ffffff" then c.pix[k] = "#fff4d6" end
  end
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
  local WAX = GV.ramp("#f1ece0", { shade = "#d8c49a", bounce = "#e6d4ac", deep = "#b08a5a", rim = "#fff4d6", dot = "#fff4d6" })
  local GLOW = { base = "#ffe38a", rim = "#fff1c8", shade = "#f5cf6a", deep = "#f5b82e", bounce = "#f5cf6a", gloss = "#fff1c8", dot = "#fff4d6" }
  -- crescent moon (upper right), clear of the flame
  local moon = c:ellipse(76, 22, 13, 13):cut(c:ellipse(83, 17, 11, 11))
  c:part(moon, "gold", { cres = 4, deep = 1, gloss = false })
  star(c, 16, 22, 4); star(c, 86, 50, 3); star(c, 22, 46, 2)
  -- stool: legs, rung, seat
  c:part(c:poly({ { 28, 76 }, { 35, 76 }, { 31, 91 }, { 24, 91 } }), DWOOD, { cres = 3, deep = 1, gloss = false })
  c:part(c:poly({ { 61, 76 }, { 68, 76 }, { 72, 91 }, { 65, 91 } }), DWOOD, { cres = 3, deep = 1, gloss = false })
  c:part(c:rect(29, 84, 67, 86), "soil", { cres = 2, deep = 1, gloss = false })
  c:part(c:rrect(18, 70, 78, 79, 3), "wood", { cres = 5, deep = 2 })
  -- holder dish
  c:part(c:ellipse(48, 69, 17, 4), "gold", { cres = 3, deep = 1, gloss = false })
  -- flame glow: a two-step halo hugging the flame (drawn behind it)
  local flp = { { 49, 9 }, { 54, 19 }, { 57, 28 }, { 53, 37 }, { 44, 37 }, { 40, 29 }, { 43, 20 } }
  local halo = c:poly(flp):grow(4):cut(c:rect(0, 41, 95, 95))
  c:part(halo, GLOW, { flat = true, rim = false, contact = false })
  c:fill(halo:copy():cut(c:poly(flp):grow(2)), "#f5cf6a")
  -- candle: uneven melted top, side drips that break the silhouette
  local cand = c:rrect(41, 42, 55, 68, 2):add(c:rect(41, 40, 45, 44)):add(c:rect(52, 41, 55, 44))
  cand:add(c:rrect(39, 43, 41, 53, 1)):add(c:rrect(55, 43, 57, 49, 1))
  c:part(cand, WAX, { cres = 5, deep = 2, gloss = false })
  -- melt pool in the dip, front drips with a shade edge
  c:fill(c:rect(46, 41, 51, 42), "#d8c49a")
  for _, d in ipairs({ { 44, 43, 57 }, { 49, 43, 50 } }) do
    c:fill(c:rect(d[1], d[2], d[1] + 1, d[3]), "#fff4d6")
    c:fill(c:rect(d[1] + 2, d[2] + 1, d[1] + 2, d[3]), "#d8c49a")
    c:fill(c:rect(d[1], d[3] + 1, d[1] + 1, d[3] + 1), "#d8c49a")
  end
  -- wax puddle on the dish
  c:part(c:rrect(37, 65, 59, 68, 1), WAX, { cres = 2, deep = 1, gloss = false })
  -- wick
  c:part(c:rect(47, 34, 48, 41), GV.ramp("#4e2a16"), FL)
  -- flame (teardrop, slight lean) + gold core + cream heart
  c:part(c:poly(flp), "flame", { cres = 5, deep = 1, gloss = false, contact = false, contour = false })
  c:part(c:poly({ { 49, 19 }, { 53, 28 }, { 52, 35 }, { 45, 35 }, { 44, 28 } }), GLOW, { flat = true, rim = false, contour = false, contact = false })
  c:fill(c:rect(47, 28, 49, 33), "#fff4d6")
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
  local BLADE = GV.ramp("#b4bcc8", { rim = "#e6ecf2", gloss = "#eef3f7", dot = "#f4f7fa", shade = "#7d8596", deep = "#545a6e", bounce = "#8c93a3" })
  local function sword(x0, y0, x1, y1)
    -- tip at (x0,y0), pommel end at (x1,y1); guard sits just outside the shield's lower edge
    local function lerp(t) return { x0 + (x1 - x0) * t, y0 + (y1 - y0) * t } end
    local b = band(lerp(0.07), lerp(0.76), 4.5)
    local tip = c:poly({ lerp(0.0), b[1], b[4] }):add(c:poly(band(lerp(0.065), lerp(0.76), 4.5)))
    c:part(tip, BLADE, { cres = 3, deep = 1, gloss = false })
    -- fuller: dark groove down the blade middle
    c:part(c:line({ lerp(0.09), lerp(0.74) }, 1), flatr("#7d8596"), FL)
    c:part(c:poly(band(lerp(0.745), lerp(0.79), 11)), "gold", { cres = 2, deep = 1, gloss = false })
    c:part(c:poly(band(lerp(0.79), lerp(0.91), 2.6)), DWOOD, { cres = 2, deep = 1, gloss = false })
    local pm = lerp(0.935)
    c:part(c:ellipse(pm[1], pm[2], 4, 4), "gold", { cres = 2, deep = 1, gloss = false })
  end
  sword(6, 4, 86, 88)
  sword(90, 4, 10, 88)
  -- shield (hero): iron rim with a battle notch, red face, wooden cross, gold boss
  local sh = c:poly({ { 26, 19 }, { 70, 19 }, { 72, 46 }, { 64, 66 }, { 48, 85 }, { 32, 66 }, { 24, 46 } })
  sh:cut(c:poly({ { 64, 15 }, { 74, 15 }, { 74, 34 }, { 63, 26 } }))
  c:part(sh, IRON, { cres = 6, deep = 2 })
  local face = c:poly({ { 31, 25 }, { 65, 25 }, { 66, 45 }, { 59, 62 }, { 48, 77 }, { 37, 62 }, { 30, 45 } })
  face:cut(c:poly({ { 60, 22 }, { 72, 22 }, { 72, 38 }, { 60, 30 } }))
  c:part(face, "red", { cres = 6, deep = 2 })
  c:part(c:rect(45, 25, 51, 78):clip(face), "wood", { cres = 3, deep = 1, gloss = false })
  c:part(c:rect(30, 41, 66, 47):clip(face), "wood", { cres = 3, deep = 1, gloss = false })
  c:part(c:ellipse(48, 44, 7, 7), "gold", { cres = 4, deep = 1 })
  save(c, "trial")
end

local fns = { vigil = vigil, befriend = befriend, trial = trial }
for _, n in ipairs({ "vigil", "befriend", "trial" }) do
  if ONLY == "all" or ONLY == n then fns[n](canvas()) end
end
