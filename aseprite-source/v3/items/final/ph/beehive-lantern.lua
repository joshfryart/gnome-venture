-- beehive-lantern (final pass, Opus). A slim hexagonal hanging lantern turned hive: iron hanging ring, flared brass
-- cap with a finial, glass panels in a brass frame with a glowing honeycomb comb inside, brass base plate with a round
-- entrance and a drop finial underneath.
-- Material: brass per-pixel cylinder light with a bevelled bright edge and specular streak; iron ring with a lit
-- top and dark inner eye; glass with a bright rim and a diagonal glare; the comb is emissive (brightest at the core,
-- dimmer on the side panels, dark wax walls, a few pale capped cells); AO under the cap eaves and above the base.
-- quirk: a little moth has landed on the right-hand glass, drawn to the glow.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local norm = A.norm
local c = A.new("beehive-lantern")
local CX = 31.5
local BR = { "#3e2630", "#6e4428", "#a2682a", "#d29a36", "#f0c85c", "#fff0b0" }
local IR = { "#262335", "#3a3b58", "#55577a", "#7a7c98", "#aaa9bf", "#e2e0ea" }
local HO = { "#7a2e22", "#b4481c", "#de701e", "#f6a028", "#ffcc4a", "#ffeaa0" }

-- vertical-cylinder lit mask (x across, optional upward tilt)
local function vlit(m, ramp, hw, tilt, o)
  local n = {}
  m:each(function(x, y)
    local sx = max(-0.97, min(0.97, (x - CX) / (hw + 0.5)))
    n[K(x, y)] = { norm(sx, tilt or 0, sqrt(1 - sx * sx)) }
  end)
  return A.tone(c, m, n, ramp, o), n
end

-- hanging ring (iron)
local ring = c:ellipse(31.5, 9.5, 3.5, 3.5):cut(c:ellipse(31.5, 9.5, 1.5, 1.5))
local rn = {}
ring:each(function(x, y) local dx, dy = x - 31.5, y - 9.5 local l = sqrt(dx*dx + dy*dy) + 0.01
  rn[K(x, y)] = { norm(dx / l * 0.8, dy / l * 0.8, 0.6) } end)
A.tone(c, ring, rn, IR, { amb = 0.1 })
-- finial knob under the ring
local fin = c:rect(30, 13, 33, 15)
vlit(fin, BR, 2)
c:put(30, 13, BR[6])

-- cap: flared brass roof
local cap = HP.mask()
for y = 16, 22 do
  local t = (y - 16) / 6
  local hw = 3 + 9.5 * t ^ 1.6
  if y == 22 then hw = 13 end
  for x = floor(CX - hw), floor(CX + hw + 1) do if abs(x - CX) <= hw then cap:set(x, y) end end
end
local capN = {}
cap:each(function(x, y)
  local t = (y - 16) / 6
  local hw = 3 + 9.5 * t ^ 1.6 + 0.5
  local sx = max(-0.97, min(0.97, (x - CX) / hw))
  capN[K(x, y)] = { norm(sx * 0.9, -0.75 + 0.5 * t, sqrt(1 - sx * sx * 0.8)) }
end)
local cidx = A.tone(c, cap, capN, BR, { amb = 0.08 })
-- eave lip: bright bevel row, dark underside
for x = 19, 44 do if cap:has(x, 22) then c:put(x, 22, x < 36 and BR[4] or BR[3]) end end
for x = 19, 44 do if cap:has(x, 21) and x < 30 then c:put(x, 21, BR[5]) end end
-- cap ribs (hexagonal roof edges)
for y = 17, 21 do
  local t = (y - 16) / 6
  local hw = 3 + 9.5 * t ^ 1.6
  local ox = floor(hw * 0.45 + 0.5)
  c:put(floor(CX - ox), y, BR[6]) c:put(floor(CX + ox + 1), y, BR[2])
end
c:put(27, 18, "#fff4d6")

-- body: frame rails + bars, glass panels with the comb
local Y0, Y1 = 23, 45
local L0, R1 = 20, 43
local bars = { { 20, 21 }, { 25, 26 }, { 37, 38 }, { 42, 43 } }
local panels = { { 22, 24, -1 }, { 27, 36, 0 }, { 39, 41, -2 } }   -- x0, x1, glow bias
-- honeycomb: voronoi cells on a hex lattice (flat-topped, wider than tall)
local function cellId(x, y)
  local best, id = 1e9, 0
  for j = -1, 8 do for i = -1, 6 do
    for o = 0, 1 do
      local cx, cy = 18 + 6 * i + o * 3, Y0 + 3 + 5 * j + o * 2.5
      local q = (x - cx) ^ 2 + ((y - cy) * 1.25) ^ 2
      if q < best then best, id = q, (j * 20 + i) * 2 + o end
    end
  end end
  return id
