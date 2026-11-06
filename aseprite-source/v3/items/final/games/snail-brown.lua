-- snail-brown (final, Opus single pass). A garden snail gliding right: a round, flat-coiled (planispiral) shell
-- riding on a long slim foot that tapers to a point behind; the head lifts gently with two eye stalks and two
-- short feelers.
-- Material: shell = per-pixel sphere light plus a bulge per whorl (6-tone brown), a darker spiral colour band,
-- deep suture groove with a lit lip, fine radial growth lines, one glossy specular + glint; body = 6-tone soft
-- skin, tubercle grooves, a wet sheen streak along the foot, cool reflected light under the belly, AO where the
-- shell sits on the body; a thin glossy slime trail behind.
-- quirk: a tiny red toadstool has sprouted on top of the shell.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, pi, max, min, sqrt, abs, atan, log, exp = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.abs, math.atan, math.log, math.exp
local c = A.new("snail-brown")
local SHL  = { "#3e2228", "#62362c", "#8a5434", "#b07a46", "#d4a464", "#f2cf8e" }
local BAND = { "#331c24", "#4e2a28", "#6c3c2c", "#8c5636", "#ae7848", "#cc9a62" }
local SKN  = { "#4a3442", "#785a62", "#a2807a", "#c4a08a", "#ddbe9e", "#f2dab6" }
local SLM  = { "#8bc4ea", "#b9e2f5", "#e4f6ff" }
local tokS, tokB, tokE = { r = { name = "shell" } }, { r = { name = "body" } }, { r = { name = "stalk" } }

-- slime trail (behind the foot)
for x = 6, 16 do c:put(x, 51, (x % 4 == 0) and SLM[3] or SLM[1]) end
for x = 8, 13 do if x % 3 ~= 0 then c:put(x, 50, SLM[2]) end end

-- far eye stalk (behind the head), then the body
local function stalk(pts, w, tipx, tipy)
  local m, n, T, S, idx = A.stem(c, pts, function(t) return w - 0.4 * t end, SKN, { tok = tokE, amb = 0.12, wrap = 0.3 })
  return m
end
stalk({ {48, 37}, {50, 32}, {52, 27}, {54, 23} }, 1.25)
-- foot + neck + head as one tube (tail point at left, head at right)
local P = { {11, 50}, {28, 50}, {41, 50}, {48, 38} }
local function hw(t)
  if t < 0.5 then return 0.5 + 2.9 * (t / 0.5) ^ 0.7 end
  if t < 0.86 then return 3.4 + (t - 0.5) * 0.8 end
  return 3.7 + sin((t - 0.86) / 0.14 * pi * 0.5) * 0.6
end
local bm, bn, BT, BS, samp = A.tube(P, hw)
bm:add(c:ellipse(48, 38.5, 4, 3.6))      -- rounded head
-- flatten the sole: cut everything below y=51
bm:each(function(x, y) if y > 51 then bm.s[K(x, y)] = nil end end)
local nb = X.pillow(bm, 3.2)
local bias = {}
-- AO under the shell (shell rests on x 14..38)
bm:each(function(x, y) local k = K(x, y) if x > 12 and x < 38 and y <= 47 then bias[k] = -2 elseif x > 12 and x < 38 and y == 48 then bias[k] = -1 end end)
local bidx = A.shade(c, bm, nb, SKN, { amb = 0.1, wrap = 0.3, bias = bias, tok = tokB })
-- sole edge: darker skirt row with tiny frill
bm:each(function(x, y) if y == 51 or (y == 50 and not bm:has(x, y + 1)) then c:put(x, y, (x % 3 == 0) and SKN[1] or SKN[2], tokB) end end)
-- tubercle grooves: short slanted dashes over the skin
bm:each(function(x, y) local k = K(x, y)
  if (x * 2 + y * 3) % 7 == 0 and A.hash(x, y, 5) < 0.55 and bm:has(x + 1, y) and bm:has(x, y + 1) and y < 50 then
    c:put(x, y, SKN[max(1, (bidx[k] or 3) - 1)], tokB) end end)
