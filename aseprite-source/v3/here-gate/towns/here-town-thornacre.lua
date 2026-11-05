-- Hearth Pop v3 · gate-view town: Thornacre Savanna (golden sunset), 480x270 native
local ROOT = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(ROOT .. "/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or (ROOT .. "/v3/here-gate/towns/")
local NAME = "here-town-thornacre"
local W, H, HZ, VX, VY = 480, 270, 112, 240, 112
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, abs, sin = math.floor, math.abs, math.sin

local function hash(x, y, s) local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return n - floor(n) end
local function P(p) return c:poly(p) end
local function R(a, b, cc, d) return c:rect(a, b, cc, d) end
local function E(a, b, cc, d) return c:ellipse(a, b, cc, d) end
local function L(p, w) return c:line(p, w) end
local function fill(m, h) c:fillMask(m, h) return m end
local function put(x, y, h) c:put(floor(x), floor(y), h) end
local function edge(m, h) c:edgeIn(m, h) end
local function bbox(m)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  m:each(function(x, y) if x < x0 then x0 = x end if x > x1 then x1 = x end if y < y0 then y0 = y end if y > y1 then y1 = y end end)
  return x0, y0, x1, y1
end
-- tone a mask by light from upper-left; ramp = {hi, base, mid, shade, deep(edge)}
local function tone(m, rp, seed, o)
  o = o or {}
  local x0, y0, x1, y1 = bbox(m)
  local wx, wy = math.max(1, x1 - x0), math.max(1, y1 - y0)
  local ky = o.ky or 0.35
  m:each(function(x, y)
    local v = (x - x0) / wx + (y - y0) / wy * ky
    if o.cyl then v = (x - x0) / wx end
    local i = v < 0.22 and 1 or v < 0.6 and 2 or v < 0.85 and 3 or 4
    local hh = hash(x, y, seed or 1)
    if o.tex ~= false then
      if hh < (o.dens or 0.1) then i = math.min(4, i + 1) elseif hh > 1 - (o.dens or 0.1) * 0.6 then i = math.max(1, i - 1) end
    end
    c:put(x, y, rp[i])
  end)
  if rp[5] then edge(m, rp[5]) end
  return m
end

-------------------------------------------------------------------- SKY
local sky = {
  { 0, "#3a2858", "#46306a" }, { 14, "#4c2f68", "#5a3876" }, { 26, "#6a3672", "#7a407c" },
  { 38, "#8c4074", "#9c4c7c" }, { 50, "#b04e6c", "#c05c70" }, { 61, "#cf6260", "#dc7066" },
  { 71, "#e6784e", "#ee8a58" }, { 80, "#f0904a", "#f6a256" }, { 88, "#f6a84a", "#fab858" },
  { 95, "#fabe5a", "#fcca68" }, { 102, "#fcd274", "#fdde88" }, { 108, "#fde294", "#fde294" },
}
local function skyAt(y) local r = sky[1] for _, s in ipairs(sky) do if y >= s[1] then r = s end end return r end
for y = 0, HZ do local s = skyAt(y) for x = 0, W - 1 do c:put(x, y, s[2]) end end
-- sun rays fanning from the low sun behind the far hills (left)
local SX, SY = 112, 118
for i = 0, 7 do
  local a0 = math.pi * (1.06 + i * 0.12)
  local a1 = a0 + 0.045
  local ray = P{ { SX, SY }, { SX + math.cos(a0) * 420, SY + sin(a0) * 420 }, { SX + math.cos(a1) * 420, SY + sin(a1) * 420 } }
  ray:each(function(x, y) if y <= HZ and y >= 0 then c:put(x, y, skyAt(y)[3]) end end)
end
-- sun glow: stacked warm bars near the horizon (no disc)
for k, b in ipairs{ { 10, 96, "#fdeab0" }, { 18, 100, "#fdeab0" }, { 26, 104, "#fef0c0" }, { 34, 108, "#fef0c0" } } do
  fill(R(SX - b[1], b[2], SX + b[1], b[2] + 1), b[3])
end
-- long streak clouds lit from below
local function streak(x, y, w, hh)
  hh = hh or 4
  local m = R(x + 3, y, x + w - 3, y):add(R(x + 1, y + 1, x + w - 1, y + hh - 1)):add(R(x, y + 2, x + w, y + hh - 1))
  m:each(function(px, py)
    local t = (py - y) / hh
    local h = t < 0.3 and "#b8587c" or t < 0.7 and "#e07e70" or "#f8b878"
    if hash(px, py, 7) < 0.06 then h = "#f6a072" end
    c:put(px, py, h)
  end)
  for px = x + 2, x + w - 2 do if hash(px, y, 9) > 0.35 then c:put(px, y + hh, "#fcd28c") end end
end
streak(150, 22, 90, 5); streak(196, 30, 70, 4); streak(300, 18, 110, 5); streak(350, 28, 60, 3)
streak(30, 40, 80, 4); streak(70, 50, 60, 3); streak(250, 56, 120, 4); streak(150, 64, 70, 3)
streak(380, 62, 70, 3); streak(20, 72, 50, 3)
c:cloud(232, 84, 34, "#f2a07a", "#fcd08a")
c:cloud(330, 88, 26, "#f2a07a", "#fcd08a")
c:cloud(150, 82, 24, "#f2a07a", "#fcd08a")

-------------------------------------------------------------------- FAR HILLS
local far = c:terrain(function(x)
  local y = 98 - 5 * sin(x / 41) - 3 * sin(x / 13 + 1)
  if x > 284 and x < 336 then y = math.min(y, 86 + abs(x - 310) * 0.08) end -- distant mesa
  if x >= 276 and x <= 284 then y = math.min(y, 86 + (284 - x) * 1.3) end
  if x >= 336 and x <= 344 then y = math.min(y, 86 + (x - 336) * 1.3) end
  return floor(y)
end, "#8e4c74", HZ)
far:each(function(x, y) if hash(x, y, 3) < 0.05 then c:put(x, y, "#7e4268") end end)
-- sunlit rim on far hills (sun to the left)
for x = 0, W - 1 do for y = 70, HZ do if far:has(x, y) then c:put(x, y, "#b85e78") break end end end
local near = c:terrain(function(x) return floor(106 - 2 * sin(x / 23 + 2) - 1.5 * sin(x / 7)) end, "#a45a6a", HZ)
near:each(function(x, y) if hash(x, y, 4) < 0.07 then c:put(x, y, "#94506a") end end)
-- tiny far acacias on the ridges
local function farAcacia(x, y, w, col)
  fill(R(x, y - 6, x, y), col)
  fill(R(x - floor(w / 2), y - 8, x + floor(w / 2), y - 7), col)
  fill(R(x - floor(w / 2) + 1, y - 9, x + floor(w / 2) - 2, y - 9), col)
end
for _, a in ipairs{ { 40, 104, 11 }, { 70, 106, 8 }, { 150, 103, 9 }, { 190, 106, 7 }, { 300, 105, 10 }, { 372, 104, 12 }, { 410, 106, 7 }, { 445, 103, 9 } } do
  farAcacia(a[1], a[2], a[3], "#6c3c5e")
end

-------------------------------------------------------------------- GROUND
for y = HZ, H - 1 do
  for x = 0, W - 1 do
    local base = y < 122 and "#c48446" or y < 150 and "#d29a46" or "#dba84c"
    local hh = hash(x, y, 11)
    if y > 150 and hh < 0.05 then base = "#bd8538"
    elseif y > 150 and hh > 0.975 then base = "#efc66e"
    elseif y <= 150 and hh < 0.06 then base = y < 122 and "#b47440" or "#bf8a3c" end
    c:put(x, y, base)
  end
end
-- grass strokes (vertical dashes), sparse, bigger near
for i = 1, 900 do
  local x, y = floor(hash(i, 1, 21) * W), floor(HZ + 8 + hash(i, 2, 21) ^ 0.7 * (H - HZ - 8))
  local len = y > 200 and 3 or y > 150 and 2 or 1
  for k = 0, len - 1 do c:put(x, y - k, "#b47a30") end
  c:put(x + 1, y - len + 1, "#efc66a")
end
-- street: red earth, wide at bottom, to the vanishing point
local street = P{ { 138, 270 }, { 342, 270 }, { 252, VY }, { 228, VY } }
street:each(function(x, y)
  local hh = hash(x, y, 31)
  local h = "#c96f44"
  if hh < 0.07 then h = "#ad5838" elseif hh > 0.95 then h = "#e08c5a" end
  -- faint ruts converging
  local t = (y - VY) / (270 - VY)
  local rl, rr = VX - 48 * t, VX + 48 * t
  if t > 0.15 and (abs(x - rl) < 0.6 + t or abs(x - rr) < 0.6 + t) and hh < 0.6 then h = "#b96240" end
  c:put(x, y, h)
end)
-- pebbles near
for i = 1, 70 do
  local y = floor(150 + hash(i, 5, 41) * 118)
  local t = (y - VY) / (270 - VY)
  local x = floor(VX + (hash(i, 6, 41) - 0.5) * (24 + 176 * t))
  if street:has(x, y) and street:has(x + 2, y) then
    fill(R(x, y, x + 1, y), "#e6b08a"); c:put(x, y + 1, "#8e4836"); c:put(x + 1, y + 1, "#8e4836")
  end
end
-- kerb stones along both street edges
local function kerb(xb, xt)
  local y = 268
  while y > 136 do
    local t = (y - VY) / (270 - VY)
    local x = floor(xt + (xb - xt) * t)
    local sz = math.max(1, floor(4 * t))
    local col = (floor(y / 3) % 2 == 0) and "#e6c89c" or "#c9a476"
    fill(R(x - sz, y - sz + 1, x + sz, y), col)
    fill(R(x - sz, y + 1, x + sz, y + 1), "#8e5a46")
    y = y - (2 * sz + 3)
  end
end
kerb(138, 228); kerb(342, 252)

-- shadows: cool violet; long, falling to the right (sun low on the left)
local function shadow(pts)
  P(pts):each(function(x, y)
    if y > HZ then c:put(x, y, street:has(x, y) and "#97586a" or "#a7706c") end
  end)
end

-------------------------------------------------------------------- FAR HUTS (depth)
local function farHut(x, y, w, wall, roof)
  local hw = floor(w / 2)
  fill(R(x - hw + 1, y - 4, x + hw - 1, y), wall)
  fill(R(x + 1, y - 4, x + hw - 1, y), "#9a5c5e")
  fill(P{ { x, y - 4 - hw }, { x + hw + 1, y - 4 }, { x - hw - 1, y - 4 } }, roof)
  c:put(x, y - 1, "#ffd27a")
end
for _, h in ipairs{ { 146, 113, 10 }, { 160, 114, 8 }, { 176, 113, 10 }, { 300, 114, 8 }, { 214, 113, 8 }, { 266, 113, 8 } } do
  farHut(h[1], h[2], h[3], "#c88a62", "#a86e4a")
end

-------------------------------------------------------------------- WATERHOLE (left, between library & tea)
local pond = P{ { 34, 140 }, { 50, 135 }, { 84, 134 }, { 112, 137 }, { 124, 142 }, { 116, 148 }, { 80, 150 }, { 46, 148 } }
fill(pond:copy():grow(1), "#7a4a36")
pond:each(function(x, y)
  local h = y < 139 and "#4a7a96" or y < 145 and "#3e6a8a" or "#355c7c"
  if (y == 138 or y == 142 or y == 146) and hash(x, y, 51) > 0.45 then h = "#f2b26a" end
  c:put(x, y, h)
end)
fill(R(36, 149, 120, 150):clip(pond:copy():grow(1)):cut(pond), "#5e3a32")
-- reeds
for _, r in ipairs{ { 36, 138 }, { 40, 137 }, { 120, 140 }, { 123, 141 }, { 60, 134 } } do
  fill(R(r[1], r[2] - 6, r[1], r[2]), "#6a7a32"); c:put(r[1], r[2] - 7, "#8a5a2e"); c:put(r[1], r[2] - 8, "#8a5a2e")
end
-- quirk: giant elephant footprints (the elephants remember) with a tiny gnome print inside one
for _, f in ipairs{ { 100, 152 }, { 114, 150 }, { 126, 153 } } do
  local m = c:rrect(f[1] - 4, f[2] - 2, f[1] + 4, f[2] + 2, 2)
  fill(m, "#a26a3e"); fill(R(f[1] - 3, f[2] - 2, f[1] + 3, f[2] - 2), "#86542e")
  c:put(f[1] - 3, f[2] - 3, "#86542e"); c:put(f[1], f[2] - 3, "#86542e"); c:put(f[1] + 3, f[2] - 3, "#86542e")
end
fill(R(113, 150, 114, 150), "#5e3424"); c:put(115, 149, "#5e3424")

-------------------------------------------------------------------- 1) LIBRARY  [36,52,122,130]
shadow{ { 40, 128 }, { 122, 127 }, { 132, 132 }, { 60, 133 } }
do
  local wall = P{ { 40, 92 }, { 104, 92 }, { 104, 128 }, { 40, 128 } }
  tone(wall, { "#f2dcae", "#e8cc96", "#dcba84", "#c8a274", "#7e5a44" }, 61, { ky = 0.2 })
  -- adobe texture blobs
  for i = 1, 40 do local x, y = 42 + floor(hash(i, 1, 62) * 60), 94 + floor(hash(i, 2, 62) * 32)
    if wall:has(x + 2, y) then fill(R(x, y, x + 2, y), "#d6b27e") end end
  local side = P{ { 104, 92 }, { 120, 95 }, { 120, 126 }, { 104, 128 } }
  tone(side, { "#b89480", "#a8847a", "#987474", "#886672", "#5e4250" }, 63, { tex = true })
  -- painted blue diamond band
  fill(R(41, 99, 103, 103), "#3e6aa4")
  for x = 42, 102, 6 do fill(P{ { x + 3, 99 }, { x + 6, 101 }, { x + 3, 103 }, { x, 101 } }, "#f2d27a") end
  fill(R(41, 104, 103, 104), "#2c4a7a")
  fill(P{ { 104, 99 }, { 120, 101 }, { 120, 104 }, { 104, 103 } }, "#2e5288")
  -- windows with bookshelves
  for _, wx in ipairs{ 46, 86 } do
    fill(R(wx - 1, 107, wx + 13, 120), "#5a3a2e")
    fill(R(wx, 108, wx + 12, 119), "#ffcf72")
    local cols = { "#b8443a", "#3e6aa4", "#5e8a3a", "#e0a03a", "#7a4a8a", "#c86a3a", "#3e8a8a" }
    for row = 0, 1 do
      local yy = 109 + row * 5
      for k = 0, 11 do if hash(wx + k, row, 64) > 0.2 then
        local hgt = 3 + floor(hash(wx + k, row, 65) * 2)
        fill(R(wx + k, yy + 4 - hgt, wx + k, yy + 3), cols[(k + row + wx) % #cols + 1]) end end
      fill(R(wx, yy + 4, wx + 12, yy + 4), "#7a4e34")
    end
  end
  -- door
  local door = c:rrect(66, 108, 78, 128, 4)
  fill(door, "#6e4430"); fill(R(72, 110, 72, 128), "#56342a"); edge(door, "#3e2622"); c:put(75, 118, "#f2c84a")
  -- hipped thatch roof
  local roof = P{ { 34, 94 }, { 110, 94 }, { 98, 68 }, { 46, 68 } }
  local rs = P{ { 110, 94 }, { 124, 97 }, { 114, 74 }, { 98, 68 } }
  roof:each(function(x, y)
    local v = (x - 34) / 76
    local h = v < 0.25 and "#e8c070" or v < 0.65 and "#d4a656" or "#bc8c46"
    if (y - 68) % 5 == 4 then h = "#a87a3e" end
    if hash(x, y, 66) < 0.12 then h = "#a87a3e" elseif hash(x, y, 67) > 0.94 then h = "#f2d48a" end
    c:put(x, y, h)
  end)
  rs:each(function(x, y) local h = (y % 5 == 4 or hash(x, y, 68) < 0.15) and "#8a6040" or "#a07250"; c:put(x, y, h) end)
  for x = 34, 124 do if hash(x, 9, 69) > 0.4 then c:put(x, (x <= 110) and 95 or 98, "#8a6038") end end
  edge(roof:copy():add(rs), "#6a4630")
  -- book sign on the ridge
  fill(R(71, 62, 73, 68), "#5a3a2e")
  local cover = P{ { 55, 52 }, { 72, 56 }, { 89, 52 }, { 89, 64 }, { 72, 68 }, { 55, 64 } }
  fill(cover, "#2e4c86"); edge(cover, "#1e2e58")
  local pl = P{ { 57, 53 }, { 71, 56 }, { 71, 65 }, { 57, 62 } }
  local pr = P{ { 73, 56 }, { 87, 53 }, { 87, 62 }, { 73, 65 } }
  fill(pl, "#f8ecd0"); fill(pr, "#ead8b4")
  for k = 0, 2 do fill(L({ { 59, 56 + k * 2 }, { 69, 58 + k * 2 } }, 1), "#a89478"); fill(L({ { 75, 58 + k * 2 }, { 85, 56 + k * 2 } }, 1), "#a08868") end
  fill(R(72, 56, 72, 67), "#c8443a") -- ribbon bookmark
  fill(R(72, 68, 72, 70), "#c8443a")
end

-------------------------------------------------------------------- 3) NOTICE BOARD  [132,78,170,140]
shadow{ { 134, 140 }, { 170, 140 }, { 196, 146 }, { 150, 146 } }
do
  local posts = R(135, 84, 138, 140):add(R(164, 84, 167, 140))
  tone(posts, { "#7a5a8a", "#5e4a7a", "#4e3e6a", "#3e3058", "#2c2240" }, 71, { cyl = true })
  local frame = R(132, 86, 170, 122)
  fill(frame, "#3e5a8a"); fill(R(132, 86, 133, 122), "#5a7ab0"); fill(R(132, 86, 170, 87), "#5a7ab0")
  fill(R(169, 86, 170, 122), "#2c3e66"); fill(R(132, 121, 170, 122), "#2c3e66")
  local panel = R(135, 89, 167, 119)
  panel:each(function(x, y) local h = (y % 6 == 0) and "#8a5c38" or "#b07a4a"; if hash(x, y, 72) < 0.1 then h = "#9a6a40" end c:put(x, y, h) end)
  edge(frame, "#1e2a4a")
  -- thatch cap
  local cap = P{ { 128, 87 }, { 174, 87 }, { 166, 78 }, { 136, 78 } }
  cap:each(function(x, y) local h = (hash(x, y, 73) < 0.18 or (y - 78) % 4 == 3) and "#a87a3e" or ((x < 150) and "#e2b864" or "#c89c50") c:put(x, y, h) end)
  edge(cap, "#6a4630")
  -- pinned papers
  local papers = { { 137, 91, 147, 103, "#f4e6c4" }, { 150, 90, 164, 99, "#bcd8e8" }, { 138, 106, 150, 117, "#f6c0b0" },
                   { 153, 102, 165, 117, "#f6e08a" } }
  for i, p in ipairs(papers) do
    fill(R(p[1] + 1, p[2] + 1, p[3] + 1, p[4] + 1), "#6a4430")
    fill(R(p[1], p[2], p[3], p[4]), p[5])
    for yy = p[2] + 3, p[4] - 2, 2 do for xx = p[1] + 2, p[3] - 2 do if hash(xx, yy, 74 + i) > 0.3 then c:put(xx, yy, "#8a7a8a") end end end
    c:put(floor((p[1] + p[3]) / 2), p[2], "#d8443a"); c:put(floor((p[1] + p[3]) / 2), p[2] + 1, "#9a2a2a")
  end
  -- quirk: one notice is an acacia leaf
  local leaf = P{ { 145, 112 }, { 149, 108 }, { 152, 112 }, { 149, 118 } }
  fill(leaf, "#7a9a3a"); fill(L({ { 149, 109 }, { 149, 117 } }, 1), "#4e6a2a"); c:put(149, 108, "#d8443a")
end

-------------------------------------------------------------------- 2) TEAHOUSE: THE ROOIBOS REST  [24,150,150,236]
shadow{ { 36, 228 }, { 124, 226 }, { 196, 236 }, { 120, 240 } }
do
  local wall = R(36, 190, 124, 226):add(E(80, 226, 44, 6))
  wall:cut(R(0, 233, 480, 270))
  local rp = { "#e28a5c", "#c95e3e", "#ae4a38", "#8e3c38", "#5e2430" }
  tone(wall, rp, 81, { cyl = true, dens = 0.08 })
  -- painted bands: cream zigzag + deep base band
  for x = 37, 123 do
    local f = (x - 36) / 88
    local cream = f < 0.75 and "#f4e0b4" or "#d8b898"
    for y = 198, 203 do
      local z = abs(((x - 36) % 8) - 4)
      if y - 198 >= z * 1 and y - 198 <= z + 1 then c:put(x, y, cream) end
    end
    c:put(x, 197, "#f2c25a"); c:put(x, 204, "#f2c25a")
    local by = (x - 80) * (x - 80) / 1936 * 4
    for y = 220 + floor(by), 222 + floor(by) do c:put(x, y, f < 0.75 and "#4a2a30" or "#3a2028") end
  end
  -- glowing door with dark frame
  local door = c:rrect(70, 204, 90, 230, 6)
  fill(door:copy():grow(1), "#5e2430"); fill(door, "#ffbe5c")
  fill(R(72, 214, 88, 230), "#f8a448"); fill(R(70, 224, 90, 230), "#e88a3c")
  -- bead curtain strands
  for x = 72, 88, 3 do for y = 206, 222, 2 do c:put(x, y, (y % 4 == 0) and "#c8443a" or "#f4e0b4") end end
  -- windows
  for _, wx in ipairs{ 46, 104 } do
    local w = c:rrect(wx, 208, wx + 9, 216, 2); fill(w:copy():grow(1), "#5e2430"); fill(w, "#ffcf72"); fill(R(wx, 213, wx + 9, 216), "#f6a84e")
  end
  -- conical thatch roof
  local roof = P{ { 78, 166 }, { 82, 166 }, { 136, 194 }, { 128, 198 }, { 32, 198 }, { 24, 194 } }
  roof:add(E(80, 195, 54, 5))
  roof:each(function(x, y)
    local f = (x - 24) / 112
    local i = f < 0.3 and 1 or f < 0.62 and 2 or f < 0.85 and 3 or 4
    local a = (x - 80) / (y - 162)
    if floor(a * 14 + 100) % 3 == 0 then i = math.min(4, i + 1) end
    if (y - 166) % 6 == 5 then i = math.min(4, i + 1) end
    if hash(x, y, 82) < 0.08 then i = math.min(4, i + 1) end
    c:put(x, y, ({ "#f0c874", "#dcae5a", "#c49248", "#a07040" })[i])
  end)
  for x = 26, 134 do if hash(x, 3, 83) > 0.45 then
    local yb = 195 + floor(math.sqrt(math.max(0, 1 - ((x - 80) / 54) ^ 2)) * 5)
    c:put(x, yb + 1, "#a07040") end end
  edge(roof, "#6a4630")
  -- painted roof band (red/cream)
  for x = 40, 120 do
    local yb = 186 + floor(math.sqrt(math.max(0, 1 - ((x - 80) / 46) ^ 2)) * 3)
    if roof:has(x, yb) then c:put(x, yb, (floor(x / 3) % 2 == 0) and "#c8443a" or "#f4e0b4"); c:put(x, yb + 1, "#8e3c38") end
  end
  -- quirk/sign: big cream teapot finial with rooibos-red band and steam
  local pot = c:rrect(71, 154, 89, 166, 4)
  fill(R(78, 166, 82, 168), "#8e3c38")
  local handle = R(66, 156, 70, 164):cut(R(68, 158, 70, 162))
  fill(handle, "#e8d0a8"); edge(handle, "#6a3a30")
  local spout = L({ { 88, 162 }, { 95, 155 } }, 2)
  fill(spout, "#e8d0a8"); edge(spout, "#6a3a30")
  tone(pot, { "#fbf0d8", "#f2e0bc", "#e2c8a0", "#c8a888", "#6a3a30" }, 84, { tex = false })
  fill(R(72, 160, 88, 161), "#c8443a")
  fill(R(76, 151, 84, 153), "#c8443a"); fill(R(79, 149, 81, 150), "#8e3c38")
  c:put(74, 156, "#fffaf0")
  for k, s in ipairs{ { 97, 152 }, { 98, 151 }, { 97, 150 }, { 96, 149 }, { 97, 148 }, { 99, 154 } } do c:put(s[1], s[2], "#fbe8cc") end
  -- outside: coffee pot (clay jebena) on a fire, with thimble cups on a red tray
  fill(E(139, 232, 9, 2), "#8a4e48")
  for _, s in ipairs{ { 132, 229 }, { 138, 230 }, { 144, 229 } } do local st = c:rrect(s[1] - 2, s[2], s[1] + 2, s[2] + 3, 1); fill(st, "#9a8a8a"); fill(R(s[1] - 2, s[2] + 3, s[1] + 2, s[2] + 3), "#5e5258"); c:put(s[1] - 1, s[2], "#c8bcbc") end
  fill(P{ { 134, 229 }, { 137, 220 }, { 139, 225 }, { 141, 219 }, { 144, 229 } }, "#f6842e")
  fill(P{ { 136, 229 }, { 138, 223 }, { 140, 226 }, { 142, 229 } }, "#ffd060")
  local jb = c:rrect(132, 206, 146, 219, 5):add(R(137, 199, 141, 206))
  tone(jb, { "#6a4a48", "#4e3436", "#3e282c", "#30202a", "#1e141c" }, 85, { tex = false })
  local js = L({ { 145, 211 }, { 149, 205 } }, 2); fill(js, "#4e3436")
  fill(R(136, 197, 142, 198), "#6a4a48"); c:put(134, 209, "#9a7a6a"); c:put(135, 208, "#9a7a6a")
  fill(R(132, 213, 146, 213), "#c8a050")
  -- tray of thimbles (coffee drunk from thimbles)
  local tray = R(100, 230, 126, 233); fill(tray, "#b8443a"); fill(R(100, 233, 126, 233), "#7e2a2e"); fill(R(100, 230, 126, 230), "#d86a50")
  for k = 0, 4 do
    local x = 102 + k * 5
    fill(R(x, 226, x + 3, 229), "#d8c8b4"); fill(R(x + 3, 226, x + 3, 229), "#a89890"); fill(R(x, 225, x + 3, 225), "#8a7a78")
    c:put(x + 1, 227, "#f8f0e4"); c:put(x + 1, 226, "#4e2e26"); c:put(x + 2, 226, "#4e2e26")
  end
