-- sm.lua: shared helpers for the small-assets pass (Yarn icons, tile, bookhead, yarn balls, season bits)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/h3.lua")
local L = H.L
local S = { H = H, L = L, DIR = DIR }
local floor, sin, cos, sqrt, abs, pi, min, max = math.floor, math.sin, math.cos, math.sqrt, math.abs, math.pi, math.min, math.max
S.floor, S.sin, S.cos, S.sqrt, S.abs, S.pi, S.min, S.max = floor, sin, cos, sqrt, abs, pi, min, max
-- the new cats' coat ramp (exact grey tones)
S.CAT = { D = "#3d3654", s = "#57516f", b = "#6e6684", m = "#8a859b", l = "#aca7b9", L = "#cdc9d3", g = "#f1ebe3" }
S.INK = "#2b1c26"
S.NOSE = "#e8909e"
S.PINKD = "#c66a80"
S.CREAMC = "#f2e4c0"
local part, px, sep = H.part, H.px, H.sep
S.part, S.px, S.sep = part, px, sep
local function rgba(h) return app.pixelColor.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
S.rgba = rgba
-- plain canvas
function S.new(w, h) return L.canvas(w, h, true) end
function S.save(c, name, noink)
  if not noink then c:outline() end
  c:save(H.OUT, name)
  print(name, c:colours())
end
-- yarn ball with wrap strands
function S.ball(c, cx, cy, r, ramp, o)
  o = o or {}
  local m = L.ellipse(cx, cy, r, r)
  part(c, m, ramp, o.ws or 2, o.wl or 2)
  local ph = o.ph or 0
  for _, off in ipairs(o.offs or { -0.5, 0, 0.5 }) do
    for t = -r, r do
      local x, y = floor(cx + t + 0.5), floor(cy + off * r - t * 0.55 + ph + 0.5)
      if m:has(x, y) and m:has(x + 1, y + 1) and m:has(x - 1, y - 1) then
        c:put(x, y, ramp.s, "detail")
        if m:has(x, y - 1) and m:has(x, y - 2) then c:put(x, y - 1, ramp.L, "detail") end
      end
    end
  end
  c:put(floor(cx - r * 0.45), floor(cy - r * 0.55), ramp.g, "detail")
  c:put(floor(cx - r * 0.45) + 1, floor(cy - r * 0.55) - 1, ramp.g, "detail")
  return m
end
-- front-facing cat head+body (sitting). s = scale; returns masks
function S.cat(c, cx, cy, ramp, o)
  ramp = ramp or S.CAT
  o = o or {}
  local hw, hh = o.hw or 9, o.hh or 7.5
  local le = L.poly({ { cx - hw - 0.5, cy - 1 }, { cx - hw + 1, cy - hh - 5 }, { cx - 2.5, cy - hh + 0.5 } })
  local re = L.poly({ { cx + hw + 0.5, cy - 1 }, { cx + hw - 1, cy - hh - 5 }, { cx + 2.5, cy - hh + 0.5 } })
  if o.body ~= false then
    local bd = L.ellipse(cx, cy + hh + 4, hw * 0.8, hh * 1.1)
    part(c, bd, ramp, 2, 2) sep(c, bd)
    local ch = L.ellipse(cx, cy + hh + 6, hw * 0.45, hh * 0.6)
    ch:each(function(x, y) if bd:has(x, y) then c:put(x, y, ramp.L, "detail") end end)
  end
  part(c, le, ramp, 1, 1) part(c, re, ramp, 1, 1)
  local hd = L.ellipse(cx, cy, hw + 0.5, hh)
  part(c, hd, ramp, 2, 2) sep(c, hd)
  local ie = L.poly({ { cx - hw + 2, cy - hh * 0.5 }, { cx - hw + 2.5, cy - hh - 3 }, { cx - hw * 0.55, cy - hh * 0.8 } })
  local ie2 = L.poly({ { cx + hw - 2, cy - hh * 0.5 }, { cx + hw - 2.5, cy - hh - 3 }, { cx + hw * 0.55, cy - hh * 0.8 } })
  ie:each(function(x, y) c:put(x, y, S.NOSE, "detail") end) ie2:each(function(x, y) c:put(x, y, S.NOSE, "detail") end)
  local ex = floor(hw * 0.5)
  for _, e in ipairs({ { floor(cx - ex), floor(cy - 1) }, { floor(cx + ex - 1), floor(cy - 1) } }) do
    c:put(e[1], e[2], '#', "detail") c:put(e[1], e[2] + 1, '#', "detail")
    if o.big then c:put(e[1] + 1, e[2], '#', "detail") c:put(e[1] + 1, e[2] + 1, '#', "detail") c:put(e[1], e[2] - 1, S.CREAMC, "detail") end
  end
  c:put(floor(cx) - 1, floor(cy + 2), S.NOSE, "detail") c:put(floor(cx), floor(cy + 2), S.NOSE, "detail")
  return hd
end
-- sparkle
function S.spark(c, x, y, r, col, hi) H.star4(c, x, y, r, col, hi, "detail") end
return S
