-- tide-shell (lean D3o_2)
-- Scallop fan shell: radial ribs in coral to rose, scalloped lip, notched hinge ears, growth arcs. Quirk: a tiny pearl in the hinge.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tide-shell" }
local floor, abs, sqrt, atan, sin, cos, pi = math.floor, math.abs, math.sqrt, math.atan, math.sin, math.cos, math.pi
local SH = { "#5a2a58", "#8a3a74", "#b85690", "#dc7aa6", "#f5a4bc", "#ffd6dc" }
local SAND = { "#7a5e56", "#a8857a", "#d0ad98" }
c:groundShadow(32, 56, 13, 2)
local HX, HY, NR = 32, 53, 11
local A0 = 52 * pi / 180
local fan, ridge = HP.mask(), {}
local fv = {}
for y = 8, 56 do for x = 4, 60 do
  local dx, dy = x - HX, HY - y
  local r = sqrt(dx*dx + dy*dy)
  local a = atan(dx, dy)           -- 0 = straight up
  if dy > 0 and abs(a) < A0 then
    local ph = (a + A0) / (2 * A0) * NR
    local f = ph - floor(ph)
    local rr = 34 - 1.8 * (abs(f - 0.5) * 2) ^ 2 * 2
    if r <= rr then
      fan:set(x, y)
      local k = K(x, y)
      local crest = 1 - abs(f - 0.5) * 2         -- 1 at rib centre
      local lit = 0.62 + 0.3 * crest - 0.35 * (a + A0) / (2 * A0) + 0.12 * (1 - r / 34)
      -- growth arcs
      if floor(r / 5.5 + 0.5) ~= floor((r - 1) / 5.5 + 0.5) then lit = lit - 0.14 end
      if f < 0.09 or f > 0.91 then lit = lit - 0.2 end
      fv[k] = math.max(0, math.min(1, lit))
    end
  end
end end
-- ears
local ear = HP.mask()
for y = 48, 56 do for x = 20, 44 do
  local t = (y - 48) / 8
  if abs(x - HX) <= 12 - 4 * (1 - t) and abs(x - HX) >= 1 then ear:set(x, y) end
end end
ear:cut(fan)
local ev = {}
ear:each(function(x, y) ev[K(x, y)] = 0.5 + 0.25 * ((HX - x) / 12) + (y == 48 and 0.1 or 0) end)
G.tone(c, fan, fv, SH)
G.tone(c, ear, ev, SH)
-- ear ridges
for i = 0, 2 do c:px(HX - 4 - i * 3, 52 - (i > 0 and 0 or 0), SH[1]) c:px(HX + 4 + i * 3, 52, SH[1]) end
-- hinge notch and pearl (quirk)
c:fillMask(c:ellipse(HX, 54, 3, 2), SH[1])
c:fillMask(c:ellipse(HX, 53, 2, 1), SAND[2])
c:px(HX - 1, 52, "#fffaf0") c:px(HX, 53, "#e7dee2") c:px(HX + 1, 53, SAND[3]) c:px(HX, 54, SAND[1])
-- gloss glint on upper-left ribs
for _, p in ipairs{ {19,28},{20,27},{21,26},{22,25},{20,29} } do if fan:has(p[1], p[2]) then c:px(p[1], p[2], "#fff4f2") end end
G.fin(c, "tide-shell")
