-- Samara Spin (mw-samara-spin), yard sprite 64x64. Opus pass, art-2701-opus.
-- Thornblade, rare, hovers. A maple key that learned to fly: a plump ribbed nutlet with a brave
-- little face and brow, one long red-amber wing with fanned veins, hovering high over a small
-- shadow inside cream spin arcs. quirk: the wing's leading edge is set with tiny thorns.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("samara-spin-yard", 64)

local WING = { "#5e1e2a", "#8e2c30", "#c0443a", "#e0683e", "#f29a5a", "#fcc888" }
local NUT  = { "#4a2426", "#7a3a2e", "#a65a36", "#c97c44", "#e2a35e", "#f4ca88" }
local THORN= { "#3e1a24", "#6e2038" }

c:groundShadow(23, 59, 8, 2)

-- wing: narrow at the nut, broad toward the rounded tip, sweeping up and right. Flat membrane
-- tones by position across the wing (not a tube): thick vein on the upper edge, pale band, mid,
-- shade toward the lower trailing edge.
local WP = { { 25, 34 }, { 29, 20 }, { 42, 9 }, { 57, 9 } }
local wfn = function(t)
  if t > .78 then return 8.2 * math.sqrt(math.max(0, 1 - ((t - .78) / .24) ^ 2)) + .3 end
  return 2.2 + 6.0 * (t / .78) ^ .8 end
local wm, wn, wT, wS = O.tube(WP, wfn)
-- quirk: thorn teeth on the lower edge, part of the silhouette (outlined with the wing)
local teeth = HP.mask()
for _, t in ipairs({ .3, .46, .62, .78 }) do
  local x, y = O.bez(WP, t)
  local x2, y2 = O.bez(WP, t + .01)
  local tx, ty = x2 - x, y2 - y
  local l = math.sqrt(tx * tx + ty * ty)
  local px, py = -ty / l, tx / l
  if px + py < 0 then px, py = -px, -py end
  local w = wfn(t)
  local ux, uy = tx / l, ty / l
  w = 0
  while wm:has(math.floor(x + px * (w + 1) + .5), math.floor(y + py * (w + 1) + .5)) do w = w + 1 end
  w = w + .8
  for d = 0, 4 do -- triangle: 5 px base on the edge, tapering out to a point hooked toward the tip
    local half = 1.5 * (1 - d / 4.2)
    local cx, cy = x + px * (w - .5 + d) + ux * d * .7, y + py * (w - .5 + d) + uy * d * .7
    for q = -half, half, .25 do teeth:set(math.floor(cx + ux * q + .5), math.floor(cy + uy * q + .5)) end
  end
end
teeth:cut(wm)
local wtok = { r = { name = "wing" } }
wm:each(function(x, y)
  local k = K(x, y)
  local sv, t = wS[k] or 0, wT[k] or 0
  local col
  if sv < -.72 and t < .9 then col = WING[2]
  elseif sv < -.25 then col = WING[5]
  elseif sv < .45 then col = WING[4]
  else col = WING[3] end
  if t > .9 and sv > -.2 then col = WING[3] end
  c:put(x, y, col, wtok)
end)
-- veins sweeping from the thick upper vein down to the trailing edge
for _, v in ipairs({ { .12, .34 }, { .22, .48 }, { .34, .62 }, { .48, .76 }, { .62, .9 } }) do
  local ax, ay = O.bez(WP, v[1])
  local bx, by = O.bez(WP, v[2])
  ax, ay = ax - 2, ay - 2
  local w = wfn(v[2])
  bx, by = bx + w * .55, by + w * .55
  c:line({ { math.floor(ax + .5), math.floor(ay + .5) }, { math.floor(bx + .5), math.floor(by + .5) } }, 1):each(function(x, y)
    if wm:has(x, y) and (wS[K(x, y)] or 0) > -.72 then O.mark(c, { { x, y } }, WING[3]) end
  end)
end
for i = 8, 44 do -- thick vein along the upper edge
  local t = i / 50
  local x, y = O.bez(WP, t)
  local x2, y2 = O.bez(WP, t + .01)
  local tx, ty = x2 - x, y2 - y
  local l = math.sqrt(tx * tx + ty * ty)
  local px, py = ty / l, -tx / l
  if px + py > 0 then px, py = -px, -py end
  local w = wfn(t) - 1.2
  local vx, vy = math.floor(x + px * w + .5), math.floor(y + py * w + .5)
  if wm:has(vx, vy) then O.mark(c, { { vx, vy } }, WING[2]) end
end
O.mark(c, { {38,15},{39,14},{40,14},{36,17} }, WING[6]) -- sheen on the pale band
teeth:each(function(x, y) c:put(x, y, THORN[2], wtok) end)
teeth:each(function(x, y) if not teeth:has(x - 1, y) and not teeth:has(x, y - 1) then c:put(x, y, WING[3], wtok) end end)

-- nutlet body
local nut = c:ellipse(22, 41, 10.5, 9.5)
local nb = {}
nut:each(function(x, y) if (x - y) % 5 == 0 and y > 43 then nb[K(x, y)] = -1 end end) -- ribs
O.shade(c, nut, NUT, { sphere = { 20, 38, 12 }, amb = .15, wrap = .3, bias = nb, sep = NUT[2] })
-- stem nub where it once hung from the tree
O.dots(c, { {13,49},{12,50},{11,51} }, NUT[2]) O.dot(c, 12, 49, NUT[4])

-- face: brave brow, eyes, cheeks, set mouth
c:eyeLocked(14, 38)
c:eyeLocked(24, 38)
O.dots(c, { {14,36},{15,36},{16,35},{17,35} }, NUT[1])
O.dots(c, { {25,35},{26,35},{27,36},{28,36} }, NUT[1])
c:cheek(12, 44) c:cheek(29, 44)
O.dots(c, { {20,46},{21,46},{22,46},{23,45} }, NUT[1])

O.done(c, "samara-spin-yard", function(c)
  -- spin arcs (effect, no outline): cream and pale sky, broken dashes around the body
  local arcs = {
    { cx = 22, cy = 41, rx = 17, ry = 14, a0 = 140, a1 = 215, col = "#fff4d6" },
    { cx = 22, cy = 41, rx = 17, ry = 14, a0 = 330, a1 = 390, col = "#fff4d6" },
    { cx = 22, cy = 41, rx = 14, ry = 12, a0 = 100, a1 = 125, col = "#b9e2f5" },
  }
  for _, a in ipairs(arcs) do
    local n = 0
    for d = a.a0, a.a1, 2 do
      local r = math.rad(d)
      local x, y = math.floor(a.cx + math.cos(r) * a.rx + .5), math.floor(a.cy + math.sin(r) * a.ry + .5)
      n = n + 1
      if not c:get(x, y) and n % 6 ~= 0 then c:put(x, y, a.col) end
    end
  end
  c:sparkle(8, 22) -- rare glint
end)
