-- ico-barrel (final, Opus). Upright oak barrel seen a little from above: bulged body of curved staves,
-- two iron hoop pairs, lid with the stave chime and a cork bung.
-- Material: per-pixel cylinder light (6-tone oak), stave grooves that follow the bulge, broken grain dashes,
-- paler end grain on the chime, iron hoops with a lit top edge, dark bottom edge, rivets and a specular streak,
-- AO under each hoop and inside the chime, cool reflected light on the right.
-- quirk: a tiny red toadstool has sprouted from the damp bottom stave.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-barrel")
local OAK  = { "#4a2826", "#6e3a2a", "#955430", "#bb7640", "#d89a5a", "#f0c488" }
local IRON = { "#29283a", "#403f58", "#5c5e7a", "#7f84a0", "#aab0c6", "#dde2ee" }
local END  = { "#7a4a30", "#a46c44", "#c99260", "#e4b47c", "#f4d29c" }
local BOUNCE = "#6e4a5e"

c:groundShadow(32, 56, 17, 2)
local CX, H0, H1, TILT = 31.5, 13, 50, 4.5
local function wfn(h) return 11.6 + 2.6 * sin(pi * (h - H0) / (H1 - H0)) end
local body, bn, BI = A.vessel(CX, H0, H1, wfn, TILT)
local otok = { r = { name = "oak" } }
local bias = {}
local HOOPS = { { 16, 19.6 }, { 44, 47.6 } }
-- AO under hoops
body:each(function(x, y) local k = K(x, y) local h = BI[k].h
  for _, hp in ipairs(HOOPS) do if h > hp[2] and h < hp[2] + 1.6 then bias[k] = -1 end end
  if h > H1 - 1.2 then bias[k] = (bias[k] or 0) - 1 end
end)
local idx = A.shade(c, body, bn, OAK, { bias = bias, tok = otok, amb = 0.03, wrap = 0.12, cuts = { 0.12, 0.3, 0.48, 0.66, 0.84 } })
-- staves: grooves at fixed angles, grain dashes between
local NS, OFF = 8, 0.37
body:each(function(x, y) local k = K(x, y) local inf = BI[k]
  local f = (inf.phi + pi / 2) / (pi / NS) + OFF
  local fr = f - floor(f)
  local dphi = 1 / ((wfn(inf.h) + 0.5) * max(0.15, cos(inf.phi)))
  local pw = dphi / (pi / NS)
  if abs(inf.u) < 0.93 then
    if fr < pw * 0.95 then A.step(c, idx, OAK, x, y, -2, otok)
    elseif fr < pw * 1.9 and inf.u < -0.35 and inf.u > -0.8 then A.step(c, idx, OAK, x, y, 1, otok)      -- lit lip on the next stave
    else
      local st = floor(f)
      local g = fr - (0.45 + 0.25 * X.hash(st, 3, 1))
      if abs(g) < pw * 0.5 and X.hash(st, floor(inf.h / 4), 7) > 0.62 then A.step(c, idx, OAK, x, y, -1, otok) end
    end
  end
end)
-- cool bounce on the right rim
body:each(function(x, y) local k = K(x, y) local inf = BI[k]
  if not body:has(x + 1, y) and inf.h > 21 and inf.h < 44 then c:put(x, y, BOUNCE, otok) end
end)
-- hoops
local itok = { r = { name = "iron" } }
for hi, hp in ipairs(HOOPS) do
  local hm, hn = HP.mask(), {}
  body:each(function(x, y) local k = K(x, y) local h = BI[k].h
    if h >= hp[1] and h <= hp[2] then hm:set(x, y)
      local t = (h - hp[1]) / (hp[2] - hp[1])
      local nn = bn[k]
      hn[k] = { A.norm(nn[1] * 1.15, nn[2] + (t < 0.34 and -0.55 or (t > 0.7 and 0.6 or 0)), nn[3]) }
    end end)
  local hidx = A.shade(c, hm, hn, IRON, { tok = itok, amb = 0.04, wrap = 0.15 })
  -- rivets on the lit side
  for _, ph in ipairs{ -0.75, 0.15 } do
    local w = wfn((hp[1] + hp[2]) / 2)
    local x = floor(CX + sin(ph) * (w + 0.5) + 0.5)
    local y = floor((hp[1] + hp[2]) / 2 + TILT * cos(ph) + 0.5)
    if hm:has(x, y) then c:put(x, y, IRON[6], itok) if hm:has(x + 1, y) then c:put(x + 1, y, IRON[2], itok) end end
  end
  -- specular streak on the top edge, lit side
  local w = wfn(hp[1])
  for _, ph in ipairs{ -0.62, -0.5, -0.38 } do
    local x = floor(CX + sin(ph) * (w + 0.5) + 0.5)
    local y = floor(hp[1] + TILT * cos(ph) + 0.5)
    if hm:has(x, y) then c:put(x, y, IRON[6], itok) end
  end
end
-- lid: chime ring of pale end grain, recessed head, plank seams, bung
local LW = wfn(H0) + 0.5
local lid = A.ellM(CX, H0, LW, TILT)
local inner = A.ellM(CX, H0 + 0.4, LW - 2.4, TILT - 1.6)
local etok = { r = { name = "end" } }
local ln = X.pillow(lid, 2)
local lidx = A.shade(c, lid, ln, END, { tok = etok, cuts = { 0.25, 0.45, 0.65, 0.85 } })
-- end grain ticks on the chime (stave ends)
lid:each(function(x, y) if not inner:has(x, y) then
  local u = (x - CX) / LW
  local f = (math.asin(max(-1, min(1, u))) + pi / 2) / (pi / NS) + OFF
  if f - floor(f) < 0.12 and y > H0 then A.step(c, lidx, END, x, y, -1, etok) end
end end)
local hn = {}
inner:each(function(x, y) hn[K(x, y)] = { 0.05, -0.25, 1 } end)
local hb = {}
X.ao(hb, inner, lid:copy():cut(inner), 1, -1)   -- recess shadow just inside the chime (upper rim)
inner:each(function(x, y) local k = K(x, y) if y > H0 + 1.5 then hb[k] = nil end end)
local hidx = A.shade(c, inner, hn, OAK, { tok = otok, bias = hb, cuts = { 0.3, 0.5, 0.7, 0.9, 0.98 } })
for _, sx in ipairs{ -4.5, 3.5 } do
  local x = floor(CX + sx)
  for y = floor(H0 - TILT), floor(H0 + TILT) do if inner:has(x, y) then A.step(c, hidx, OAK, x, y, -2, otok) end end
end
-- cork bung
local bx, by = floor(CX + 5), floor(H0)
A.map(c, { ".hb.", "hbbs", ".sd." }, bx - 1, by - 1, { h = "#e8c08a", b = "#c99a62", s = "#9a6a44", d = "#6e4632" }, etok)

-- quirk: toadstool sprouting from the bottom-left stave
local mx, my = floor(CX - 11), 49
A.map(c, {
  ".hRR.",
  "hRcRr",
  "RRRrd",
  "..sw.",
  "..sw.",
}, mx - 2, my - 3, { h = "#ff8a5c", R = "#e8493b", r = "#b52e3f", d = "#6e2038", c = "#fff4d6", s = "#f2e2c0", w = "#c8b494" })

A.save(c, "ico-barrel")
