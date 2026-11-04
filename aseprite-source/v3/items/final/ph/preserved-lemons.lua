-- preserved-lemons (D10 final, Sonnet high). A tall, slim clamp-top glass jar (neck, shoulder, thick base) brimming with
-- straw-coloured brine and four lemon halves packed cut-face out: wrinkled soft golden rind, pale pith ring, seven pulp
-- segments with pith spokes. Salt sediment and suspended crystals, a waterline with a bright meniscus, glass walls with a
-- bright left rim, specular streak and cool reflected right edge. Orange rubber gasket, glass lid dome, steel wire bail and a
-- little clamp lever, a thin ground shadow.
-- quirk: a kraft tag on twine hangs off the neck, with a hand-drawn lemon doodle.
local NAME = "preserved-lemons"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_2.lua")
local HP, X, K, G = A.HP, A.X, A.K, A.G
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local GLASS = { "#2f6f86", "#58a0b0", "#8ccbd0", "#bfe6e2", "#e0f6f0", "#f6fffb" }
local BR = { "#a89a48", "#c8b858", "#e0d472", "#f0e690", "#f8f0b0", "#fffbd0" }
local RIND = { "#7a4a14", "#a8661c", "#d08a24", "#ecaa30", "#fbc94a", "#ffe27a" }
local PITH = { "#b89a48", "#d4b860", "#ecd682", "#fff0b0" }
local PULP = { "#c9962c", "#e8b53a", "#f6cf4e", "#fde06e", "#fff09a", "#fffac4" }
local STONE = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local TW = { "#6b4a2a", "#9a7040", "#c89a5a", "#e6c488" }
local KRAFT = { "#6b4a2a", "#9a6a3c", "#c89a5a", "#e0b878", "#f0d498", "#fff0c0" }
local CUT6 = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function cl(i, a, b) return max(a or 1, min(b or 6, i)) end

-- ground shadow
c:groundShadow(31, 57, 14, 1.5)

-- glass body: shoulders + neck, thick-glass tone
local body = HP.rrect(17, 25, 46, 56, 5)
body:add(HP.rrect(21, 20, 42, 27, 1))
local bn = X.pillow(body, 3)
local gtok = { r = { name = "glass" } }
G.toneN(c, body, bn, GLASS, { tok = gtok, cuts = { 0.2, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })

-- brine
local inner = body:copy():shrink(2)
local brine = HP.mask()
inner:each(function(x, y) if y >= 30 then brine:set(x, y) end end)
local brn = X.pillow(brine, 4)
local btok = { r = { name = "brine" } }
G.toneN(c, brine, brn, BR, { tok = btok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.3 })
brine:each(function(x, y) if y == 30 then c:put(x, y, BR[6], btok) elseif y == 31 then c:put(x, y, BR[5], btok) end end)

-- lemons
local function lemon(cx, cy, rx, ry, ang, id)
  local m, n = G.oval(cx, cy, rx, ry, ang, 0.6)
  m:clip(brine)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  local ca, sa = cos(ang), sin(ang)
  local tok = { r = { name = "lemon" .. id } }
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - cx, y - cy
    local u, w = (dx * ca + dy * sa) / (rx + .45), (-dx * sa + dy * ca) / (ry + .45)
    local r2 = u * u + w * w
    local L = v[k] or 0.5
    local hex
    if r2 > 0.74 then
      local i = floor(L * 6) + 1
      if X.hash(x, y, 9 + id) < 0.2 then i = i - 2 end
      hex = RIND[cl(i)]
    elseif r2 > 0.55 then
      hex = PITH[cl(floor(L * 4) + 1, 1, 4)]
    else
      local a = atan(w, u)
      local sp = (a + pi) / (2 * pi / 7)
      local sec, fr = floor(sp), sp - floor(sp)
      local rr = sqrt(r2)
      if rr < 0.16 then hex = PITH[3]
      elseif fr < 0.17 then hex = PITH[4]
      else
        local i = floor(L * 6) + (sec % 2)
        if rr > 0.42 then i = i - 1 end
        hex = PULP[cl(i)]
      end
    end
    c:put(x, y, hex, tok)
  end)
  return m
