-- Tentacle Wisp (pl-bjq-1), yard sprite 64x64. Opus second pass (c15/opus2), built on the Haiku idea.
-- Seedkeeper, common, Reef of the Box-Jelly Queen. "A pink tentacle curl that sways to music nobody else can hear."
-- A jelly-pink tentacle with a soft teardrop head: the head is glassy (pale core, bright rim), the tentacle
-- tapers through an S-sway into a tight spiral curl resting on the sand, ringed with pale stinger beads.
-- Haiku weakness fixed: a round head on a worm with a sharp elbow; now one continuous tapering tentacle, ringed,
-- with a spiral foot, the whole body leaning into the sway.
-- quirk: it sways with its eyes shut-happy to a single music note only it hears, the curl tip tapping the beat.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-bjq-1-yard", 64)

local JEL  = { "#6a2252", "#a83a72", "#d85a8e", "#f2829f", "#ffb4c8", "#ffe2ea" }
local BEAD = "#ffd6e0"

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
  local I, Tk = O.shadeN(c, m, n, JEL, { amb = .36, wrap = .5, rim = true, bounce = "#8a7ad0", bmax = 2, sep = JEL[2] })
  O.tex(c, I, Tk, JEL, function(x, y, i)
    local t, sd = T[K(x, y)] or 0, S[K(x, y)] or 0
    local ph = (t * (7 - 2 * si)) % 1
    if ph < .12 then return -1 end                                  -- ring grooves
  end)
end
-- pale stinger beads in a row down the lit side of the tentacle
for _, b in ipairs({ { 1, .15 }, { 1, .38 }, { 1, .6 }, { 1, .82 }, { 2, .25 }, { 2, .55 }, { 2, .85 } }) do
  local sp, t = spans[b[1]], b[2]
  local x, y = O.bez(sp, t)
  local x2, y2 = O.bez(sp, t + .02)
  local tx, ty = x2 - x, y2 - y
  local l = math.sqrt(tx * tx + ty * ty)
  local px, py = ty / l, -tx / l               -- one side normal
  if px + py > 0 then px, py = -px, -py end    -- pick the upper-left side
  local w = (b[1] == 1) and 3.2 or 2
  local bx, by = math.floor(x + px * w * .55 + .5), math.floor(y + py * w * .55 + .5)
  O.mark(c, { { bx, by } }, JEL[6]) O.mark(c, { { bx + 1, by + 1 } }, JEL[3])
end
-- body: a soft jelly bulb the tentacle grows from; glassy pale core, bright cap glint
local head = c:ellipse(30, 45, 13, 10)
local hI, hT = O.shade(c, head, JEL, { sphere = { 26, 40, 16 }, amb = .38, wrap = .5, rim = true, bounce = "#8a7ad0", bmax = 2, sep = JEL[2] })
O.tex(c, hI, hT, JEL, function(x, y, i)
  local dx, dy = (x - 30) / 13, (y - 44) / 10
  local r = math.sqrt(dx * dx + dy * dy)
  if r > .74 and r < .86 and y < 47 and i >= 3 then return 1 end
end)
O.mark(c, { { 21, 38 }, { 22, 37 }, { 23, 37 } }, JEL[6])
-- frilly hem where the bulb sits on the sand
for x = 19, 41, 3 do O.mark(c, { { x, 53 }, { x + 1, 54 } }, JEL[2]) end
-- stinger beads spotted on the bulb
O.mark(c, { { 37, 39 }, { 40, 43 }, { 20, 47 } }, BEAD)

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
