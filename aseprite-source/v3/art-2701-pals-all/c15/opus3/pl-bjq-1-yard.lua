-- Tentacle Wisp (pl-bjq-1), yard sprite 64x64. Opus richness pass (c15/opus3), built on c15/opus2.
-- Seedkeeper, common, Reef of the Box-Jelly Queen. "A pink tentacle curl that sways to music nobody else can hear."
-- A glassy pink jelly bulb holding the face, one ringed tentacle rising from it in an S-sway and rolling into a
-- tight spiral curl at the top, studded with lilac stinger beads.
-- quirk: it sways to a single music note only it hears, the curl tip tapping the beat (sway arcs).
-- richness: hue-shifted jelly ramp (plum deeps, peach-pink lights), ring grooves with a lit shoulder on each ring,
-- a glassy pale ring inside the bulb, a scalloped frill hem, rim light and lilac bounce.
-- opus2 weakness fixed: the stinger beads were 1-px marks; now 2x2 lilac sea-glass beads (pale glint,
-- mid, violet shade) that contrast in hue with the pink, along the tentacle's lit edge and on the bulb.
-- closer look (seedkeeper): it keeps one little seed tucked in the middle of its spiral curl.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-bjq-1-yard", 64)

local JEL  = { "#5a1e56", "#9c3474", "#d4568c", "#f2809c", "#ffb2bc", "#ffe4e2" }
local BEAD = { "#9c3474", "#7a5ab8", "#b89ae8", "#f0e2fa" }
local SEED = { "#6e3416", "#b0662a", "#e0a050", "#ffe0a0" }
local BOUNCE = "#8a7ad0"
local function bead(x, y) -- a 2x2 lilac bead: glint upper-left, violet shade lower-right
  O.dot(c, x, y, BEAD[4]) O.dot(c, x + 1, y, BEAD[3]) O.dot(c, x, y + 1, BEAD[3]) O.dot(c, x + 1, y + 1, BEAD[2])
end

c:groundShadow(31, 56, 14, 2)

-- the tentacle rises from the body in an S-sway and rolls into a spiral curl at the top
local spans = {
  { { 31, 38 }, { 42, 30 }, { 22, 25 }, { 27, 15 } },
  { { 27, 15 }, { 30, 6 }, { 43, 7 }, { 43, 15 } },
  { { 43, 15 }, { 43, 21 }, { 35, 21 }, { 36, 15 } },
}
local w0 = { 5.6, 3.6, 2.3 }
local w1 = { 3.6, 2.3, 1.1 }
for si = #spans, 1, -1 do
  local m, n, T, S = O.tube(spans[si], function(t) return w0[si] + (w1[si] - w0[si]) * t end)
  local I, Tk = O.shadeN(c, m, n, JEL, { amb = .36, wrap = .5, rim = true, bounce = BOUNCE, bmax = 2, sep = JEL[2] })
  O.tex(c, I, Tk, JEL, function(x, y, i)
    local t = T[K(x, y)] or 0
    local ph = (t * (7 - 2 * si)) % 1
    if ph < .12 then return -1 end                                    -- ring grooves
    if ph > .14 and ph < .26 and i >= 3 and i <= 5 then return 1 end  -- lit shoulder after each groove
  end)
end
-- bead spots along the lit (upper-left) edge of the tentacle
local beads = {}
for _, b in ipairs({ { 1, .15 }, { 1, .38 }, { 1, .6 }, { 1, .82 }, { 2, .25 }, { 2, .55 }, { 2, .85 } }) do
  local sp, t = spans[b[1]], b[2]
  local x, y = O.bez(sp, t)
  local x2, y2 = O.bez(sp, t + .02)
  local tx, ty = x2 - x, y2 - y
  local l = math.sqrt(tx * tx + ty * ty)
  local px, py = ty / l, -tx / l
  if px + py > 0 then px, py = -px, -py end
  local w = (b[1] == 1) and (5.6 - 2 * t) or (3.6 - 1.3 * t)
  beads[#beads + 1] = { math.floor(x + px * (w - 1.6) + .5), math.floor(y + py * (w - 1.6) + .5) }
end
-- body: a soft jelly bulb the tentacle grows from; glassy pale ring inside, bright cap glint
local head = c:ellipse(30, 45, 13, 10)
local hI, hT = O.shade(c, head, JEL, { sphere = { 26, 40, 16 }, amb = .38, wrap = .5, rim = true, bounce = BOUNCE, bmax = 2, sep = JEL[2] })
O.tex(c, hI, hT, JEL, function(x, y, i)
  local dx, dy = (x - 30) / 13, (y - 44) / 10
  local r = math.sqrt(dx * dx + dy * dy)
  if r > .74 and r < .86 and y < 47 and i >= 3 then return 1 end
end)
O.mark(c, { { 21, 38 }, { 22, 37 }, { 23, 37 } }, JEL[6])
-- frilly scalloped hem where the bulb sits on the sand
for x = 19, 41, 3 do O.mark(c, { { x, 53 }, { x + 1, 54 } }, JEL[2]) O.mark(c, { { x + 1, 53 } }, JEL[4]) end
-- the beads: on the tentacle's lit edge and a few on the bulb
for _, b in ipairs(beads) do bead(b[1], b[2]) end
bead(39, 38) bead(41, 43) bead(18, 41)
-- the seed it keeps, tucked into the spiral
O.shade(c, c:ellipse(39.5, 15.5, 1.4, 1.1), SEED, { sphere = { 38.5, 14.5, 2.2 }, amb = .3, cuts = { .3, .55, .8 }, sep = SEED[1] })

-- face: blissful, humming
c:eyeLocked(23, 41)
c:eyeLocked(33, 41)
c:cheek(21, 47) c:cheek(38, 47)
O.mark(c, { { 29, 48 }, { 30, 49 }, { 31, 49 }, { 32, 48 } }, P.ink)

O.done(c, "pl-bjq-1-yard", function(c)
  local function put(x, y, h) if not c:get(x, y) then c:put(x, y, h) end end
  -- one music note only it hears
  for _, p in ipairs({ { 14, 10 }, { 14, 11 }, { 14, 12 }, { 14, 13 }, { 14, 14 }, { 14, 15 }, { 15, 10 }, { 16, 11 }, { 17, 12 },
    { 12, 15 }, { 13, 15 }, { 12, 16 }, { 13, 16 }, { 14, 16 } }) do put(p[1], p[2], P.ink) end
  -- sway arcs beside the curl
  for _, p in ipairs({ { 49, 9 }, { 50, 10 }, { 50, 11 }, { 50, 12 }, { 49, 13 }, { 18, 24 }, { 17, 25 }, { 17, 26 }, { 17, 27 }, { 18, 28 } }) do put(p[1], p[2], P.ink) end
end)
