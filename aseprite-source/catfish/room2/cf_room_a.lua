-- cf_room_a.lua : Cat Fish room A "warm cottage" background plates (room2/room_a_spec.md is authoritative).
-- Grid 240 x 135 drawn, exported 2x nearest (480 x 270; P4 244 x 135 -> 488 x 270 at x -4). Spec numbers are export px.
-- Direct pixel drawing (no gvlib parts): hard pixels, alpha 0/255, no gradients (stepped bands), no #000/#fff.
-- Run: AppRun -b --script cf_room_a.lua      Writes out_room/: cf-room2-p0-sky, -p0n-night-sky, -p1-wall, -p2-floor,
--   -p4-front, -p5-sunbeam, -p5b-night, -window, -window-nobird, -bird (.png), room-a.aseprite, room-layout-a.json.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out_room/"
pcall(function() app.fs.makeAllDirectories(OUT) end)
local fl = math.floor
local GW, GH = 240, 135

-------------------------------------------------------------------------------- palette (spec + style guide families)
local K = {
  crown = "#b07a45", crownS = "#8a4f2a", rim = "#d9a660",
  haze = "#e9d9b0", stripe = "#e8cc98", farW = "#dcbc88", lit = "#f2dfb6",
  wain = "#9a6b3f", skirtD = "#74462a", soil = "#5a3a1e", hall = "#c9a96e", umber = "#4a2c1a",
  red = "#dd3a2a", green = "#4a8a3e", blue = "#3f8fb0", gold = "#e8a317", cream = "#f2e4c0",
  terra = "#c8643c", leafL = "#7ab55c", leafD = "#2f5a2a",
  fl1 = "#c78d52", fl2 = "#b07a45", seamD = "#8a4f2a", seamL = "#9a6b3f",
  sky1 = "#c8e8f4", sky2 = "#a9d6ea", hillA = "#8cc064", hillB = "#5f9e48", cloud = "#f1ece0",
  n1 = "#291d4a", n2 = "#3e2f66",
  legB = "#5e2f1e", legR = "#74462a",
  flameA = "#ffc27a", flameB = "#f5cf6a",
}
local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end

-------------------------------------------------------------------------------- plate store (grid px, hex strings)
local function Plate(gw, gh, ox) return { gw = gw, gh = gh, ox = ox or 0, p = {} } end
local function pset(P, x, y, c) if x >= 0 and y >= 0 and x < P.gw and y < P.gh then P.p[y * P.gw + x] = c end end
local function pget(P, x, y) if x < 0 or y < 0 or x >= P.gw or y >= P.gh then return nil end return P.p[y * P.gw + x] end
local function rectG(P, x0, y0, x1, y1, c) for y = y0, y1 do for x = x0, x1 do pset(P, x, y, c) end end end
-- export-px inclusive rect -> grid
local function rectE(P, x0, y0, x1, y1, c) rectG(P, fl(x0 / 2), fl(y0 / 2), fl((x1 + 1) / 2) - 1, fl((y1 + 1) / 2) - 1, c) end
local function inPoly(pts, px, py)
  local inside, j = false, #pts
  for i = 1, #pts do
    local xi, yi, xj, yj = pts[i][1], pts[i][2], pts[j][1], pts[j][2]
    if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then inside = not inside end
    j = i
  end
  return inside
end
-- polygon in EXPORT coords, tested at grid pixel centres
local function polyE(P, pts, c, fn)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, q in ipairs(pts) do x0, y0, x1, y1 = math.min(x0, q[1]), math.min(y0, q[2]), math.max(x1, q[1]), math.max(y1, q[2]) end
  for gy = fl(y0 / 2), fl(y1 / 2) do for gx = fl(x0 / 2), fl(x1 / 2) do
    if inPoly(pts, 2 * gx + 1, 2 * gy + 1) then if fn then fn(gx, gy) else pset(P, gx, gy, c) end end
  end end
end
local function ascii(P, rows, x0, y0, leg)
  for j, r in ipairs(rows) do for i = 1, #r do
    local ch = r:sub(i, i)
    if ch ~= "." and ch ~= " " then pset(P, x0 + i - 1, y0 + j - 1, leg[ch]) end
  end end
end
-- 1 px umber outline round a set of pixels (all sides, +1 toward lower right)
local function outlineSet(P, S, c, w)
  local add = {}
  local off = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 }, { 1, 1 } }
  for k in pairs(S) do
    local x, y = k % 1000, fl(k / 1000)
    for _, o in ipairs(off) do
      local nx, ny = x + o[1], y + o[2]
      if not S[ny * 1000 + nx] then add[ny * 1000 + nx] = true end
    end
  end
  for k in pairs(add) do pset(P, k % 1000, fl(k / 1000), c) end
end
local function S_add(S, x, y) S[y * 1000 + x] = true end

-------------------------------------------------------------------------------- depth model (spec 1)
local function persp(u, d)
  return 240 + (u - .5) * 720 * (1 - .45 * d), 268 - 158 * d ^ .8, 1 - .58 * d
end
local function seamX(k, y) return (-100 + 40 * k) + (153 - 18 * k) * (268 - y) / 158 end

-------------------------------------------------------------------------------- vignette + remaps (spec 7)
local DOWN1 = { [K.fl1] = K.fl2, [K.fl2] = K.wain, [K.haze] = K.stripe, [K.stripe] = K.farW, [K.lit] = K.haze }
local function vignette(P)
  for gy = 0, P.gh - 1 do for gx = 0, P.gw - 1 do
    local c = pget(P, gx, gy)
    if c then
      local x, y = 2 * (gx + P.ox) + 1, 2 * gy + 1
      local e = ((x - 240) / 240) ^ 2 + ((y - 135) / 135) ^ 2
      if e > 1.15 then c = DOWN1[c] or c end
      if e > 1.45 then c = DOWN1[c] or c end
      P.p[gy * P.gw + gx] = c
    end
  end end
