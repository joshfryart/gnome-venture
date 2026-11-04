-- dukkah (final, Opus single pass). A slim kraft-paper cone lying on its side, tied with twine, its mouth tipped
-- lower-right and spilling a toasted heap of dukkah onto the ground; one whole hazelnut rolled beside it.
-- Material: cone with per-pixel cylinder light on a 6-tone kraft ramp, a spiral glued seam (dark groove + lit lip),
-- a folded rim cuff, crinkle creases; twine with a 2-tone twist and a bow; the heap on a 6-tone toasted ramp with
-- sesame, hazelnut chunks, coriander and pistachio flecks; contact shadow under the cone mouth; ground shadow.
-- quirk: an ant is marching off with a single sesame seed.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.sqrt
local c = A.new("dukkah")
local KR = { "#4e2c26", "#7c4a32", "#a8703f", "#c99456", "#e2b87a", "#f4d9a4" }
local DK = { "#3a2018", "#61361f", "#8a552b", "#b07a3a", "#cf9f52", "#ebc77c" }
local TW = { "#6e5838", "#c8ab70", "#e9d39a" }
local ptok, dtok, ttok = { r = { name = "paper" } }, { r = { name = "dukkah" } }, { r = { name = "twine" } }

c:groundShadow(39, 46, 17, 2)
local TX, TY, MX, MY = 14, 18, 35, 31
local ux, uy = MX - TX, MY - TY
local LEN = sqrt(ux * ux + uy * uy) ux, uy = ux / LEN, uy / LEN
local px, py = -uy, ux if px + py < 0 then px, py = -px, -py end
local cw = function(t) return 0.9 + t * 7.6 end

-- spill heap + mouth heap masks (heap in front of cone mouth)
local heap = HP.mask()
heap:add(c:ellipse(43, 41, 9, 4.5))
heap:add(c:ellipse(39, 37, 5, 4))
heap:cut(c:rect(0, 45, 63, 63))
-- cone
local cm, cn, CT, CS = X.cyl(TX, TY, MX, MY, cw)
-- mouth opening ellipse (perpendicular to axis)
local mouth = HP.mask()
for y = MY - 10, MY + 10 do for x = MX - 10, MX + 10 do
  local dx, dy = x - MX, y - MY
  local a, b = dx * px + dy * py, dx * ux + dy * uy
  if (a / 8.6) ^ 2 + (b / 3.4) ^ 2 <= 1 then mouth:set(x, y) end
end end
cm:cut(mouth)
local cb = {}
X.ao(cb, cm, heap, 2, -1)
local ci = A.shade(c, cm, cn, KR, { amb = 0.12, wrap = 0.3, bias = cb, tok = ptok })
-- spiral glued seam: from tip side (lit) wrapping to the shade side at the mouth
cm:each(function(x, y) local k = K(x, y) local t, s = CT[k], CS[k]
  if t and t > 0.08 then
    local target = -0.75 + t * 1.25
    local d = (s - target) * cw(t)
    if d > -0.5 and d < 0.5 then c:put(x, y, KR[max(1, (ci[k] or 3) - 2)], ptok)
    elseif d >= 0.5 and d < 1.5 then c:put(x, y, KR[min(6, (ci[k] or 3) + 1)], ptok) end
  end
end)
-- crinkle creases (short dark ticks + lit pixel)
for _, q in ipairs{ { 0.35, 0.45 }, { 0.6, -0.25 }, { 0.78, 0.55 } } do
  local t, s = q[1], q[2]
  local bx, by = TX + ux * LEN * t + px * s * cw(t), TY + uy * LEN * t + py * s * cw(t)
  for j = 0, 2 do local x, y = floor(bx + px * j * 0.9 + .5), floor(by + py * j * 0.9 + .5)
    if cm:has(x, y) then c:put(x, y, KR[max(1, (ci[K(x, y)] or 3) - 1)], ptok) end end
  local x, y = floor(bx - ux + .5), floor(by - uy + .5) if cm:has(x, y) then c:put(x, y, KR[min(6, (ci[K(x, y)] or 3) + 1)], ptok) end