end
local L1 = lemon(26, 37, 5.9, 4.8, -0.25, 1)
local L2 = lemon(38, 36, 5.9, 4.8, 0.35, 2)
local L3 = lemon(26, 47, 5.9, 4.8, 0.18, 3)
local L4 = lemon(38, 47, 5.9, 4.8, -0.3, 4)
-- cast: contact shadow of each lemon in the brine below-right
for _, m in ipairs({ L1, L2, L3, L4 }) do
  m:shift(1, 1):each(function(x, y) if brine:has(x, y) and not m:has(x, y) and not L1:has(x, y) and not L2:has(x, y) and not L3:has(x, y) and not L4:has(x, y) then
    local cur = c:get(x, y) for i = 2, 6 do if BR[i] == cur then c:put(x, y, BR[i - 1], btok) break end end end end)
end
-- one lemon pip in L2
c:put(39, 35, "#fff4d6", { r = { name = "lemon2" } }) c:put(40, 35, PITH[3], { r = { name = "lemon2" } })

-- salt: sediment on the base + suspended crystals
brine:each(function(x, y)
  if y >= 51 and X.hash(x, y, 21) < (y == 53 and 0.8 or y == 52 and 0.5 or 0.28) and not L3:has(x, y) and not L4:has(x, y) then
    c:put(x, y, (x + y) % 2 == 0 and "#fff4d6" or "#e8dfc0", btok)
  end
end)
for _, p in ipairs({ { 32, 36 }, { 32, 44 }, { 31, 50 }, { 44, 41 }, { 21, 41 } }) do
  if brine:has(p[1], p[2]) and not (L1:has(p[1], p[2]) or L2:has(p[1], p[2]) or L3:has(p[1], p[2]) or L4:has(p[1], p[2])) then c:put(p[1], p[2], "#fff4d6", btok) end
end

-- glass overlays: bright left wall, shaded right wall, thick base, specular streak, cool reflected edge
body:each(function(x, y)
  if y >= 31 and y <= 52 then
    if x == 18 then c:put(x, y, (y % 9 == 0) and GLASS[4] or GLASS[6], gtok)
    elseif x == 19 and y % 7 ~= 0 then c:put(x, y, GLASS[4], gtok)
    elseif x == 45 then c:put(x, y, GLASS[2], gtok)
    elseif x == 44 and y % 5 ~= 0 then c:put(x, y, GLASS[3], gtok) end
  end
end)
for x = 20, 43 do if body:has(x, 55) then c:put(x, 55, GLASS[2], gtok) c:put(x, 54, (x % 4 == 0) and GLASS[3] or GLASS[4], gtok) end end
for y = 34, 44 do c:put(21, y, "#f6fffb", gtok) end
for y = 47, 49 do c:put(21, y, "#f6fffb", gtok) end
c:put(22, 33, "#f6fffb", gtok) c:put(22, 45, GLASS[5], gtok)
for y = 37, 51 do if y % 4 ~= 0 then c:put(43, y, "#7fd0d8", gtok) end end
-- neck glass
for y = 21, 27 do c:put(22, y, GLASS[5], gtok) c:put(41, y, GLASS[2], gtok) end

