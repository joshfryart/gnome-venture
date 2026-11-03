-- ico-paw (final, Opus). A furry paw seen from below: four toe lobes fanned over a broad heel lobe, each with a
-- glossy pink bean pad, air between the toes.
-- Material: fur = 6-tone pillow light with strand ticks (dark root, lit tip) and a tufted edge; pads = waxy pink
-- with a fine pebbled texture, one bright specular each, a cool reflected light on the shade side, and AO in the fur
-- ring around each pad.
-- quirk: a little clover leaf is stuck to the heel fur.
local A = dofile("/home/user/gnome-venture/aseprite-source/v3/items/final/_helpers/_aA7_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, atan, cos, sin = math.floor, math.max, math.min, math.sqrt, math.abs, math.atan, math.cos, math.sin
local c = A.new("ico-paw")
local FU = { "#3a2220", "#5a3428", "#80502f", "#a66e3e", "#c69058", "#e4b47a" }
local PD = { "#6e2a48", "#a4406a", "#cc6288", "#ec8aa6", "#f9b0c2", "#ffd6e0" }
local BOUNCE = "#b88ac8"
local MO = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local PCX, PCY = 32, 33 -- palm centre (toes fan around it)

local function furLobe(cx, cy, rx, ry, ang, name, padScale, padDrop)
  local tk = A.tok(name)
  local m, n = A.oval(cx, cy, rx, ry, ang)
  -- tufted edge: little outward bumps at hashed spots on the rim (not on the inner sides)
  local add = HP.mask()
  m:edge():each(function(x, y)
    if X.hash(x, y, 5) > 0.8 and (x - cx) + (y - cy) > -4 then
      local dx, dy = x - cx, y - cy local l = sqrt(dx * dx + dy * dy) + 1e-6
      local ox, oy = floor(x + dx / l * 1.2 + .5), floor(y + dy / l * 1.2 + .5)
      if not m:has(ox, oy) then add:set(ox, oy) n[K(ox, oy)] = { dx / l * 0.8, dy / l * 0.8, 0.5 } end
    end
  end)
  m:add(add)
  local bias = {}
  local idx = A.shade(c, m, n, FU, { tok = tk, bias = bias, cuts = { 0.18, 0.36, 0.54, 0.72, 0.9 }, wrap = 0.15 })
  -- strand ticks: radial 2-px marks (dark root inward, lit tip outward)
  m:each(function(x, y)
    if X.hash(x, y, 9) > 0.86 then
      local dx, dy = x - cx, y - cy local l = sqrt(dx * dx + dy * dy) + 1e-6
      local ox, oy = floor(x + dx / l + .5), floor(y + dy / l + .5)
      if m:has(ox, oy) then A.step(c, idx, FU, x, y, -1, tk) A.step(c, idx, FU, ox, oy, 1, tk) end
    end
  end)
  -- pad
  local px, py = cx - (cx - PCX) * padDrop / 10, cy - (cy - PCY) * padDrop / 10
  return m, idx, tk, px, py
end

local function bean(m, cx, cy, rx, ry, ang, name, fur, fidx, ftk)
  local pm, pn = A.oval(cx, cy, rx, ry, ang)
  -- AO ring in the fur around the pad
  A.near(fur, pm, 1):each(function(x, y) A.step(c, fidx, FU, x, y, -2, ftk) end)
  local tk = A.tok(name)
  local idx = A.shade(c, pm, pn, PD, { tok = tk, cuts = { 0.1, 0.26, 0.44, 0.62, 0.84 }, wrap = 0.3 })
  -- pebbled texture
  pm:each(function(x, y) if X.hash(x, y, 21) > 0.9 and (idx[K(x, y)] or 0) >= 3 then A.step(c, idx, PD, x, y, -1, tk) end end)
  -- cool reflected light lower-right rim
  local rim = X.rim(pn)
  pm:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.72 then c:put(x, y, BOUNCE, tk) end end)
  -- specular
  local sx, sy = A.specAt(pm, pn, 30)
  c:put(sx, sy, A.CREAM, tk) c:put(sx + 1, sy, PD[6], tk)
  return pm
end

-- toes (outer pair lower and tilted out)
local toes = {
  { 13.5, 26, 5.6, 6.6, -0.5 },
  { 25, 15.5, 5.6, 7.0, -0.18 },
  { 39, 15.5, 5.6, 7.0, 0.18 },
  { 50.5, 26, 5.6, 6.6, 0.5 },
}
for i, t in ipairs(toes) do
  local m, idx, tk, px, py = furLobe(t[1], t[2], t[3], t[4], t[5], "toe" .. i, 1, 1.2)
  bean(m, px, py + 0.8, 3.2, 4.0, t[5], "bean" .. i, m, idx, tk)
end
-- heel lobe
local hm, hidx, htk = furLobe(32, 42, 14.5, 11, 0, "heel", 1, 0)
-- heel pad: rounded trilobe (heart turned upside down)
local pad = HP.mask()
local o1 = A.oval(32, 45.5, 8.2, 5.6, 0)
local o2 = A.oval(25.5, 41.5, 4.4, 4.6, 0)
local o3 = A.oval(38.5, 41.5, 4.4, 4.6, 0)
local o4 = A.oval(32, 40.5, 3.6, 3.6, 0)
pad:add(o1):add(o2):add(o3):add(o4)
local pn = X.pillow(pad, 3.2)
A.near(hm, pad, 1):each(function(x, y) A.step(c, hidx, FU, x, y, -2, htk) end)
local ptk = A.tok("heelpad")
local pidx = A.shade(c, pad, pn, PD, { tok = ptk, cuts = { 0.1, 0.26, 0.44, 0.62, 0.84 }, wrap = 0.3 })
pad:each(function(x, y) if X.hash(x, y, 21) > 0.9 and (pidx[K(x, y)] or 0) >= 3 then A.step(c, pidx, PD, x, y, -1, ptk) end end)
-- the two dimples between the lobes on top
c:put(29, 38, PD[2], ptk) c:put(35, 38, PD[2], ptk) c:put(29, 39, PD[3], ptk) c:put(35, 39, PD[3], ptk)
local rim = X.rim(pn)
pad:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.6 and y > 44 then c:put(x, y, BOUNCE, ptk) end end)
c:put(24, 40, A.CREAM, ptk) c:put(25, 40, PD[6], ptk) c:put(24, 41, PD[6], ptk)

-- quirk: a clover leaf stuck to the heel fur (lower right)
local ct = A.tok("clover")
A.map(c, {
  ".ab.cb",
  "abbcbb",
  ".bdbd.",
  "..ee..",
  "...e..",
}, 39, 49, { a = MO[4], b = MO[3], c = MO[4], d = MO[2], e = MO[1] }, ct)
A.save(c, "ico-paw")
