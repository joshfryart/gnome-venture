-- variety-journal-a.lua : Road Journal region pictures, first pass: na ca cb sa nwe se ee (96x96, icon mode).
-- Family: a cream journal-paper card (stitched edge, faint ruled lines) with ONE sketched subject on it.
-- Params: --script-param root=<repo> only=<code>   (default: all seven). PNG -> game/assets/img/journal/<code>.png
local P = app.params
local H = dofile((P.root or "/home/user/gnome-venture") .. "/aseprite-source/extras-pixel/scripts/variety-tier-common.lua")
local GV = H.GV
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs

local CREAM = GV.ramp("#f1ece0")
local PLANK = GV.ramp("#c9a96e")
local WOOD = GV.ramp("#9a6b3f")
local DWOOD = GV.ramp("#7a4a1f")
local STONE = GV.ramp("#8b8f96")

local OUTDIR = (P.root or "/home/user/gnome-venture") .. "/game/assets/img/journal/"
local function save(c, code)
  local t = c:save(H.out .. "/variety-journal-" .. code .. ".aseprite", OUTDIR .. code .. ".png")
  print(code .. " " .. GV.report(t))
end

-- the journal page every picture sits on
local function page(c)
  c:part(c:rrect(9, 9, 86, 86, 3), CREAM, { stitch = { side = "lit" }, gloss = false, cres = 4, deep = 1 })
  for _, y in ipairs({ 22, 31, 40, 49, 58, 67, 76 }) do
    for x = 15, 80 do if c:get(x, y) then c:px(x, y, "#e6d9b4") end end
  end
end

-- rotated ellipse / leaf mask: centre, half-length a (along angle deg, 0 = up), half-width b, pointed ends if pt
local function blade(c, cx, cy, a, b, deg, pt)
  local m = c:mask()
  local th = math.rad(deg)
  local ux, uy = sin(th), -cos(th)
  for y = 0, 95 do for x = 0, 95 do
    local dx, dy = x - cx, y - cy
    local t = dx * ux + dy * uy
    local n = -dx * uy + dy * ux
    local f = t / a
    if abs(f) <= 1 then
      local w = pt and (b * (1 - f * f) ^ 0.7) or b * (1 - f * f) ^ 0.5
      if abs(n) <= w then m:set(x, y) end
    end
  end end
  return m
end

