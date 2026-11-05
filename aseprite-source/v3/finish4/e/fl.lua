---------------------------------------------------------------- flourishes (384x96 = 4 frames of 96x96 sparkle ring, transparent)
local F = {}
local FC = { ox = 0 }
local function fput(x, y, col) x = floor(x + .5); y = floor(y + .5); if x >= 0 and x < 96 then put(FC.ox + x, y, col) end end
local function fmask(m, ox, oy, col) m:each(function(x, y) fput(x + ox, y + oy, col) end) end
-- 4-point star of arm length n (n>=1), colours: tip/arm/centre, dark outline
local function star4(x, y, n, arm, centre, deep, diag)
  x, y = floor(x + .5), floor(y + .5)
  local m = HP.mask()
  m:set(0, 0)
  for k = 1, n do m:set(k, 0); m:set(-k, 0); m:set(0, k); m:set(0, -k) end
  if diag then m:set(1, 1); m:set(-1, 1); m:set(1, -1); m:set(-1, -1) end
  fmask(m:grow(1), x, y, deep)
  fmask(m, x, y, arm)
  fput(x, y, centre); if n >= 2 then fput(x - 1, y, centre); fput(x, y - 1, centre) end
end
local function diamond(x, y, rx, ry, base, hi, deep, shade)
  x, y = floor(x + .5), floor(y + .5)
  local m = HP.mask()
  for j = -ry, ry do local w = floor(rx * (1 - abs(j) / (ry + .5)) + .5); for i = -w, w do m:set(i, j) end end
  fmask(m:grow(1), x, y, deep)
  m:each(function(i, j) fput(x + i, y + j, (i + j < -rx * .3) and hi or ((i + j > rx * .3) and shade or base)) end)
end
local function dot(x, y, r, base, hi, deep)
  x, y = floor(x + .5), floor(y + .5)
  local m = HP.ellipse(0, 0, r, r)
  fmask(m:grow(1), x, y, deep); fmask(m, x, y, base); fput(x - 1, y - 1, hi)
end
local function leafsp(x, y, a, len, wid, base, hi, deep, shade)
  local pts = {}
  for i, p in ipairs({ {0, 0}, {len * .4, -wid}, {len, 0}, {len * .4, wid} }) do pts[i] = { p[1] * cos(a) - p[2] * sin(a), p[1] * sin(a) + p[2] * cos(a) } end
  local m = HP.poly(pts)
  local ox, oy = floor(x + .5), floor(y + .5)
  fmask(m:grow(1), ox, oy, deep)
  m:each(function(i, j) fput(ox + i, oy + j, ((i * cos(a - pi / 2) + j * sin(a - pi / 2)) > 0) and shade or base) end)
  fput(ox + floor(len * .35 * cos(a)), oy + floor(len * .35 * sin(a)), hi)
end

-- ring generator: N slots, step per frame, radius pulse
local function ringFrames(o)
  for f = 0, 3 do
    FC.ox = f * 96
    local rot = f * o.step
    local rr = o.r + o.pulse[f + 1]
    o.draw(f, rot, rr)
  end
end

function F.common()
  local P = { hi = "#fff4d6", base = "#e9e2c4", deep = "#8b7a5a", shade = "#c4b98e" }
  ringFrames({ step = (2 * pi / 6) / 4, r = 36, pulse = { 0, 1, 2, 1 }, draw = function(f, rot, rr)
    for i = 0, 5 do
      local a = rot + i * 2 * pi / 6
      local x, y = 48 + rr * cos(a), 48 + rr * sin(a)
      local tw = ((i + f) % 3 == 0)
      if tw then star4(x, y, 2, P.base, P.hi, P.deep) else dot(x, y, 2, P.base, P.hi, P.deep) end
    end
    for i = 0, 5 do
      local a = rot + (i + .5) * 2 * pi / 6
      fput(48 + (rr - 5) * cos(a), 48 + (rr - 5) * sin(a), P.hi)
    end
  end })
