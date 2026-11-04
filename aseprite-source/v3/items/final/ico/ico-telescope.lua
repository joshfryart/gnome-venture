-- ico-telescope (final, Opus). A slim brass-and-mahogany spyglass on a light wooden tripod, aimed up-right:
-- eyepiece -> polished brass draw tube -> mahogany barrel -> flared brass hood with a blue lens face.
-- Material: per-pixel cylinder light (6-tone brass, 6-tone mahogany), bevelled brass collars with a bright edge,
-- specular streak along the brass, dark eye hole in the eyepiece, mahogany grain along the barrel, ambient dark
-- where each section steps down into the next and where the clamp grips the barrel, wood grain on the legs, brass
-- ferrule feet, glass lens with a bright rim and a pale core glint.
-- quirk: the lens cap dangles on a little cord from the hood.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_1.lua")
local HP, X, K = R.HP, R.X, R.K
local sqrt, floor, max, min, abs, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin
local c = R.new("ico-telescope")
local BRASS = { "#4e2a1e", "#8a4e1f", "#c07d26", "#e2a73a", "#f6d264", "#fff0a6" }
local MAHO  = { "#3a1822", "#5e2428", "#86362e", "#a84d34", "#c86f44", "#e0965e" }
local WOOD  = { "#3e2422", "#5e3a2a", "#864c33", "#a86a40", "#c88f5c", "#e8b982" }
local GLASS = { "#1e2a5a", "#2a4a8a", "#3a78b8", "#6fb4dc", "#b6e6f0" }

-- tripod (back leg first)
local MX, MY = 33, 34
local function leg(bx, by, hwid, ramp, back)
  local m, n, T, S = X.cyl(MX, MY, bx, by, function() return hwid end)
  local bias = {}
  if back then m:each(function(x, y) bias[K(x, y)] = -1 end) end
  local idx, _, tok = R.shade(c, m, n, ramp, { amb = 0.1, wrap = 0.3, bias = bias })
  -- grain: a darker line along the leg on the lit half, paler end grain at the foot
  m:each(function(x, y) local k = K(x, y)
    if S[k] > -0.45 and S[k] < -0.05 and (floor(T[k] * 23) % 5) ~= 0 then R.step(c, idx, ramp, x, y, -1, tok) end
    if T[k] > 0.93 then c:put(x, y, BRASS[S[k] < 0 and 5 or 3], tok) end
  end)
  return m
end
local lb = leg(37, 56, 1.3, WOOD, true)
local ll = leg(16, 57, 1.6, WOOD)
local lr = leg(50, 57, 1.6, WOOD)

-- telescope tube: one swept cylinder, sections by t
local EX, EY, OX, OY = 9, 44, 52, 17
local SEC = {
  { 0.00, 0.11, 2.4, "brass" }, { 0.11, 0.15, 3.4, "brass" }, { 0.15, 0.36, 3.0, "brass" },
  { 0.36, 0.40, 4.3, "brass" }, { 0.40, 0.85, 3.9, "maho" }, { 0.85, 0.89, 4.6, "brass" }, { 0.89, 1.00, 5.4, "brass" } }
