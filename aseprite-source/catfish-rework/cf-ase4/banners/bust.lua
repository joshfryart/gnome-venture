-- bust.lua: shared helpers for the 80x100 shopkeeper busts (Hearth Pop v3 portrait rules)
local HPDIR = "/home/user/gnome-venture/aseprite-source/v3/lib"
local HP = dofile(HPDIR .. "/hp.lua")
local P = HP.P
local floor, max, min = math.floor, math.max, math.min
local M = { HP = HP, P = P }
local out = app.params.out or "./"
M.out = out
local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function mix(a, b, t)
  local ar, ag, ab = rgb(a) local br, bg, bb = rgb(b)
  return string.format("#%02x%02x%02x", floor(ar + (br - ar) * t + .5), floor(ag + (bg - ag) * t + .5), floor(ab + (bb - ab) * t + .5))
end
M.mix = mix
-- ramp from a base colour: cool-violet shade, warm light
function M.R(base, o)
  o = o or {}
  local shade = o.shade or mix(base, "#4a2f6a", 0.34)
  local deep = o.deep or mix(base, "#2b1c3a", 0.62)
  local hi = o.hi or mix(base, "#fff2c8", 0.42)
  return { hi = hi, base = base, shade = shade, deep = deep, mid = mix(base, shade, 0.5) }
end
local D4 = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
function M.new(name) local c = HP.canvas{ w = 80, h = 100, scale = 1, name = name } c.nm = name return c end
function M.keep(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) else c:put(x, y, hex) end end
function M.pts(c, list, hex) for _, p in ipairs(list) do M.keep(c, p[1], p[2], p[3] or hex) end end
-- part with an extra mid tone where base meets shade
function M.part(c, mask, r, o)
  o = o or {}
  c:part(mask, r, o)
  if r.mid and not o.nomid then
    local s = {}
    mask:each(function(x, y) if c:get(x, y) == r.base then
      for _, d in ipairs(D4) do if c:get(x + d[1], y + d[2]) == r.shade then s[#s + 1] = { x, y } break end end end end)
    for _, p in ipairs(s) do M.keep(c, p[1], p[2], r.mid) end
  end
  return mask
end
function M.recol(c, mask, map) mask:each(function(x, y) local v = map[c:get(x, y) or ""] if v then M.keep(c, x, y, v) end end) end
function M.eyes(c, lx, ly, rx, ry) c:eyeLocked(lx or 31, ly or 48) c:eyeLocked(rx or 44, ry or lx and ly or 48) end
function M.paint(c, rows, x, y, map) c:paint(rows, x, y, map) end
-- 62px backdrop disc (shade crescent lower-right, 1px outline in its own darker tone)
function M.backdrop(c, r)
  local disc = HP.ellipse(39.5, 46.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  disc:grow(1):cut(disc):each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs(D4) do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or mix(r.shade, r.deep, .5), "bg") end end)
end
-- designed noses ------------------------------------------------------------------------------------
-- ball nose (mammals): lit bridge, warm ball with 2x1 lit tip, shadow underside + nostrils. x,y = top-left of 6x5
function M.noseBall(c, x, y, r, nose)
  nose = nose or "#4f2620"
  c:paint({ "..wm..", "..wm..", ".whhm.", "wwwwwm", ".nssnc" }, x, y,
    { w = r.base, h = r.hi, m = r.shade, s = r.deep, n = nose, c = r.shade })
end
-- sheep/llama-style small dark nose: 4x3 with highlight
function M.noseDot(c, x, y, col, hi) c:paint({ ".hhh.", "ccccc", ".ccc." }, x, y, { c = col, h = hi }) end
-- hair/fur ticks along a mask edge (lit top)
function M.ticks(c, mask, hex, every, seed)
  mask:each(function(x, y) if (x * 7 + y * 13 + (seed or 0)) % (every or 9) == 0 then M.keep(c, x, y, hex) end end)
end
function M.fin(c, name, bd, bottomCut)
  c:finish{ outline = true }
  if bd then M.backdrop(c, bd) end
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
M.D4 = D4
return M