end

-------------------------------------------------------------------- 4) THE ACACIA GREEN  [184,52,300,150]
shadow{ { 236, 150 }, { 300, 146 }, { 312, 152 }, { 244, 154 } }
do
  -- lawn with stone kerb
  local lawn = P{ { 192, 136 }, { 288, 136 }, { 298, 150 }, { 186, 150 } }
  fill(lawn:copy():grow(1), "#a8845e")
  lawn:each(function(x, y)
    local h = (floor((x - y * 0.3) / 7) % 2 == 0) and "#8fae44" or "#80a03e"
    if hash(x, y, 91) < 0.08 then h = "#6a8a34" elseif hash(x, y, 92) > 0.95 then h = "#b2c858" end
    c:put(x, y, h)
  end)
  for x = 186, 298, 3 do local y = 150; fill(R(x, y, x + 1, y + 1), (x % 2 == 0) and "#e6c89c" or "#c9a476") end
  for x = 192, 288, 4 do fill(R(x, 135, x + 2, 135), "#d8b88a") end
  fill(R(186, 152, 298, 152), "#7e5a44")
  -- canopy shadow pool on the lawn (right of trunk)
  P{ { 246, 140 }, { 288, 138 }, { 296, 148 }, { 250, 148 } }:each(function(x, y) if lawn:has(x, y) then c:put(x, y, "#5e7a4a") end end)
  -- trunk + branches
  local trunk = P{ { 229, 149 }, { 249, 149 }, { 245, 140 }, { 244, 104 }, { 235, 104 }, { 234, 140 } }
  trunk:add(L({ { 238, 108 }, { 222, 92 }, { 204, 82 } }, 4)):add(L({ { 241, 106 }, { 258, 92 }, { 278, 80 } }, 4))
  trunk:add(L({ { 239, 106 }, { 240, 80 } }, 3)):add(L({ { 222, 92 }, { 222, 80 } }, 2)):add(L({ { 258, 92 }, { 262, 80 } }, 2))
  tone(trunk, { "#a87a56", "#8a5e42", "#704a38", "#5a3a30", "#3e2424" }, 93, { dens = 0.14 })
  for y = 112, 146, 6 do fill(R(236, y, 238, y), "#5a3a30") end
  -- quirk: a gnome door in the trunk
  local gd = c:rrect(234, 133, 244, 148, 4)
  fill(gd:copy():grow(1), "#3e2424"); fill(gd, "#3e7ac0"); fill(R(239, 133, 239, 148), "#2e5a96"); c:put(242, 141, "#f2c84a")
  fill(R(232, 148, 246, 149), "#8a6e5a")
  -- flat-topped canopy
  local can = E(214, 72, 32, 11):add(E(252, 69, 38, 12)):add(E(284, 75, 15, 7)):add(E(194, 78, 12, 6))
  can:cut(R(0, 0, 480, 59))
  can:each(function(x, y)
    local v = (x - 182) / 118 * 0.5 + (y - 59) / 28
    local i = v < 0.3 and 1 or v < 0.62 and 2 or v < 0.92 and 3 or 4
    local hh = hash(floor(x / 2), floor(y / 2), 94)
    if hh < 0.2 then i = math.min(4, i + 1) elseif hh > 0.85 then i = math.max(1, i - 1) end
    c:put(x, y, ({ "#b4c456", "#8ca43e", "#6a8634", "#4c6a2c" })[i])
  end)
  -- sunset rim light on the flat top
  for x = 182, 300 do for y = 59, 70 do if can:has(x, y) then if x < 270 then c:put(x, y, "#e8c860") end break end end end
  -- underside clumps
  local under = E(206, 85, 10, 3):add(E(232, 83, 12, 3)):add(E(266, 82, 12, 3))
  under:cut(can)
  fill(under, "#4c6a2c")
  edge(can:copy():add(under), "#2e4420")
  -- lanterns hanging from branches
  for _, ln in ipairs{ { 206, 88 }, { 274, 86 } } do
    fill(R(ln[1], ln[2], ln[1], ln[2] + 4), "#3e2424")
    local g = R(ln[1] - 3, ln[2] + 5, ln[1] + 3, ln[2] + 12)
    fill(g:copy():grow(1), "#fbe0a0")
    fill(g, "#ffd060"); fill(R(ln[1] - 3, ln[2] + 5, ln[1] + 3, ln[2] + 5), "#8a3a2e"); fill(R(ln[1] - 3, ln[2] + 12, ln[1] + 3, ln[2] + 12), "#8a3a2e")
    c:put(ln[1] - 1, ln[2] + 7, "#fff4d0")
  end
  -- bench on the green
  fill(R(258, 140, 278, 141), "#b8443a"); fill(R(258, 142, 278, 142), "#7e2a2e")
  fill(R(260, 143, 261, 146), "#5e3a30"); fill(R(275, 143, 276, 146), "#5e3a30")
