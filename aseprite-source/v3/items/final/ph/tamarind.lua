-- tamarind (lean P1b_O16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function pick(r, v, cuts) cuts = cuts or {.22,.4,.56,.72,.86} local i = 1 for _, t in ipairs(cuts) do if v > t then i = i + 1 end end return r[min(i, #r)] end

local c = HP.canvas{ w=64, h=64, scale=1, name="tamarind" }
local SHELL = { "#3d2a22", "#6b4a35", "#946a47", "#bd9062", "#dcb882", "#f3dcaa" }
local PULP  = { "#2a1418", "#4e2220", "#7a3a28", "#a65a34" }
local SEED  = { "#2a1214", "#512421", "#7b3a2c", "#a85f45" }
c:groundShadow(32, 54, 18, 2)
local P = { {6,22}, {14,54}, {46,56}, {58,24} }
local m, n, T, S = G.tube(P, function(t) return 1.2 + 4.6 * sin(pi * min(1, t * 1.05)) ^ 0.7 * (0.82 + 0.18 * cos(t * pi * 10)) end)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
local pulp = HP.mask()
m:each(function(x, y) local k = K(x, y) if T[k] > 0.4 and T[k] < 0.6 and abs(S[k]) < 0.55 then pulp:set(x, y) end end)
m:each(function(x, y)
  local k = K(x, y)
  if not pulp:has(x, y) then
    local col = pick(SHELL, v[k])
    -- segment constrictions + grain streaks
    local seg = (cos(T[k] * pi * 10) < -0.85)
    if seg then col = SHELL[max(1, 2)] end
    if abs(abs(S[k]) - 0.5) < 0.12 and X.hash(x, y, 3) > 0.35 and not seg then col = pick(SHELL, v[k] - 0.2) end
    if X.hash(x, y, 7) > 0.93 and v[k] > 0.5 then col = SHELL[6] end
    c:px(x, y, col)
  end
end)
pulp:each(function(x, y) local k = K(x, y) c:px(x, y, pick(PULP, v[k] + 0.1 * sin(x * 1.3 + y))) end)
pulp:edge():each(function(x, y) c:px(x, y, SHELL[1]) end)
-- seed in the crack
local sm, sn = G.oval(32, 54.5 - 1, 2.8, 2.2, 0.3, 1)
local sv = X.light(sn, { amb = 0.1, wrap = 0.3 })
sm:each(function(x, y) c:px(x, y, pick(SEED, sv[K(x, y)])) end)
c:px(31, 52, "#ffd9b8")
-- cracked rim highlight on the shell
for _, p in ipairs{ {14,40}, {15,38}, {50,40}, {49,38} } do c:px(p[1], p[2], SHELL[6]) end
G.save(c, "tamarind")
