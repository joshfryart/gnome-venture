-- w5lib.lua : small character/terrain helpers shared by the w5 scene scripts (gnome folk, goat, terraces).
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local K = { L = L, GV = GV }
local function R(h, o) return GV.ramp(h, o) end
local TINY = { flat = true, gloss = false, outline = false }
K.TINY = TINY

-- chibi gnome folk, feet at (x, y). o: tunic, hat, lean, beard, hatkind ("cone" | "bamboo" | "turban"), look (-1/0/1)
function K.gnome(c, x, y, o)
  o = o or {}
  local lean = o.lean or 2
  c:part(c:rect(x - 4, y - 1, x - 1, y), R("#5e2f1e"), TINY)
  c:part(c:rect(x + 1, y - 1, x + 4, y), R("#5e2f1e"), TINY)
  c:part(c:rrect(x - 4, y - 9, x + 4, y - 2, 2), R(o.tunic or "#4e8a3e"), { gloss = false, outline = false, cres = 3, deep = 5 })
  c:part(c:ellipse(x, y - 11, 4.5, 4), R("#e9b98a"), { flat = true, gloss = false, outline = false })
  if o.beard ~= false then
    c:part(c:poly({ { x - 4, y - 9 }, { x + 5, y - 9 }, { x + 1, y - 3 } }), R(o.beardc or "#f2e4c0", { dot = "#fff3c8" }), TINY)
  end
  if o.hatkind == "bamboo" then
    c:part(c:poly({ { x - 8, y - 14 }, { x + 9, y - 14 }, { x, y - 22 } }), R(o.hat or "#d9a660"), { gloss = false, outline = false, cres = 3, deep = 4 })
  elseif o.hatkind == "turban" then
    c:part(c:ellipse(x, y - 16, 5.5, 3.5), R(o.hat or "#f2e4c0", { dot = "#fff3c8" }), { gloss = false, outline = false, cres = 3, deep = 4 })
  else
    c:part(c:poly({ { x - 5, y - 15 }, { x + 6, y - 15 }, { x + lean, y - 27 } }), R(o.hat or "#d6322b"), { gloss = false, outline = false, cres = 3, deep = 5 })
  end
  local lk = o.look or 0
  c:eye(x - 3 + lk, y - 14, true); c:eye(x + 1 + lk, y - 14, true)
  c:part(c:ellipse(x + lk, y - 10, 1.5, 1.2), R("#d9885a"), TINY)
end

-- flat part with a hand-made lower-right crescent (for pale furry things where gvlib's crescent turns orange)
function K.fur(c, m, base, shade, deep)
  c:fill(m, base)
  local lit = m:copy():shift(-1, -1)
  local lit2 = m:copy():shift(-2, -2)
  c:fill(m:copy():cut(lit2), shade)
  if deep then c:fill(m:copy():cut(lit), deep) end
end

-- chibi goat, feet at (x,y), body centre x, facing d (1 right, -1 left). o.coat / o.shade / o.deep
function K.goat(c, x, y, o)
  o = o or {}
  local d = o.dir or 1
  local coat, sh, dp = o.coat or "#f2e4c0", o.shade or "#d8c496", o.deep or "#b89a6a"
  local function X(dx) return x + d * dx end
  local function span(a, b) local p, q = X(a), X(b); if p > q then p, q = q, p end return p, q end
  for _, dx in ipairs({ -6, -3, 3, 6 }) do
    local a, b = span(dx, dx + 1)
    c:fill(c:rect(a, y - 6, b, y), sh); c:fill(c:rect(a, y - 1, b, y), "#4a2c1a")
  end
  local a, b = span(-10, -8); c:fill(c:rect(a, y - 13, b, y - 10), coat)
  K.fur(c, c:ellipse(x, y - 9, 8, 5), coat, sh, dp)
  K.fur(c, c:ellipse(X(9), y - 14, 5, 4.5), coat, sh, dp)
  c:fill(c:ellipse(X(13), y - 12, 3, 2.5), "#ecd9b0")
  local ea = span(11, 12); c:fill(c:rect(ea, y - 11, ea + 1, y - 9), "#d9885a")
  local hx0, hx1 = span(6, 7); c:fill(c:rect(hx0, y - 21, hx1, y - 19), "#c9a96e"); c:px(X(5), y - 22, "#c9a96e")
  local jx0, jx1 = span(10, 11); c:fill(c:rect(jx0, y - 21, jx1, y - 19), "#c9a96e"); c:px(X(9), y - 22, "#c9a96e")
  local bx0, bx1 = span(12, 14); c:fill(c:rect(bx0, y - 9, bx1, y - 7), sh)
  c:px(X(15), y - 13, "#2a1a10"); c:px(X(15), y - 12, "#2a1a10")
  local function ex(dx) if d == 1 then return x + dx else return x - dx - 2 end end
  c:eye(ex(6), y - 17, true); c:eye(ex(10), y - 17, true)
  if o.brow then
    c:fill(c:rect(ex(6), y - 18, ex(6) + 2, y - 18), "#8b8f96"); c:fill(c:rect(ex(10), y - 18, ex(10) + 2, y - 18), "#8b8f96")
  end
end

-- stepped terrace band: grass top below f(x), stone wall below f(x)+gd (everything below gets overpainted by the next terrace)
function K.terrace(c, f, gd, grass, wall, edge)
  c:fill(L.below(c, f), grass)
  local m1 = L.below(c, function(x) return f(x) + gd end)
  c:fill(m1, wall)
  local m2 = L.below(c, function(x) return f(x) + gd + 1 end)
  c:fill(m1:copy():cut(m2), edge or "#5b6470")
  local m0 = L.below(c, function(x) return f(x) + 1 end)
  local lip = L.below(c, f):cut(m0)
  c:fill(lip, "#c8d77a")
  -- stone courses
  for x = 0, L.W - 1 do
    local y = math.floor(f(x) + gd + 0.5)
    if (x % 7) < 4 then c:px(x, y + 3, "#74808c") end
    if ((x + 3) % 9) < 3 then c:px(x, y + 6, "#74808c") end
  end
end
return K
