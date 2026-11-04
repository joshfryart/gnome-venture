-- hazelnut (aC11_2 final, Opus single pass). One hazelnut hanging from a short twig: glossy chestnut shell, slightly
-- pointed with a pale downy tip, sitting in a leafy frilled husk (involucre) whose toothed lobes hang over its
-- shoulders. Shell: sphere light, 6 tones, fine curved meridian striations, one hard specular, cool bounce lower-right,
-- cast shadow under the husk lobes. Husk: pillow-lit green with veins and yellowed tooth tips. Twig: 2-tone bark + node.
-- quirk: a tiny round weevil hole in the shell, lower right, with a lit lower lip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new("hazelnut")

local SHELL = { "#3f1f1e", "#62301f", "#8a4a26", "#ad6531", "#c98545", "#e4ad6c" }
local TIPC  = { "#b08a64", "#d8bc92", "#f1dfba" }
local HUSK  = { "#24442e", "#2f6036", "#47803c", "#6aa046", "#93bf58", "#c7dc7c" }
local HTIP  = { "#a8a040", "#d6c866" }
local BARK  = { "#3e2a26", "#6a4a36", "#93704c" }
local SPEC, BOUNCE = "#fff1cf", "#8a5a72"
local ntok, htok, btok = A.tok("shell"), A.tok("husk"), A.tok("twig")

-- shell: egg, slightly pointed at the bottom, a touch tilted
local CX, CY, RX, RY = 31, 39, 11, 12.5
local shell = HP.mask()
for y = 20, 58 do for x = 14, 48 do
  local dx, dy = x + .5 - CX, y + .5 - CY
  local ry = dy > 0 and RY + 1.2 or RY
  local rx = RX * (dy > 0 and (1 - 0.28 * (dy / ry) ^ 2) or 1)
  if (dx / (rx + .3))^2 + (dy / (ry + .3))^2 <= 1 then shell:set(x, y) end
end end
-- pointed tip
shell:set(31, 53) shell:set(30, 53) shell:set(31, 54)
local sn = X.sphere(CX - 0.5, CY - 0.5, RY, shell)
local bias = {}
-- striations: curved meridians
shell:each(function(x, y) local k = K(x, y)
  local dy = (y + .5 - CY) / (RY + 1)
  local half = RX * sqrt(max(0.05, 1 - dy * dy))
  local lon = (x + .5 - CX) / half
  local f = (lon * 4.2 + 10) % 1
  if f < 0.16 and abs(lon) < 0.92 and y > 26 then bias[k] = -1 end
end)

-- husk: frilled lobes around the top of the nut
local husk = HP.mask()
local lobes = {
  { 17.5, 26.0, 0.45, 1, 5.2, 2.6 }, { 21, 29.0, 0.25, 1, 5.4, 2.7 }, { 26, 29.5, 0.05, 1, 5.5, 2.8 },
  { 31.5, 30.0, -0.05, 1, 5.6, 2.8 }, { 37, 29.5, -0.2, 1, 5.3, 2.7 }, { 42, 27.5, -0.4, 1, 5.0, 2.6 },
  { 45, 24.0, -0.75, 1, 4.6, 2.4 },
}
for _, L in ipairs(lobes) do
  local ux, uy = L[3], L[4] local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  husk:add(A.rell(L[1], L[2], ux, uy, L[5], L[6]))
end
husk:add(HP.ellipse(31, 24, 12, 4))                    -- cup body over the nut's crown
husk:add(HP.ellipse(31, 21, 7, 3))
-- teeth: little points at the lobe ends
local teeth = { {16,31},{19,34},{23,35},{26,35},{29,36},{33,36},{36,35},{39,34},{43,32},{46,29},{48,25} }
for _, t in ipairs(teeth) do husk:set(t[1], t[2]) end
-- cut notches between lobes along the lower edge
for _, nx in ipairs{ 24, 34, 40 } do husk.s[K(nx, 34)] = nil husk.s[K(nx, 33)] = nil end