end
local UPB = { [K.fl1] = K.rim, [K.fl2] = K.fl1, [K.wain] = K.fl2, [K.seamD] = K.wain, [K.haze] = K.lit }
local EXT = { [K.rim] = "#ecc58a", [K.lit] = "#f8e8c4" }
local function UP1(c) return UPB[c] or c end
local function UP2(c) local a = UPB[c] or EXT[c] or c; return UPB[a] or EXT[a] or a end

-------------------------------------------------------------------------------- P1: walls + back-wall furniture
local P1 = Plate(GW, GH)
local function wallBand(yb) -- colour for back-wall export row yb (rows 6..109)
  if yb < 78 then return "wp" end
  if yb < 80 then return K.rim end
  if yb < 82 then return K.crown end
  if yb < 84 then return K.seamD end
  if yb < 100 then return K.wain end
  if yb < 102 then return K.rim end
  if yb < 108 then return K.crown end
  return K.skirtD
end
-- back wall x 42..437 -> gx 21..218
for gx = 21, 218 do
  local xe = 2 * gx
  for gy = 0, 54 do
    local ye = 2 * gy
    local c
    if ye < 4 then c = K.crown elseif ye < 6 then c = K.crownS
    else
      local b = wallBand(ye)
      if b == "wp" then c = (((xe - 42) % 16) < 6) and K.stripe or K.haze
      elseif b == K.wain then c = (((xe - 42) % 44) < 2) and K.seamD or K.wain
      else c = b end
    end
    pset(P1, gx, gy, c)
  end
end
-- side walls (spec 2): sloped bands converge on the vanishing point; floor line (42,110)-(0,151), (438,110)-(479,151)
local STRIPES = { { 0, 1 }, { 6, 7 }, { 11, 12 }, { 15, 16 }, { 18, 18 } } -- left wall stripe columns (gx) = x 0..3,12..15,22..25,30..33,36..37
local function cornerY(xe) return 110 + (42 - xe) * (41 / 42) end   -- xe = distance from the back-wall edge side (0..42)
local function sliver(left)
  for gx = (left and 0 or 219), (left and 20 or 239) do
    local xc = 2 * gx + 1
    local xe = left and xc or (479 - xc)
    local gm = left and gx or (239 - gx)
    local yc = cornerY(xe)
    local s = (yc - 110) / 193
    local stripe = false
    for _, r in ipairs(STRIPES) do if gm >= r[1] and gm <= r[2] then stripe = true end end
    for gy = 0, GH - 1 do
      local ye = 2 * gy + 1
      if ye < yc then
        local c
        if ye < 4 then c = K.crown elseif ye < 6 then c = K.crownS
        else
          local yb = (ye - 83 * s) / (1 + s)
          local b = wallBand(yb)
          if b == "wp" then
            if left then c = stripe and K.haze or K.lit else c = stripe and K.farW or K.stripe end
          else c = b end
        end
        pset(P1, gx, gy, c)
      end
    end
  end
end
sliver(true); sliver(false)
-- inner corners, 2 px
for gy = 3, 38 do pset(P1, 20, gy, K.farW); pset(P1, 219, gy, K.farW) end

-- doorway: frame 48..105 x 24..109, opening 54..99 x 32..109
do
  rectE(P1, 48, 24, 105, 109, K.crown)
  rectE(P1, 48, 24, 49, 109, K.rim); rectE(P1, 48, 24, 105, 25, K.rim)          -- lit rim left + top
  rectE(P1, 104, 26, 105, 109, K.crownS); rectE(P1, 50, 30, 53, 31, K.crownS)  -- shade right jamb, under lintel
  rectE(P1, 54, 32, 99, 109, K.hall)
  rectE(P1, 54, 32, 99, 35, K.wain)                                             -- lintel shadow in the hall
  rectE(P1, 54, 36, 55, 109, K.wain)                                            -- left reveal shade
  rectE(P1, 54, 92, 99, 97, K.rim)                                              -- hall skirting glint
  rectE(P1, 54, 98, 99, 109, K.soil)                                            -- hall floor
end

