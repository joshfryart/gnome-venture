-- npc-old-baobab-kito portrait (npc2 P1_26) species: elephant
local NAME = "npc-old-baobab-kito"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local INK, CREAM = "#2b1c26", "#f4ead0"
local function eye4(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 }, { 1, 1 } }) do c:put(x + q[1], y + q[2], CREAM) end
  c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local function recol(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:put(x, y, to) end end) end
local HIDE  = { hi = "#c4b4b4", base = "#8e8098", shade = "#665a7a", deep = "#463c5a" }
local EAR   = { hi = "#c89aa4", base = "#a87888", shade = "#7c5670", deep = "#5a3e5a" }
local KUFI  = { hi = "#f6eed8", base = "#e6d6b4", shade = "#bca88c", deep = "#8a7464" }
local GOLD  = { hi = "#f8d870", base = "#e8a830", shade = "#b8702a", deep = "#7a4630" }
local GRN   = { hi = "#7cc048", base = "#3f8a3a", shade = "#2e6038", deep = "#24403a" }
local RED   = { hi = "#f07a50", base = "#c8402e", shade = "#94303a", deep = "#5e2436" }
local BASK  = { hi = "#e8c27a", base = "#c08a44", shade = "#8e5a34", deep = "#5e3a2e" }
local CAT   = { hi = "#f4b46a", base = "#e0843a", shade = "#a8562e", deep = "#6e3428" }
local TUSK  = { hi = CREAM, base = "#e8dcc0", shade = "#c0ae94", deep = "#8a7868" }
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- big fan ears behind
for _, s in ipairs{ -1, 1 } do
  c:part(c:ellipse(40 + s * 25, 53, 12, 15), HIDE, { band = 2, nopop = true })
  c:part(c:ellipse(40 + s * 26, 54, 8, 11), EAR, { band = 2, nopop = true, inner = false })
  for y = 48, 60, 4 do c:put(40 + s * 26, y, EAR.shade) end
end
-- kente shawl body bleeding off the bottom
local sh = c:ellipse(40, 106, 35, 31):clip(c:rect(0, 74, 79, 99))
c:part(sh, GOLD, { band = 3, pop = { x = 14, y = 88 } })
local S = { [79] = GRN, [80] = GRN, [81] = GRN, [85] = RED, [86] = RED, [87] = RED, [91] = GRN, [92] = GRN, [93] = GRN, [97] = RED, [98] = RED }
sh:each(function(x, y) local r = S[y] if r then
  local v = c:get(x, y)
  c:put(x, y, (v == GOLD.shade or v == GOLD.deep) and r.shade or (x % 8 == 3 and GOLD.hi or r.base)) end end)
sh:each(function(x, y) if S[y] and not S[y + 1] and S[y] == RED then c:put(x, y + 1, RED.deep) end end)
-- basket + ginger cat (lower right)
local ct = c:ellipse(63, 81, 7, 5.5)
ct:add(c:poly{ { 56, 79 }, { 57, 71 }, { 61, 76 } }) ct:add(c:poly{ { 65, 76 }, { 69, 71 }, { 70, 79 } })
c:part(ct, CAT, { band = 2, pop = { x = 58, y = 78 } })
c:put(58, 75, EAR.base) c:put(68, 75, EAR.base)
for _, q in ipairs{ { 59, 80 }, { 60, 80 }, { 66, 80 }, { 67, 80 } } do c:put(q[1], q[2], INK) end
c:put(59, 79, GRN.hi) c:put(66, 79, GRN.hi)
c:put(63, 82, EAR.base) c:put(62, 83, INK) c:put(64, 83, INK)
for _, q in ipairs{ { 56, 82 }, { 69, 82 } } do c:put(q[1], q[2], CAT.shade) end
local bk = c:rrect(52, 84, 75, 99, 3)
c:part(bk, BASK, { band = 2, nopop = true })
bk:each(function(x, y) if (x + (y // 2) * 2) % 4 < 2 and y % 2 == 0 and c:get(x, y) == BASK.base then c:put(x, y, BASK.shade) end end)
for x = 53, 74 do c:put(x, 84, x < 64 and BASK.hi or BASK.base) c:put(x, 85, BASK.deep) end
-- head
local hd = c:ellipse(40, 52, 20, 16)
c:part(hd, HIDE, { band = 3, pop = { x = 27, y = 43 } })
for _, q in ipairs{ { 33, 40 }, { 34, 40 }, { 35, 39 }, { 44, 39 }, { 45, 40 }, { 46, 40 }, { 38, 42 }, { 39, 42 }, { 40, 42 }, { 41, 42 } } do c:put(q[1], q[2], HIDE.shade) end
-- trunk: tapering bezier that curls toward the cat
local tr = HP.mask()
local A, B, C2, D = { 40, 58 }, { 40, 76 }, { 42, 84 }, { 52, 82 }
for i = 0, 48 do
  local t = i / 48 local u = 1 - t
  local x = u^3 * A[1] + 3 * u^2 * t * B[1] + 3 * u * t^2 * C2[1] + t^3 * D[1]
  local y = u^3 * A[2] + 3 * u^2 * t * B[2] + 3 * u * t^2 * C2[2] + t^3 * D[2]
  local r = 5.5 - 3 * t
  tr:add(HP.ellipse(x, y, r, r))
end
c:part(tr, HIDE, { band = 2, nopop = true, inner = false })
tr:each(function(x, y) if y % 3 == 0 and y > 62 and y < 80 and c:get(x, y) == HIDE.base then c:put(x, y, HIDE.shade) end end)
c:put(36, 63, HIDE.hi) c:put(36, 64, HIDE.hi) c:put(36, 66, HIDE.hi)
c:put(53, 81, HIDE.deep) c:put(53, 82, HIDE.deep)
-- tusks + smile corners
c:part(c:line({ { 32, 64 }, { 31, 69 }, { 33, 72 } }, 3), TUSK, { band = 1, nopop = true, inner = false })
c:part(c:line({ { 48, 64 }, { 49, 69 }, { 47, 72 } }, 3), TUSK, { band = 1, nopop = true, inner = false })
for _, q in ipairs{ { 34, 63 }, { 35, 64 }, { 46, 63 }, { 45, 64 } } do c:put(q[1], q[2], INK) end
-- eyes, heavy lids, bushy cream brows
c:eyeLocked(28, 48) c:eyeLocked(47, 48)
for x = 28, 32 do c:put(x, 47, HIDE.deep) end for x = 47, 51 do c:put(x, 47, HIDE.deep) end
local br = c:ellipse(30.5, 45, 4.5, 1.6) br:add(c:ellipse(49.5, 45, 4.5, 1.6))
c:part(br, TUSK, { band = 1, nopop = true, inner = false })
c:cheek(25, 57) c:cheek(53, 57)
-- kufi cap: cylinder, pattern band
local kf = c:rect(26, 24, 54, 35)
kf:add(c:ellipse(40, 24, 14, 3.5)) kf:add(c:ellipse(40, 35, 14, 2))
c:part(kf, KUFI, { band = 3, pop = { x = 30, y = 22 } })
for x = 27, 53 do c:put(x, 29, KUFI.shade) c:put(x, 33, KUFI.shade) end
local DOT = { RED.base, GRN.base, GOLD.base }
for x = 28, 52, 3 do local k = DOT[(x // 3) % 3 + 1] c:put(x, 31, k) c:put(x + 1, 31, k) c:put(x, 30, k) end
for x = 30, 50, 4 do c:put(x, 26, KUFI.shade) end
c:finish{ outline = true }
backdrop(c, { base = "#f0a848", shade = "#d07c34", deep = "#a0562c" })
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