-- gasket + lid dome
local gask = HP.rrect(19, 18, 44, 20, 1)
G.toneN(c, gask, X.pillow(gask, 1.5), { "#5a1c30", "#8e2a3a", "#c4402f", "#e8602e", "#ff8a40", "#ffc07a" }, { tok = { r = { name = "gasket" } }, cuts = CUT6, amb = 0.1, wrap = 0.3 })
local lid = HP.rrect(20, 11, 43, 17, 3)
local ln = X.pillow(lid, 3)
G.toneN(c, lid, ln, GLASS, { tok = { r = { name = "lid" } }, cuts = { 0.2, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })
c:put(23, 13, "#f6fffb", { r = { name = "lid" } }) c:put(24, 13, "#f6fffb", { r = { name = "lid" } }) c:put(22, 14, GLASS[5], { r = { name = "lid" } })

-- steel wire bail over the lid
local wtok = { r = { name = "wire" } }
local wm, wn = G.tube({ { 17, 27 }, { 15, 7 }, { 48, 7 }, { 46, 27 } }, function(t) return 0.85 end)
X.tone(c, wm, X.light(wn, { amb = 0.2, wrap = 0.3 }), STONE, { cuts = { 0.3, 0.55, 0.8 }, tok = wtok })
-- hinge pin + clamp lever
for _, p in ipairs({ { 16, 26 }, { 17, 26 }, { 16, 27 }, { 17, 27 } }) do c:put(p[1], p[2], STONE[3], wtok) end
c:put(16, 26, STONE[4], wtok) c:put(17, 27, STONE[1], wtok)
for y = 22, 30 do c:put(46, y, y == 22 and STONE[4] or STONE[3], wtok) c:put(47, y, STONE[2], wtok) end
c:put(46, 31, STONE[1], wtok) c:put(47, 31, STONE[1], wtok) c:put(46, 25, STONE[4], wtok) c:put(47, 25, STONE[1], wtok)

-- twine around the neck + knot
local ttok = { r = { name = "twine" } }
for x = 21, 42 do c:put(x, 23, ((x % 3 == 0) and TW[4] or TW[3]), ttok) c:put(x, 24, TW[2], ttok) end
for _, p in ipairs({ { 20, 22 }, { 21, 22 }, { 20, 23 }, { 19, 24 }, { 20, 24 } }) do c:put(p[1], p[2], TW[4], ttok) end
c:put(21, 22, TW[3], ttok) c:put(19, 24, TW[2], ttok)

-- quirk: kraft tag hanging off the knot
local tcx, tcy, ang = 11, 36, -0.22
local function rc(dx, dy) return tcx + dx * cos(ang) - dy * sin(ang), tcy + dx * sin(ang) + dy * cos(ang) end
local pts = {}
for _, d in ipairs({ { -3.6, -4.2 }, { 3.6, -4.2 }, { 4.2, 4.6 }, { -4.2, 4.6 } }) do local x, y = rc(d[1], d[2]) pts[#pts + 1] = { x, y } end
local tag = HP.poly(pts)
-- clip the top corners
local topl, topr = HP.mask(), HP.mask()
local ax, ay = rc(-3.6, -4.2) local bx, by = rc(3.6, -4.2)
tag:cut(HP.rect(floor(ax + .5) - 1, floor(ay + .5) - 1, floor(ax + .5), floor(ay + .5)))
tag:cut(HP.rect(floor(bx + .5), floor(by + .5) - 1, floor(bx + .5) + 1, floor(by + .5)))
local kt = { r = { name = "tag" } }
G.toneN(c, tag, X.pillow(tag, 1.6), KRAFT, { tok = kt, cuts = CUT6, amb = 0.12, wrap = 0.3 })
tag:edge():each(function(x, y) c:put(x, y, KRAFT[2], kt) end)
local hx, hy = rc(0, -2.8)
c:put(floor(hx + .5), floor(hy + .5), "#2b1c26", kt)
-- string from knot to the hole
do
  local x0, y0, x1, y1 = 20, 25, floor(hx + .5), floor(hy + .5)
  local nn = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, nn - 1 do c:put(floor(x0 + (x1 - x0) * i / nn + .5), floor(y0 + (y1 - y0) * i / nn + .5), TW[3], ttok) end
end
-- doodle: a tiny lemon with a leaf
local dx0, dy0 = rc(-1, 1.2)
local qx, qy = floor(dx0 + .5), floor(dy0 + .5)
for _, p in ipairs({ { 0, 0 }, { 1, 0 }, { 2, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { 3, 1 }, { 0, 2 }, { 1, 2 }, { 2, 2 } }) do c:put(qx + p[1], qy + p[2], (p[2] == 2) and RIND[3] or RIND[5], kt) end
c:put(qx + 1, qy + 1, "#fff09a", kt) c:put(qx + 3, qy - 1, "#43995a", kt) c:put(qx + 2, qy - 1, "#64b566", kt)
A.save(c, NAME)