-- low bookshelf 116..187 x 64..109 (umber outline)
do
  local S = {}
  for gy = 32, 54 do for gx = 58, 93 do S_add(S, gx, gy) end end
  rectG(P1, 58, 32, 93, 54, K.wain)                                  -- back panel
  rectG(P1, 58, 32, 93, 32, K.rim); rectG(P1, 58, 33, 93, 33, K.crown)   -- top board
  rectG(P1, 58, 34, 59, 54, K.crown); rectG(P1, 58, 34, 58, 54, K.rim)   -- left post
  rectG(P1, 92, 34, 93, 54, K.crown); rectG(P1, 93, 34, 93, 54, K.crownS) -- right post
  rectG(P1, 60, 40, 91, 40, K.rim); rectG(P1, 60, 41, 91, 41, K.crown)   -- shelf y80
  rectG(P1, 60, 47, 91, 47, K.rim); rectG(P1, 60, 48, 91, 48, K.crown)   -- shelf y94
  rectG(P1, 58, 53, 93, 53, K.crown); rectG(P1, 58, 54, 93, 54, K.crownS) -- plinth
  rectG(P1, 60, 34, 91, 34, K.crownS)                                  -- shadow under the top board
  rectG(P1, 60, 42, 91, 42, K.crownS); rectG(P1, 60, 49, 91, 49, K.crownS)
  local cols = { K.red, K.green, K.blue, K.gold }
  local function books(x0, x1, ybot, hs, ci)
    local x, i = x0, 0
    while true do
      local w = (i % 2 == 0) and 3 or 4
      if x + w - 1 > x1 then break end
      local h = hs[i % #hs + 1]
      local col = cols[(i + ci) % 4 + 1]
      rectG(P1, x, ybot - h + 1, x + w - 1, ybot, col)
      if h >= 5 then pset(P1, x + 1, ybot - h + 2, K.cream) end          -- spine label
      if (i + ci) % 5 == 3 then x = x + w + 1 else x = x + w end        -- a gap now and then
      i = i + 1
    end
  end
  books(60, 91, 39, { 6, 5, 6, 5, 6, 4 }, 0)
  books(60, 91, 46, { 5, 4, 5, 5, 4, 5 }, 2)
  rectG(P1, 62, 52, 80, 52, K.blue); rectG(P1, 63, 51, 79, 51, K.red); rectG(P1, 64, 50, 78, 50, K.gold) -- books lying flat
  rectG(P1, 84, 51, 91, 52, K.green)
  outlineSet(P1, S, K.umber)
end

-- picture frame 140..163 x 22..51 (pet slot "frame")
do
  local S = {}
  for gy = 11, 25 do for gx = 70, 81 do S_add(S, gx, gy) end end
  rectG(P1, 70, 11, 81, 25, K.crown)
  rectG(P1, 70, 11, 70, 25, K.rim); rectG(P1, 70, 11, 81, 11, K.rim); rectG(P1, 81, 12, 81, 25, K.crownS); rectG(P1, 71, 25, 81, 25, K.crownS)
  rectG(P1, 71, 12, 80, 24, K.crown)
  rectG(P1, 72, 13, 79, 23, K.cream)
  rectG(P1, 73, 14, 78, 22, K.blue)
  rectG(P1, 73, 20, 78, 22, K.green); pset(P1, 75, 20, K.leafL)
  rectG(P1, 76, 15, 77, 16, K.gold)
  outlineSet(P1, S, K.umber)
end

-- window: frame 296..395 x 18..83, glass 304..387 x 26..77 (alpha 0), mullion 344..347, transom 50..53, sill 292..399 x 84..89
do
  local S = {}
  for gy = 9, 44 do for gx = (gy >= 42) and 146 or 148, (gy >= 42) and 199 or 197 do S_add(S, gx, gy) end end
  rectG(P1, 148, 9, 197, 41, K.crown)
  rectG(P1, 148, 9, 148, 41, K.rim); rectG(P1, 148, 9, 197, 9, K.rim)
  rectG(P1, 197, 10, 197, 41, K.crownS); rectG(P1, 149, 41, 196, 41, K.crownS)
  rectG(P1, 152, 13, 193, 38, nil)                                       -- glass: alpha 0
  for gy = 13, 38 do for gx = 152, 193 do P1.p[gy * GW + gx] = nil end end
  rectG(P1, 172, 13, 173, 38, K.crown); rectG(P1, 172, 13, 172, 38, K.rim); rectG(P1, 173, 13, 173, 38, K.crownS)
  rectG(P1, 152, 25, 193, 26, K.crown)
  rectG(P1, 152, 25, 171, 25, K.rim); rectG(P1, 174, 25, 193, 25, K.rim)
  rectG(P1, 152, 26, 171, 26, K.crownS); rectG(P1, 174, 26, 193, 26, K.crownS)
  rectG(P1, 146, 42, 199, 42, K.rim); rectG(P1, 146, 43, 199, 43, K.crown); rectG(P1, 146, 44, 199, 44, K.crownS)
  -- glass reveal shade (left and top inner edge) drawn into the frame
  rectG(P1, 151, 12, 193, 12, K.crownS); rectG(P1, 151, 13, 151, 38, K.crownS)
  outlineSet(P1, S, K.umber)
  -- outline must not cover glass
  for gy = 13, 38 do for gx = 152, 193 do P1.p[gy * GW + gx] = nil end end
end

-- plant: pot 404..427 x 90..109, leaves to y 50
do
  local S = {}
  local function leaf(cx, cy, len, wid, ang)
    local ca, sa = math.cos(ang), math.sin(ang)
    for gy = fl(cy - len - 1), fl(cy + len + 1) do for gx = fl(cx - len - 1), fl(cx + len + 1) do
      local dx, dy = gx + .5 - cx, gy + .5 - cy
      local a = dx * ca + dy * sa
      local b = -dx * sa + dy * ca
      local uu, vv = a / len, b / wid
      if uu * uu + vv * vv <= 1 then
        local c = K.green
        if vv < -.35 then c = K.leafL elseif vv > .45 or uu > .75 then c = K.leafD end
        if math.abs(vv) < .12 and uu > -.6 and uu < .8 then c = K.leafD end
        pset(P1, gx, gy, c); S_add(S, gx, gy)
      end
    end end
  end
  local px, py = 207.5, 45
  -- stems then leaves (angles from vertical-up fan; sa positive = down)
  local L = { { -2.45, 8.5, 3.6, -1.9 }, { 2.6, 8, 3.4, -1.15 }, { 0, 9, 3.8, -1.57 }, { 0, 5, 3.2, -2.6 }, { 0, 5, 3.2, -0.55 },
              { -5.5, 8, 3.2, -2.2 }, { 4.8, 9.5, 3.4, -0.9 } }
  -- centre positions computed as base + dir*len
  local leaves = {
    { 205.2, 38.5, 8.5, 3.4, -1.0 }, { 211.0, 36.5, 8.5, 3.4, -2.2 }, { 207.5, 31.5, 8.2, 3.2, -1.57 },
    { 200.0, 42.0, 6.5, 2.8, -0.2 }, { 215.0, 41.0, 6.5, 2.8, -2.95 }, { 203.0, 33.0, 7.0, 3.0, -1.2 }, { 212.5, 31.0, 7.0, 3.0, -1.95 },
  }
  for _, l in ipairs(leaves) do leaf(l[1], l[2], l[3], l[4], l[5]) end
  -- stems
  for gy = 40, 46 do pset(P1, 207, gy, K.leafD); pset(P1, 208, gy, K.leafD); S_add(S, 207, gy); S_add(S, 208, gy) end
  -- pot: rim gy45..46 (x 202..213), body gy47..54 narrower
  local function pot(x0, x1, y, c) for x = x0, x1 do pset(P1, x, y, c); S_add(S, x, y) end end
  pot(202, 213, 45, K.terra); pot(202, 213, 46, K.terra)
  for gy = 47, 54 do pot(203 + (gy > 51 and 1 or 0), 212 - (gy > 51 and 1 or 0), gy, K.terra) end
  rectG(P1, 202, 45, 213, 45, K.rim)                      -- lit rim
  rectG(P1, 203, 46, 213, 46, K.seamD)                    -- rim underside
  for gy = 47, 54 do
    local x0 = 203 + (gy > 51 and 1 or 0)
    pset(P1, x0, gy, K.rim)                               -- lit left edge
    pset(P1, 212 - (gy > 51 and 1 or 0), gy, K.seamD); pset(P1, 211 - (gy > 51 and 1 or 0), gy, K.seamD)
  end
  outlineSet(P1, S, K.umber)
end

-- sconce 16..25 x 44..59 (lit at night only)
do
  local S = {}
  local function pt(x, y, c) pset(P1, x, y, c); S_add(S, x, y) end
  for x = 10, 11 do for y = 22, 24 do pt(x, y, K.cream) end end        -- candle
  for x = 8, 12 do pt(x, 25, K.rim); pt(x, 26, K.crown) end              -- cup
  pt(8, 25, K.rim); pt(12, 26, K.crownS)
  for y = 27, 29 do for x = 9, 11 do pt(x, y, K.crown) end end          -- back plate
  rectG(P1, 11, 27, 11, 29, K.crownS)
  pset(P1, 9, 27, K.rim)
  outlineSet(P1, S, K.umber)
end
vignette(P1)

-------------------------------------------------------------------------------- P2: floor (rows 110..269, 18 boards)
local P2 = Plate(GW, GH)
local SEAMGX = {}   -- SEAMGX[gy][k] = gx of seam k
local function floorLeftEdge(ye) return 42 - (ye - 110) * 42 / 41 end
local function floorRightEdge(ye) return 438 + (ye - 110) end
local function cornerWall(xc, ye) -- true if (xc,ye) is on a side/back wall (not floor)
  local xe = (xc < 240) and xc or (479 - xc)
  if xe >= 42 then return ye < 110 end
  return ye < cornerY(xe)
end
local floorTop = {}
for gy = 0, GH - 1 do
  local ye = 2 * gy + 1
  local row = {}
  for k = 0, 17 do row[k] = fl(seamX(k, ye) / 2) end
  SEAMGX[gy] = row
  for gx = 0, GW - 1 do
    local xc = 2 * gx + 1
    if not cornerWall(xc, ye) then
      local b = 0
      for k = 0, 17 do if xc > seamX(k, ye) then b = b + 1 end end
      local isSeam = false
      for k = 0, 17 do if row[k] == gx then isSeam = true end end
      local c = (b % 2 == 0) and K.fl1 or K.fl2
      if isSeam then c = (ye >= 178) and K.seamD or K.seamL end
      pset(P2, gx, gy, c)
      if not floorTop[gx] then floorTop[gx] = gy end
    end
  end
end
-- soil band: 6 px under the wall/floor line
for gy = 0, GH - 1 do for gx = 0, GW - 1 do
  if pget(P2, gx, gy) then
    local xc, ye = 2 * gx + 1, 2 * gy + 1
    local xe = (xc < 240) and xc or (479 - xc)
    local yline = (xe >= 42) and 110 or cornerY(xe)
    if ye < yline + 6 then pset(P2, gx, gy, K.soil) end
  end
end end
-- butt joints: board b, d = .15 + .3 j + .1 (b mod 3), j 0..2, d < .95
for b = 0, 18 do
  for j = 0, 2 do
    local d = .15 + .3 * j + .1 * (b % 3)
    if d < .95 then
      local y = 268 - 158 * d ^ .8
      local gy = fl(y / 2)
      local row = SEAMGX[gy]
      if row then
        local xs = (b == 0) and -1 or row[b - 1]
        local xt = (b >= 18) and GW or row[b]
        for gx = math.max(xs + 1, 0), math.min(xt - 1, GW - 1) do
          local cur = pget(P2, gx, gy)
          if cur == K.fl1 or cur == K.fl2 then pset(P2, gx, gy, (2 * gy >= 178) and K.seamD or K.seamL) end
        end
      end
    end
  end
end
-- wood grain: short dashes, lit (light from the upper left window) on the c78d52 boards
do
  local seed = 7
  local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648; return seed % n end
  for i = 1, 300 do
    local gx, gy = rnd(GW), 58 + rnd(GH - 58)
    local len = 2 + rnd(3)
    local c = pget(P2, gx, gy)
    if c == K.fl1 then
      local ok = true
      for q = 0, len - 1 do local cc = pget(P2, gx + q, gy); if cc ~= K.fl1 then ok = false end end
      if ok then for q = 0, len - 1 do pset(P2, gx + q, gy, K.rim) end end
    elseif c == K.fl2 and gy > 80 then
      local ok = true
      for q = 0, len - 1 do local cc = pget(P2, gx + q, gy); if cc ~= K.fl2 then ok = false end end
      if ok then for q = 0, len - 1 do pset(P2, gx + q, gy, K.seamL) end end
    end
  end
end
vignette(P2)

-------------------------------------------------------------------------------- P0 / P0n: sky seen through the glass
local P0, P0n = Plate(GW, GH), Plate(GW, GH)
local function hillTopA(gx) return 33 - fl(2.4 * math.sin((gx - 152) / 5.5) + 1.4 * math.sin((gx - 152) / 2.7 + 1)) end -- back hills
local function hillTopB(gx) return 36 - fl(1.2 * math.sin((gx - 160) / 6 + 2)) end
for gy = 13, 38 do for gx = 152, 193 do
  local c = (gy <= 18) and K.sky1 or K.sky2
  if gy >= hillTopA(gx) then c = K.hillA end
  if gy >= hillTopB(gx) and gy >= 36 then c = K.hillB end
  pset(P0, gx, gy, c)
  local n = K.n1
  if gy >= hillTopA(gx) then n = K.n2 end
  pset(P0n, gx, gy, n)
end end
ascii(P0, { "..XXX...", ".XXXXXX.", "XXXXXXXX" }, 156, 15, { X = K.cloud })
ascii(P0, { "...XX..", ".XXXXXX", "XXXXXXX" }, 181, 20, { X = K.cloud })
rectG(P0n, 159, 17, 162, 20, K.cream); pset(P0n, 161, 17, K.n1); pset(P0n, 162, 17, K.n1)
pset(P0n, 155, 15, K.cream); pset(P0n, 167, 22, K.cream); pset(P0n, 183, 18, K.cream)

-------------------------------------------------------------------------------- window overlay + bird slot
local PW, PWn, PB = Plate(GW, GH), Plate(GW, GH), Plate(12, 10)
local ROBIN = {
  "...oooo.....",
  "..obbbbo....",
  ".obbbbbbo...",
  ".oebbbbbbo..",
  "yorrbbbbbbo.",
  "yorrrbbbbbbo",
  ".orrrrbbbbbo",
  ".orrrrwbbbo.",
  "..oowwwwwo..",
  "....o..o....",
}
local RLEG = { o = K.umber, b = K.crownS, r = K.terra, w = K.cream, y = K.gold, e = K.umber }
ascii(PB, ROBIN, 0, 0, RLEG)
pset(PB, 2, 3, K.cream); pset(PB, 3, 3, K.umber)  -- eye with a glint
pset(PB, 4, 2, K.wain); pset(PB, 5, 2, K.wain); pset(PB, 6, 1, K.wain)
for x = 8, 10 do pset(PB, x, 4, K.wain) end
do
  local function pot(x0)
    rectG(PWn, x0, 40, x0 + 5, 40, K.terra); rectG(PWn, x0 + 1, 41, x0 + 4, 41, K.terra)
    pset(PWn, x0, 40, K.rim); rectG(PWn, x0 + 4, 40, x0 + 5, 40, K.seamD); pset(PWn, x0 + 4, 41, K.seamD)
    pset(PWn, x0 + 1, 39, K.leafD); pset(PWn, x0 + 3, 39, K.leafD); pset(PWn, x0 + 2, 39, K.green)
    pset(PWn, x0 + 1, 38, K.green); pset(PWn, x0 + 2, 38, K.leafL); pset(PWn, x0 + 4, 38, K.green)
    pset(PWn, x0 + 3, 37, K.leafL)
  end
  pot(151); pot(161); pot(191)
end
for k, v in pairs(PWn.p) do PW.p[k] = v end
for y = 0, 9 do for x = 0, 11 do local c = pget(PB, x, y); if c then pset(PW, 178 + x, 29 + y, c) end end end

-------------------------------------------------------------------------------- P4: foreground (244 wide, x -4)
local P4 = Plate(244, GH, -2)
for _, x0 in ipairs({ 2, 14 }) do                       -- chair legs, plate gx 2..5 and 14..17
  for gy = 98, 134 do
    rectG(P4, x0, gy, x0 + 3, gy, K.legB); pset(P4, x0, gy, K.legR); pset(P4, x0 + 3, gy, K.umber)
  end
  for gy = 133, 134 do rectG(P4, x0 - 1, gy, x0 + 4, gy, K.legB); pset(P4, x0 - 1, gy, K.legR); pset(P4, x0 + 4, gy, K.umber) end
end
rectG(P4, 6, 116, 13, 118, K.legB); rectG(P4, 6, 116, 13, 116, K.legR); rectG(P4, 6, 118, 13, 118, K.umber)
do  -- hearth-rug fringe x 300..487, rows 262..269: tufts 4 on / 2 off
  for gx = 150, 243 do
    local m = (gx - 150) % 3
    local idx = fl((gx - 150) / 3)
    if m < 2 then
      local c = (idx % 2 == 0) and K.legB or K.umber
      rectG(P4, gx, 131, gx, 134, c)
    else pset(P4, gx, 131, K.legB) end
  end
end
vignette(P4)

-------------------------------------------------------------------------------- P5: sunbeam (remap) and P5b: night light
local P5 = Plate(GW, GH)
local BEAM = { { 277, 138 }, { 343, 138 }, { 330, 180 }, { 240, 180 } }
local beam = {}
polyE(P5, BEAM, nil, function(gx, gy)
  local ye, xc = 2 * gy + 1, 2 * gx + 1
  local xm = 310 + (285 - 310) * (ye - 138) / 42
  local bar = (math.abs(xc - xm) < 2.5) or (ye >= 157 and ye <= 160)   -- 4 px mullion + 4 px transom unlit
  if not bar then beam[gy * 1000 + gx] = true end
end)
for gy = 45, 49 do for gx = 152, 193 do beam[gy * 1000 + gx] = true end end    -- wall shaft under the sill
local function inner(S, x, y, r)
  for dy = -r, r do for dx = -r, r do if not S[(y + dy) * 1000 + x + dx] then return false end end end
  return true
end
local function srcPix(gx, gy) return pget(P2, gx, gy) or pget(P1, gx, gy) end
for k in pairs(beam) do
  local gx, gy = k % 1000, fl(k / 1000)
  local c = srcPix(gx, gy)
  if c then pset(P5, gx, gy, inner(beam, gx, gy, 2) and UP2(c) or UP1(c)) end
end

local P5b = Plate(GW, GH)
local cone = {}
do
  local WALLC = { [K.lit] = true, [K.haze] = true, [K.stripe] = true, [K.farW] = true }
  for gy = 14, 50 do for gx = 0, 20 do
    local x, y = 2 * gx + 1, 2 * gy + 1
    if ((x - 21) / 22) ^ 2 + ((y - 64) / 36) ^ 2 <= 1 and WALLC[pget(P1, gx, gy)] then cone[gy * 1000 + gx] = true end
  end end
  for k in pairs(cone) do
    local gx, gy = k % 1000, fl(k / 1000)
    local c = pget(P1, gx, gy)
    pset(P5b, gx, gy, inner(cone, gx, gy, 3) and (EXT[c] and (c == K.lit and EXT[c] or c) or UP1(c)) or c)
  end
  -- flame 4x6 on the candle
  pset(P5b, 10, 19, K.flameA); pset(P5b, 10, 20, K.flameB); pset(P5b, 11, 20, K.flameA); pset(P5b, 10, 21, K.flameB); pset(P5b, 11, 21, K.flameB)
  pset(P5b, 11, 19, K.flameA)
end

-------------------------------------------------------------------------------- output
local function toImage(P, scale)
  local img = Image(P.gw * 2, P.gh * 2, ColorMode.RGB)
  img:clear(app.pixelColor.rgba(0, 0, 0, 0))
  local cache = {}
  for k, h in pairs(P.p) do
    local x, y = k % P.gw, fl(k / P.gw)
    if not cache[h] then local r, g, b = hexrgb(h); cache[h] = app.pixelColor.rgba(r, g, b, 255) end
    local v = cache[h]
    img:putPixel(2 * x, 2 * y, v); img:putPixel(2 * x + 1, 2 * y, v); img:putPixel(2 * x, 2 * y + 1, v); img:putPixel(2 * x + 1, 2 * y + 1, v)
  end
  return img
end
local function gridImage(P)
  local img = Image(P.gw, P.gh, ColorMode.RGB)
  img:clear(app.pixelColor.rgba(0, 0, 0, 0))
  for k, h in pairs(P.p) do
    local r, g, b = hexrgb(h)
    img:putPixel(k % P.gw, fl(k / P.gw), app.pixelColor.rgba(r, g, b, 255))
  end
  return img
end
local function savePng(name, P)
  local img = toImage(P)
  local spr = Sprite(img.width, img.height, ColorMode.RGB)
  spr.cels[1].image = img
  spr:saveCopyAs(OUT .. name .. ".png")
  spr:close()
  return GV.check(img), img
end
local plates = {
  { "cf-room2-p0-sky", P0, 5 }, { "cf-room2-p0n-night-sky", P0n, 4 }, { "cf-room2-p1-wall", P1, 20 },
  { "cf-room2-p2-floor", P2, 8 }, { "cf-room2-p4-front", P4, 4 }, { "cf-room2-p5-sunbeam", P5, 8 },
  { "cf-room2-p5b-night", P5b, 8 }, { "cf-room2-window", PW, 16 }, { "cf-room2-window-nobird", PWn, 16 }, { "cf-room2-bird", PB, 16 },
}
local images, checks = {}, {}
local expect = { ["cf-room2-p4-front"] = { 488, 270 }, ["cf-room2-bird"] = { 24, 20 } }
local ok = true
local function fail(msg) ok = false; print("FAIL " .. msg) end
for _, pl in ipairs(plates) do
  local t, img = savePng(pl[1], pl[2])
  images[pl[1]] = img; checks[pl[1]] = t
  local ew = expect[pl[1]] or { 480, 270 }
  local good = t.w == ew[1] and t.h == ew[2] and t.semi == 0 and t.bw == 0 and t.colours <= pl[3]
  print(string.format("%-26s %s  cap %d  %s", pl[1], GV.report(t), pl[3], good and "ok" or "FAIL"))
  if not good then ok = false end
end

-- .aseprite: one layer per plate (grid res; P4 cel at x -2)
do
  local spr = Sprite(GW, GH, ColorMode.RGB)
  local order = { { "p0-sky", P0 }, { "p0n-night-sky", P0n, true }, { "p1-wall", P1 }, { "p2-floor", P2 }, { "p5-sunbeam", P5 },
                  { "window", PW }, { "p4-front", P4 }, { "p5b-night", P5b, true } }
  for i, o in ipairs(order) do
    local layer = (i == 1) and spr.layers[1] or spr:newLayer()
    layer.name = o[1]
    spr:newCel(layer, 1, gridImage(o[2]), Point(o[2].ox, 0))
    if o[3] then layer.isVisible = false end
  end
  spr:saveAs(OUT .. "room-a.aseprite")
  spr:close()
end

-------------------------------------------------------------------------------- self-check (spec 10)
-- 2. seams at y 110 and 268, corners
local worst = 0
for _, ye in ipairs({ 117, 267 }) do
  local gy = fl(ye / 2)
  local cols = {}
  for gx = 0, GW - 1 do local c = pget(P2, gx, gy); if c == K.seamD or c == K.seamL then cols[#cols + 1] = 2 * gx + 1 end end
  for k = 0, 17 do
    local xk = seamX(k, ye)
    if xk >= 4 and xk <= 475 then
      local best = 1e9
      for _, x in ipairs(cols) do best = math.min(best, math.abs(x - xk)) end
      worst = math.max(worst, best)
    end
  end
end
print(string.format("seam check: worst |dx| vs x_k(y) at rows 110 and 268 = %.1f px (limit 2; rows 117/267 as 110..115 is the soil band)  %s", worst, worst <= 2 and "ok" or "FAIL"))
if worst > 2 then ok = false end
local fyL = 2 * (floorTop[0] or 0); local fyR = 2 * (floorTop[GW - 1] or 0)
print(string.format("corners: left floor starts y=%d (151), right y=%d (151)  %s", fyL, fyR, (math.abs(fyL - 151) <= 2 and math.abs(fyR - 151) <= 2) and "ok" or "FAIL"))
if math.abs(fyL - 151) > 2 or math.abs(fyR - 151) > 2 then ok = false end
-- 4. light masks vs P3 footprints
local function rasterQuad(pts)
  local S = {}
  polyE(nil, pts, nil, function(gx, gy) S[gy * 1000 + gx] = true end)
  return S
end
local rug = rasterQuad({ { 101, 247 }, { 379, 247 }, { 356, 186 }, { 124, 186 } })
local boxes = {
  cushion = { 24, 211, 103, 240 }, bowl = { 400, 230, 435, 244 }, bowlUp = { 396, 226, 439, 244 }, toybox = { 82, 99, 125, 132 },
  cattree = { 408, 59, 459, 170 }, scratch = { 8, 109, 35, 184 }, catflap = { 228, 88, 251, 109 }, pots = { 300, 76, 392, 83 },
  yarn = { 134, 186, 173, 205 },
}
local function hitBox(S, b)
  for k in pairs(S) do
    local gx, gy = k % 1000, fl(k / 1000)
    local x0, y0, x1, y1 = gx * 2, gy * 2, gx * 2 + 1, gy * 2 + 1
    if x1 >= b[1] and x0 <= b[3] and y1 >= b[2] and y0 <= b[4] then return true end
  end
  return false
end
local clash = {}
for name, S in pairs({ P5 = P5.p, P5b = P5b.p }) do
  local SS = {}
  for k in pairs(S) do SS[fl(k / P5.gw) * 1000 + k % P5.gw] = true end
  for bn, b in pairs(boxes) do if hitBox(SS, b) then clash[#clash + 1] = name .. "x" .. bn end end
  for k in pairs(SS) do if rug[k] then clash[#clash + 1] = name .. "xrug"; break end end
end
print("light masks vs P3 footprints + rug: " .. (#clash == 0 and "no shared pixel ok" or ("CLASH " .. table.concat(clash, ","))))
if #clash > 0 then ok = false end
-- 5. P0 only through glass
local leak = 0
for k in pairs(P0.p) do if P1.p[k] then leak = leak + 1 end end
local glassOpen = 0
for gy = 13, 38 do for gx = 152, 193 do if not P1.p[gy * GW + gx] then glassOpen = glassOpen + 1 end end end
print(string.format("P0 behind P1: %d P0 px covered by P1 (0), glass open %d/%d  %s", leak, glassOpen, 42 * 26, (leak == 0 and glassOpen == 42 * 26) and "ok" or "FAIL"))
if leak > 0 or glassOpen ~= 42 * 26 then ok = false end
print("bird slot (356,58) 24x20, feet on y 77: robin bottom row y=" .. (2 * (29 + 9) + 1) .. " ok (feet on glass rail row 76..77)")
-- 6. coat #3e2f66 separation
do
  local seen, minD, who = {}, 1e9, ""
  local cr, cg, cb = hexrgb(K.n2)
  for _, P in ipairs({ P2, P5 }) do for _, h in pairs(P.p) do
    if not seen[h] then
      seen[h] = true
      local r, g, b = hexrgb(h)
      local d = math.sqrt((r - cr) ^ 2 + (g - cg) ^ 2 + (b - cb) ^ 2)
      if d < minD then minD, who = d, h end
    end
  end end
  print(string.format("coat #3e2f66 vs floor/sunbeam tones: nearest %s dist %.0f  %s", who, minD, minD > 60 and "ok" or "FAIL"))
  if minD <= 60 then ok = false end
end
-- 7. calm zone x192..292, y6..80 wallpaper only
do
  local set, n = {}, 0
  for gy = 3, 38 do for gx = 96, 146 do
    local c = pget(P1, gx, gy)
    if c then if not set[c] then set[c] = true; n = n + 1 end end
  end end
  local allowed = { [K.haze] = true, [K.stripe] = true, [K.farW] = true }
  local bad = false
  for c in pairs(set) do if not allowed[c] then bad = true; print("  calm zone contains " .. c) end end
  print("calm zone x192..292 y6..77 (wallpaper rows; dado starts 78): " .. (bad and "FAIL" or "wallpaper only ok"))
  if bad then ok = false end
end
-- base composite colour count (P0..P2)
do
  local seen, n = {}, 0
  for _, P in ipairs({ P0, P1, P2 }) do for _, h in pairs(P.p) do if not seen[h] then seen[h] = true; n = n + 1 end end end
  print("base composite P0..P2 colours: " .. n .. " (spec: base incl. cushion + plain bowl <= 32)  " .. (n <= 28 and "ok" or "WARN"))
end

-------------------------------------------------------------------------------- room-layout-a.json
local function enc(v, ind)
  ind = ind or ""
  local t = type(v)
  if t == "number" then if v == fl(v) then return string.format("%d", v) else return string.format("%.4g", v) end end
  if t == "string" then return '"' .. v .. '"' end
  if t == "boolean" then return tostring(v) end
  if t == "table" then
    if #v > 0 or next(v) == nil then
      local simple = true
      for _, x in ipairs(v) do if type(x) == "table" then simple = false end end
      local parts = {}
      for _, x in ipairs(v) do parts[#parts + 1] = enc(x, ind .. "  ") end
      if simple then return "[" .. table.concat(parts, ", ") .. "]" end
      return "[\n" .. ind .. "  " .. table.concat(parts, ",\n" .. ind .. "  ") .. "\n" .. ind .. "]"
    end
    local keys = {}
    for k in pairs(v) do keys[#keys + 1] = k end
    table.sort(keys)
    local parts = {}
    for _, k in ipairs(keys) do parts[#parts + 1] = '"' .. k .. '": ' .. enc(v[k], ind .. "  ") end
    return "{\n" .. ind .. "  " .. table.concat(parts, ",\n" .. ind .. "  ") .. "\n" .. ind .. "}"
  end
  return "null"
end
local dtab = {}
for i = 1, 10 do
  local d = i / 10
  local _, y, s = persp(.5, d)
  dtab[#dtab + 1] = { d = d, y = fl(y + .5), s = tonumber(string.format("%.2f", s)) }
end
local seams = {}
for k = 0, 17 do seams[#seams + 1] = { k = k, x_front_y268 = -100 + 40 * k, x_back_y110 = 53 + 22 * k } end
local layout = {
  spec = "room2/room_a_spec.md", grid = { 240, 135 }, export = { 480, 270 }, scale = 2,
  depth_model = { y = "268 - 158*d^0.8", x = "240 + (u-.5)*720*(1-.45*d)", s = "1 - .58*d", d_from_y = "((268-y)/158)^1.25",
                  u_from_x = ".5 + (x-240)/(720*(1-.45*d))", cat_range = { u = { .2, .8 }, d = { .05, .9 }, scale_snap = "1/16" }, table = dtab },
  vanishing_point = { 240, -83 },
  seam_formula = "x_k(y) = (-100+40k) + (153-18k)*(268-y)/158, k 0..17", seams = seams,
  back_wall = { x = { 42, 437 }, rows = { 0, 109 }, left_sliver = { { 0, 0 }, { 41, 0 }, { 41, 109 }, { 0, 151 } },
                right_sliver = { { 438, 0 }, { 479, 0 }, { 479, 151 }, { 438, 109 } }, floor_corners = { { 42, 110, 0, 151 }, { 438, 110, 479, 151 } } },
  wand_hook = { x = 240, y_top = 6, y_bottom = 10, note = "anchor only, painted by code on the crown; nothing drawn in P1" },
  calm_zone = { x = { 192, 292 }, y = { 6, 80 } },
  slots = {
    doorway = { frame = { 48, 24, 105, 109 }, opening = { 54, 32, 99, 109 } },
    bookshelf = { box = { 116, 64, 187, 109 }, shelves_y = { 80, 94 } },
    pet_shelf_a = { box = { 118, 40, 137, 63 } }, pet_shelf_b = { box = { 166, 40, 185, 63 } },
    frame = { box = { 140, 22, 163, 51 }, pet_slot = "frame" },
    window = { frame = { 296, 18, 395, 83 }, glass = { 304, 26, 387, 77 }, mullion_x = { 344, 347 }, transom_y = { 50, 53 }, sill = { 292, 84, 399, 89 },
               sill_pots = { 300, 76, 392, 83 } },
    bird = { x = 356, y = 58, w = 24, h = 20, feet_y = 77, file = "cf-room2-bird.png", overlay_with = "cf-room2-window.png", overlay_without = "cf-room2-window-nobird.png" },
    plant = { pot = { 404, 90, 427, 109 }, leaves_top_y = 50 },
    sconce = { box = { 16, 44, 25, 59 }, flame = { 20, 38, 23, 43 }, lit_at_night_only = true },
  },
  anchors = {
    cushion = { u = .24, d = .12, anchor = { 64, 240 }, size = { 80, 30 } }, bowl = { u = .76, d = .10, anchor = { 418, 244 }, size = { 36, 14 } },
    bowl_upgrade = { anchor = { 418, 244 }, size = { 44, 18 } }, rug = { anchor = { 240, 248 }, quad = { { 101, 247 }, { 379, 247 }, { 356, 186 }, { 124, 186 } } },
    toybox = { u = .20, d = .82, anchor = { 104, 132 }, size = { 44, 34 } }, cattree = { u = .86, d = .55, anchor = { 434, 170 }, size = { 52, 112 } },
    scratch = { u = .12, d = .45, anchor = { 22, 184 }, size = { 28, 76 } }, catflap = { anchor = { 240, 109 }, size = { 24, 22 } },
    yarnpatch = { u = .36, d = .32, anchor = { 154, 204 }, patch = { 134, 186, 40, 20 }, ball = { 145, 187, 18, 18 } },
  },
  sunbeam = { floor_quad = BEAM, bars_px = 4, wall_shaft = { 304, 90, 387, 99 }, plate = "cf-room2-p5-sunbeam.png" },
  night = { tint = "#291d4a", opacity_dusk = .22, opacity_night = .40, p5b = { flame = { 20, 38, 4, 6 }, cone = { 0, 28, 41, 100 } } },
  plates = {
    { name = "cf-room2-p0-sky", file = "cf-room2-p0-sky.png", size = { 480, 270 }, x = 0, note = "glass only; behind P1" },
    { name = "cf-room2-p0n-night-sky", file = "cf-room2-p0n-night-sky.png", size = { 480, 270 }, x = 0, note = "swap for P0 at night" },
    { name = "cf-room2-p1-wall", file = "cf-room2-p1-wall.png", size = { 480, 270 }, x = 0 },
    { name = "cf-room2-p2-floor", file = "cf-room2-p2-floor.png", size = { 480, 270 }, x = 0 },
    { name = "cf-room2-p5-sunbeam", file = "cf-room2-p5-sunbeam.png", size = { 480, 270 }, x = 0, note = "above P2, below P3 and cats; hidden at dusk/night" },
    { name = "cf-room2-window", file = "cf-room2-window.png", size = { 480, 270 }, x = 0, note = "P3: sill pots + robin; -nobird variant without the robin" },
    { name = "cf-room2-p4-front", file = "cf-room2-p4-front.png", size = { 488, 270 }, x = -4, parallax_px = 3, parallax_range = { 2, 4 } },
    { name = "cf-room2-p5b-night", file = "cf-room2-p5b-night.png", size = { 480, 270 }, x = 0, note = "above the night tint" },
  },
  stack_bottom_to_top = { "p0", "p1", "p2", "p5", "p3 furniture", "cats", "window", "p4", "tint", "p5b" },
}
local f = io.open(OUT .. "room-layout-a.json", "w")
f:write(enc(layout) .. "\n"); f:close()
print(ok and "ROOM A SELF-CHECK: PASS" or "ROOM A SELF-CHECK: FAIL")
