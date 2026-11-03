-- rambutan (pass B, final, Opus). One round fruit on a short woody stalk; soft spines radiate from the rind and
-- hook at the tip, fading crimson -> lime green, spaced so each one reads with its own outline.
-- Material: sphere light (6-tone crimson, cool-violet shade), rind tubercles with a raised hooked hair each
-- (lit ridge + shadow dot), cool reflected light lower-right, one glossy specular, calyx collar + AO at the stalk.
-- History: rambutan.pA (pass A). Draft by Sonnet replaced.
-- quirk: a torn window in the rind shows the glossy pearl flesh inside (pale rind lip, jagged tear).
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "rambutan" }
local floor, sin, cos, pi, max, min, sqrt, atan = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local RIND  = { "#3a0e2c", "#621533", "#8e1f3b", "#b92b3e", "#d9404a", "#f2685e" }
local HAIRC = { "#6e1a36", "#a3263d", "#d23e46", "#f06a5c" }
local TIPG  = { "#3f7a40", "#7fb54a", "#bfe06c" }
local PEARL = { "#a3a9bf", "#cfd5dc", "#ebeee9", "#fbf9f0" }
local STEM  = { "#3a2622", "#5b3e2e", "#81603f", "#a8844f" }
local CX, CY, R = 31.5, 38.5, 11

-- stalk (behind)
local sm, sn = G.tube({ {32, 28}, {32, 23}, {33, 21}, {36, 18} }, function(t) return 1.25 - 0.3 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.2, wrap = 0.3 }), STEM, { 0.3, 0.55, 0.8 })
c:px(36, 17, STEM[3]) c:px(37, 17, STEM[4])                      -- snapped end, paler wood

-- outer spines: 13 tapered, curved tufts (2-3 px at the root, 1 px hooked tip), lit per pixel, green tips
local NS = 18
for i = 0, NS - 1 do
  local a = -pi / 2 + (i + 0.5) / NS * 2 * pi + 0.08
  local da = math.abs(((a + pi / 2 + pi) % (2 * pi)) - pi)
  if da > 0.3 then
    local L = (i % 2 == 0) and 6.5 or 5.5
    local function P(r, off) local aa = a + off return { CX + cos(aa) * r, CY + sin(aa) * r } end
    local ctrl = { P(R - 2, 0), P(R + L * 0.45, 0.02), P(R + L * 0.8, 0.12), P(R + L, 0.3) }
    local m, sn2, T2 = G.tube(ctrl, function(t) return 0.95 * (1 - t) + 0.3 end, { steps = 40 })
    local v2 = X.light(sn2, { amb = 0.15, wrap = 0.35 })
    local lit = -cos(a) * 0.6 - sin(a) * 0.75
    local bi = {}
    m:each(function(x, y) local k = K(x, y) bi[k] = (lit < -0.3) and -1 or ((lit > 0.4) and 1 or 0) end)
    local id2 = G.tone(c, m, v2, HAIRC, { 0.3, 0.55, 0.8 }, bi)
    m:each(function(x, y) local k = K(x, y)
      if T2[k] > 0.72 then c:px(x, y, TIPG[min(3, max(1, (id2[k] or 2) - 1))]) end end)
  end
end

-- body
local body = c:ellipse(CX, CY, R, R)
local n = X.sphere(CX - 0.6, CY - 0.6, R, body)
local v = X.light(n, { amb = 0.05, wrap = 0.2 })
local bias = {}
X.ao(bias, body, c:rect(30, 26, 34, 27), 2, -1)                  -- AO under the stalk
local idx = G.tone(c, body, v, RIND, { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias)
-- tubercles + hooked hairs lying on the face (offset rows), each: shadow dot, lit ridge, tip
local core = body:copy():shrink(1)
for row = -3, 3 do for col = -3, 3 do
  local x0 = CX + col * 3.2 + (row % 2) * 1.6 - 0.5
  local y0 = CY + row * 3.0
  local dx, dy = x0 - CX, y0 - CY
  local r = sqrt(dx*dx + dy*dy)
  if r < R - 1.6 then
    local a = atan(dy, dx)
    local sx, sy = floor(x0 + .5), floor(y0 + .5)
    -- hair points outward-ish with a clockwise sweep, foreshortened toward the rim
    local ha = a + 0.9
    local hl = 2
    local tx, ty = floor(x0 + cos(ha) * hl + .5), floor(y0 + sin(ha) * hl + .5)
    if core:has(sx, sy) and core:has(tx, ty) then
      local i = idx[K(sx, sy)] or 3
      c:px(sx + 1, sy + 1, RIND[max(1, i - 2)])                    -- shadow under the bump
      G.line(c, { {sx, sy}, {tx, ty} }, RIND[min(6, i + 1)])        -- raised hair, lit
      c:px(tx, ty, i >= 5 and TIPG[3] or (i >= 4 and TIPG[2] or RIND[max(1, i - 1)]))
    end
  end
end end
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.72 then c:px(x, y, "#7b3f78") end end)
-- calyx collar where the stalk enters
for _, p in ipairs{ {30, 28, 1}, {31, 28, 2}, {32, 28, 3}, {33, 28, 2}, {34, 28, 1}, {31, 27, 2}, {33, 27, 1} } do c:px(p[1], p[2], STEM[p[3]]) end
-- specular (glossy rind), bloom halo
c:px(24, 32, "#fff1dc") c:px(25, 32, "#fff1dc") c:px(24, 33, RIND[6]) c:px(26, 32, RIND[6])

-- quirk: torn window, pearl flesh, jagged upper tear, pale rind lip below
local win = c:ellipse(35, 41, 3.6, 2.8)
local wn = X.sphere(34, 39.5, 5.5, win)
G.tone(c, win, X.light(wn, { amb = 0.25, wrap = 0.35 }), PEARL, { 0.3, 0.55, 0.78 })
win:grow(1):cut(win):each(function(x, y) if body:has(x, y) then
  c:px(x, y, (y >= 42) and "#f6cdb6" or RIND[1]) end end)
win:edge():each(function(x, y) if y <= 39 then c:px(x, y, PEARL[1]) end end)  -- shadow cast by the rind lip
c:px(33, 40, "#fefcf4") c:px(34, 40, "#fefcf4") c:px(33, 41, PEARL[4])     -- wet glint on the flesh
G.fin(c, "rambutan")
