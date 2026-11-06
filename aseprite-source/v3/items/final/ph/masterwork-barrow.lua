-- masterwork-barrow (aC22_4, Opus single pass). Side view, wheel left: a deep teal-enamelled steel tray with a
-- rolled brass rim, a pressed rib and brass rivets, sloping front wall over a solid oak disc wheel (iron tyre,
-- brass hub). Two slim oak handles run under the tray to leather-wrapped grips; one slim leg with an iron foot.
-- Material: pillow-lit enamel with specular streak, brass bevel + glints, oak grain, wrap twist, AO under the tray.
-- quirk: a snail is slowly climbing the leg.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min = math.floor, math.max, math.min
local c = G.new("masterwork-barrow")
c:groundShadow(32, 46, 24, 2)

-- far handle + far leg (behind, one tone darker)
local fh, fhn, fhT = G.rod(26, 29, 56, 19, 1.3)
local b = {} fh:each(function(x, y) b[K(x, y)] = -1 end)
local fidx, ftok = G.shade(c, fh, fhn, G.OAK, { bias = b })
local fl, fln = G.rod(43, 23, 46, 44, 1.1)
local b2 = {} fl:each(function(x, y) b2[K(x, y)] = -2 end)
G.shade(c, fl, fln, G.OAK, { bias = b2 })

-- tray
local tray = c:poly{ { 7, 14 }, { 46, 14 }, { 43, 26 }, { 24, 32 } }
local tb = {}
-- darker lower band (AO toward the bottom / where handle meets)
tray:each(function(x, y) if y >= 30 or (y >= 25 and x > 36) then tb[K(x, y)] = -1 end end)
local tidx, ttok, tn = G.pillow(c, tray, 3, G.TEAL, { bias = tb, amb = 0.12, wrap = 0.25, flat = 0.35, flatv = 0.62 })
-- pressed rib: lit row then dark groove following the tray, from front wall to back
for x = 12, 44 do
  if tray:has(x, 20) and tray:has(x, 21) and x > 11 then c:put(x, 19, G.TEAL[5], ttok) c:put(x, 20, G.TEAL[2], ttok) end
end
-- specular streak on the upper-left of the side panel
G.pline(c, { { 12, 17 }, { 22, 17 } }, G.TEAL[6], ttok, tray)
c:put(13, 17, G.SPEC, ttok) c:put(14, 17, G.SPEC, ttok)
-- brass badge (diamond) mid panel
local badge = c:poly{ { 30, 22 }, { 33, 25 }, { 30, 28 }, { 27, 25 } }
local bn = X.pillow(badge, 1.5)
G.shade(c, badge, bn, G.BRASS, { amb = 0.15 })
c:put(29, 24, G.SPEC) c:put(30, 25, G.BRASS[2]) c:put(31, 25, G.BRASS[3])
-- rivets on the front and back seams
for _, p in ipairs{ { 11, 17 }, { 18, 27 }, { 44, 17 }, { 42, 23 } } do
  c:put(p[1], p[2], G.BRASS[4]) c:put(p[1] + 1, p[2], G.BRASS[2]) c:put(p[1], p[2] - 1, G.BRASS[6])
end
-- rolled brass rim along the top (overhangs a pixel each side)
local rim, rn = G.rod(6, 13.5, 47, 13.5, 1.4)
G.shade(c, rim, rn, G.BRASS, { amb = 0.15, wrap = 0.2, spec = { 30, 0.8, G.SPEC } })
-- rim end caps curl: dark eye at each end
c:put(6, 13, G.BRASS[2]) c:put(47, 13, G.BRASS[2])

-- wheel: solid oak disc of two planks + iron tyre + brass hub
local WX, WY, WR = 15, 37, 8
local disc, dn = G.oval(WX, WY, WR - 2.2, WR - 2.2, 0, 1.6)
local dB = {}
local didx, dtok = G.shade(c, disc, dn, G.WOOD, { bias = dB, amb = 0.2, wrap = 0.3 })
-- plank seams + grain
for y = WY - 6, WY + 6 do if disc:has(WX - 2, y) then c:put(WX - 2, y, G.WOOD[2], dtok) end end
for _, g in ipairs{ { WX - 4, -3, 1 }, { WX + 2, -4, 2 }, { WX + 4, 1, 3 }, { WX - 5, 2, 2 } } do
  for i = 0, g[3] do if disc:has(g[1], WY + g[2] + i) then
    local k = K(g[1], WY + g[2] + i) c:put(g[1], WY + g[2] + i, G.WOOD[max(1, (didx[k] or 3) - 1)], dtok) end end
end
G.wheel(c, WX, WY, { R = WR, tw = 2, spokes = 0, hub = 1.6, tyre = G.IRON, hubRamp = G.BRASS, spec = G.IRON[6] })

-- near handle (axle to grip) passing under the tray
local nh, nhn, nhT = G.rod(15, 37, 55, 22, 1.5)
local nb = {}
G.cast(nb, nh, tray, 0, 1, -1)
local nidx, ntok = G.shade(c, nh, nhn, G.OAK, { bias = nb, amb = 0.12 })
-- grain flecks along the handle
for _, t in ipairs{ 0.3, 0.42, 0.55, 0.68 } do
  local x, y = floor(15 + 40 * t + .5), floor(37 - 15 * t + .5)
  if nh:has(x, y) then c:put(x, y, G.OAK[3], ntok) end
end
-- grips: leather wrap with twist (diagonal dark turns)
local function grip(m, idx, tok, T, x0)
  m:each(function(x, y) local k = K(x, y)
    if x >= x0 then
      local i = max(2, (idx[k] or 3) - 1)
      if (x + y) % 3 == 0 then i = max(1, i - 1) end
      c:put(x, y, ({ "#2a1820", "#40222a", "#5e3226", "#81482c", "#a4643a", "#c88a54" })[i], tok)
    end
  end)
end
grip(nh, nidx, ntok, nhT, 50)
grip(fh, fidx, ftok, fhT, 51)

-- near leg + iron foot
local lg, lgn = G.rod(41, 27, 43, 44, 1.2)
local lb = {}
G.cast(lb, lg, nh, 0, 1, -1)
local lidx, ltok = G.shade(c, lg, lgn, G.OAK, { bias = lb })
local foot = c:rect(40, 44, 45, 45)
local ftn = X.pillow(foot, 1)
G.shade(c, foot, ftn, G.IRON, {})
-- iron strap where the leg bolts to the handle
c:put(41, 28, G.IRON[4]) c:put(42, 28, G.IRON[3]) c:put(43, 28, G.IRON[2]) c:put(41, 29, G.IRON[5])

-- quirk: snail climbing the leg (shell on the right of the leg, body along it)
local SN = { K = "#2b1c26", a = "#f5809f", b = "#c94f84", d = "#7d2c5e", h = "#ffc4d8", s = "#c9c3a8", t = "#9a927a", e = "#e8e2c8" }
local rows = {
  "e.hab.",
  "s.aKbd",
  "ssabKd",
  "s.bbdd",
  "stt...",
}
for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if SN[ch] then c:put(43 + xx - 1, 33 + yy - 1, SN[ch]) end end end
c:put(43, 32, SN.t) c:put(42, 31, SN.s)

G.save(c, "ph", "masterwork-barrow")