end
-- comb (emissive)
for _, p in ipairs(panels) do
  for y = Y0 + 2, Y1 - 2 do for x = p[1], p[2] do
    local wall = cellId(x, y) ~= cellId(x + 1, y) or cellId(x, y) ~= cellId(x, y + 1)
    local dx, dy = (x - CX) / 9, (y - 34) / 11
    local e = max(0, 1 - sqrt(dx*dx + dy*dy))
    local i
    if wall then i = 2 + floor(e * 2.2 + 0.3) else i = 4 + floor(e * 2.3 + 0.2) end
    i = i + p[3]
    if y == Y0 + 2 then i = i - 1 end             -- shadow of the top rail
    i = max(1, min(6, i))
    c:put(x, y, HO[i])
  end end
end
-- a few pale wax-capped cells near the bottom of the front
for _, q in ipairs{ { 28, 41 }, { 34, 41 } } do
  for yy = 0, 1 do for xx = 0, 1 do c:put(q[1] + xx, q[2] + yy, yy == 0 and "#ffe6a8" or "#f2c070") end end
end
-- glass: bright rim along the top of each panel + diagonal glare on the front pane
for _, p in ipairs(panels) do for x = p[1], p[2] do c:put(x, Y0 + 2, p[3] == 0 and HO[3] or "#f0b850") end end
for y = Y0 + 3, Y0 + 12 do
  local x = 35 - (y - Y0 - 3)
  if x >= 27 then c:put(x, y, "#fff4d6") if x - 1 >= 27 then c:put(x - 1, y, "#ffe6a8") end end
end
-- rails
local rails = c:rect(L0, Y0, R1, Y0 + 1):add(c:rect(L0, Y1 - 1, R1, Y1))
vlit(rails, BR, 12, -0.3)
for x = L0, R1 do c:put(x, Y0, x < 34 and BR[5] or BR[4]) end
-- bars
for bi, b in ipairs(bars) do
  local m = c:rect(b[1], Y0, b[2], Y1)
  for y = Y0, Y1 do
    local lit = ({ 5, 4, 3, 2 })[bi]
    c:put(b[1], y, BR[lit]) c:put(b[2], y, BR[max(1, lit - 1)])
  end
end
-- specular streak on the front-left bar
for y = Y0 + 4, Y0 + 9 do c:put(25, y, BR[6]) end
-- AO under the eaves on the top rail
for x = L0, R1 do c:put(x, Y0, BR[3]) end
for x = L0, 33 do c:put(x, Y0 + 1, BR[5]) end

-- base plate + entrance + drop finial
local base = HP.mask()
for y = 46, 49 do
  local hw = (y <= 47) and 13 or (y == 48 and 12 or 10)
  for x = floor(CX - hw), floor(CX + hw + 1) do if abs(x - CX) <= hw then base:set(x, y) end end
end
local bidx = vlit(base, BR, 13, 0.25)
for x = 19, 44 do if base:has(x, 46) then c:put(x, 46, x < 34 and BR[5] or BR[4]) end end
for x = 19, 44 do if base:has(x, 47) then c:put(x, 47, BR[2]) end end        -- groove
-- round entrance on the base front
c:put(31, 48, "#2a1520") c:put(32, 48, "#2a1520") c:put(31, 49, "#3a1d24") c:put(32, 49, "#2a1520")
local drop = c:rect(30, 50, 33, 51):add(c:rect(31, 52, 32, 53))
vlit(drop, BR, 2)
c:put(31, 50, BR[6])

-- quirk: a moth on the right glass
local moth = {
  "Kw...wK",
  "wWwKwWw",
  "wWWbWWw",
  ".wwbww.",
  "..w.w..",
}
local MC = { K = "#5a4466", w = "#b8a4c8", W = "#e8dcee", b = "#5a4466" }
for yy, row in ipairs(moth) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if MC[ch] then c:put(37 + xx, 33 + yy - 1, MC[ch]) end end end
A.save(c, "beehive-lantern")
