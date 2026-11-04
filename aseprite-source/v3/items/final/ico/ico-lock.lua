-- ico-lock (final, Opus). A closed padlock: a tall polished-steel U shackle (round tube, 5 px) dropping into a
-- squared brass body with soft bevelled corners.
-- Material: per-pixel lit 6-tone steel tube with a specular streak on the upper-left of the arc, dark sockets where
-- the legs enter the body (AO); brass body pillow-lit with a raised face plate (groove + lit lip), four domed rivets,
-- a deep keyhole with a lit lower lip, a bright corner glint and a cool reflected light on the lower-right edge.
-- quirk: someone tied a little red ribbon bow round the shackle.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min, pi, cos, sin = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi, math.cos, math.sin
local c = A.new("ico-lock")
local ST = { "#2b2a46", "#47496d", "#6c7193", "#98a0bc", "#c6cde0", "#eef1f8" }
local BR = { "#5e2a1e", "#8f4a1f", "#c5772a", "#e8a536", "#f9cd5a", "#ffeaa0" }
local SPEC, BOUNCE = "#fff8e2", "#9a6a8a"
local stok, btok = { r = { name = "steel" } }, { r = { name = "brass" } }

-- shackle: legs at x 21.5 / 42.5, arc centre (32, 20), tube half width 2.6
local pts = {}
local LX, RX, CY, R = 21.5, 42.5, 20.5, 10.5
for y = 36, CY, -0.5 do pts[#pts + 1] = { LX, y } end
for i = 0, 60 do local a = pi + pi * i / 60 pts[#pts + 1] = { 32 + R * cos(a), CY + R * sin(a) } end
for y = CY, 36, 0.5 do pts[#pts + 1] = { RX, y } end
local sm, sn = A.ptube(pts, 2.6)
local sidx = A.shade(c, sm, sn, ST, { amb = 0.04, wrap = 0.12, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, tok = stok })
-- specular streak along the lit crown of the arc
for i = 0, 6 do local a = pi + 0.55 + i * 0.11
  local x, y = floor(32 + (R - 1.2) * cos(a) + .5), floor(CY + (R - 1.2) * sin(a) + .5)
  if sm:has(x, y) then c:put(x, y, ST[6], stok) end end
c:put(floor(32 + (R - 1.2) * cos(pi + 0.85) + .5), floor(CY + (R - 1.2) * sin(pi + 0.85) + .5), SPEC, stok)
-- lit line down the left leg
for y = 22, 29 do c:put(20, y, ST[5], stok) end

-- body
local bm = HP.rrect(13, 29, 50, 55, 5)
local bn = X.pillow(bm, 4.5)
local bias = {}
-- raised face plate: groove 3 px in from the edge, plate a touch lighter
local plate = HP.rrect(17, 33, 46, 51, 3)
local pe = plate:edge()
local bidx = A.shade(c, bm, bn, BR, { amb = 0.12, wrap = 0.3, tok = btok })
pe:each(function(x, y)
  local lower = (x >= 45 or y >= 50)
  A.step(c, bidx, BR, x, y, lower and 1 or -2, btok) end)
-- groove shadow just inside the lit top/left of the plate
plate:shrink(1):edge():each(function(x, y) if (y == 34 or x == 18) then A.step(c, bidx, BR, x, y, 1, btok) end end)
-- sockets where the shackle enters (AO)
for _, sx in ipairs{ LX, RX } do
  for dx = -3, 2 do local x = floor(sx) + dx
    c:put(x, 29, BR[1], btok) c:put(x, 30, BR[2], btok) end
  c:put(floor(sx) - 3, 30, BR[2], btok) c:put(floor(sx) + 2, 30, BR[2], btok)
end
for _, sx in ipairs{ LX, RX } do for dx = -2, 1 do c:put(floor(sx) + dx, 29, ST[1], stok) end end
-- rivets (domed): lit upper-left, dark lower-right
local function rivet(x, y)
  A.map(c, { ".lb.", "lhbs", "bbsd", ".sd." }, x, y, { l = BR[5], h = BR[6], b = BR[4], s = BR[2], d = BR[1] }, btok)
end
rivet(13, 30) rivet(47, 30) rivet(13, 51) rivet(47, 51)
-- keyhole: round head + flared slot, deep, with lit lower lip
local kh = A.ell(31.5, 39.5, 2.6, 2.6):add(HP.poly{ { 30, 41 }, { 33, 41 }, { 34, 47 }, { 29, 47 } })
kh:each(function(x, y) c:put(x, y, "#2b1c26", btok) end)
kh:each(function(x, y) if (x == 30 or x == 31) and y >= 38 and y <= 39 then c:put(x, y, "#4a2a26", btok) end end)
kh:grow(1):cut(kh):each(function(x, y)
  if kh:has(x - 1, y - 1) or kh:has(x, y - 1) and y > 40 then c:put(x, y, BR[6], btok)
  elseif kh:has(x + 1, y + 1) or kh:has(x + 1, y) then c:put(x, y, BR[2], btok) end end)
-- bright corner glint + streak on the upper-left bevel
for x = 19, 25 do c:put(x, 30, BR[6], btok) end
c:put(14, 34, BR[6], btok) c:put(14, 35, BR[6], btok)
c:put(17, 30, SPEC, btok) c:put(18, 30, SPEC, btok)
-- cool reflected light on the lower-right edge
for y = 40, 51 do c:put(50, y, BOUNCE, btok) end
for x = 26, 46 do c:put(x, 55, BOUNCE, btok) end
-- tiny scratches in the brass
c:put(38, 45, BR[3], btok) c:put(39, 46, BR[3], btok) c:put(24, 48, BR[3], btok)

-- quirk: red ribbon bow round the upper-left of the shackle
local map = {
  ".rr....rr.",
  "rhRr..rRRr",
  "rRRRkkRRRr",
  "rRRkhRkRRr",
  ".rrkkRkrr.",
  "...rd.rd..",
  "..rd...rd.",
  "..d.....d.",
}
local pal = { r = "#b52e3f", R = "#e8493b", h = "#ff8a5c", k = "#7d2038", d = "#6e2038" }
A.map(c, map, 13, 18, pal)
A.save(c, "ico-lock")
