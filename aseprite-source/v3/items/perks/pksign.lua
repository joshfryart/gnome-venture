-- pk-sign (perks popover): a wooden plank sign on a short stake, with a pixel-lit bevel, grain, knots, four iron nails and
-- a dark AO line under the plank. 64x48; the % digits are laid over the plank by the page.
-- quirk: a tiny green sprout pushes up out of the soil at the stake's foot.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local P = dofile(DIR .. "/_pk.lua")
local A, HP, X, K = P.A, P.HP, P.X, P.K
local c = P.new("pk-sign", 64, 48)
c:groundShadow(32, 45, 11, 2)
-- stake
local sm, sn, ST = X.cyl(32, 28, 32, 44, function() return 3.2 end)
local sb = {}
sm:each(function(x, y) if ST[K(x, y)] < 0.12 then sb[K(x, y)] = -2 end end)    -- plank shadow on the stake
local sidx = A.shade(c, sm, sn, P.WD, { amb = 0.08, bias = sb, tok = P.tok.pot })
sm:each(function(x, y) if X.hash(x, y, 5) < 0.12 then c:put(x, y, P.WD[1], P.tok.pot) end end)
-- plank
local pm = c:rrect(2, 3, 61, 29, 2)
local pn = A.slab(pm, 3, { -0.1, -0.2 })
local pidx = A.shade(c, pm, pn, P.WD, { amb = 0.1, wrap = 0.35, tok = P.tok.pot })
-- grain: long dark runs that drift, a lit edge under each
for _, gy in ipairs{ 8, 14, 19, 25 } do
  local y = gy
  for x = 5, 58 do
    if X.hash(x, gy, 3) < 0.05 then y = y + (X.hash(x, gy, 4) < 0.5 and -1 or 1) end
    if pm:has(x, y) and pm:has(x, y + 1) and X.hash(x, y, 9) < 0.78 then
      local i = pidx[K(x, y)] or 3
      c:put(x, y, P.WD[math.max(1, i - 1)], P.tok.pot)
    end
  end
end
-- knots
for _, kn in ipairs{ { 17, 12 }, { 47, 21 } } do
  c:put(kn[1], kn[2], P.WD[1], P.tok.pot) c:put(kn[1] + 1, kn[2], P.WD[2], P.tok.pot) c:put(kn[1], kn[2] + 1, P.WD[2], P.tok.pot) c:put(kn[1] + 1, kn[2] + 1, P.WD[3], P.tok.pot)
  c:put(kn[1] - 1, kn[2], P.WD[4], P.tok.pot)
end
-- bottom AO line and top lit edge
for x = 4, 59 do if pm:has(x, 28) then c:put(x, 28, P.WD[1], P.tok.pot) end if pm:has(x, 4) then c:put(x, 4, P.WD[6], P.tok.pot) end end
-- nails
for _, nl in ipairs{ { 6, 7 }, { 57, 7 }, { 6, 24 }, { 57, 24 } } do
  c:put(nl[1], nl[2], P.ST[3], P.tok.misc) c:put(nl[1] + 1, nl[2], P.ST[2], P.tok.misc) c:put(nl[1], nl[2] + 1, P.ST[2], P.tok.misc) c:put(nl[1] + 1, nl[2] + 1, P.ST[1], P.tok.misc)
  c:put(nl[1], nl[2], P.ST[4], P.tok.misc)
end
-- quirk: a tiny sprout at the foot
c:put(38, 44, P.SM[3], P.tok.stem) c:put(38, 43, P.SM[2], P.tok.stem) c:put(39, 42, P.SM[4], P.tok.stem) c:put(37, 42, P.SM[4], P.tok.stem)
P.finish(c, "pk-sign")