end

-------------------------------------------------------------------- 5) LOOKOUT TOWER  [312,26,364,140]
shadow{ { 316, 139 }, { 362, 139 }, { 400, 146 }, { 352, 146 } }
do
  local wd = { "#d8a46a", "#b8824e", "#9a6a40", "#7a5234", "#4e3024" }
  local back = L({ { 330, 136 }, { 332, 58 } }, 2):add(L({ { 348, 136 }, { 346, 58 } }, 2))
  fill(back, "#7a5234")
  local legs = L({ { 318, 139 }, { 324, 58 } }, 3):add(L({ { 360, 139 }, { 354, 58 } }, 3))
  local br = L({ { 320, 120 }, { 357, 90 } }, 2):add(L({ { 358, 120 }, { 321, 90 } }, 2)):add(L({ { 322, 86 }, { 355, 66 } }, 2)):add(L({ { 356, 86 }, { 323, 66 } }, 2))
  fill(br, "#9a6a40"); edge(br, "#5e3a28")
  tone(legs, wd, 101, { cyl = true })
  -- ladder
  fill(R(336, 58, 336, 138), "#c89058"); fill(R(342, 58, 342, 138), "#8a5c38")
  for y = 62, 136, 5 do fill(R(337, y, 341, y), "#b07a4a") end
  -- platform
  local plat = R(312, 52, 364, 58); tone(plat, wd, 102)
  for x = 316, 362, 6 do c:put(x, 55, "#7a5234") end
  -- teal rail
  local rail = R(314, 43, 362, 45):add(R(314, 43, 316, 52)):add(R(337, 43, 339, 52)):add(R(360, 43, 362, 52))
  fill(rail, "#3e9a92"); fill(R(314, 45, 362, 45), "#2a6a6a"); edge(rail, "#1e4a4e")
  for x = 320, 356, 5 do fill(R(x, 46, x, 51), "#2a6a6a") end
  -- roof posts + conical thatch
  fill(R(318, 34, 319, 43), "#7a5234"); fill(R(357, 34, 358, 43), "#7a5234")
  local roof = P{ { 337, 22 }, { 339, 22 }, { 366, 36 }, { 362, 38 }, { 314, 38 }, { 310, 36 } }
  roof:each(function(x, y)
    local f = (x - 310) / 56
    local i = f < 0.3 and 1 or f < 0.65 and 2 or 3
    if (y - 22) % 4 == 3 or hash(x, y, 103) < 0.12 then i = math.min(4, i + 1) end
    c:put(x, y, ({ "#f0c874", "#d6a656", "#b88a46", "#986a3a" })[i])
  end)
  edge(roof, "#6a4630")
  -- pennant
  fill(R(338, 14, 338, 22), "#4e3024"); fill(P{ { 339, 14 }, { 348, 16 }, { 339, 19 } }, "#3e9a92")
  -- spyglass (watch the animals)
  local sg = L({ { 352, 44 }, { 364, 39 } }, 3); fill(sg, "#e0a83a"); edge(sg, "#7a5020")
  fill(R(362, 38, 364, 40), "#a87020"); c:put(355, 42, "#fbe08a")
  -- quirk: a coffee pot left at the foot of the ladder
  fill(R(326, 130, 331, 136), "#4e3436"); fill(R(327, 128, 330, 129), "#6a4a48"); fill(R(332, 131, 333, 131), "#4e3436"); c:put(327, 131, "#9a7a6a")
