-- box-hedge-end (final pass, Opus aB10_1). A short clipped boxwood run that stops in a rounded end, crowned by a
-- topiary ball on a slim clipped neck: block in 3/4 view (lit top, shaded front, rounded clipped edges), ball with
-- per-pixel sphere light broken into leaf clusters, deep AO where the neck meets the block and under the ball,
-- waxy glints, woody stems at the base, ground shadow.
-- quirk: a small yellow butterfly rests on the topiary ball.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_1.lua")
local HP, X, K = A.HP, A.X, A.K
local NAME = "box-hedge-end"
local c = A.new(NAME)
local F, H, OY = 0.55, 13, 46
local function S(x, z)
  if z < 0 or z > 12 then return false end
  if x >= 10 and x <= 40 then
    if x < 12 then return (x - 12)^2 + (math.max(0, math.min(z, 10) - 10))^2 + (math.min(0, z - 2))^2 <= 4.2 or (z >= 2 and z <= 10) end
    return true
  end
  return (x - 40)^2 + ((z - 6) * 1.0)^2 <= 36
end
c:groundShadow(28, OY + 12 * F + 1, 20, 1)
local m, face, Z = A.prism(S, 8, 48, 0, 12, H, F, OY)
A.roundCorners(m, 2)
A.ragged(m, face, Z, 5, 0.3)
-- neck (short clipped cylinder) and ball, centred over the round end
local BX, BY, BR = 39.5, OY + 6 * F - H - 13, 7.2
local neck = HP.rect(38, math.floor(BY + 6), 41, math.floor(OY + 6 * F - H) + 1)
local ball = HP.ellipse(BX, BY, BR, BR - 0.3)
-- block first
local bias = {}
neck:each(function(x, y) local k = K(x, y) end)
local idx, tok = A.foliage(c, m, face, { seed = 5, Z = Z, ground = true, glints = 4 })
A.twigs(c, m, idx, 5, tok)
-- contact shadow the neck/ball cast onto the block top (to the lower right)
local cast = HP.ellipse(42, OY + 6 * F - H + 1, 4, 1.4)
cast:each(function(x, y) if m:has(x, y) then local k = K(x, y) local i = idx[k] if i then c:put(x, y, A.BOX[math.max(1, i - 2)], tok) end end end)
-- neck
local nbase, nface = {}, {}
neck:each(function(x, y) local s = (x - 39.5) / 2.5 nbase[K(x, y)] = { A.norm(s, 0, 1) } nface[K(x, y)] = "front" end)
local nb = {}
neck:each(function(x, y) local k = K(x, y) if y >= math.floor(OY + 6 * F - H) then nb[k] = -1 end if y <= BY + BR then nb[k] = (nb[k] or 0) - 1 end end)
local ntok = { r = { name = "neck" } }
A.foliage(c, neck, nface, { seed = 9, base = nbase, bias = nb, tok = ntok, glints = 0, sp = 2.2 })
-- ball
local bn = X.sphere(BX, BY, BR, ball)
local bface = {}
ball:each(function(x, y) bface[K(x, y)] = "ball" end)
local bb = {}
ball:each(function(x, y) local k = K(x, y) local d = (x - BX)^2 + (y - BY)^2 if y > BY + BR - 2 and d > (BR - 1.5)^2 then bb[k] = -1 end end)
local btok = { r = { name = "ball" } }
local bidx = A.foliage(c, ball, bface, { seed = 13, base = bn, bias = bb, tok = btok, glints = 3, leaf = 0.26 })
-- cool reflected light on the ball's lower-right rim
local rim = X.rim(bn)
ball:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.75 and bidx[k] and bidx[k] <= 3 and y < BY + BR - 1 then c:put(x, y, "#2f6e66", btok) end end)
-- quirk: butterfly on the upper-left of the ball
A.map(c, {
  "Yy.Yy",
  "YyKYy",
  ".oKo.",
  "..K..",
}, math.floor(BX) - 6, math.floor(BY) - 8, { Y = "#ffe38a", y = "#f5b82e", o = "#d98322", K = A.INK })
A.save(c, NAME)