local function sec(t) for i, s in ipairs(SEC) do if t <= s[2] then return s, i end end return SEC[#SEC], #SEC end
local tm, tn, TT, TS = X.cyl(EX, EY, OX, OY, function(t)
  local s, i = sec(t)
  if i == #SEC then return s[3] + (t - s[1]) / (s[2] - s[1]) * 0.8 end   -- flared hood
  return s[3]
end)
local LEN = sqrt((OX - EX)^2 + (OY - EY)^2)
local bmask, mmask = HP.mask(), HP.mask()
tm:each(function(x, y) local s = sec(TT[K(x, y)]) if s[4] == "maho" then mmask:set(x, y) else bmask:set(x, y) end end)
-- ambient: pixels just after a step-up / before a step-down get darker; clamp shadow on the barrel
local bias = {}
tm:each(function(x, y) local k = K(x, y) local t = TT[k] local s, i = sec(t)
  local d0, d1 = (t - s[1]) * LEN, (s[2] - t) * LEN
  local prev, nxt = SEC[i - 1], SEC[i + 1]
  if prev and prev[3] > s[3] and d0 < 1.2 then bias[k] = -2 end
  if nxt and nxt[3] > s[3] and d1 < 1.2 then bias[k] = (bias[k] or 0) - 1 end
  if prev and prev[3] < s[3] and d0 < 0.9 then bias[k] = (bias[k] or 0) + 1 end      -- lit leading bevel of a collar
end)
local btok, mtok = { r = { name = "brass" } }, { r = { name = "maho" } }
local v = X.light(tn, { amb = 0.08, wrap = 0.25 })
local bidx = X.tone(c, bmask, v, BRASS, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = btok })
local midx = X.tone(c, mmask, v, MAHO, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = mtok })
-- mahogany grain: wavy dark streaks along the axis
mmask:each(function(x, y) local k = K(x, y) local t, s = TT[k], TS[k]
  local g = s * 3.2 + sin(t * 40) * 0.35
  if abs(g - floor(g + .5)) < 0.13 and abs(s) < 0.85 then R.step(c, midx, MAHO, x, y, -1, mtok) end
end)
-- brass specular streak on the lit side + glint on the draw tube
bmask:each(function(x, y) local k = K(x, y) local t, s = TT[k], TS[k]
  if s > -0.62 and s < -0.3 and bidx[k] and bidx[k] >= 4 then c:put(x, y, BRASS[6], btok) end
end)
-- dark eye hole at the eyepiece end
local ux, uy = (OX - EX) / LEN, (OY - EY) / LEN
local eye = R.rell(EX + ux * 0.2, EY + uy * 0.2, ux, uy, 0.9, 1.6)
eye:each(function(x, y) if tm:has(x, y) then c:put(x, y, BRASS[1], btok) end end)
-- lens face on the hood end: bright brass rim, glass with a pale core glint
local lens = R.rell(OX + ux * 1.3, OY + uy * 1.3, ux, uy, 2.6, 5.8)
local ltok = { r = { name = "lens" } }
local rimL = lens:copy():cut(lens:shrink(1))
lens:each(function(x, y)
  local px, py = -uy, ux
  local s = (x - OX) * px + (y - OY) * py
  local col = rimL:has(x, y) and (s < 0 and BRASS[6] or BRASS[4]) or (s < -1.5 and GLASS[3] or (s < 1.5 and GLASS[2] or GLASS[1]))
  c:put(x, y, col, ltok)
end)
do local gx, gy = floor(OX + ux * 0.4 - uy * -2.2 + .5), floor(OY + uy * 0.4 + ux * -2.2 + .5)
  c:put(gx, gy, GLASS[5], ltok) c:put(gx, gy + 1, GLASS[4], ltok) end

-- clamp: brass saddle under the barrel at the mount
local cl = c:rect(MX - 2, MY - 3, MX + 2, MY):cut(tm)
local cln = {}
cl:each(function(x, y) local s = (x - MX) / 3 cln[K(x, y)] = { R.norm(s, 0.3, 1) } end)
R.shade(c, cl, cln, BRASS, { amb = 0.1 })
tm:each(function(x, y) if cl:has(x, y + 1) then R.step(c, mmask:has(x, y) and midx or bidx, mmask:has(x, y) and MAHO or BRASS, x, y, -1, mmask:has(x, y) and mtok or btok) end end)
c:put(MX, MY - 1, BRASS[1]) -- thumb-screw hole

-- quirk: lens cap dangling on a cord from the hood
local hx, hy = OX - 1, OY + 6
local CORD = { "#5e2434", "#a84d48" }
for i = 0, 5 do c:put(hx + (i >= 3 and 1 or 0), hy + i, CORD[(i % 2) + 1]) end
local cap = c:ellipse(hx + 1, hy + 9, 2.5, 2.5)
local capn = X.sphere(hx + 0.6, hy + 8.6, 2.5, cap)
local cidx, _, ctok = R.shade(c, cap, capn, BRASS, { amb = 0.08 })
c:put(hx + 1, hy + 9, BRASS[2], ctok) c:put(hx, hy + 8, BRASS[6], ctok)
R.save(c, "ico-telescope")