end
function F.uncommon()
  local G = { hi = "#d6f08a", base = "#7ab55c", shade = "#4f8f44", deep = "#25503e" }
  ringFrames({ step = (2 * pi / 8) / 4, r = 36, pulse = { 0, 1, 2, 1 }, draw = function(f, rot, rr)
    for i = 0, 7 do
      local a = rot + i * 2 * pi / 8
      local x, y = 48 + rr * cos(a), 48 + rr * sin(a)
      leafsp(x - cos(a + pi / 2) * 4, y - sin(a + pi / 2) * 4, a + pi / 2 - .35, 10, 3, G.base, G.hi, G.deep, G.shade)
    end
    for i = 0, 3 do
      local a = rot + (i * 2 + 1) * 2 * pi / 8
      local x, y = 48 + (rr + 1) * cos(a), 48 + (rr + 1) * sin(a)
      if (i + f) % 2 == 0 then star4(x, y, 2, "#fff4d6", "#fffbe8", "#8a7a4a") else dot(x, y, 2, "#ffe38a", "#fff4d6", "#9a6a2a") end
    end
  end })
end
function F.rare()
  local B = { hi = "#e8fcff", base = "#a9d6ea", shade = "#5aa0d4", deep = "#2a4a7a" }
  local V = { hi = "#e0d0ff", base = "#a98ae0", shade = "#6c52b0", deep = "#2e2a66" }
  ringFrames({ step = (2 * pi / 10) / 4, r = 37, pulse = { 0, 1, 2, 1 }, draw = function(f, rot, rr)
    for i = 0, 9 do
      local a = rot + i * 2 * pi / 10
      local x, y = 48 + rr * cos(a), 48 + rr * sin(a)
      local P = (i % 2 == 0) and B or V
      local big = (i % 2 == 0)
      if math.abs(cos(a)) > math.abs(sin(a)) then diamond(x, y, 2, big and 5 or 4, P.base, P.hi, P.deep, P.shade) else diamond(x, y, big and 5 or 4, 2, P.base, P.hi, P.deep, P.shade) end
    end
    for i = 0, 4 do
      local a = rot + (i * 2 + 1) * 2 * pi / 10
      local x, y = 48 + (rr - 6) * cos(a), 48 + (rr - 6) * sin(a)
      if (i + f) % 2 == 0 then star4(x, y, 3, B.hi, "#ffffff" == "" and "" or "#fffdf0", B.deep, true) else star4(x, y, 1, B.base, B.hi, B.deep) end
    end
  end })
end
function F.legendary()
  local G = { hi = "#fff2a0", base = "#f5c43a", shade = "#e8a317", deep = "#7a4a14" }
  ringFrames({ step = (2 * pi / 12) / 4, r = 36, pulse = { 0, 1, 3, 1 }, draw = function(f, rot, rr)
    for i = 0, 11 do                       -- rays
      local a = rot + i * 2 * pi / 12
      local long = (i % 2 == 0)
      local x, y = 48 + (rr - 3) * cos(a), 48 + (rr - 3) * sin(a)
      local ex, ey = 48 + (rr + (long and 8 or 3)) * cos(a), 48 + (rr + (long and 8 or 3)) * sin(a)
      local m = HP.line({ { 0, 0 }, { ex - x, ey - y } }, 2)
      fmask(m:grow(1), floor(x + .5), floor(y + .5), G.deep)
      fmask(m, floor(x + .5), floor(y + .5), long and G.base or G.shade)
    end
    for i = 0, 11 do
      local a = rot + i * 2 * pi / 12
      if i % 2 == 0 then dot(48 + (rr - 8) * cos(a), 48 + (rr - 8) * sin(a), 1, G.hi, G.hi, G.deep) end
    end
    for i = 0, 3 do                         -- four big stars between
      local a = rot + (i * 3 + 1.5) * 2 * pi / 12
      local x, y = 48 + (rr + 1) * cos(a), 48 + (rr + 1) * sin(a)
      star4(x, y, ((i + f) % 2 == 0) and 4 or 2, G.base, "#fffbe0", G.deep, true)
    end
  end })
end