end

-------------------------------------------------------------------- 6) KOPJE: SUNSET ROCK  [376,52,456,142]
shadow{ { 380, 142 }, { 456, 142 }, { 470, 150 }, { 420, 150 } }
do
  local rp = { "#f8c08a", "#e8966a", "#cc7462", "#a25a66", "#5a2e48" }
  local base = P{ { 378, 142 }, { 381, 120 }, { 388, 98 }, { 398, 84 }, { 414, 76 }, { 434, 78 }, { 447, 88 }, { 454, 106 }, { 456, 126 }, { 456, 142 } }
  local top = P{ { 404, 77 }, { 407, 64 }, { 417, 56 }, { 430, 57 }, { 437, 66 }, { 433, 78 } }
  local side = P{ { 440, 100 }, { 452, 108 }, { 456, 142 }, { 444, 142 } }
  tone(base, rp, 111, { ky = 0.25 })
  tone(top, rp, 112, { ky = 0.25 })
  -- contact dark where boulder sits
  fill(R(410, 77, 432, 78), "#5a2e48")
  -- cracks
  fill(L({ { 420, 88 }, { 424, 100 }, { 421, 114 } }, 1), "#7a3e5e")
  fill(L({ { 444, 96 }, { 448, 118 }, { 446, 136 } }, 1), "#6a3452")
  -- carved steps up the sunny face
  for i = 0, 9 do
    local x, y = 382 + floor(i * 2.4), 136 - i * 6
    fill(R(x, y, x + 7, y + 1), "#fbd0a8"); fill(R(x, y + 2, x + 7, y + 3), "#a85e6c"); c:put(x + 7, y, "#d8866a")
  end
  -- scratches: one for every gnome who watched the sunset
  local function tally(x, y)
    for k = 0, 3 do fill(R(x + k * 2, y, x + k * 2, y + 4), "#fbe0c0") end
    fill(L({ { x - 1, y + 4 }, { x + 7, y } }, 1), "#fbe0c0")
  end
  for _, t in ipairs{ { 410, 92 }, { 420, 104 }, { 430, 90 }, { 412, 116 }, { 428, 120 }, { 398, 108 }, { 436, 108 }, { 420, 64 }, { 404, 128 }, { 432, 132 } } do tally(t[1], t[2]) end
  -- a cool shaded flank
  side:each(function(x, y) if base:has(x, y) and hash(x, y, 113) > 0.3 then c:put(x, y, "#8e4e62") end end)
  edge(base:copy():add(top), "#5a2e48")
  -- sunset flag on top
  fill(R(424, 44, 424, 56), "#4e3024"); fill(P{ { 425, 44 }, { 434, 46 }, { 425, 49 } }, "#f6842e")
  -- tufts at the foot
  for _, g in ipairs{ { 384, 141 }, { 450, 141 }, { 396, 141 } } do fill(P{ { g[1] - 3, g[2] }, { g[1], g[2] - 5 }, { g[1] + 3, g[2] } }, "#9aa040") end