-- paint shell (under the husk), with cast shadow from the husk
local cast = husk:shift(1, 2)
cast:each(function(x, y) if shell:has(x, y) and not husk:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) - 2 end end)
local sv = X.light(sn, { amb = 0.05, wrap = 0.2 })
local sidx = X.tone(c, shell, sv, SHELL, { cuts = A.CUTS, bias = bias, tok = ntok })
-- bounce light lower-right
local rim = X.rim(sn)
shell:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and y > CY - 2 and y < 52 then c:put(x, y, BOUNCE, ntok) end end)
-- pale downy tip
for _, p in ipairs{ {30,52,2},{31,52,2},{32,52,1},{30,53,2},{31,53,3},{31,54,1},{29,51,1},{33,51,1},{30,51,2},{31,51,2},{32,51,1} } do
  if shell:has(p[1], p[2]) then c:put(p[1], p[2], TIPC[p[3]], ntok) end end
-- specular: 2x1 + glint, upper-left of the exposed shell
c:put(23, 40, SHELL[6], ntok) c:put(23, 41, SHELL[6], ntok) c:put(24, 39, SHELL[6], ntok)
c:put(23, 42, SPEC, ntok) c:put(22, 43, SHELL[6], ntok)
-- quirk: weevil hole
c:put(36, 46, A.INK, ntok) c:put(37, 46, "#24141c", ntok) c:put(36, 45, SHELL[1], ntok) c:put(37, 45, SHELL[2], ntok)
c:put(36, 47, SHELL[5], ntok) c:put(37, 47, SHELL[4], ntok) c:put(38, 46, SHELL[3], ntok)

-- husk paint (pillow light, veins, yellowed tooth tips)
local hn = X.pillow(husk, 2.2)
local hbias = {}
husk:each(function(x, y) local k = K(x, y)
  -- deep where the cup gathers to the stalk
  if (x - 31)^2 / 30 + (y - 20)^2 / 4 < 1 then hbias[k] = -1 end
end)
local hidx = A.shade(c, husk, hn, HUSK, { bias = hbias, tok = htok, amb = 0.1, wrap = 0.3 })
-- veins: radial lines from the stalk base out to each lobe
for _, L in ipairs(lobes) do
  local x0, y0 = 31, 22
  local x1, y1 = L[1] + (L[3] / 1.2) * 2.5, L[2] + 2.8
  local nseg = floor(max(abs(x1 - x0), abs(y1 - y0)))
  for j = 2, nseg do
    local f = j / nseg
    local x, y = floor(x0 + (x1 - x0) * f + .5), floor(y0 + (y1 - y0) * f + .5)
    if husk:has(x, y) then
      local i = hidx[K(x, y)] or 3
      c:put(x, y, HUSK[i >= 4 and i + 1 <= 6 and i + 1 or max(1, i - 1)], htok)
    end
  end
end
for _, t in ipairs(teeth) do if husk:has(t[1], t[2]) then c:put(t[1], t[2], (t[1] < 31) and HTIP[2] or HTIP[1], htok) end end
-- lower lip of the husk: dark underside row where it overhangs the shell
husk:each(function(x, y) if not husk:has(x, y + 1) and shell:has(x, y + 1) then c:put(x, y, HUSK[2], htok) end end)

-- twig: from the husk top up and to the right, with a node bump and a leaf scar
local twig = A.tube({ { 31, 19 }, { 31, 14 }, { 34, 10 }, { 40, 7 } }, function(t) return 1.3 - 0.35 * t end)
twig:each(function(x, y)
  if husk:has(x, y) then return end
  local lit = not twig:has(x - 1, y) or not twig:has(x, y - 1)
  local dark = not twig:has(x + 1, y) or not twig:has(x, y + 1)
  c:put(x, y, lit and BARK[3] or dark and BARK[1] or BARK[2], btok)
end)
c:put(40, 7, "#c7a37a", btok) c:put(41, 7, "#b08a64", btok)  -- cut end grain
c:put(33, 11, BARK[3], btok) c:put(32, 12, BARK[1], btok)       -- node

A.save(c, "hazelnut")
