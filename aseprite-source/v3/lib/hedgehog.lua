-- hedgehog.lua: shared hedgehog head/back for folk + npc hedgehogs (2026-11-05 redesign).
-- Clear animal read: dome of 3-tone spines in staggered rows (lit upper-left), small round ears,
-- pale tapered face ending in a pointed snout with a dark nose, small bead eyes.
-- local HH = dofile(<v3>/lib/hedgehog.lua)
-- HH.head(c, { cx=, cy=, s=1 (sprite) | 1.4 (portrait), SP=ramp, FACE=ramp, blink=bool, ears=bool })
-- HH.back(c, cx, cy, rx, ry, SP [, a0, a1])  spine mound (draw before the body)
local HH = {}
local INK = "#2b1c26"
local NOSE, NOSEHI, NOSESH = "#3e2634", "#8c6a7c", "#2f1d2a"
local EARIN = "#d98a86"
local function rnd(v) return math.floor(v + 0.5) end

-- spine silhouette: ellipse plus outward tips over angles a0..a1 (deg, 0 = right, 90 = down)
local function dome(c, cx, cy, rx, ry, a0, a1, step, len, half)
  local m = c:ellipse(cx, cy, rx, ry)
  local a = a0
  while a <= a1 + 0.01 do
    local r, r1, r2 = math.rad(a), math.rad(a - half), math.rad(a + half)
    m:add(c:poly{ { cx + math.cos(r1) * rx * 0.9, cy + math.sin(r1) * ry * 0.9 },
      { cx + math.cos(r) * (rx + len), cy + math.sin(r) * (ry + len) },
      { cx + math.cos(r2) * rx * 0.9, cy + math.sin(r2) * ry * 0.9 } })
    a = a + step
  end
  return m
end

-- paint a spine field: shaded base, then staggered rows of little spines (tip hi/base, root deep)
local function texture(c, m, cx, cy, rx, ry, SP, clip, sp)
  local function ok(x, y) return m:has(x, y) and (not clip or not clip:has(x, y)) end
  m:each(function(x, y)
    if clip and clip:has(x, y) then return end
    local nx, ny = (x - cx) / (rx + 2), (y - cy) / (ry + 2)
    local l = -(nx * 0.65 + ny * 0.75)
    c:put(x, y, l > 0.25 and SP.base or (l > -0.6 and SP.shade or SP.deep))
  end)
  sp = sp or 3.2
  local rows = math.max(2, math.floor(math.max(rx, ry) / sp) + 1)
  for i = 1, rows do
    local f = (i - 0.35) / rows
    local circ = 2 * math.pi * f * (rx + ry) / 2
    local n = math.max(3, math.floor(circ / sp))
    for j = 0, n - 1 do
      local a = (j + (i % 2) * 0.5) / n * 2 * math.pi + i * 0.3
      local x, y = cx + math.cos(a) * rx * f, cy + math.sin(a) * ry * f
      local dx, dy = math.cos(a) * 1.0, math.sin(a) * 1.0 - 0.6
      local d = math.sqrt(dx * dx + dy * dy) dx, dy = dx / d, dy / d
      local l = -((x - cx) / rx * 0.65 + (y - cy) / ry * 0.75)
      local tip = l > -0.1 and SP.hi or (l > -0.6 and SP.base or SP.shade)
      local mid = l > -0.1 and SP.base or (l > -0.6 and SP.shade or SP.deep)
      local seen = {}
      local function pt(px, py, hex) px, py = rnd(px), rnd(py)
        local k = px .. "," .. py if seen[k] then return end seen[k] = true
        if ok(px, py) then c:put(px, py, hex) end end
      pt(x + dx * 1.2, y + dy * 1.2, tip)
      pt(x, y, mid)
      pt(x - dx * 1.2, y - dy * 1.2, SP.deep)
      -- shadow gap under the spine (light comes from upper-left)
      pt(x + 1, y + 1, SP.deep)
    end
  end
  -- outer tips: light tip on the lit side
  m:each(function(x, y)
    if clip and clip:has(x, y) then return end
    if not m:has(x, y - 1) and not m:has(x - 1, y) and not m:has(x + 1, y) then
      local l = -((x - cx) / rx * 0.65 + (y - cy) / ry * 0.75)
      c:put(x, y, l > -0.2 and SP.hi or SP.base)
    end
  end)
  -- bottom rim
  m:each(function(x, y) if not m:has(x, y + 1) and (not clip or not clip:has(x, y)) then c:put(x, y, SP.deep) end end)
end
HH.texture = texture

function HH.back(c, cx, cy, rx, ry, SP, a0, a1, o)
  o = o or {}
  local m = dome(c, cx, cy, rx, ry, a0 or 160, a1 or 380, o.step or 13, o.len or 3.5, o.half or 6)
  if o.clip then m:clip(o.clip) end
  texture(c, m, cx, cy, rx, ry, SP, nil, o.sp)
  return m
end