end

-------------------------------------------------------------------- 8) WILD TRAIL path (drawn before shops so the counter sits in front)
do
  local path = P{ { 312, 226 }, { 326, 218 }, { 410, 214 }, { 470, 211 }, { 480, 211 }, { 480, 221 }, { 440, 223 }, { 340, 232 }, { 316, 234 } }
  path:each(function(x, y) local h = hash(x, y, 121) < 0.08 and "#c08a52" or "#dcb07a"; c:put(x, y, h) end)
  edge(path, "#b07a48")
end

-------------------------------------------------------------------- 7) SHOPS: seed shop + spice stall  [318,148,402,226]
shadow{ { 320, 225 }, { 402, 224 }, { 440, 230 }, { 350, 232 } }
do
  -- posts
  for _, px in ipairs{ 322, 360, 398 } do local p = R(px, 166, px + 2, 224); fill(p, "#8a5c38"); fill(R(px + 2, 166, px + 2, 224), "#5e3a28") end
  -- back wall (inside, shaded)
  fill(R(325, 178, 397, 199), "#7a4a5a")
  for x = 326, 396, 7 do fill(R(x, 180, x + 4, 186), "#946070") end
  -- shelves with seed jars
  fill(R(325, 188, 397, 188), "#5e3a3e")
  local jc = { "#e0a03a", "#7a9a3a", "#c8443a", "#7a4a8a", "#3e8a8a", "#f2d27a" }
  for k = 0, 11 do local x = 327 + k * 6; fill(R(x, 183, x + 3, 187), jc[k % 6 + 1]); fill(R(x, 182, x + 3, 182), "#d8c8b4"); c:put(x, 184, "#f8ecd8") end
  -- awnings: green/cream (seeds) and saffron/rust (spices)
  local function awning(x0, x1, a, b)
    local m = P{ { x0, 164 }, { x1, 164 }, { x1 + 3, 178 }, { x0 - 3, 178 } }
    m:each(function(x, y) local s = floor((x - x0 + (y - 164) * 0.2) / 6) % 2 == 0; c:put(x, y, s and a or b); if y == 164 then c:put(x, y, "#f8e6c0") end end)
    for x = x0 - 3, x1 + 3, 6 do fill(R(x, 179, x + 3, 180), (floor((x - x0) / 6) % 2 == 0) and a or b); c:put(x + 1, 181, "#5e3a28") end
    edge(m, "#4e3024")
  end
  awning(321, 359, "#5e9a3e", "#f2e2b8")
  awning(363, 401, "#e8a838", "#b8443a")
  -- counter
  local ct = R(320, 200, 402, 224)
  ct:each(function(x, y) local h = ((x - 320) % 10 == 0) and "#8a5c38" or "#c08a52"; if hash(x, y, 131) < 0.08 then h = "#a8744a" end c:put(x, y, h) end)
  fill(R(320, 200, 402, 201), "#e0b07a"); fill(R(320, 223, 402, 224), "#7a4e34")
  edge(ct, "#4e3024")
  -- seed sacks & heaps on the counter
  local heaps = { { 330, "#5a3a2e", "#e8d8b8" }, { 344, "#f2c84a", "#fbe08a" }, { 372, "#c8443a", "#e87a5a" }, { 388, "#c8743a", "#e8a058" } }
  for _, hp in ipairs(heaps) do
    local s = c:rrect(hp[1] - 6, 192, hp[1] + 6, 200, 2); fill(s, "#c8a070"); fill(R(hp[1] - 6, 192, hp[1] + 6, 193), "#a87e50"); edge(s, "#6a4a30")
    local hm = P{ { hp[1] - 5, 193 }, { hp[1], 188 }, { hp[1] + 5, 193 } }
    hm:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and hp[2] or hp[3]) end)
  end
  -- quirk: one giant baobab-ish seed pod on the counter
  local pod = c:rrect(352, 194, 364, 200, 3); fill(pod, "#9a7a4a"); fill(R(353, 194, 363, 195), "#c8a46a"); edge(pod, "#5e4428")
  -- seed sign: seed with sprout atop the awning
  fill(R(361, 156, 362, 163), "#5e3a28")
  local seed = P{ { 361, 147 }, { 366, 151 }, { 366, 157 }, { 361, 160 }, { 356, 157 }, { 356, 151 } }
  tone(seed, { "#c88a52", "#a8683a", "#8a5030", "#6a3a26", "#3e2218" }, 132, { tex = false })
  c:put(358, 152, "#e8b07a")
  fill(R(361, 145, 361, 147), "#5e9a3e")
  fill(P{ { 361, 146 }, { 355, 144 }, { 357, 148 } }, "#7aba4a"); fill(P{ { 362, 146 }, { 368, 143 }, { 366, 148 } }, "#5e9a3e")
