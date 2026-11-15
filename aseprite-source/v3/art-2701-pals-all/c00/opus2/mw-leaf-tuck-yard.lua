-- Leaf Tuck (mw-leaf-tuck), yard sprite 64x64. Opus second pass (c00/opus2), built from the Haiku first pass.
-- Bloomcaller, common, Maplewold. "Folds itself into the nearest red leaf pile."
-- A red maple leaf with a face, half sunk in a heap of fallen leaves: three lit lobes with teeth and veins
-- above the heap, the lower lobes buried.
-- quirk: its right lobe folds forward over the heap like an arm tucking in a blanket, showing the paler
-- underside of the leaf.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mw-leaf-tuck-yard", 64)

local RED  = { "#4a1730", "#7a1f36", "#b52e3f", "#e0453a", "#f76f4a", "#ffa070" }
local UND  = { "#7a2e36", "#a8463e", "#d0684c", "#e98a5e", "#f6ad7a", "#ffd09a" }
local ORNG = { "#5c2a26", "#8f4a1f", "#c96a22", "#ec9a2c", "#f9c14e", "#ffe38a" }
local BRWN = { "#3e2526", "#5e3428", "#864c33", "#a86a40", "#c98a55", "#e8b982" }
local CRIM = { "#3e1530", "#6e2038", "#9a2a40", "#c43a44", "#e65a52", "#ff8a6c" }

-- pointed leaf / lobe along a line, widest at wpos
local function lobe(ax, ay, bx, by, w, wpos, teeth)
  wpos = wpos or .35
  local function wf(t)
    if t < wpos then return w * (.55 + .45 * t / wpos) end
    return w * ((1 - t) / (1 - wpos)) ^ .8
  end
  if teeth then -- attached teeth on both edges, pointing toward the tip
    local m = lobe(ax, ay, bx, by, w, wpos)
    local L = math.sqrt((bx - ax)^2 + (by - ay)^2)
    local ux, uy = (bx - ax) / L, (by - ay) / L
    for _, t in ipairs(teeth) do for _, sd in ipairs({ -1, 1 }) do
      local px, py = -uy * sd, ux * sd
      local cx, cy = ax + (bx - ax) * t, ay + (by - ay) * t
      local e = wf(t) - .5
      m:add(c:poly{ { cx + px * e - ux * 2, cy + py * e - uy * 2 }, { cx + px * (e + 2.5) + ux * 1.5, cy + py * (e + 2.5) + uy * 1.5 }, { cx + px * (e - 1) + ux * 2, cy + py * (e - 1) + uy * 2 } })
    end end
    return m
  end
  return O.tube({ { ax, ay }, { ax + (bx - ax) / 3, ay + (by - ay) / 3 }, { ax + 2 * (bx - ax) / 3, ay + 2 * (by - ay) / 3 }, { bx, by } },
    function(t)
      if t < wpos then return w * (.55 + .45 * t / wpos) end
      return w * ((1 - t) / (1 - wpos)) ^ .8
    end)
end

c:groundShadow(32, 57, 23, 3)

-- the maple leaf: top lobe, left lobe, body; lower lobes are under the heap
local leaf = c:ellipse(32, 32, 12, 11)
leaf:add((lobe(32, 26, 32, 4, 8.5, .35, { .55 })))
leaf:add((lobe(28, 30, 7, 21, 7.5, .35, { .6 })))
leaf:add((lobe(36, 30, 51, 17, 6.5, .35, { .62 })))  -- right lobe tip, behind the fold
leaf:add((lobe(30, 36, 12, 43, 5.5)))
local lI, lT = O.shade(c, leaf, RED, { R = 6, amb = .2, wrap = .35, rim = true, bounce = "#6a3a6a", bmax = 1 })
-- waxy sheen and fine flecks
O.tex(c, lI, lT, RED, function(x, y, i) if H(x, y, 11) > .94 and i >= 3 then return -1 end end)
-- veins: midrib up the top lobe, one into each side lobe (stop short of the face)
local function vein(pts, tone)
  for s = 1, #pts - 1 do
    local a, b = pts[s], pts[s + 1]
    local n = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2]))
    for k = 0, n do
      local x, y = math.floor(a[1] + (b[1] - a[1]) * k / n + .5), math.floor(a[2] + (b[2] - a[2]) * k / n + .5)
      if c.own[y * c.w + x] == lT then
        local i = lI[K(x, y)] or 3
        c.pix[y * c.w + x] = RED[math.max(2, i - 1)]
      end
    end
  end