----------------------------------------------------------------- na: maple leaf
local function na()
  local c = H.canvas()
  page(c)
  local R = { { 48, 14 }, { 53, 27 }, { 59, 22 }, { 59, 36 }, { 71, 31 }, { 67, 43 }, { 77, 48 }, { 64, 57 }, { 66, 64 }, { 52, 60 } }
  local pts = {}
  for _, p in ipairs(R) do pts[#pts + 1] = { p[1], p[2] } end
  pts[#pts + 1] = { 48, 70 }
  for i = #R, 1, -1 do pts[#pts + 1] = { 96 - R[i][1], R[i][2] } end
  c:part(c:rect(46, 62, 49, 80), GV.ramp("#8a4a1f"), { flat = true })
  c:part(c:poly(pts), "red", { cres = 7, deep = 2 })
  -- veins
  local V = "#8a1f1a"
  for y = 24, 66 do c:px(48, y, V) end
  for i = 0, 14 do c:px(48 + i, 50 - i, V); c:px(47 - i, 50 - i, V) end
  for i = 0, 9 do c:px(48 + i, 56 - floor(i * 0.3), V); c:px(47 - i, 56 - floor(i * 0.3), V) end
  for i = 0, 8 do c:px(48 + i, 38 - i, V); c:px(47 - i, 38 - i, V) end
  save(c, "na")
end

----------------------------------------------------------------- ca: maize cob
local function ca()
  local c = H.canvas()
  page(c)
  local cob = c:ellipse(48, 42, 12, 26):cut(c:rect(0, 66, 99, 99))
  c:part(cob, "gold", { cres = 6, deep = 2, gloss = false })
  local K = "#b07a10"
  for y = 20, 62, 4 do for x = 40, 56, 4 do
    local xx = x + ((y // 4) % 2) * 2
    if c:get(xx, y) and c:get(xx + 1, y + 1) then c:px(xx, y, K); c:px(xx + 1, y, K) end
  end end
  -- silk tuft
  c:part(c:rect(46, 10, 50, 17), GV.ramp("#9a6b3f"), { flat = true, contact = false })
  -- husks wrapped round the base
  c:part(blade(c, 33, 60, 25, 10, -18, true), "moss", { cres = 5, deep = 1 })
  c:part(blade(c, 63, 60, 25, 10, 18, true), "moss", { cres = 5, deep = 1 })
  c:part(blade(c, 48, 66, 20, 8, 0, true):clip(c:rect(0, 40, 99, 99)), GV.ramp("#8cc060"), { cres = 4, deep = 1 })
  save(c, "ca")
end

----------------------------------------------------------------- cb: conch shell
local function cb()
  local c = H.canvas()
  page(c)
  local SH = GV.ramp("#f2b48a")
  -- spire: stacked whorls climbing to the upper left
  local whorls = { { 22, 24, 4, 3.5 }, { 27, 29, 6, 5 }, { 33, 35, 8, 6.5 }, { 40, 42, 10, 8.5 } }
  for _, w in ipairs(whorls) do c:part(c:ellipse(w[1], w[2], w[3], w[4]), SH, { cres = 3, deep = 1, gloss = false }) end
  -- body whorl
  c:part(blade(c, 56, 58, 26, 17, -68, false), SH, { cres = 7, deep = 2 })
  -- shoulder spikes
  for _, p in ipairs({ { 47, 44 }, { 55, 41 }, { 63, 41 }, { 71, 44 } }) do
    c:part(c:poly({ { p[1] - 3, p[2] + 3 }, { p[1], p[2] - 4 }, { p[1] + 3, p[2] + 3 } }), GV.ramp("#f6c9a4"), { flat = true })
  end
  -- long pink aperture along the lower edge
  c:part(blade(c, 57, 69, 17, 6, -78, false), GV.ramp("#e8777f"), { cres = 3, deep = 1, gloss = false })
  c:part(blade(c, 58, 70, 11, 3, -78, false), GV.ramp("#a8404a"), { flat = true, contour = false, contact = false })
  local G = "#d98a5e"
  for i = 0, 16 do c:px(42 + i, 56 - floor(i * 0.15), G) end
  for i = 0, 12 do c:px(48 + i, 50, G) end
  save(c, "cb")
end

----------------------------------------------------------------- sa: pan pipes
local function sa()
  local c = H.canvas()
  page(c)
  local BAM = GV.ramp("#d9b25a")
  local tops = { 22, 29, 36, 43, 50, 57 }
  for i, y in ipairs(tops) do
    local x = 16 + (i - 1) * 11
    c:part(c:rrect(x, y, x + 10, 76, 2), BAM, { cres = 3, deep = 1, gloss = false })
    c:part(c:ellipse(x + 5, y + 2, 3, 1.5), GV.ramp("#3d2a1c"), { flat = true, contour = false, contact = false })
  end
  -- binding bands
  c:part(c:rect(16, 52, 80, 57), "red", { flat = true })
  c:part(c:rect(16, 66, 80, 69), "red", { flat = true })
  for x = 18, 78, 11 do c:px(x, 54, "#f1ece0"); c:px(x + 1, 55, "#f1ece0") end
  save(c, "sa")
end

----------------------------------------------------------------- nwe: post box
local function nwe()
  local c = H.canvas()
  page(c)
  c:part(c:rrect(30, 72, 66, 80, 2), STONE, { gloss = false })
  c:part(c:rrect(34, 32, 62, 76, 3), "red", { cres = 6, deep = 2 })
  c:part(c:ellipse(47.5, 33, 14, 8):cut(c:rect(0, 34, 99, 99)), "red", { cres = 4, deep = 1 })
  c:part(c:rect(34, 40, 62, 43), GV.ramp("#a8241f"), { flat = true })
  -- the slot with a letter
  c:part(c:rrect(39, 47, 57, 52, 1), GV.ramp("#2a1a10"), { flat = true, contact = false })
  c:part(c:rect(42, 43, 54, 50), CREAM, { flat = true, contact = false })
  c:px(48, 45, "#d6322b"); c:px(49, 45, "#d6322b")
  -- gold crest band and lower door panel
  c:seam({ { 37, 60 }, { 59, 60 } })
  c:part(c:rrect(39, 63, 57, 72, 1), GV.ramp("#b8301f"), { flat = true, contact = false })
  c:button(46, 65)
  save(c, "nwe")
end

----------------------------------------------------------------- se: olive sprig
local function se()
  local c = H.canvas()
  page(c)
  c:part(c:line({ { 17, 74 }, { 36, 60 }, { 56, 48 }, { 78, 28 } }, 3), WOOD, { flat = true })
  local LEAF = GV.ramp("#8fa860")
  local leaves = { { 30, 52, -50 }, { 44, 66, 45 }, { 47, 40, -45 }, { 60, 56, 50 }, { 64, 32, -55 }, { 74, 42, 60 }, { 22, 66, -40 } }
  for _, l in ipairs(leaves) do c:part(blade(c, l[1], l[2], 11, 3.5, l[3], true), LEAF, { cres = 3, deep = 1, gloss = false }) end
  local GR, PU = GV.ramp("#a8b84a"), GV.ramp("#5b4a7a")
  c:part(c:ellipse(37, 66, 4, 5), GR, { cres = 3, deep = 1 })
  c:part(c:ellipse(57, 63, 4, 5), PU, { cres = 3, deep = 1 })
  c:part(c:ellipse(66, 47, 4, 5), PU, { cres = 3, deep = 1 })
  c:part(c:ellipse(52, 31, 4, 5), GR, { cres = 3, deep = 1 })
  save(c, "se")
end

----------------------------------------------------------------- ee: sunflower
local function ee()
  local c = H.canvas()
  page(c)
  c:part(c:rect(46, 50, 50, 80), GV.ramp("#4f9a45"), { flat = true })
  c:part(blade(c, 33, 66, 14, 6, -60, true), "moss", { cres = 3, deep = 1 })
  c:part(blade(c, 63, 70, 14, 6, 60, true), "moss", { cres = 3, deep = 1 })
  local cx, cy = 48, 36
  local pet = c:mask()
  for i = 0, 11 do
    local a = i * 30
    local th = math.rad(a)
    pet:add(blade(c, cx + sin(th) * 17, cy - cos(th) * 17, 10, 4.5, a, true))
  end
  c:part(pet, "gold", { cres = 6, deep = 2, gloss = false })
  for i = 0, 11 do
    local th = math.rad(i * 30 + 15)
    for r = 13, 21 do
      local x, y = floor(cx + sin(th) * r + 0.5), floor(cy - cos(th) * r + 0.5)
      if pet:has(x, y) and pet:has(x + 1, y) and pet:has(x - 1, y) then c:px(x, y, "#c98a10") end
    end
  end
  c:part(c:ellipse(cx, cy, 11, 11), DWOOD, { cres = 4, deep = 2, gloss = false })
  for y = 28, 44, 3 do for x = 40, 56, 3 do
    if (x - cx) ^ 2 + (y - cy) ^ 2 < 70 then c:px(x + ((y // 3) % 2), y, "#3d2a1c") end
  end end
  save(c, "ee")
end

local fns = { na = na, ca = ca, cb = cb, sa = sa, nwe = nwe, se = se, ee = ee }
local order = { "na", "ca", "cb", "sa", "nwe", "se", "ee" }
for _, k in ipairs(order) do if not P.only or P.only == "" or P.only == "all" or P.only == k then fns[k]() end end