end

-------------------------------------------------------------------- 8) WILD TRAIL arch + signpost  [414,150,458,226]
shadow{ { 428, 214 }, { 458, 212 }, { 474, 216 }, { 440, 218 } }
do
  local arch = L({ { 430, 214 }, { 431, 186 }, { 432, 168 } }, 4):add(L({ { 455, 212 }, { 456, 186 }, { 454, 168 } }, 4))
  arch:add(L({ { 431, 170 }, { 434, 160 }, { 443, 155 }, { 451, 159 }, { 455, 170 } }, 4))
  tone(arch, { "#a87a56", "#8a5e42", "#704a38", "#5a3a30", "#3e2424" }, 141, { dens = 0.16 })
  -- twig tips & leaves along the arch
  for _, t in ipairs{ { 428, 162 }, { 436, 152 }, { 446, 151 }, { 457, 160 }, { 427, 176 }, { 459, 178 } } do
    local lf = P{ { t[1] - 4, t[2] + 1 }, { t[1], t[2] - 2 }, { t[1] + 4, t[2] + 1 }, { t[1], t[2] + 2 } }
    fill(lf, "#7a9a3a"); c:put(t[1] - 1, t[2] - 1, "#a8c050"); edge(lf, "#3e5224")
  end
  -- signpost pointing out of town
  local post = R(420, 186, 422, 222); fill(post, "#8a5c38"); fill(R(422, 186, 422, 222), "#5e3a28")
  local board = P{ { 414, 184 }, { 432, 184 }, { 437, 188 }, { 432, 192 }, { 414, 192 } }
  fill(board, "#e8b07a"); fill(R(414, 191, 432, 192), "#c08a52"); edge(board, "#5e3a28")
  -- tiny flat-top acacia icon on the sign
  fill(R(420, 186, 427, 186), "#5e9a3e"); fill(R(423, 187, 423, 190), "#5e3a28")
  fill(R(429, 187, 431, 189), "#c8443a")
  -- grass tufts
  for _, g in ipairs{ { 418, 224 }, { 461, 210 }, { 444, 210 } } do fill(P{ { g[1] - 3, g[2] }, { g[1] - 1, g[2] - 6 }, { g[1] + 1, g[2] - 3 }, { g[1] + 3, g[2] - 7 }, { g[1] + 4, g[2] } }, "#a8a040") end