-- wet sheen streak along the foot's upper flank
for x = 38, 44 do local y = (x < 41) and 47 or 47 - (x - 41) if bm:has(x, y) then c:put(x, y, SKN[6], tokB) end end
c:put(39, 47, SLM[3], tokB)
-- near eye stalk (in front of the head)
stalk({ {45, 36}, {45, 31}, {45, 26}, {46, 22} }, 1.35)
-- feelers (short lower tentacles)
A.ln(c, 51, 40, 54, 41, SKN[3], nil, tokE) c:put(54, 41, SKN[2], tokE) c:put(51, 39, SKN[5], tokE)
-- eyes: ink knob with cream glint at each stalk tip
local function eye(x, y)
  A.map(c, { ".kk.", "kgkk", "kkkk", ".kk." }, x - 1, y - 1, { k = A.INK, g = A.CREAM }, tokE)
end
eye(46, 20) eye(54, 21)
-- face: smile + cheek
c:put(49, 40, SKN[1], tokB) c:put(50, 41, SKN[1], tokB) c:put(51, 41, SKN[1], tokB)
c:put(47, 39, "#f5809f", tokB) c:put(48, 39, "#f5809f", tokB)

-- shell: planispiral disc
local CX, CY, R = 25, 33, 12.9
local sm = c:ellipse(CX, CY, 12.5, 12.5)
sm:each(function(x, y) if y > 46 then sm.s[K(x, y)] = nil end end)
local GR = 2.3        -- growth per turn
local LG = log(GR)
-- whorl coordinate: w = turns from the outer suture (0 at rim, increasing inward), u = position across the whorl
local function whorl(x, y)
  local dx, dy = x - CX + 0.5, y - CY + 0.5
  local r = max(0.4, sqrt(dx*dx + dy*dy))
  local th = atan(dy, dx) / (2 * pi)                -- -0.5..0.5 turns
  local q = log(R / r) / LG + th                    -- continuous
  return q, r, dx / r, dy / r
end
local sn = X.sphere(CX - 1, CY - 1, 13.5, sm)
local n = {}
sm:each(function(x, y) local k = K(x, y)
  local q, r, ux, uy = whorl(x, y)
  local f = q - floor(q)                            -- 0 at outer side of a whorl .. 1 inner side
  local u = (f - 0.5) * 2                           -- -1 outer .. 1 inner
  local a = sn[k]
  local b = 0.75 * (r > 3 and 1 or 0)
  n[k] = { A.norm(a[1] - ux * u * b, a[2] - uy * u * b, a[3]) }
end)
local sbias = {}
local sidx = A.shade(c, sm, n, SHL, { amb = 0.06, wrap = 0.22, tok = tokS, bias = sbias })
-- colour band + suture groove + growth lines
sm:each(function(x, y) local k = K(x, y)
  local q, r = whorl(x, y)
  local f = q - floor(q)
  local i = sidx[k] or 3
  local rw = r * (1 - 1 / GR)                        -- whorl width in px here
  local dpx = f * rw                                 -- px from outer suture
  local din = (1 - f) * rw                           -- px to inner suture
  if r < 1.2 then c:put(x, y, SHL[1], tokS)
  elseif din < 0.85 and r > 1.5 then c:put(x, y, SHL[max(1, i - 3)], tokS)            -- suture groove
  elseif din < 1.85 and r > 4 then c:put(x, y, SHL[min(6, i + 1)], tokS)              -- lit lip over the groove
  elseif f > 0.38 and f < 0.62 and r > 5 then c:put(x, y, BAND[i], tokS)              -- spiral colour band
  end
  -- fine radial growth lines on the outer whorl
  if q < 1 and r > 8 then
    local th = atan(y - CY + 0.5, x - CX + 0.5)
    if ((th * 13 / pi) % 2) < 0.22 and din >= 1.85 then c:put(x, y, SHL[max(1, i - 1)], tokS) end
  end
end)
-- aperture lip where the body leaves the shell (lower right): pale thickened rim
for _, p in ipairs{ {36, 42}, {37, 41}, {37, 40}, {35, 43}, {34, 44} } do if sm:has(p[1], p[2]) then c:put(p[1], p[2], SHL[5], tokS) end end
-- glossy specular + glint
c:put(18, 25, SHL[6], tokS) c:put(19, 24, SHL[6], tokS) c:put(20, 23, SHL[6], tokS) c:put(17, 27, SHL[6], tokS)
c:put(18, 24, A.CREAM, tokS)

-- quirk: tiny red toadstool on top of the shell
A.map(c, {
  ".hRRr.",
  "hRcRRr",
  "RRRRdr",
  "..sw..",
  "..sw..",
}, 22, 16, { h = "#ff8a5c", R = "#e8493b", r = "#b52e3f", d = "#6e2038", c = A.CREAM, s = "#fff0d0", w = "#c8b49a" }, tokS)
A.save(c, "snail-brown")
