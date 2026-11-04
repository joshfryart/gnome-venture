-- feast-forest-roast (Opus single pass). A rolled, twine-tied roast lying on a slim oak carving board with a holed handle.
-- Roast: per-pixel ellipsoid light on a 6-tone glazed-brown ramp, pepper crust speckle, wet specular streak, sunken
-- creases under each loop of twisted twine; its cut end shows the pink rolled meat with a green herb-stuffing spiral.
-- A rosemary sprig on top, two porcini on the board (domed caps, pale stems, ambient under the cap).
-- Board: bevelled top with wavy grain and a knot, paler end grain on the front edge, contact shadow under the roast.
-- quirk: a small snail has climbed onto the front porcini cap.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_2.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, sqrt, max, min, abs, sin, cos, pi, atan = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
local c = D.new("feast-forest-roast")
local WOOD = { "#3a2020", "#5e3428", "#864c33", "#b07040", "#cf9258", "#ecbe86" }
local ROAST = { "#3a161c", "#682a22", "#964224", "#c0662c", "#e08e46", "#f8be76" }
local MEAT = { "#8e2e40", "#c45a66", "#e88a8a", "#f8b4a8" }
local STUF = { "#2e5030", "#4f8040", "#7cae58" }
local TWINE = { "#8a6a4a", "#c8a87a", "#f0dcb0" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local wtok, rtok, ttok = D.tok("wood"), D.tok("roast"), D.tok("twine")

c:groundShadow(31, 53, 22, 1)
-- board: top face + handle, then front thickness
local btop = HP.rrect(7, 39, 50, 49, 3):add(HP.rrect(48, 41, 57, 46, 2))
local hole = D.ellipseMask(54.5, 43.5, 1, 0.6)
btop:cut(hole)
local bfront = D.sweep(btop, 3):cut(btop):cut(D.sweep(hole, 0))
-- hole shows the board's inner wall
local fidx = D.toneN(c, bfront, D.vcylN(bfront, 30, 40, 0.9), WOOD, { tok = wtok, cuts = { 0.05, 0.12, 0.3, 0.55, 0.95 } })
-- end grain on the front edge: short vertical ticks, paler
bfront:each(function(x, y) if x % 5 == 1 and bfront:has(x, y - 1) and bfront:has(x, y + 1) then c:put(x, y, WOOD[3], wtok) end
  if not bfront:has(x, y + 1) then c:put(x, y, WOOD[1], wtok) end end)
-- roast footprint for contact shadow
local RCX, RCY, RRX, RRY = 28, 32, 15, 8.5
local roastM, roastN = D.oval(RCX, RCY, RRX, RRY, -0.05, 0.9)
local foot = D.ellipseMask(RCX, RCY + RRY - 1, RRX - 1, 2.5)
local bbias = {}
X.ao(bbias, btop, foot, 2, -1)
foot:each(function(x, y) if btop:has(x, y) then bbias[K(x, y)] = (bbias[K(x, y)] or 0) - 2 end end)
local bn = X.pillow(btop, 1.5)
for k, n in pairs(bn) do local nx, ny, nz = n[1], n[2] - 0.5, n[3] bn[k] = { D.norm(nx, ny, nz) } end
local bidx = D.toneN(c, btop, bn, WOOD, { tok = wtok, bias = bbias, cuts = { 0.2, 0.36, 0.5, 0.64, 0.8 } })
-- wavy grain lines + a knot
btop:shrink(1):each(function(x, y)
  local g = y + floor(1.3 * sin(x / 6.5 + y * 0.7) + 0.5)
  local i = bidx[K(x, y)] or 4
  if g % 3 == 0 and (x + y) % 7 ~= 0 then c:put(x, y, WOOD[max(1, i - 1)], wtok) end
end)
local knot = D.ellipseMask(12, 45, 1.5, 0.7)
knot:each(function(x, y) c:put(x, y, WOOD[2], wtok) end) c:put(12, 45, WOOD[1], wtok) c:put(11, 44, WOOD[5], wtok)
-- handle hole rim
c:put(54, 43, WOOD[1], wtok) c:put(55, 43, WOOD[1], wtok) c:put(54, 44, WOOD[3], wtok) c:put(55, 44, WOOD[3], wtok)
-- bright bevel on the board's back edge
btop:edge():each(function(x, y) if y <= 40 then c:put(x, y, WOOD[6], wtok) end end)

-- rosemary sprig (behind the roast top)
local spr = D.tok("leaf")
local stemPts = {}
for i = 0, 12 do local x = 22 + i local y = floor(24.5 - i * 0.45 + 0.5) stemPts[#stemPts + 1] = { x, y } end
for i, p in ipairs(stemPts) do
  c:put(p[1], p[2], "#6a4a2e", spr)
  if i % 2 == 0 then
    c:put(p[1] - 1, p[2] - 1, LEAF[5], spr) c:put(p[1] - 2, p[2] - 2, LEAF[6], spr)
    c:put(p[1] + 1, p[2] + 1, LEAF[3], spr) c:put(p[1] + 1, p[2] + 2, LEAF[2], spr)
  end
end

-- roast body
local rbias = {}
local loops = { 21, 29, 37 }
roastM:each(function(x, y) for _, lx in ipairs(loops) do
  local d = abs(x - lx)
  if d == 1 then rbias[K(x, y)] = -1 end end end)            -- sunken crease beside each twine loop
local ridx = D.toneN(c, roastM, roastN, ROAST, { tok = rtok, bias = rbias, amb = 0.05, wrap = 0.2, cuts = { 0.18, 0.34, 0.5, 0.64, 0.8 } })
-- pepper crust + crackle
roastM:each(function(x, y) local i = ridx[K(x, y)] or 3
  local h = X.hash(x, y, 13)
  if h > 0.95 and i >= 3 then c:put(x, y, ROAST[max(1, i - 2)], rtok) elseif h > 0.88 and i >= 3 then c:put(x, y, ROAST[min(6, i + 1)], rtok) end end)
-- cool reflected light on the lower-right edge
local rim = X.rim(roastN)
roastM:edge():each(function(x, y) if rim[K(x, y)] > 0.75 and x > RCX then c:put(x, y, "#7a3a52", rtok) end end)
-- wet glaze specular streak
for _, p in ipairs{ { 18, 27 }, { 19, 26 }, { 20, 26 }, { 21, 25 } } do if roastM:has(p[1], p[2]) then c:put(p[1], p[2], ROAST[6], rtok) end end
c:put(19, 27, "#fff1cf", rtok)

-- cut end: pink rolled meat with green stuffing spiral (left end)
local ecx, ecy = 14.5, 32
local endM = D.ellipseMask(ecx, ecy, 3.2, 7.4)
local etok = D.tok("meat")
endM:each(function(x, y)
  local u, v = (x - ecx) / 3.6, (y - ecy) / 7.8
  local r = sqrt(u*u + v*v)
  local a = atan(v, u)
  local sp = (r * 3.2 - a / (2 * pi)) % 1          -- archimedean spiral bands
  local col
  if r > 0.86 then col = ROAST[3]                  -- crust ring
  elseif sp < 0.28 then col = (u < 0) and STUF[2] or STUF[1]
  else col = (u < -0.2 and v < 0.2) and MEAT[3] or MEAT[2] end
  c:put(x, y, col, etok)
end)
c:put(13, 28, MEAT[4], etok) c:put(13, 29, MEAT[4], etok)
-- ambient line where the cut face meets the rolled body
endM:each(function(x, y) if not endM:has(x + 1, y) and roastM:has(x + 1, y) then c:put(x + 1, y, ROAST[1], rtok) end end)

-- twine loops: 1 px twisted cord following the surface, knot on top of the middle loop
for li, lx in ipairs(loops) do
  for y = 0, 63 do
    if roastM:has(lx, y) then
      local i = ridx[K(lx, y)] or 3
      local lit = (y % 2 == 0)
      local col = (i >= 4) and (lit and TWINE[3] or TWINE[2]) or (lit and TWINE[2] or TWINE[1])
      c:put(lx, y, col, ttok)
    end
  end
end
local kx, ky = 29, 23
for y = 0, 63 do if roastM:has(kx, y) then ky = y break end end
c:put(kx - 1, ky, TWINE[3], ttok) c:put(kx + 1, ky, TWINE[2], ttok) c:put(kx, ky - 1, TWINE[2], ttok)
c:put(kx + 2, ky - 1, TWINE[1], ttok) c:put(kx + 3, ky - 2, TWINE[2], ttok)    -- loose tail

-- porcini on the board (back one, then front one)
local mtok = D.tok("shroom")
local CAP = { "#3a1c1a", "#5e2e22", "#864a2c", "#a8683a", "#c88a52", "#e8b47a" }
local STEM = { "#8a7a6a", "#c8b898", "#efe2c2" }
local function porcini(sx, sy, w, hgt)
  local stem = HP.rrect(sx - w, sy - hgt, sx + w, sy, 1)
  local sn = D.vcylN(stem, sx, w)
  D.toneN(c, stem, sn, { STEM[1], STEM[1], STEM[2], STEM[2], STEM[3], STEM[3] }, { tok = mtok })
  for x = sx - w, sx + w do c:put(x, sy - hgt, STEM[1], mtok) end              -- ambient under the cap
  local cm, cn = D.oval(sx + 0.3, sy - hgt - 1.6, w + 2.4, 2.4, 0, 0.8)
  local cbm = HP.mask() cm:each(function(x, y) if y <= sy - hgt then cbm:set(x, y) end end)
  local idx = D.toneN(c, cbm, cn, CAP, { tok = mtok })
  for x = sx - w - 2, sx + w + 2 do if cbm:has(x, sy - hgt) then c:put(x, sy - hgt, CAP[2], mtok) end end
  return cbm
end
porcini(50, 39, 1, 4)
local front = porcini(43, 47, 2, 5)
c:put(41, 39, "#fff1cf", mtok)
-- quirk: a snail on the front cap
local sc = { K = "#2b1c26", s = "#f5809f", S = "#c94f84", d = "#7d2c5e", b = "#c8b8a0", B = "#9a8a7a", e = "#2b1c26" }
local snail = {
  "e.e...",
  "b.bsS.",
  "bbsdSS",
  ".BBBBB",
}
local nx, ny = 43, 34
for yy, row in ipairs(snail) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if sc[ch] then c:put(nx + xx - 1, ny + yy - 1, sc[ch], D.tok("snail")) end end end
D.save(c, "ph", "feast-forest-roast")