end
vein({ { 32, 23 }, { 32, 6 } }, 2)
vein({ { 32, 15 }, { 28, 11 } }) vein({ { 32, 17 }, { 36, 12 } })
vein({ { 21, 28 }, { 9, 22 } })
vein({ { 15, 25 }, { 14, 22 } })

-- the leaf heap: overlapping fallen leaves, back row first
local heap = {
  { 9, 50, 22, 43, 4.5, BRWN }, { 54, 50, 41, 44, 4.5, ORNG }, { 18, 46, 34, 41, 5, ORNG },
  { 48, 46, 30, 42, 5, CRIM }, { 12, 53, 28, 48, 4.5, CRIM }, { 52, 54, 36, 49, 4.5, RED },
  { 22, 55, 40, 51, 4.5, BRWN }, { 26, 50, 42, 46, 4, ORNG },
}
for _, h in ipairs(heap) do
  local m, n = O.tube({ { h[1], h[2] }, { (2 * h[1] + h[3]) / 3, (2 * h[2] + h[4]) / 3 - 1 }, { (h[1] + 2 * h[3]) / 3, (h[2] + 2 * h[4]) / 3 - 1 }, { h[3], h[4] } },
    function(t) return h[5] * math.sin(math.pi * t) ^ .7 + .3 end)
  local I, T = O.shadeN(c, m, n, h[6], { amb = .22, wrap = .4, sep = h[6][1] })
  -- midrib
  local L = math.max(math.abs(h[3] - h[1]), math.abs(h[4] - h[2]))
  for k = 2, L - 2 do
    local x, y = math.floor(h[1] + (h[3] - h[1]) * k / L + .5), math.floor(h[2] + (h[4] - h[2]) * k / L + .5)
    if c.own[y * c.w + x] == T then c.pix[y * c.w + x] = h[6][math.max(2, (I[K(x, y)] or 3) - 1)] end
  end
end

-- quirk: the right lobe folded forward over the heap, pale underside up, like an arm tucking a blanket
local fold, fn = O.tube({ { 43, 25 }, { 48, 31 }, { 50, 38 }, { 50, 47 } }, function(t)
  if t < .3 then return 4.5 + 1.5 * t / .3 end
  return 6 * ((1 - t) / .7) ^ .8
end)
fold:add(c:poly{ { 52, 32 }, { 57, 35 }, { 53, 37 } }) -- a side tooth
local fI, fT = O.shadeN(c, fold, fn, UND, { amb = .25, wrap = .4, sep = RED[2], rim = true })
-- underside veins (raised, paler on a mid tone)
for _, p in ipairs({ { 45, 28 }, { 46, 30 }, { 47, 32 }, { 48, 34 }, { 49, 36 }, { 49, 38 }, { 49, 40 }, { 50, 42 } }) do
  if c.own[p[2] * c.w + p[1]] == fT then c.pix[p[2] * c.w + p[1]] = UND[6] end
end
for _, p in ipairs({ { 50, 35 }, { 51, 35 }, { 52, 35 }, { 46, 37 }, { 45, 38 } }) do
  if c.own[p[2] * c.w + p[1]] == fT then c.pix[p[2] * c.w + p[1]] = UND[3] end
end
-- crease where the lobe bends over (dark fold line along its root)
for _, p in ipairs({ { 40, 24 }, { 41, 25 }, { 42, 26 }, { 43, 27 } }) do O.dot(c, p[1], p[2], RED[2]) end

-- face
c:eyeLocked(24, 26)
c:eyeLocked(33, 26)
c:cheek(22, 33) c:cheek(38, 33)
O.dots(c, { { 28, 34 }, { 29, 35 }, { 30, 35 }, { 31, 35 }, { 32, 35 }, { 33, 34 } }, P.ink)
O.dots(c, { { 30, 36 }, { 31, 36 } }, RED[2])

O.shift(c, 0, -1)
O.done(c, "mw-leaf-tuck-yard")
