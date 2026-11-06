-- glow-silk (final, Opus single pass). A twisted hank of luminous chartreuse silk on the diagonal: two plies wound
-- round each other (helical grooves, lit crests, fine fibre lines), the top end folded into an open loop, a gold
-- thread wrap tying the lower end, and splayed fibre tails below. Shadows stay light and green because it glows.
-- quirk: one loose glowing thread wanders off the tail, and a firefly sits on its tip comparing glows.
local NAME = "glow-silk"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_3.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = B.new(NAME)
local SILK = { "#2f5e52", "#4a8a5c", "#78b862", "#b2de70", "#e0f49a", "#fbffd6" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local tok, gtok, ftok = { r = { name = "silk" } }, { r = { name = "wrap" } }, { r = { name = "fly" } }

-- top loop (ring), drawn first so the hank end lies over it
local LX, LY = 45, 15
local loop = HP.mask()
local loopN, LA, LR = {}, {}, {}
for y = LY - 9, LY + 9 do for x = LX - 9, LX + 9 do
  local dx, dy = (x - LX) / 6.6, (y - LY) / 6.0
  local r = sqrt(dx * dx + dy * dy)
  if r <= 1 and r >= 0.56 then
    loop:set(x, y)
    local k = K(x, y)
    local s = (r - 0.78) / 0.25                       -- -1 inner .. +1 outer
    s = max(-0.95, min(0.95, s))
    local ux, uy = dx / max(r, 0.01), dy / max(r, 0.01)
    loopN[k] = { B.norm(ux * s, uy * s, sqrt(1 - s * s)) }
    LA[k], LR[k] = atan(dy, dx), s
  end
end end
local li = B.shade(c, loop, loopN, SILK, { tok = tok, amb = 0.22, wrap = 0.35 })
loop:each(function(x, y) local k = K(x, y)
  local ph = (LA[k] * 6.6 * 0.8 / 3.2 + LR[k] * 0.6)
  local f = ph - floor(ph)
  if f < 0.16 then B.step(c, li, SILK, x, y, -2, tok) elseif f > 0.45 and f < 0.6 and LR[k] < 0.3 then B.step(c, li, SILK, x, y, 1, tok) end
end)

-- twisted hank body
local pts = { { 17, 47 }, { 24, 39 }, { 33, 31 }, { 41, 20 } }
local hm, hn, HT, HS, samp = B.tube(pts, function(t) return 4.3 - 0.6 * abs(t - 0.5) end)
local hlen = 0
for i = 2, #samp do hlen = hlen + sqrt((samp[i].x - samp[i - 1].x) ^ 2 + (samp[i].y - samp[i - 1].y) ^ 2) end
local hb = {}
X.ao(hb, loop, hm, 1, -1)
-- re-darken the loop where the hank lies over it (contact)
hm:shift(1, 1):each(function(x, y) if loop:has(x, y) and not hm:has(x, y) then B.step(c, li, SILK, x, y, -1, tok) end end)
local PER = 6.2
local PH = {}
local hv = X.light(hn, { amb = 0.22, wrap = 0.35 })
hm:each(function(x, y) local k = K(x, y)
  local ph = HT[k] * hlen / PER - HS[k] * 0.9
  PH[k] = ph - floor(ph)
  -- each ply is a little cylinder across the groove: crest light / groove dark
  local f = PH[k]
  local bump = sin(f * pi)               -- 0 at groove, 1 at crest
  hv[k] = hv[k] * (0.62 + 0.45 * bump)
end)
local hi = X.tone(c, hm, hv, SILK, { cuts = { 0.12, 0.26, 0.42, 0.6, 0.8 }, tok = tok })
hm:each(function(x, y) local k = K(x, y) local f = PH[k]
  if f < 0.09 or f > 0.95 then B.step(c, hi, SILK, x, y, -1, tok) end                -- groove
  -- fibre lines running with the ply
  local g = (HT[k] * hlen * 0.5 + HS[k] * 4.2)
  if f > 0.2 and f < 0.85 and (floor(g) % 3 == 0) and X.hash(x, y, 4) > 0.3 then B.step(c, hi, SILK, x, y, (HS[k] < 0) and 1 or -1, tok) end
end)

-- gold thread wrap tying the lower end (3 turns, twist)
local wrap = HP.mask()
hm:each(function(x, y) local k = K(x, y) if HT[k] > 0.13 and HT[k] < 0.22 then wrap:set(x, y) end end)
wrap:each(function(x, y) local k = K(x, y)
  local nn = hn[k] local v = (nn[1] * X.L[1] + nn[2] * X.L[2] + nn[3] * X.L[3])
  local i = v > 0.75 and 4 or (v > 0.45 and 3 or (v > 0.15 and 2 or 1))
  local turn = (HT[k] - 0.13) / 0.09 * 3 + HS[k] * 0.35
  if (turn - floor(turn)) < 0.25 then i = max(1, i - 1) end
  c:put(x, y, GOLD[i], gtok)
end)
-- AO on the silk just above and below the wrap
hm:each(function(x, y) local k = K(x, y)
  if (HT[k] >= 0.1 and HT[k] <= 0.13) or (HT[k] >= 0.22 and HT[k] < 0.245) then B.step(c, hi, SILK, x, y, -1, tok) end end)

-- splayed tails below the wrap
local tails = { { 13, 45, 7, 52, 0 }, { 15, 48, 10, 55, 1 }, { 18, 49, 15, 56, 0 }, { 20, 50, 20, 56, 1 } }
for i, t in ipairs(tails) do
  B.ln(c, t[1], t[2], t[3], t[4], SILK[t[5] == 0 and 4 or 3], tok)
  B.ln(c, t[1] + 1, t[2], t[3] + 1, t[4], SILK[t[5] == 0 and 2 or 5], tok)
end

-- quirk: a loose glowing thread wanders off and a firefly sits on its tip
local th = { { 21, 52 }, { 24, 55 }, { 28, 56 }, { 32, 55 }, { 35, 53 }, { 37, 50 } }
for i = 1, #th - 1 do B.ln(c, th[i][1], th[i][2], th[i + 1][1], th[i + 1][2], SILK[5], tok) end
B.map(c, {
  ".w..",
  "wwd.",
  ".ddb",
  ".gGb",
  ".Gg.",
}, 37, 45, { w = "#d6e6f0", d = "#3a2a3a", b = "#5a4458", g = "#ffe38a", G = "#f5b82e" }, ftok)
c:put(38, 46, B.CREAM, ftok)

c:sparkle(54, 26)

B.save(c, NAME)