end
-- folded cuff: last 2.5 px of the cone before the mouth, a lighter band with a dark fold line
cm:each(function(x, y) local k = K(x, y) local t = CT[k]
  if t and t * LEN > LEN - 3 then
    local d = LEN - t * LEN
    if d > 2.2 then c:put(x, y, KR[max(1, (ci[k] or 3) - 2)], ptok)
    else c:put(x, y, KR[min(6, (ci[k] or 3) + 1)], ptok) end
  end
end)
-- mouth: interior (dark) far side, rim light near side
mouth:each(function(x, y)
  local dx, dy = x - MX, y - MY
  local a, b = dx * px + dy * py, dx * ux + dy * uy
  c:put(x, y, (b < -0.6) and KR[1] or KR[2], ptok)
end)
mouth:edge():each(function(x, y)
  local dx, dy = x - MX, y - MY
  local b = dx * ux + dy * uy
  local a = dx * px + dy * py
  c:put(x, y, b > 0 and (a < 0 and KR[6] or KR[4]) or KR[3], ptok)
end)
-- dukkah heaped in the mouth (lower half of opening) + the spill heap
local fill = HP.mask()
mouth:shrink(1):each(function(x, y) local a = (x - MX) * px + (y - MY) * py if a > -2.5 then fill:set(x, y) end end)
local pile = heap:copy():add(fill)
local hn = X.pillow(pile, 3.5)
local hb = {}
-- contact shadow: pile pixels right under the rim line darker
mouth:edge():each(function(x, y) for d = 1, 2 do if pile:has(x + 1, y + d) and not mouth:edge():has(x + 1, y + d) then local k = K(x + 1, y + d) hb[k] = (hb[k] or 0) - 1 end end end)
local di = A.shade(c, pile, hn, DK, { amb = 0.12, wrap = 0.3, bias = hb, tok = dtok })
-- re-draw the near rim over the mouth heap so the lip reads in front
mouth:edge():each(function(x, y)
  local dx, dy = x - MX, y - MY
  local b = dx * ux + dy * uy
  local a = dx * px + dy * py
  if b > 0.5 and a < 3 then c:put(x, y, a < 0 and KR[6] or KR[4], ptok) end
end)
-- crumbly bumpy top: lumps and flecks
local FL = {
  ses = { "#c9b48a", "#f6ecc8" }, haz = { "#4a2616", "#7a4526" }, cor = { "#9a6a2a", "#d9a84e" }, pis = { "#4f7a3a", "#97c25e" },
}
pile:each(function(x, y) local k = K(x, y) local i = di[k] or 3
  local h = X.hash(x, y, 21)
  if c:get(x, y) == KR[6] or c:get(x, y) == KR[4] then return end
  local lit = i >= 4
  if h < 0.10 then c:put(x, y, FL.ses[lit and 2 or 1], dtok)
  elseif h < 0.16 then c:put(x, y, FL.haz[lit and 2 or 1], dtok)
  elseif h < 0.21 then c:put(x, y, FL.cor[lit and 2 or 1], dtok)
  elseif h < 0.245 then c:put(x, y, FL.pis[lit and 2 or 1], dtok)
  elseif h < 0.33 then c:put(x, y, DK[max(1, i - 1)], dtok) end
end)
-- a few loose grains rolled out on the ground
for _, q in ipairs{ { 54, 44, FL.ses[2] }, { 31, 45, FL.cor[2] }, { 28, 44, FL.haz[2] } } do c:put(q[1], q[2], q[3], dtok) end
-- toasty glint on the heap top
c:put(41, 37, DK[6], dtok) c:put(42, 37, DK[6], dtok) c:put(41, 36, "#fff0c8", dtok)

-- twine around the cone at t=0.42: 2 px band, alternating twist, bow ends dangling on the shade side
do
  local t0 = 0.42
  cm:each(function(x, y) local k = K(x, y) local t = CT[k]
    if t then local d = (t - t0) * LEN
      if d > -1 and d <= 1 then
        local s = CS[k]
        local tone = (x + y) % 2 == 0 and 3 or 2
        if s > 0.5 then tone = tone - 1 end
        c:put(x, y, TW[tone], ttok)
      end
    end
  end)
  -- bow below the cone
  local bx, by = floor(TX + ux * LEN * t0 + px * (cw(t0) + 1) + .5), floor(TY + uy * LEN * t0 + py * (cw(t0) + 1) + .5)
  A.map(c, { "a.b", "aab", ".c.", "a.c", "a..c" }, bx - 1, by, { a = TW[3], b = TW[2], c = TW[1] }, ttok)
end
-- paper sheen: one glint on the lit ridge
do local t, s = 0.62, -0.62
  local x, y = floor(TX + ux * LEN * t + px * s * cw(t) + .5), floor(TY + uy * LEN * t + py * s * cw(t) + .5)
  c:put(x, y, KR[6], ptok) c:put(x + 1, y, KR[6], ptok) end

-- whole hazelnut beside the heap
do
  local nm, nn = A.oval(55.5, 40.5, 2.4, 2.9, 0.25)
  local NR = { "#3e2016", "#64341e", "#8c5028", "#b0703a", "#d29a5c", "#ecc48a" }
  local ni = A.shade(c, nm, nn, NR, { amb = 0.08, wrap = 0.2, tok = dtok })
  -- pale cupule scar on top
  c:put(55, 38, "#e8d6a8", dtok) c:put(56, 38, "#cdb88a", dtok) c:put(55, 37, "#cdb88a", dtok)
  c:put(54, 39, NR[6], dtok)
end
-- quirk: ant with a sesame seed, marching left on the ground
do
  local x0, y0 = 20, 42
  local AN = { k = "#3a1e22", m = "#5e2c2c", h = "#8a4a3a", s = "#f6ecc8", t = "#c9b48a" }
  A.map(c, {
    ".st.....",
    ".hmk.kk.",
    "mkk.kmmk",
    ".k.k.kk.",
    "k..k.k..",
  }, x0, y0, AN, { r = { name = "ant" } })
end
A.save(c, "dukkah")
