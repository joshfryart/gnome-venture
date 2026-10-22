-- Flower head "bell" (Stitched Toy). Petals neutral grey (runtime tint), centre/clapper + stitching fixed gold.
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0, margin = 1 }

-- neutral petal ramps (no hue)
local GREY = { gloss = "#f3f3f3", dot = "#fafafa", rim = "#e2e2e2", base = "#cbcbcb",
               shade = "#a0a0a0", deep = "#767676", bounce = "#adadad", pale = true }
local INNER = { gloss = "#8a8a8a", dot = "#8a8a8a", rim = "#7a7a7a", base = "#5f5f5f",
                shade = "#4c4c4c", deep = "#404040", bounce = "#5f5f5f", pale = false }
local GOLD = GV.R.gold
-- back bell sits a step darker (original's 14% overlay), still neutral
local GREY2 = { gloss = "#e6e6e6", dot = "#f0f0f0", rim = "#d2d2d2", base = "#b9b9b9",
                shade = "#929292", deep = "#6c6c6c", bounce = "#9e9e9e", pale = true }

-- SVG path sampler: bell outline in 64-unit space, transformed by (ox,oy,s)
local SEG = { {32,4, 23,4, 21,14, 21,24}, {21,24, 21,33, 15,37, 12,44}, {12,44, 22,49, 42,49, 52,44},
              {52,44, 49,37, 43,33, 43,24}, {43,24, 43,14, 41,4, 32,4} }
local function bellPoly(ox, oy, s)
  local pts = {}
  for _, g in ipairs(SEG) do
    for i = 0, 15 do
      local t = i / 16; local u = 1 - t
      local X = u*u*u*g[1] + 3*u*u*t*g[3] + 3*u*t*t*g[5] + t*t*t*g[7]
      local Y = u*u*u*g[2] + 3*u*u*t*g[4] + 3*u*t*t*g[6] + t*t*t*g[8]
      pts[#pts+1] = { ox + s*X + 0.5, oy + s*Y + 0.5 }
    end
  end
  return c:poly(pts)
end
local function T(ox, oy, s, X, Y) return ox + s*X, oy + s*Y end

local function bell(ox, oy, s, big)
  local body = bellPoly(ox, oy, s)
  -- five-lobed scalloped hem (campanula lobes) along the lip
  local lx = { 15, 23.5, 32, 40.5, 49 }
  for i, X in ipairs(lx) do
    local cx, cy = T(ox, oy, s, X, (i == 1 or i == 5) and 45.5 or 47.2)
    body:add(c:ellipse(cx, cy, math.max(1.5, 4.2*s), math.max(1.5, 2.6*s)))
  end
  local ocx, ocy = T(ox, oy, s, 32, 43.8)
  local open = c:ellipse(ocx, ocy, 15.5*s, math.max(1.5, 2.4*s))
  -- clapper (fixed centre): stalk + ball
  local sx0, sy0 = T(ox, oy, s, 32, 44)
  local bx, by = T(ox, oy, s, 32, 53)
  local stalk = c:rect(math.floor(sx0) - 1 + (big and 0 or 1), math.floor(sy0), math.floor(sx0) + (big and 0 or 1), math.floor(by) - 1)
  local ball = c:ellipse(bx, by, big and 2.5 or 1.5, big and 2.5 or 1.5)
  return body, open, stalk, ball
end

-- small bell behind (upper right), big bell in front (left)
local sb, so, ss, sbl = bell(31, 15, 0.5, false)
local bb, bo, bs, bbl = bell(-5, 5, 0.9, true)

local P = {}
P.sbody  = c:part(sb, GREY2, { light = sb:grow(1), cres = 4 })
P.sopen  = c:part(so, INNER, { flat = true, rim = false, contour = false, contact = false })
P.sstalk = c:part(ss, GOLD, { flat = true, contact = false, contour = false })
P.sball  = c:part(sbl, GOLD, { flat = true, contour = false })
P.bbody  = c:part(bb, GREY, { gloss = { 17, 14 }, light = bb:grow(1), cres = 6, deep = 3 })
P.bopen  = c:part(bo, INNER, { flat = true, rim = false, contact = false, contour = false })
P.bstalk = c:part(bs, GOLD, { flat = true, contact = false, contour = false })
P.bball  = c:part(bbl, GOLD, { flat = true, contour = false })

-- throat: the top rows of each opening fall into the deepest grey
for _, o in ipairs({ P.bopen, P.sopen }) do
  o.m:each(function(x, y) if not o.m:has(x, y - 2) or not o.m:has(x, y - 1) then c:px(x, y, INNER.deep) end end)
end
-- highlight streak (original's white stroke M25 10 C22 18 22 26 24 32) on the big bell, in petal greys
for _, p in ipairs({ {20,18},{20,19},{19,20},{19,21},{19,22},{19,23},{19,24},{19,25},{19,26},{20,27},{20,28},{20,29} }) do
  if c:get(p[1], p[2]) == GREY.base then c:px(p[1], p[2], GREY.rim) end
end
-- felt panel seams (thread gold 2 on / 1 off) following the original's shade stroke, plus calyx buttons
c:seam({ {27, 15}, {29, 20}, {30, 26}, {30, 31}, {29, 36}, {28, 40} })
c:seam({ {51, 21}, {52, 25}, {52, 29} })
c:button(22, 10)
c:px(48, 18, GV.C.gold); c:px(49, 18, GV.C.gold); c:px(48, 19, GV.C.goldS); c:px(49, 19, GV.C.goldS)
-- glints on the clapper balls (fixed group)
c:px(22, 51, GOLD.gloss); c:px(46, 41, GOLD.gloss)

c:finish()

---------------------------------------------------------------- split into petals / centre
local centreM = c:mask()
for _, k in ipairs({ "sstalk", "sball", "bstalk", "bball" }) do centreM:add(P[k].m) end
local petalM = c:mask()
for _, k in ipairs({ "sbody", "sopen", "bbody", "bopen" }) do petalM:add(P[k].m) end
local cg, pg = centreM:grow(3), petalM:grow(2)
local FIXED = {}
for _, v in pairs(GOLD) do if type(v) == "string" then FIXED[v] = true end end
FIXED[GV.C.gold], FIXED[GV.C.goldS], FIXED[GV.C.hole] = true, true, true

local pc = app.pixelColor
local function newImg() local i = Image(64, 64, ColorMode.RGB) i:clear(pc.rgba(0,0,0,0)) return i end
local full, pet, cen = newImg(), newImg(), newImg()
local function rgba(h) return pc.rgba(tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16), 255) end
for k, h in pairs(c.pix) do
  local x, y = c:xy(k)
  if c:inside(x, y) then
    local v = rgba(h)
    full:putPixel(x, y, v)
    local isCentre = centreM.s[k] or FIXED[h] or (not petalM.s[k] and cg.s[k] and not pg.s[k])
    if isCentre then cen:putPixel(x, y, v) else pet:putPixel(x, y, v) end
  end
end

for _, d in ipairs({ "png", "aseprite", "scripts" }) do pcall(function() app.fs.makeAllDirectories(OUT .. d) end) end
local spr = Sprite(64, 64, ColorMode.RGB)
spr.layers[1].name = "petals"
spr.cels[1].image = pet
local lc = spr:newLayer(); lc.name = "centre"
spr:newCel(lc, spr.frames[1], cen, Point(0, 0))
spr:saveAs(OUT .. "aseprite/bell.aseprite")
spr:close()
full:saveAs(OUT .. "png/bell.png")
pet:saveAs(OUT .. "png/bell-petals.png")
cen:saveAs(OUT .. "png/bell-centre.png")
print("full   " .. GV.report(GV.check(full)))
print("petals " .. GV.report(GV.check(pet)))
print("centre " .. GV.report(GV.check(cen)))
if os.getenv("BELL_DUMP") then -- ASCII inspection of the full head (debug only)
  local map, n, chars = {}, 0, "abcdefghijklmnopqrstuvwxyz"
  for y = 0, 63 do
    local row = {}
    for x = 0, 63 do
      local h = c:get(x, y)
      if not h then row[#row+1] = " " else
        if not map[h] then n = n + 1; map[h] = chars:sub(n, n); print(map[h] .. " " .. h) end
        row[#row+1] = map[h]
      end
    end
    print(string.format("%2d ", y) .. table.concat(row))
  end
end
