-- birch-log (final pass, Opus). A slim birch log lying on its side, seen 3/4 from the right: chalk-white papery
-- bark lit as a cylinder (6 cool-white tones), rows of dark horizontal lenticels, one dark chevron branch scar, a
-- pale end-grain cap with growth rings, pith, a radial check crack, a thin bark rim and a cambium line; contact
-- shadow on the ground. quirk: a strip of bark has peeled back and curled up into a little paper scroll, showing
-- the orange inner bark underneath.
local NAME = "birch-log"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.atan
local c = A.new(NAME)
local BARK = { "#4a4562", "#7a7692", "#a8a4ba", "#cfcbd8", "#ebe6e4", "#fbf6ec" }
local CAP = { "#7a4a30", "#a46c40", "#c48e56", "#dcad72", "#ecc994", "#f7e0b4" }
local LENT_L, LENT_S = "#3d2f3c", "#2f2534"
local CY, R, X0, X1 = 33, 8, 11, 47

c:groundShadow(30, 42, 21, 2)

-- bark body: cylinder along x, far end rounded
local body = c:rect(X0, CY - R, X1, CY + R):add(c:ellipse(X0, CY, 3, R))
local cap = c:ellipse(X1, CY, 4, R)
local bn = {}
body:each(function(x, y)
  local sn = max(-0.97, min(0.97, (y - CY) / (R + 0.5)))
  local nx = min(0, x - X0) / 4.2
  bn[K(x, y)] = { A.norm(nx * 0.8, sn, sqrt(max(0.05, 1 - sn*sn))) }
end)
local btok = { r = { name = "bark" } }
local bidx = A.shade(c, body, bn, BARK, { tok = btok, amb = 0.12, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })

-- lenticels: short dark horizontal dashes in staggered rows (shorter on the shade side)
for row = 0, 5 do
  local y = CY - R + 2 + row * 3 - (row > 2 and 1 or 0)
  local x = X0 - 1 + floor(X.hash(row, 1, 7) * 6)
  while x < X1 - 3 do
    local L = 2 + floor(X.hash(x, y, 3) * 4)
    if y > CY + 3 then L = max(2, L - 1) end
    for i = 0, L - 1 do
      local px = x + i
      if body:has(px, y) and not cap:has(px, y) and not cap:has(px + 1, y) and body:has(px - 1, y) and body:has(px, y - 1) and body:has(px, y + 1) then
        c:put(px, y, (bidx[K(px, y)] or 3) >= 4 and LENT_L or LENT_S, btok)
        -- a paler lip under each lenticel (papery ridge)
        if i == 1 and (bidx[K(px, y + 1)] or 0) >= 3 and body:has(px, y + 2) then c:put(px, y + 1, BARK[6], btok) end
      end
    end
    x = x + L + 3 + floor(X.hash(x, y, 9) * 6)
  end
end
-- chevron branch scar ("birch eye")
c:paint({
  "d.....d",
  ".dd.dd.",
  "...D...",
}, 17, 35, { d = LENT_L, D = BARK[2] })

-- end-grain cap
local ctok = { r = { name = "cap" } }
cap:each(function(x, y)
  local u, v = (x - X1) / 4.45, (y - CY) / (R + 0.45)
  local r = sqrt(u*u + v*v)
  local col
  if r > 0.84 then
    col = (v < 0.2 and u < 0.4) and BARK[5] or BARK[3]
    if v > 0.55 then col = BARK[2] end
  elseif r > 0.72 then
    col = CAP[2]
  else
    local i = 5
    if abs(r - 0.24) < 0.08 or abs(r - 0.5) < 0.07 then i = 4 end
    if r < 0.1 then i = 2 end
    if v > 0.3 and u > -0.2 then i = i - 1 end
    if u < -0.3 and v < -0.2 and i == 5 then i = 6 end
    col = CAP[i]
  end
  c:put(x, y, col, ctok)
end)
-- radial check crack toward the upper right
for i = 2, 6 do local x, y = X1 + floor(i * 0.45 + 0.5), CY - i
  if cap:has(x, y) then c:put(x, y, CAP[1], ctok) end end
-- ambient line where the cap rim meets the bark top/bottom
c:put(X1 - 2, CY - R, BARK[4], btok) c:put(X1 - 2, CY + R, BARK[1], btok)

-- quirk: bark strip peeled up into a scroll; orange inner bark showing beneath
c:paint({
  "....wW.",
  "...waTw",
  "...wTp.",
  "..wT...",
  "OOOOo..",
  "oOOoo..",
  ".ooo...",
}, 27, 21, { w = BARK[6], W = BARK[5], p = BARK[3], a = "#e9a77a", T = "#c7744e", O = "#eaa478", o = "#c27050" })
-- tiny contact shadow under the curl's free edge
c:put(33, 25, BARK[3], btok) c:put(32, 26, BARK[4], btok)

A.save(c, NAME)
