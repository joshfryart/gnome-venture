-- frames.lua : frame-<size>-<me|foe|env> (rim and owner decoration on the body perimeter) and overlay-<size>-<picked|faded|now>
local D = debug.getinfo(1, "S").source:match("@(.*/)")
local L = dofile(D .. "lib47.lua")
local F = {}
local function pat(i, len) local j = i; if i >= len / 2 then j = len - 1 - i end; return (j % 3) < 2 end

local function ring2(c, nrings, col, cv)  -- non-rim body pixels within nrings steps of the rim
  for y = 0, c.BH - 1 do for x = 0, c.BW - 1 do
    if L.inBody(c, x, y) and not L.isRim(c, x, y) then
      local best = 99
      for dy = -nrings, nrings do for dx = -nrings, nrings do
        if math.abs(dx) + math.abs(dy) <= nrings and L.isRim(c, x + dx, y + dy) then best = math.min(best, math.abs(dx) + math.abs(dy)) end
      end end
      if best <= nrings then cv:set(c.T + x, c.T + y, col) end
    end
  end end
end

function F.frame(c, owner)
  local rim, band, thorns = L.cv(c.W, c.H), L.cv(c.W, c.H), L.cv(c.W, c.H)
  local hand = c.name == "hand"
  for y = 0, c.BH - 1 do for x = 0, c.BW - 1 do
    if L.isRim(c, x, y) then
      local col = L.INK
      if owner == "env" then
        local i, len
        if y < c.R and (x < c.R or x >= c.BW - c.R) or y >= c.BH - c.R and (x < c.R or x >= c.BW - c.R) then i = nil
        elseif y == 0 or y == c.BH - 1 then i, len = x, c.BW else i, len = y, c.BH end
        if i and not pat(i, len) then col = 0x9aa6b5 end
      end
      rim:set(c.T + x, c.T + y, col)
    end
  end end
  if owner == "foe" then
    ring2(c, hand and 2 or 1, 0xc8402e, band)
    local RED2, BONE, TOOTH = 0x8e2a1c, 0xf4d6a8, 0xd9b27c
    local pos = hand and { 7, 17, 26 } or { 5, 11 }
    local wmax = hand and 9 or 5
    for _, p0 in ipairs(pos) do for _, cx in ipairs({ p0, c.BW - 1 - p0 }) do
      local rows = (wmax + 1) // 2
      for r = 0, rows - 1 do
        local w = wmax - 2 * r
        for k = -(w - 1) // 2, (w - 1) // 2 do
          local col = (k == (w - 1) // 2 or r == rows - 1) and TOOTH or BONE
          if L.inBody(c, cx + k, 1 + r) and not L.isRim(c, cx + k, 1 + r) then thorns:set(c.T + cx + k, c.T + 1 + r, col) end
          if L.inBody(c, cx + k, c.BH - 2 - r) and not L.isRim(c, cx + k, c.BH - 2 - r) then thorns:set(c.T + cx + k, c.T + c.BH - 2 - r, col) end
        end
      end
    end end
  elseif owner == "env" then
    ring2(c, hand and 2 or 1, 0x8b8f96, band)
  end
  local tex
  if owner == "env" then   -- faint ground texture: sparse darker / lighter felt flecks
    tex = L.cv(c.W, c.H)
    for y = 2, c.BH - 3 do for x = 2, c.BW - 3 do
      local edge = math.min(x, y, c.BW - 1 - x, c.BH - 1 - y)
      if L.inBody(c, x, y) and edge > 2 and math.abs(edge - c.stitchIn) > 1 and not L.reserved(c, x, y, 1) then
        local h = ((x * 83492791) ~ (y * 73856093) ~ (x * y * 19349663)) % 1000
        if h < 45 then tex:set(c.T + x, c.T + y, (h % 2 == 0) and 0x58554a or 0x8c8777) end
      end
    end end
  end
  local layers = { { name = "rim", cv = rim } }
  if tex then table.insert(layers, 1, { name = "ground-texture", cv = tex }) end
  if owner ~= "me" then table.insert(layers, 1, { name = "band", cv = band }) end
  if owner == "foe" then table.insert(layers, 2, { name = "thorns", cv = thorns }) end
  -- order bottom to top: band, thorns, rim
  L.save(D .. "../" .. c.name .. "/frame-" .. c.name .. "-" .. owner, c.W, c.H, layers)
end

function F.overlay(c, kind)
  local layers = {}
  if kind == "picked" then
    local gold, edge = L.cv(c.W, c.H), L.cv(c.W, c.H)
    for y = 0, c.H - 1 do for x = 0, c.W - 1 do
      local d = L.distBody(c, x, y)
      if d > 0 and d <= c.ring then
        local steps = c.ring == 3 and { 0xffe58a, 0xf6c453, 0xe0922a } or { 0xffe58a, 0xf6c453, 0xe8a317, 0xc9741c }
        gold:set(x, y, steps[math.min(#steps, math.floor(d - 0.01) + 1)])
      elseif d > c.ring and d <= c.ring + 1 then edge:set(x, y, L.INK) end
    end end
    layers = { { name = "ink-edge", cv = edge }, { name = "gold-ring", cv = gold } }
  elseif kind == "faded" then
    local veil = L.cv(c.W, c.H)
    for y = 0, c.BH - 1 do for x = 0, c.BW - 1 do if L.inBody(c, x, y) and (x + y) % 2 == 0 then veil:set(c.T + x, c.T + y, L.INK) end end end
    layers = { { name = "veil", cv = veil } }
  else
    local a, b, cc, sp = L.cv(c.W, c.H), L.cv(c.W, c.H), L.cv(c.W, c.H), L.cv(c.W, c.H)
    for y = 0, c.H - 1 do for x = 0, c.W - 1 do
      local d = L.distBody(c, x, y)
      if d > 0 and d <= 1.5 then a:set(x, y, L.CREAM)
      elseif d > 1.5 and d <= (c.name == "hand" and 4.2 or 3.2) then if (x + y) % 3 ~= 2 then b:set(x, y, d <= 2.5 and 0xffe58a or L.GOLD) end
      elseif d > 3.2 and d <= (c.name == "hand" and 6.4 or 5.2) and (x % 2 == 0 and y % 2 == 0) then cc:set(x, y, 0xc9741c) end
    end end
    local k = c.name == "hand" and 3 or 2
    for _, p in ipairs({ { c.T - 1, c.T - 1 }, { c.T + c.BW, c.T - 1 }, { c.T - 1, c.T + c.BH }, { c.T + c.BW, c.T + c.BH } }) do
      sp:set(p[1], p[2], L.CREAM)
      for r = 1, k do for _, o in ipairs({ { r, 0 }, { -r, 0 }, { 0, r }, { 0, -r } }) do sp:set(p[1] + o[1] * 1, p[2] + o[2], r == k and L.GOLD or L.CREAM) end end
    end
    layers = { { name = "dots", cv = cc }, { name = "glow", cv = b }, { name = "halo", cv = a }, { name = "sparkle", cv = sp } }
  end
  L.save(D .. "../" .. c.name .. "/overlay-" .. c.name .. "-" .. kind, c.W, c.H, layers)
end
return F