end

-------------------------------------------------------------------- foreground grass tufts (away from stand points & UI corner)
for _, g in ipairs{ { 20, 246 }, { 160, 262 }, { 172, 150 }, { 306, 154 }, { 354, 244 }, { 128, 152 } } do
  fill(P{ { g[1] - 4, g[2] }, { g[1] - 2, g[2] - 7 }, { g[1], g[2] - 3 }, { g[1] + 2, g[2] - 8 }, { g[1] + 4, g[2] } }, "#b0a040")
  c:put(g[1] - 2, g[2] - 6, "#e0d070"); fill(R(g[1] - 4, g[2], g[1] + 4, g[2]), "#8a6a30")
end

-------------------------------------------------------------------- GATE FRAME (carved, painted posts + thatch lintel)
do
  local function post(x0, x1)
    local m = R(x0, 0, x1, H - 1)
    m:each(function(x, y)
      local f = (x - x0) / (x1 - x0)
      local h = f < 0.25 and "#a06a44" or f < 0.7 and "#84563a" or "#68422e"
      if y > 230 then h = f < 0.5 and "#84563a" or "#68422e" end
      if hash(x, floor(y / 3), 151) < 0.08 then h = "#5a3a2a" end
      c:put(x, y, h)
    end)
    -- painted carved bands (zigzag), upper part only
    for _, by in ipairs{ 40, 100, 160 } do
      fill(R(x0, by, x1, by + 1), "#f2c25a"); fill(R(x0, by + 12, x1, by + 13), "#f2c25a")
      for x = x0, x1 do
        local z = abs(((x - x0) % 6) - 3)
        for y = by + 2, by + 11 do
          local col = "#b8443a"
          if y - by - 2 >= z * 3 then col = "#f4e0b4" end
          c:put(x, y, col)
        end
      end
    end
    edge(m, "#3e2420")
  end
  post(0, 15); post(464, 479)
  -- lintel beam
  local beam = R(0, 0, W - 1, 10)
  beam:each(function(x, y) local h = y < 3 and "#a06a44" or y < 8 and "#84563a" or "#68422e"; if hash(floor(x / 3), y, 152) < 0.08 then h = "#5a3a2a" end c:put(x, y, h) end)
  for x = 20, 460, 12 do fill(P{ { x, 3 }, { x + 4, 7 }, { x + 8, 3 } }, "#f2c25a"); c:put(x + 4, 4, "#b8443a") end
  edge(beam, "#3e2420")
  -- thatch fringe below the beam
  for x = 0, W - 1 do
    local len = 4 + floor(hash(x, 1, 153) * 4) + ((x % 9 < 4) and 2 or 0)
    for y = 11, 10 + len do c:put(x, y, (y > 8 + len) and "#a87a3e" or ((hash(x, y, 154) < 0.2) and "#c49248" or "#dcae5a")) end
    c:put(x, 11 + len, "#6a4630")
  end
  -- corner brackets
  fill(P{ { 16, 18 }, { 34, 18 }, { 16, 36 } }, "#84563a"); edge(P{ { 16, 18 }, { 34, 18 }, { 16, 36 } }, "#3e2420")
  fill(P{ { 463, 18 }, { 445, 18 }, { 463, 36 } }, "#68422e"); edge(P{ { 463, 18 }, { 445, 18 }, { 463, 36 } }, "#3e2420")
  -- bunting (sagging cord, triangle flags)
  local fc = { "#c8443a", "#e8a838", "#3e9a8a", "#f2e0b8", "#7a4a8a" }
  local function cy(x, x0, x1, y0, sag) local t = (x - x0) / (x1 - x0) return y0 + sag * 4 * t * (1 - t) end
  for _, seg in ipairs{ { 34, 240, 24, 22 }, { 240, 446, 24, 22 } } do
    for x = seg[1], seg[2] do c:put(x, floor(cy(x, seg[1], seg[2], seg[3], seg[4])), "#5e3a2a") end
    local k = 0
    for x = seg[1] + 6, seg[2] - 8, 11 do
      k = k + 1
      local y = floor(cy(x + 3, seg[1], seg[2], seg[3], seg[4]))
      local fl = P{ { x, y }, { x + 7, y }, { x + 3.5, y + 8 } }
      fill(fl, fc[k % #fc + 1]); fill(R(x + 1, y + 1, x + 2, y + 1), "#fbe8c8")
    end
  end
  -- hanging lanterns
  for _, lx in ipairs{ 46, 432 } do
    fill(R(lx, 16, lx, 30), "#3e2420")
    local glow = P{ { lx, 27 }, { lx + 11, 38 }, { lx, 51 }, { lx - 11, 38 } }
    glow:each(function(x, y) if c:get(x, y) and y > 20 then c:put(x, y, (abs(x - lx) + abs(y - 39) < 8) and "#fde8a8" or "#fbd08a") end end)
    local body = R(lx - 4, 33, lx + 4, 45)
    fill(body, "#ffd060"); fill(R(lx - 2, 35, lx + 1, 41), "#fff0b0"); fill(R(lx + 3, 34, lx + 4, 44), "#f0a03a")
    fill(R(lx - 5, 31, lx + 5, 32), "#8a3a2e"); fill(R(lx - 3, 30, lx + 3, 30), "#8a3a2e")
    fill(R(lx - 5, 46, lx + 5, 47), "#8a3a2e"); fill(R(lx - 1, 48, lx + 1, 49), "#8a3a2e")
    fill(R(lx, 34, lx, 44), "#c8843a")
    edge(R(lx - 5, 30, lx + 5, 49), "#4e2420")
    fill(R(lx - 4, 33, lx + 4, 33), "#ffd060")
  end
end

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local spots = {
  { "green", "The Acacia Green", 184, 52, 300, 150 },
  { "tea", "The Rooibos Rest", 24, 150, 150, 236 },
  { "board", "Notice Board", 132, 78, 170, 140 },
  { "library", "Library", 34, 52, 124, 130 },
  { "s1", "Lookout", 310, 14, 366, 140 },
  { "s2", "Sunset Rock", 376, 44, 456, 142 },
  { "shops", "Shops", 318, 143, 402, 226 },
  { "wild", "Wild Trail", 414, 150, 462, 226 },
}
local stand = { { 120, 252 }, { 200, 242 }, { 290, 244 }, { 240, 204 }, { 204, 170 }, { 278, 170 } }
local parts = {}
for _, s in ipairs(spots) do
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2], (s[3] + s[5]) // 2, (s[4] + s[6]) // 2, s[3], s[4], s[5], s[6])
end
local sp = {}
for _, s in ipairs(stand) do sp[#sp + 1] = string.format('{"x":%d,"y":%d}', s[1], s[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write(string.format('{"w":480,"h":270,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n', HZ, table.concat(parts, ","), table.concat(sp, ",")))
f:close()
print("ok " .. NAME)