function HH.head(c, o)
  local s, cx, cy = o.s or 1, o.cx, o.cy
  local SP, FACE = o.SP, o.FACE
  local function S(v) return v * s end
  -- spine dome over the head top and sides
  local rx, ry = S(14), S(11.5)
  local dm = dome(c, cx, cy - S(1), rx, ry, 165, 375, o.step or 13, S(4.4), o.half or 6)
  dm:clip(c:rect(cx - 60, cy - 60, cx + 60, cy + S(o.chin or 5.5)))
  -- face mask (pale), widest at the cheeks, tapering to the snout
  local face = c:ellipse(cx, cy + S(3.2), S(8), S(5.3))
  face:add(c:poly{ { cx - S(7), cy + S(4.5) }, { cx + S(7), cy + S(4.5) }, { cx + S(1.3), cy + S(12.4) }, { cx - S(1.3), cy + S(12.4) } })
  -- brow: spines come down into a soft widow's peak
  local peak = c:poly{ { cx - S(6), cy - S(3.5) }, { cx + S(6), cy - S(3.5) }, { cx, cy + S(1) } }
  texture(c, dm, cx, cy - S(1), rx, ry, SP, face, o.sp or (s > 1.2 and 3.4 or 3.0))
  -- ears: small round, on the dome edge
  if o.ears ~= false then
    for _, sg in ipairs{ -1, 1 } do
      local ex, ey = cx + sg * S(10.5), cy + S(0.5)
      local em = c:ellipse(ex, ey, S(2.4), S(2.2))
      c:fillMask(em, FACE.shade)
      c:fillMask(c:ellipse(ex + sg * S(0.2), ey + S(0.4), S(1.2), S(1.1)), EARIN)
      em:each(function(x, y) if not em:has(x, y - 1) then c:put(x, y, sg < 0 and FACE.base or FACE.shade) end end)
      em:each(function(x, y) if not em:has(x, y + 1) or not em:has(x - sg, y) and not dm:has(x - sg, y) then c:put(x, y, FACE.deep) end end)
    end
  end
  c:part(face, FACE, { band = s > 1.2 and 2 or 1, nopop = true, inner = false })
  -- spines overlap the brow
  local pk = peak:copy():clip(face)
  pk:each(function(x, y) c:put(x, y, ((x + y) % 3 == 0) and SP.hi or SP.base) end)
  pk:each(function(x, y) if not pk:has(x, y + 1) then c:put(x, y, SP.deep) end end)
  -- face edge against spines: deep line
  face:each(function(x, y)
    if not face:has(x, y - 1) and dm:has(x, y - 1) then c:put(x, y - 1, SP.deep) end
  end)
  -- muzzle highlight down the snout bridge (lit from upper-left)
  for i = 0, S(2) do
    local y = rnd(cy + S(7) + i)
    local x = rnd(cx - S(1.6) - (S(2) - i) * 0.3)
    if face:has(x, y) then c:put(x, y, FACE.hi) end
  end
  -- nose: dark, at the snout tip, slightly wider than the tip
  local ny = cy + S(12.2)
  local nose = c:ellipse(cx, ny, S(2.2), S(1.6))
  c:fillMask(nose, NOSE)
  nose:each(function(x, y) if not nose:has(x, y + 1) then c:put(x, y, NOSESH) end end)
  c:put(rnd(cx - S(1.0)), rnd(ny - S(0.8)), NOSEHI)
  if s > 1.2 then c:put(rnd(cx - S(1.0)) + 1, rnd(ny - S(0.8)), NOSEHI) end
  -- mouth
  if false then
    local my = rnd(ny + S(2.2))
    c:put(rnd(cx), my - 1, FACE.deep)
    c:put(rnd(cx) - 1, my, FACE.deep) c:put(rnd(cx) + 1, my, FACE.deep)
  end
  -- eyes: small beads beside the snout
  local ey = rnd(cy + S(2.6))
  for _, sg in ipairs{ -1, 1 } do
    local ex = rnd(cx + sg * S(4.2) - 0.5)
    if o.blink then
      c:put(ex - 1, ey + 1, INK) c:put(ex, ey + 1, INK) c:put(ex + 1, ey + 1, INK)
    elseif s > 1.2 then
      for yy = 0, 2 do for xx = -1, 1 do c:put(ex + xx, ey + yy, INK) end end
      c:put(ex - 1, ey, "#f4e6d6") c:put(ex, ey - 1 + 1, INK)
      c:put(ex + 1, ey + 2, "#4a3448")
    else
      c:put(ex, ey, "#f4e6d6") c:put(ex + 1, ey, INK) c:put(ex, ey + 1, INK) c:put(ex + 1, ey + 1, INK)
    end
  end
  -- cheeks
  local by = rnd(cy + S(6.6))
  for _, sg in ipairs{ -1, 1 } do
    local bx = rnd(cx + sg * S(6.2) - 0.5)
    c:put(bx, by, "#e8968a") c:put(bx + 1, by, "#e8968a")
  end
  return { dome = dm, face = face, noseY = ny }
end

return HH
