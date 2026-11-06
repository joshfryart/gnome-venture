-- here-market-maplewold-v2: MAPLEWOLD MARKET from the entrance gate, looking in. 480x270 native, scale 1.
-- Single pass (Josh: no rich pass). Layout: here-market-maplewold.layout.json.
-- Method: a tiny ray caster renders the timber-frame street in true one-point perspective (VP 240,112):
--   every wall/roof/awning is a planar polygon with a world-space texture (timber frame, plaster, clapboard,
--   battens, ashlar, brick, shingle/scale/tile courses, lit windows with depth, shutters, flower boxes, pipes),
--   lit per pixel from a low warm sun (upper left, from behind the viewer) with cast shadows, quantised to
--   6-tone ramps whose shade ends lean cool-violet. Cobbles: perspective courses, mortar moss, puddle reflections
--   (reflected rays). Then hand-placed 2D props (hpx sphere/pillow lighting): maples, signs, stalls, fountain, gate.
-- Quirks (storyline): syrup pipeline from the sugar shack loft to the fountain barrel tap; leaning clock tower;
--   a maple growing through a roof; pumpkin wearing a gnome hat on the syrup stall; bunting of maple leaves and
--   tiny mittens; pies cooling on the bakery sills; sap bucket overflowing into a syrup trickle; maple-leaf steam puff.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local HX = dofile(d .. "/../lib/hpx.lua") HX.init(HP)
local out = app.params.out or "./"
local NAME = "here-market-maplewold-v2"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, ceil, sin, cos, abs, min, max, sqrt = math.floor, math.ceil, math.sin, math.cos, math.abs, math.min, math.max, math.sqrt
local PI = math.pi
local function hash(a, b, s) return HX.hash(floor(a), floor(b), floor(s or 0)) end
local function fr(a) return a - floor(a) end
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function Rm(x0, y0, x1, y1) return c:rect(floor(x0), floor(y0), floor(x1), floor(y1)) end
local function fm(m, hex) c:fillMask(m, hex) return m end
local function px(x, y, h) c:px(floor(x), floor(y), h) end
local T0 = os.clock()

------------------------------------------------------------------ ramps (6 tones, dark -> light, shade end cool-violet)
local TIMBER = { "#2b1c2e", "#3e2636", "#58323a", "#764640", "#94604a", "#b07c58" }
local TIMBER_R = { "#2e1630", "#48203a", "#6a2a3e", "#8c3a40", "#ae5048", "#c86a52" }
local FRAME = { "#4a3e5e", "#6c5e74", "#988a92", "#c8b8aa", "#e8dcc2", "#fbf2d8" }
local PL_CREAM = { "#4f3f66", "#6e5a7e", "#9a8196", "#cbb0a6", "#ecd3b0", "#fbe9c6" }
local PL_OCHRE = { "#583c5a", "#7e5562", "#ab7563", "#d89c62", "#efbe72", "#fcdc98" }
local PL_ROSE = { "#523a62", "#76506e", "#a0687c", "#cf8a8c", "#eaaa9c", "#f9cbb2" }
local PL_SAGE = { "#3a4262", "#4f5d72", "#6c8178", "#93a986", "#b8cc98", "#dce6b4" }
local PL_BLUE = { "#363c6a", "#4a5884", "#6679a0", "#8ea2be", "#b6c8d4", "#dbe6e2" }
local PL_BUTTER = { "#55456a", "#7a6276", "#a88a7c", "#d8b878", "#f0d488", "#fdeaae" }
local BOARD_RED = { "#3a1d36", "#5a2540", "#7f3142", "#a64240", "#c45a44", "#de7c52" }
local BOARD_W = { "#33273e", "#4c3a4a", "#6b5254", "#8f6e5e", "#b08c6a", "#cfac7e" }
local BOARD_BLUE = { "#262a52", "#2f3f6a", "#3f5884", "#5a78a2", "#7c9cbc", "#a4c0d2" }
local STONE = { "#2f2e4a", "#45445f", "#62617a", "#848296", "#a8a5b2", "#cdc8cc" }
local STONE_W = { "#3a3048", "#55485e", "#766676", "#9a8a8e", "#bfaea6", "#e0cfbe" }
local BRICK = { "#3c1c34", "#5c2638", "#82343c", "#a8483e", "#c4644a", "#dc8458" }
local SH_RED = { "#3a1a34", "#5a2238", "#822e3a", "#ac3e3a", "#cc5840", "#e67a4c" }
local SH_SLATE = { "#24264a", "#33385e", "#454f78", "#5e6a92", "#7e8aac", "#a4adc6" }
local SH_CEDAR = { "#331f38", "#4c2a3a", "#6c3c3e", "#905442", "#b26e48", "#cf9058" }
local SH_PLUM = { "#2c1c40", "#422656", "#5c3468", "#7a4878", "#9a6286", "#bc8098" }
local SH_GOLD = { "#3c2436", "#5e3438", "#8a4c34", "#b46a32", "#d68c38", "#f0b04c" }
local SH_TEAL = { "#1e2c46", "#22405a", "#2c5a6c", "#3a7a7c", "#56a08c", "#7ec4a0" }
local COBBLE = { "#2f2c46", "#47405a", "#665a6c", "#8a7a80", "#ad9a94", "#cdb8a8" }
local COB_W = { "#3a2a42", "#58404e", "#7a5a5c", "#a07a6c", "#c09a82", "#dcb898" }
local COB_B = { "#2a2e4a", "#3e4562", "#58607c", "#7a8298", "#9ca2b2", "#c0c2cc" }
local FLAG = { "#34324c", "#4c4862", "#6c667a", "#908898", "#b2a8b0", "#d2c8c6" }
local MOSS = { "#1f3a3c", "#2a5040", "#3d6a44", "#5a8a4a", "#7aa654", "#a0c464" }
local EARTH = { "#3a2a3a", "#5a3e42", "#7e5a4a", "#a07a58", "#c09a6a", "#dcba84" }
local GRASS = { "#1f3a3c", "#2e5a44", "#46804c", "#68a050", "#8cbc5c", "#b4d470" }
local COPPER = { "#3a2232", "#5a3036", "#83463a", "#ad6440", "#d08850", "#ecb070" }
local SHUT_G = { "#1f3442", "#2a4a4a", "#3a6650", "#4f8456", "#6aa25e", "#8cbc6c" }
local SHUT_B = { "#262a52", "#2f3f6a", "#3f5884", "#56749e", "#7090b4", "#90acc6" }
local SHUT_R = { "#3a1838", "#5e2040", "#862c42", "#ae3c42", "#d0544a", "#ea7a58" }
local AW_RED = { "#4a1a38", "#7a2440", "#b23a40", "#d85448", "#f07a58", "#ff9e70" }
local AW_CREAM = { "#5a4a6a", "#86718a", "#b8a2a6", "#e2cdb8", "#f6e4c6", "#fff2dc" }
local AW_GREEN = { "#1e3a40", "#2a5446", "#3c764c", "#549852", "#74b45c", "#9ccc70" }
local AW_GOLD = { "#5a3a3a", "#8a5434", "#c07a2e", "#e6a034", "#f8c454", "#ffe08a" }
local PETAL6 = { "#5a2a5a", "#7d2c5e", "#c94f84", "#f5809f", "#ffa8c0", "#ffc4d8" }
local GOLD6 = { "#5a3436", "#8f4a1f", "#d98322", "#f5b82e", "#ffd36a", "#ffe38a" }
local AMBER = { "#5a2218", "#8a3418", "#c05a1e", "#e8862a", "#f8b048", "#ffd884" }
local PUMP = { "#5a2428", "#8e3a24", "#c85e26", "#ef8a2e", "#ffb04a", "#ffd27a" }
local APPLE = { "#4a1430", "#7a1c34", "#b02a36", "#dc4038", "#f4704a", "#ffa070" }
local GL = { "#b45a26", "#d97e2c", "#f2a73a", "#ffcd5c", "#ffe492", "#fff1c4" }
local MR = { "#4a1838", "#80223e", "#b8343c", "#e0523c", "#f88a52" }
local MO = { "#55203a", "#9a3a36", "#d4642e", "#f4923a", "#ffc060" }
local MG = { "#5a2c3a", "#9a5a32", "#d8962e", "#f4c23e", "#ffe48a" }
local LEAFG = { "#1f3a3c", "#2e5a44", "#3f8a4c", "#6cb052", "#a6d468" }
local INKW = "#3b2a3e"

------------------------------------------------------------------ camera + sun
local F, VX, VY, EYE = 400, 240, 112, 5
local function proj(x, h, z) return VX + F * x / z, VY - F * (h - EYE) / z end
local Ls = { -0.49, 0.64, -0.59 }
do local l = sqrt(Ls[1]^2 + Ls[2]^2 + Ls[3]^2) Ls = { Ls[1]/l, Ls[2]/l, Ls[3]/l } end
local AMB, KD = 0.40, 0.68

------------------------------------------------------------------ texture helpers (world units)
local function per(a, p, w, fp)
  if fp > p * 0.45 then return false end
  local r = a % p if r > p * 0.5 then r = p - r end
  return r <= max(w * 0.5, fp * 0.5)
end
local function lnd(a, c0, w, fp) return abs(a - c0) <= max(w * 0.5, fp * 0.5) end
local function segDist(u, v, a1, b1, a2, b2, fu, fv)
  local du, dv = a2 - a1, b2 - b1
  local l2 = du * du + dv * dv
  local t = ((u - a1) * du + (v - b1) * dv) / l2
  if t < 0 or t > 1 then return 1e9, 0 end
  local l = sqrt(l2)
  local nx, ny = -dv / l, du / l
  return abs((u - a1) * nx + (v - b1) * ny), 0.5 * sqrt((fu * nx)^2 + (fv * ny)^2)
end
local function q(a, f) return floor(a / max(f, 0.04)) end

local function infill(kind, R, u, v, fu, fv, seed)
  seed = seed or 1
  if kind == "clap" then
    local ch = 0.3
    local k = floor(v / ch)
    local fvv = v - k * ch
    if fv < ch * 0.5 then
      if fvv < max(0.05, fv) then return R, -1 end
      if per(u + hash(k, 3, seed) * 2.4, 2.4, 0.04, fu) then return R, -1 end
    end
    return R, (hash(q(u, fu), k, seed) < 0.06) and -1 or 0
  elseif kind == "batten" then
    local p = 0.62
    if fu < p * 0.45 then
      local a = u % p
      local bw = max(0.12, fu)
      if a < bw then return R, (a < bw * 0.5) and 1 or 0 end
      if a < bw + max(0.06, fu) then return R, -1 end
    end
    return R, (hash(q(u, fu), floor(v / 0.9), seed) < 0.12) and -1 or 0
  elseif kind == "stone" then
    local ch = 0.42
    local k = floor(v / ch)
    local fvv = v - k * ch
    local bl = 0.9
    local uo = u + hash(k, 1, seed) * bl
    local j = floor(uo / bl)
    if fv < ch * 0.45 and fvv < max(0.05, fv) then return R, -2 end
    if fu < bl * 0.45 and (uo - j * bl) < max(0.05, fu) then return R, -2 end
    local hs = hash(k, j, seed + 4)
    local off = hs < 0.25 and -1 or (hs > 0.82 and 1 or 0)
    if fv < ch * 0.45 and fvv > ch - max(0.06, fv) then off = off + 1 end
    return R, off
  elseif kind == "brick" then
    local ch = 0.2
    local k = floor(v / ch)
    local fvv = v - k * ch
    local bl = 0.46
    local uo = u + (k % 2) * bl * 0.5
    local j = floor(uo / bl)
    if fv < ch * 0.5 and fvv < max(0.04, fv) then return R, -2 end
    if fu < bl * 0.45 and (uo - j * bl) < max(0.04, fu) then return R, -2 end
    local hs = hash(k, j, seed + 6)
    return R, hs < 0.25 and -1 or (hs > 0.85 and 1 or 0)
  end
  -- plaster
  local hq = hash(q(u, fu), q(v, fv), seed)
  local off = 0
  if hq < 0.06 then off = -1 elseif hq > 0.975 then off = 1 end
  if sin(u * 1.7 + seed) + sin(v * 2.3 - u * 0.6) > 1.55 then off = off - 1 end
  return R, off
end

local FLW = { PETAL6, SHUT_R, GOLD6, AW_CREAM, PETAL6, SH_PLUM }
local function glass(w, u, v, fu, fv, u0, u1, h0, h1)
  local kind = w.glass or "lit"
  local gu, gv = (u - u0) / (u1 - u0), (v - h0) / (h1 - h0)
  local FR = w.frame or FRAME
  local mu = w.mull or "cross"
  if mu == "grid" then
    local nx = max(2, floor((u1 - u0) / 0.5 + 0.5))
    local ny = max(2, floor((h1 - h0) / 0.55 + 0.5))
    if per(u - u0, (u1 - u0) / nx, 0.06, fu) or per(v - h0, (h1 - h0) / ny, 0.06, fv) then return FR, -1 end
  elseif mu == "cross" then
    if fu < (u1 - u0) * 0.3 and lnd(u, (u0 + u1) / 2, 0.08, fu) then return FR, -1 end
    if fv < (h1 - h0) * 0.3 and lnd(v, h0 + (h1 - h0) * 0.58, 0.08, fv) then return FR, -1 end
  end
  if kind == "dark" then
    if v > h1 - max(0.14, fv) then return nil, nil, "#2a2848" end
    if fr((u * 0.9 + v * 1.1) * 0.7) < 0.12 then return nil, nil, "#8a98c8" end
    return nil, nil, gv > 0.5 and "#4a4c80" or "#3c3c6c"
  end
  if v > h1 - max(0.14, fv) then return nil, nil, GL[1] end
  if u < u0 + max(0.1, fu) then return nil, nil, GL[2] end
  if w.curt and (gu < 0.17 or gu > 0.83) then return nil, nil, w.curt end
  if kind == "dim" then return nil, nil, gv > 0.6 and GL[3] or GL[2] end
  if gv > 0.62 then return nil, nil, (hash(q(u, fu), q(v, fv), 5) < 0.1) and GL[6] or GL[5] end
  return nil, nil, (gu > 0.6 and gv < 0.3) and GL[3] or GL[4]
end

local function winEval(w, u, v, fu, fv)
  local u0, u1, h0, h1 = w[1], w[2], w[3], w[4]
  local fw = 0.13
  local FR = w.frame or FRAME
  local r = (u1 - u0) / 2
  local cv = h1 - r
  if u >= u0 and u <= u1 and v >= h0 and v <= h1 then
    if not w.arch or v <= cv or (u - (u0 + r))^2 + (v - cv)^2 <= r * r then
      return glass(w, u, v, fu, fv, u0, u1, h0, h1)
    end
  end
  if u >= u0 - fw and u <= u1 + fw and v >= h0 - fw and v <= h1 + fw then
    if not w.arch or v <= cv or (u - (u0 + r))^2 + (v - cv)^2 <= (r + fw)^2 then
      return FR, (v > h1 + fw - max(0.05, fv)) and 1 or 0
    end
  end
  if v >= h0 - fw - 0.12 and v < h0 - fw and u >= u0 - fw - 0.12 and u <= u1 + fw + 0.12 then return FR, 1 end
  if w.box and v >= h0 - fw - 0.62 and v < h0 - fw - 0.12 and u >= u0 - fw and u <= u1 + fw then
    local bv = v - (h0 - fw - 0.62)
    if bv > 0.26 then
      local qq = hash(q(u, max(fu, 0.07)), q(v, max(fv, 0.07)), 9)
      if qq < 0.34 then return MOSS, (qq < 0.12) and -1 or 1 end
      local fl = w.flower or FLW
      return fl[1 + floor(qq * 17) % #fl], 1
    end
    return w.boxr or TIMBER, per(bv, 0.14, 0.03, fv) and -1 or 1
  end
  if w.shut and v >= h0 - fw and v <= h1 + fw then
    local sw = r + 0.05
    local su
    if u >= u0 - fw - sw and u < u0 - fw then su = u - (u0 - fw - sw)
    elseif u > u1 + fw and u <= u1 + fw + sw then su = u - (u1 + fw) end
    if su then
      local SR = w.shut
      if su < max(0.05, fu) or su > sw - max(0.05, fu) then return SR, -1 end
      if lnd(v, h0 + (h1 - h0) * 0.22, 0.1, fv) or lnd(v, h0 + (h1 - h0) * 0.78, 0.1, fv) then return SR, 1 end
      if per(su, 0.17, 0.035, fu) then return SR, -1 end
      return SR, 0
    end
  end
  return nil
end

local function doorEval(dd, u, v, fu, fv)
  local u0, u1, h1 = dd[1], dd[2], dd[3]
  local fw = 0.13
  local r = (u1 - u0) / 2
  local function inside(m)
    if u < u0 - m or u > u1 + m or v > h1 + m then return false end
    if dd.arch and v > h1 - r then return (u - (u0 + r))^2 + (v - (h1 - r))^2 <= (r + m)^2 end
    return true
  end
  if not inside(fw) then
    if v < 0.2 and u >= u0 - 0.25 and u <= u1 + 0.25 then return STONE, 1 end
    return nil
  end
  if not inside(0) then return TIMBER, 1 end
  local R = dd.ramp or TIMBER
  if dd.kind == "barn" then
    local mid = (u0 + u1) / 2
    if lnd(u, mid, 0.06, fu) then return R, -2 end
    local a0, a1 = (u < mid) and u0 or mid, (u < mid) and mid or u1
    local d1, f1 = segDist(u, v, a0, 0.3, a1, h1 - 0.3, fu, fv)
    local d2, f2 = segDist(u, v, a0, h1 - 0.3, a1, 0.3, fu, fv)
    if d1 <= max(0.09, f1) or d2 <= max(0.09, f2) then return R, 1 end
    if lnd(v, 0.3, 0.16, fv) or lnd(v, h1 - 0.3, 0.16, fv) then return R, 1 end
  end
  local top = h1 - (dd.arch and r or 0)
  if dd.glass and v > top - 0.85 and v < top - 0.15 and u > u0 + 0.22 and u < u1 - 0.22 then
    return nil, nil, (v > top - 0.3) and GL[2] or GL[4]
  end
  if fu < 0.1 and lnd(u, u1 - 0.22, 0.09, fu) and lnd(v, 1.2, 0.12, fv) then return GOLD6, 2 end
  if per(u - u0, 0.22, 0.035, fu) then return R, -1 end
  if v < 0.12 then return R, -1 end
  return R, 0
end

local function wallTex(def)
  local L = def.L
  local TB = def.timber or TIMBER
  local R = def.ramp
  return function(u, v, fu, fv)
    if def.pipes then for _, pu in ipairs(def.pipes) do
      if lnd(u, pu, 0.13, fu) then return COPPER, per(v, 1.1, 0.08, fv) and -1 or 0 end
    end end
    if def.doors then for _, dd in ipairs(def.doors) do
      local r, o, e = doorEval(dd, u, v, fu, fv) if r or e then return r, o, e end
    end end
    if def.wins then for _, w in ipairs(def.wins) do
      local r, o, e = winEval(w, u, v, fu, fv) if r or e then return r, o, e end
    end end
    local g = def.gable
    if g and v > g.eave + 0.12 then
      local um = g.um
      local edgeV = (u <= um) and (g.eave + (g.ridge - g.eave) * u / um) or (g.ridge - (g.ridge - g.eave) * (u - um) / (L - um))
      local dv = edgeV - v
      if dv < max(0.34, fv) then return TB, (dv < 0.17) and 1 or 0 end
      if g.loft then
        local lo = g.loft
        if u >= lo[1] - 0.12 and u <= lo[2] + 0.12 and v >= lo[3] - 0.12 and v <= lo[4] + 0.12 then
          if u < lo[1] or u > lo[2] or v < lo[3] or v > lo[4] then return TB, 1 end
          if v > (lo[3] + lo[4]) / 2 then return nil, nil, "#2a1c30" end
          return BOARD_W, per(u, 0.25, 0.04, fu) and -1 or 0
        end
      end
      local av = g.eave + (g.ridge - g.eave) * 0.36
      if g.win then
        local du, dvv = abs(u - um), abs(v - av)
        local rr = 0.55
        if du / rr + dvv / rr <= 1 then
          if fu < 0.2 and (lnd(u, um, 0.07, fu) or lnd(v, av, 0.07, fv)) then return FRAME, 0 end
          return nil, nil, (du / rr + dvv / rr > 0.62) and GL[2] or GL[4]
        end
        if du / (rr + 0.16) + dvv / (rr + 0.16) <= 1 then return TB, 1 end
      end
      if lnd(u, um, 0.2, fu) then return TB, 0 end
      if lnd(v, g.eave + (g.ridge - g.eave) * 0.66, 0.2, fv) then return TB, 0 end
      if lnd(v, g.eave + 0.12, 0.24, fv) then return TB, 1 end
      return infill(g.infill or def.infill, g.ramp or R, u, v, fu, fv, (def.seed or 1) + 50)
    end
    if def.foot and v < def.foot then
      if v > def.foot - max(0.08, fv) then return STONE, 1 end
      local r2, o2 = infill("stone", STONE, u * 1.4, v * 1.6, fu * 1.4, fv * 1.6, def.seed)
      return r2, o2
    end
    if def.beams then for _, hb in ipairs(def.beams) do
      if lnd(v, hb, 0.24, fv) then
        local off = 0
        if v > hb + 0.12 - fv * 0.9 then off = 1 elseif v < hb - 0.12 + fv * 0.5 then off = -1 end
        return TB, off
      end
    end end
    if def.posts then
      for i, pu in ipairs(def.posts) do
        if lnd(u, pu, 0.22, fu) then return TB, (hash(q(v, fv), i, 3) < 0.12) and -1 or 0 end
      end
      if def.braces then
        local pa, pb
        for i = 1, #def.posts - 1 do if u > def.posts[i] and u < def.posts[i + 1] then pa, pb = def.posts[i], def.posts[i + 1] end end
        local bz = def.bz
        if pa and bz and v > bz[1] and v < bz[2] then
          local b0, b1 = bz[1], bz[2]
          local st = def.braces
          local d1, f1, d2, f2 = 1e9, 0, 1e9, 0
          if st == "x" then
            d1, f1 = segDist(u, v, pa, b0, pb, b1, fu, fv)
            d2, f2 = segDist(u, v, pa, b1, pb, b0, fu, fv)
          elseif st == "v" then
            local m = (pa + pb) / 2
            d1, f1 = segDist(u, v, pa, b1, m, b0, fu, fv)
            d2, f2 = segDist(u, v, m, b0, pb, b1, fu, fv)
          elseif st == "k" then
            local qq = min(1.0, (pb - pa) * 0.35)
            d1, f1 = segDist(u, v, pa, b1 - qq * 1.1, pa + qq, b1, fu, fv)
            d2, f2 = segDist(u, v, pb - qq, b1, pb, b1 - qq * 1.1, fu, fv)
          end
          if d1 <= max(0.1, f1) or d2 <= max(0.1, f2) then return TB, 0 end
        end
      end
    end
    local off = 0
    if def.beams then for _, hb in ipairs(def.beams) do
      if v < hb - 0.12 and v > hb - 0.12 - max(0.12, fv) then off = -1 end
    end end
    local r, o
    if def.patch then
      local p = def.patch
      if ((u - p[1]) / p[3])^2 + ((v - p[2]) / p[4])^2 < 1 - 0.3 * hash(q(u, fu), q(v, fv), 2) then r, o = infill("brick", BRICK, u, v, fu, fv, 7) end
    end
    if not r then r, o = infill(def.infill, R, u, v, fu, fv, def.seed) end
    if def.grime and v < (def.foot or 0) + 0.45 + 0.2 * sin(u * 2.3) then o = o - 1 end
    return r, o + off
  end
end

local function roofTex(o)
  local R, Lu, Lv = o.ramp, o.Lu, o.Lv
  local ch, sw = o.ch or 0.42, o.sw or 0.5
  local seed = o.seed or 3
  return function(u, v, fu, fv)
    if v < max(0.2, fv) then return TIMBER, (v < max(0.2, fv) * 0.5) and -1 or 1 end
    if o.barge0 and u < max(0.24, fu) then return TIMBER, 1 end
    if o.barge1 and u > Lu - max(0.24, fu) then return TIMBER, 0 end
    if v > Lv - max(0.24, fv) then return R, per(u, 0.6, 0.06, fu) and -2 or -1 end
    local vv = v - 0.2
    local k = floor(vv / ch)
    local fvv = vv / ch - k
    local fpc = fv / ch
    local jo = (k % 2) * 0.5 + hash(k, 7, seed) * 0.3
    local uu = u / sw + jo
    local j = floor(uu)
    local a = uu - j
    local off = 0
    if o.moss then
      local m = sin(u * 0.9 + seed) + sin(u * 0.31 - v * 1.3 + seed * 2)
      if m > 1.35 and v < Lv * 0.55 and hash(q(u, fu), q(v, fv), 31) < 0.8 then
        return MOSS, (hash(q(u, fu), q(v, fv), 33) < 0.3) and -1 or 0
      end
    end
    if hash(q(u, max(fu, 0.12)), q(v, max(fv, 0.12)), 77) < 0.006 then return MO, 2 end
    local style = o.style
    if style == "tile" and k % 4 == 2 then style = "scale" end
    if fpc < 0.5 then
      if fvv > 1 - max(0.16, fpc) then off = -2
      elseif fvv < max(0.1, fpc) then off = 1 end
      if style == "scale" and fu < sw * 0.4 then
        local cut = 0.42 * (2 * a - 1)^2
        if fvv < cut then off = -1 end
      elseif fu < sw * 0.45 and a < max(0.08, fu / sw) and fvv < 1 - max(0.16, fpc) then off = off - 1 end
    end
    local hs = hash(k, j, seed)
    if hs < 0.14 then off = off - 1 elseif hs > 0.9 then off = off + 1 end
    if o.style == "tile" and k % 4 == 2 then off = off - 1 end
    return R, off
  end
end

local function ledgeTex(u, v, fu, fv) return TIMBER, per(u, 0.55, 0.24, fu) and 1 or -1 end

------------------------------------------------------------------ primitives
local PR, SPR = {}, {}
local function addPrim(v, o)
  local ax, ay, az = v[2][1] - v[1][1], v[2][2] - v[1][2], v[2][3] - v[1][3]
  local bx, by, bz = v[3][1] - v[1][1], v[3][2] - v[1][2], v[3][3] - v[1][3]
  local nx, ny, nz = ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  nx, ny, nz = nx / l, ny / l, nz / l
  local p = { v = v, n = { nx, ny, nz }, tex = o.tex, bid = o.bid or 0, alpha = o.alpha, O = o.O or v[1], U = o.U, V = o.V }
  p.d = nx * v[1][1] + ny * v[1][2] + nz * v[1][3]
  p.e = {}
  local x0, y0, z0, x1, y1, z1 = 1e9, 1e9, 1e9, -1e9, -1e9, -1e9
  local sx0, sy0, sx1, sy1 = 1e9, 1e9, -1e9, -1e9
  for i = 1, #v do
    local a, b = v[i], v[i % #v + 1]
    p.e[i] = { a[1], a[2], a[3], b[1] - a[1], b[2] - a[2], b[3] - a[3] }
    x0, y0, z0 = min(x0, a[1]), min(y0, a[2]), min(z0, a[3])
    x1, y1, z1 = max(x1, a[1]), max(y1, a[2]), max(z1, a[3])
    local sx, sy = proj(a[1], a[2], a[3])
    sx0, sy0, sx1, sy1 = min(sx0, sx), min(sy0, sy), max(sx1, sx), max(sy1, sy)
  end
  p.bb = { x0 - 0.02, y0 - 0.02, z0 - 0.02, x1 + 0.02, y1 + 0.02, z1 + 0.02 }
  p.sb = { max(-1, floor(sx0) - 1), max(-1, floor(sy0) - 1), min(W, ceil(sx1) + 1), min(H, ceil(sy1) + 1) }
  if not o.hide then PR[#PR + 1] = p end
  if not o.noshadow then SPR[#SPR + 1] = p end
  return p
end

local function hitPrim(p, ox, oy, oz, dx, dy, dz, tmax)
  local n = p.n
  local n1, n2, n3 = n[1], n[2], n[3]
  local den = n1 * dx + n2 * dy + n3 * dz
  if den > -1e-9 and den < 1e-9 then return nil end
  local t = (p.d - (n1 * ox + n2 * oy + n3 * oz)) / den
  if t <= 1e-3 or t >= tmax then return nil end
  local qx, qy, qz = ox + t * dx, oy + t * dy, oz + t * dz
  local bb = p.bb
  if qx < bb[1] or qx > bb[4] or qy < bb[2] or qy > bb[5] or qz < bb[3] or qz > bb[6] then return nil end
  local e = p.e
  for i = 1, #e do
    local ei = e[i]
    local wx, wy, wz = qx - ei[1], qy - ei[2], qz - ei[3]
    local cx_ = ei[5] * wz - ei[6] * wy
    local cy_ = ei[6] * wx - ei[4] * wz
    local cz_ = ei[4] * wy - ei[5] * wx
    if cx_ * n1 + cy_ * n2 + cz_ * n3 < -1e-7 then return nil end
  end
  if p.alpha then
    local O, U, V = p.O, p.U, p.V
    local rx, ry, rz = qx - O[1], qy - O[2], qz - O[3]
    if not p.alpha(rx * U[1] + ry * U[2] + rz * U[3], rx * V[1] + ry * V[2] + rz * V[3]) then return nil end
  end
  return t, qx, qy, qz
end

local function luv(p, x, y, z)
  local O, U, V = p.O, p.U, p.V
  local rx, ry, rz = x - O[1], y - O[2], z - O[3]
  return rx * U[1] + ry * U[2] + rz * U[3], rx * V[1] + ry * V[2] + rz * V[3]
end
local function planeAt(p, ox, oy, oz, dx, dy, dz)
  local n = p.n
  local den = n[1] * dx + n[2] * dy + n[3] * dz
  if abs(den) < 1e-9 then return nil end
  local t = (p.d - (n[1] * ox + n[2] * oy + n[3] * oz)) / den
  return ox + t * dx, oy + t * dy, oz + t * dz
end

local function shadowed(qx, qy, qz, self)
  local ox, oy, oz = qx + Ls[1] * 0.04, qy + Ls[2] * 0.04, qz + Ls[3] * 0.04
  for i = 1, #SPR do
    local p = SPR[i]
    local bb = p.bb
    if p ~= self and bb[5] > qy and bb[3] < qz + 0.2 and bb[1] < qx + 0.2 then
      if hitPrim(p, ox, oy, oz, Ls[1], Ls[2], Ls[3], 1e9) then return true end
    end
  end
  return false
end

local function shadeHit(p, qx, qy, qz, dx, dy, dz, u, v, fu, fv, doShadow)
  local R, off, emi = p.tex(u, v, fu, fv)
  if emi then return nil, nil, emi end
  local n = p.n
  local s = (n[1] * dx + n[2] * dy + n[3] * dz) > 0 and -1 or 1
  local lam = s * (n[1] * Ls[1] + n[2] * Ls[2] + n[3] * Ls[3])
  local lv = AMB
  if lam > 0 and not (doShadow and shadowed(qx, qy, qz, p)) then lv = AMB + KD * lam end
  return R, floor(lv * 6) + 1 + (off or 0)
end

------------------------------------------------------------------ buildings
local function frontTex(f, L)
  local wd = f.wall
  return wallTex{ L = L, infill = (wd.infill == "stone" or wd.infill == "brick" or wd.infill == "clap" or wd.infill == "batten") and wd.infill or "plaster",
    ramp = wd.ramp, timber = wd.timber, posts = (wd.infill == "plaster") and { 0.15, 3, 6, 9, 12 } or nil, beams = wd.beams, foot = wd.foot, seed = 90,
    wins = (f.h1 - f.h0 > 2.6) and { { 1.4, 2.6, f.h0 + 1.1, f.h0 + 2.4, glass = "dim" } } or nil }
end

local function building(b)
  local s, z0, z1, xs = b.side, b.z0, b.z1, b.xs or 12
  local L = z1 - z0
  local r = b.roof
  local topOff = b.floors[#b.floors].off or 0
  local back = (r.kind == "side") and (xs + 2 * r.dr - topOff) or 34
  local prevOff = 0
  for i, f in ipairs(b.floors) do
    local off = f.off or 0
    local Xw = s * (xs - off)
    local wd = f.wall
    wd.L = L
    wd.seed = wd.seed or (b.id * 7 + i)
    local verts
    if i == #b.floors and r.kind == "gable" then
      wd.gable = wd.gable or {}
      wd.gable.um, wd.gable.eave, wd.gable.ridge = r.zm - z0, f.h1, r.ridge
      verts = { { Xw, f.h0, z0 }, { Xw, f.h0, z1 }, { Xw, f.h1, z1 }, { Xw, r.ridge, r.zm }, { Xw, f.h1, z0 } }
    else
      verts = { { Xw, f.h0, z0 }, { Xw, f.h0, z1 }, { Xw, f.h1, z1 }, { Xw, f.h1, z0 } }
    end
    addPrim(verts, { tex = wallTex(wd), bid = b.id, O = { Xw, 0, z0 }, U = { 0, 0, 1 }, V = { 0, 1, 0 } })
    addPrim({ { Xw, f.h0, z0 }, { s * back, f.h0, z0 }, { s * back, f.h1, z0 }, { Xw, f.h1, z0 } },
      { tex = frontTex(f, back - xs), bid = b.id, O = { Xw, 0, z0 }, U = { s, 0, 0 }, V = { 0, 1, 0 } })
    if off > prevOff + 0.01 then
      local Xa = s * (xs - prevOff)
      addPrim({ { Xa, f.h0, z0 }, { Xa, f.h0, z1 }, { Xw, f.h0, z1 }, { Xw, f.h0, z0 } },
        { tex = ledgeTex, bid = b.id, O = { Xa, f.h0, z0 }, U = { 0, 0, 1 }, V = { -s, 0, 0 } })
    end
    prevOff = off
  end
  local eave = b.floors[#b.floors].h1
  local ov = r.ov or 0.5
  if r.kind == "side" then
    local k = (r.ridge - eave) / r.dr
    local he = eave - ov * k
    local Xe = s * (xs - topOff - ov)
    local Xr = s * (xs - topOff + r.dr)
    local vx, vy = Xr - Xe, r.ridge - he
    local Lv = sqrt(vx * vx + vy * vy)
    addPrim({ { Xe, he, z0 - ov }, { Xe, he, z1 + ov }, { Xr, r.ridge, z1 + ov }, { Xr, r.ridge, z0 - ov } },
      { tex = roofTex{ ramp = r.ramp, Lu = L + 2 * ov, Lv = Lv, style = r.style, moss = r.moss, seed = b.id, barge0 = true, barge1 = true },
        bid = b.id, O = { Xe, he, z0 - ov }, U = { 0, 0, 1 }, V = { vx / Lv, vy / Lv, 0 } })
    local Xs = s * (xs - topOff)
    local fw = b.floors[#b.floors].wall
    addPrim({ { Xs, eave, z0 }, { s * back, eave, z0 }, { Xr, r.ridge, z0 } },
      { tex = wallTex{ L = back - xs, infill = (fw.infill == "plaster") and "plaster" or "clap", ramp = fw.ramp, timber = fw.timber,
          posts = { 0.15, r.dr }, beams = { eave + 0.1 }, seed = 91,
          wins = { { r.dr - 0.45, r.dr + 0.45, eave + 0.7, eave + 1.7, glass = "lit" } } },
        bid = b.id, O = { Xs, 0, z0 }, U = { s, 0, 0 }, V = { 0, 1, 0 } })
  else
    local k = (r.ridge - eave) / (r.zm - z0)
    local he = eave - ov * k
    local Xe = s * (xs - topOff - ov)
    local vy, vz = r.ridge - he, r.zm - (z0 - ov)
    local Lv = sqrt(vy * vy + vz * vz)
    addPrim({ { Xe, he, z0 - ov }, { s * back, he, z0 - ov }, { s * back, r.ridge, r.zm }, { Xe, r.ridge, r.zm } },
      { tex = roofTex{ ramp = r.ramp, Lu = back - (xs - topOff - ov), Lv = Lv, style = r.style, moss = r.moss, seed = b.id, barge0 = true },
        bid = b.id, O = { Xe, he, z0 - ov }, U = { s, 0, 0 }, V = { 0, vy / Lv, vz / Lv } })
  end
  for _, ch in ipairs(b.chimneys or {}) do
    local xa, xb = s * (ch.x - ch.w / 2), s * (ch.x + ch.w / 2)
    local za, zb = ch.z - ch.d / 2, ch.z + ch.d / 2
    local R = ch.ramp
    local function ctex(u, v, fu, fv)
      if v > ch.t - 0.35 then return STONE, (v > ch.t - 0.12) and 1 or 0 end
      if v > ch.t - 0.5 then return R, -2 end
      if R == COPPER then return R, per(v, 0.9, 0.1, fv) and -1 or 0 end
      return infill((R == BRICK) and "brick" or "stone", R, u, v, fu, fv, 5)
    end
    addPrim({ { xa, ch.b, za }, { xb, ch.b, za }, { xb, ch.t, za }, { xa, ch.t, za } },
      { tex = ctex, bid = b.id, O = { xa, 0, za }, U = { s, 0, 0 }, V = { 0, 1, 0 } })
    addPrim({ { xa, ch.b, za }, { xa, ch.b, zb }, { xa, ch.t, zb }, { xa, ch.t, za } },
      { tex = ctex, bid = b.id, O = { xa, 0, za }, U = { 0, 0, 1 }, V = { 0, 1, 0 } })
  end
  for _, a in ipairs(b.awnings or {}) do
    local xi, xo = s * (xs - 0.03), s * (xs - a.proj)
    local vx, vy = xi - xo, a.drop
    local Lv = sqrt(vx * vx + vy * vy)
    local sw = 0.5
    addPrim({ { xo, a.h - a.drop, a.za0 }, { xo, a.h - a.drop, a.za1 }, { xi, a.h, a.za1 }, { xi, a.h, a.za0 } },
      { tex = function(u, v, fu, fv)
          local A = (floor(u / sw) % 2 == 0) and a.A or a.B
          if v < 0.3 then return A, -1 end
          if v > Lv - 0.12 then return A, -1 end
          if per(u, sw, 0.04, fu) then return A, -1 end
          return A, 0
        end,
        alpha = function(u, v) local t = fr(u / sw) return v >= 0.2 * (1 - sqrt(max(0, 1 - (2 * t - 1)^2))) end,
        bid = b.id + 100, O = { xo, a.h - a.drop, a.za0 }, U = { 0, 0, 1 }, V = { vx / Lv, vy / Lv, 0 } })
  end
end

local function row(us, w, h0, h1, o)
  local t = {}
  for i, uc in ipairs(us) do
    local wv = { uc - w / 2, uc + w / 2, h0, h1 }
    for k, v in pairs(o or {}) do wv[k] = v end
    if o and o.alt and i % 2 == 0 then for k, v in pairs(o.alt) do wv[k] = v end end
    t[#t + 1] = wv
  end
  return t
end

-- LEFT (side -1)
building{ id = 1, side = -1, z0 = 17, z1 = 34, xs = 12,
  floors = {
    { h0 = 0, h1 = 4.4, wall = { infill = "batten", ramp = BOARD_RED, foot = 0.55, posts = { 0.15, 16.85 }, beams = { 4.3 },
      doors = { { 9.0, 11.6, 3.2, kind = "barn", ramp = BOARD_W } },
      wins = { { 4.6, 6.2, 1.6, 2.9, shut = SHUT_G }, { 13.4, 15.0, 1.6, 2.9, shut = SHUT_G, box = true } },
      pipes = { 16.3 }, grime = true,
      gable = { infill = "clap", ramp = BOARD_W, loft = { 7.4, 9.6, 5.8, 7.6 } } } } },
  roof = { kind = "gable", ridge = 9.5, zm = 25.5, ov = 0.6, ramp = SH_CEDAR, style = "shingle", moss = true },
  chimneys = { { x = 13.25, z = 31, w = 0.7, d = 0.7, b = 5.5, t = 11.2, ramp = COPPER } } }
building{ id = 2, side = -1, z0 = 34, z1 = 58, xs = 12,
  floors = {
    { h0 = 0, h1 = 3.4, wall = { infill = "plaster", ramp = PL_OCHRE, foot = 0.5, posts = { 0.15, 8.1, 12.1, 23.85 }, beams = { 3.3 },
      wins = { { 1.3, 6.9, 0.9, 2.75, mull = "grid" }, { 13.2, 17.4, 0.95, 2.75, mull = "grid" }, { 19.0, 22.6, 0.95, 2.75, glass = "dim" } },
      doors = { { 9.3, 10.9, 2.7, ramp = SHUT_B, glass = true } }, pipes = { 7.6 }, grime = true, patch = { 20.8, 1.9, 0.9, 0.55 } } },
    { h0 = 3.4, h1 = 6.4, off = 0.45, wall = { infill = "plaster", ramp = PL_OCHRE, posts = { 0.15, 2.6, 5.0, 7.4, 9.8, 12.2, 14.6, 17, 19.4, 21.8, 23.85 },
      beams = { 3.5, 6.3 }, braces = "v", bz = { 3.6, 6.2 }, wins = row({ 3.8, 8.6, 15.8, 20.6 }, 1.4, 4.25, 5.75, { shut = SHUT_R, box = true }) } },
    { h0 = 6.4, h1 = 9.4, off = 0.8, wall = { infill = "plaster", ramp = PL_OCHRE, posts = { 0.15, 4, 8, 12, 16, 20, 23.85 }, beams = { 6.5, 9.3 },
      braces = "x", bz = { 6.6, 9.2 }, wins = row({ 6, 18 }, 1.3, 7.2, 8.6), gable = { win = true } } } },
  roof = { kind = "gable", ridge = 14.5, zm = 46, ov = 0.6, ramp = SH_RED, style = "scale" },
  chimneys = { { x = 16, z = 52, w = 1.3, d = 1.3, b = 10, t = 16.2, ramp = BRICK } },
  awnings = { { za0 = 34.6, za1 = 41.4, h = 3.15, proj = 1.5, drop = 0.75, A = AW_RED, B = AW_CREAM } } }
building{ id = 3, side = -1, z0 = 58, z1 = 72, xs = 12.2,
  floors = {
    { h0 = 0, h1 = 3.2, wall = { infill = "plaster", ramp = PL_ROSE, foot = 0.45, posts = { 0.15, 13.85 }, beams = { 3.1 },
      doors = { { 1.8, 3.3, 2.6, ramp = SHUT_G } }, wins = { { 5.2, 9.8, 0.9, 2.6, mull = "grid" }, { 11, 12.8, 1.0, 2.5, glass = "dark" } }, grime = true } },
    { h0 = 3.2, h1 = 6.1, off = 0.4, wall = { infill = "plaster", ramp = PL_ROSE, posts = { 0.15, 3.5, 7, 10.5, 13.85 }, beams = { 3.3, 6.0 },
      braces = "x", bz = { 3.4, 5.9 }, wins = row({ 1.8, 5.2, 8.8, 12.2 }, 1.1, 3.9, 5.4, { box = true }) } },
    { h0 = 6.1, h1 = 9.0, off = 0.7, wall = { infill = "plaster", ramp = PL_ROSE, posts = { 0.15, 7, 13.85 }, beams = { 6.2, 8.9 },
      braces = "k", bz = { 6.3, 8.8 }, wins = row({ 3.5, 10.5 }, 1.2, 6.9, 8.3, { shut = SHUT_G }) } } },
  roof = { kind = "side", ridge = 12.6, dr = 3.2, ov = 0.5, ramp = SH_GOLD, style = "tile" } }
building{ id = 4, side = -1, z0 = 72, z1 = 108, xs = 12,
  floors = {
    { h0 = 0, h1 = 3.3, wall = { infill = "stone", ramp = STONE_W, beams = { 3.2 },
      doors = { { 19.2, 21.0, 2.9, arch = true, ramp = TIMBER_R, glass = true } },
      wins = row({ 4, 9, 14.5, 25.5, 31 }, 2.0, 0.9, 2.7, { arch = true }) } },
    { h0 = 3.3, h1 = 6.4, off = 0.5, wall = { infill = "plaster", ramp = PL_CREAM, timber = TIMBER_R, posts = { 0.15, 4.5, 9, 13.5, 18, 22.5, 27, 31.5, 35.85 },
      beams = { 3.4, 6.3 }, braces = "x", bz = { 3.5, 6.2 }, wins = row({ 2.25, 6.75, 11.25, 15.75, 20.25, 24.75, 29.25, 33.75 }, 1.3, 4.0, 5.6, { box = true, shut = SHUT_R }) } },
    { h0 = 6.4, h1 = 9.4, off = 0.9, wall = { infill = "plaster", ramp = PL_CREAM, timber = TIMBER_R, posts = { 0.15, 6, 12, 18, 24, 30, 35.85 },
      beams = { 6.5, 9.3 }, braces = "v", bz = { 6.6, 9.2 }, wins = row({ 3, 9, 15, 21, 27, 33 }, 1.2, 7.1, 8.5, { alt = { glass = "dim" } }) } } },
  roof = { kind = "side", ridge = 13.8, dr = 3.6, ov = 0.6, ramp = SH_SLATE, style = "shingle", moss = true },
  chimneys = { { x = 14.6, z = 80, w = 1.2, d = 1.2, b = 11, t = 15.6, ramp = BRICK }, { x = 14.6, z = 101, w = 1.2, d = 1.2, b = 11, t = 15, ramp = STONE } },
  awnings = { { za0 = 88.6, za1 = 92.6, h = 3.1, proj = 1.3, drop = 0.6, A = AW_GOLD, B = AW_CREAM } } }
building{ id = 5, side = -1, z0 = 108, z1 = 118, xs = 12,
  floors = {
    { h0 = 0, h1 = 3.2, wall = { infill = "clap", ramp = BOARD_BLUE, foot = 0.4, posts = { 0.15, 9.85 }, beams = { 3.1 }, wins = { { 2, 6, 1, 2.6, mull = "grid" } }, doors = { { 7.2, 8.6, 2.6, ramp = SHUT_R } } } },
    { h0 = 3.2, h1 = 6.4, off = 0.4, wall = { infill = "plaster", ramp = PL_BLUE, posts = { 0.15, 5, 9.85 }, beams = { 3.3, 6.3 }, braces = "x", bz = { 3.4, 6.2 }, wins = row({ 2.5, 7.5 }, 1.2, 4, 5.5, { box = true }) } } },
  roof = { kind = "side", ridge = 10.4, dr = 3.2, ov = 0.5, ramp = SH_PLUM, style = "scale" } }
-- RIGHT (side +1)
building{ id = 6, side = 1, z0 = 17, z1 = 34, xs = 12,
  floors = {
    { h0 = 0, h1 = 3.4, wall = { infill = "plaster", ramp = PL_SAGE, foot = 0.55, posts = { 0.15, 3.8, 8.6, 12.2, 16.85 }, beams = { 3.3 },
      doors = { { 9.6, 11.2, 2.75, ramp = SH_PLUM, glass = true } },
      wins = { { 4.6, 7.8, 0.95, 2.7, mull = "grid", curt = "#3f6a44" }, { 12.9, 16.1, 0.95, 2.7, mull = "grid", curt = "#3f6a44" } }, pipes = { 0.7 }, grime = true } },
    { h0 = 3.4, h1 = 6.6, off = 0.5, wall = { infill = "plaster", ramp = PL_SAGE, posts = { 0.15, 4.2, 8.5, 12.7, 16.85 }, beams = { 3.5, 6.5 },
      braces = "x", bz = { 3.6, 6.4 }, wins = row({ 2.15, 6.35, 10.6, 14.8 }, 1.3, 4.2, 5.8, { shut = SHUT_G, box = true, flower = { MOSS, SH_PLUM, MOSS, GOLD6 } }) } } },
  roof = { kind = "side", ridge = 11.6, dr = 3.8, ov = 0.6, ramp = SH_PLUM, style = "shingle", moss = true },
  chimneys = { { x = 14.5, z = 29, w = 1.2, d = 1.2, b = 8.5, t = 13.2, ramp = STONE } } }
building{ id = 7, side = 1, z0 = 34, z1 = 54, xs = 12,
  floors = {
    { h0 = 0, h1 = 3.4, wall = { infill = "clap", ramp = BOARD_BLUE, foot = 0.5, posts = { 0.15, 19.85 }, beams = { 3.3 },
      wins = { { 1.2, 7.0, 0.85, 2.75, mull = "grid" }, { 11.2, 18.6, 0.85, 2.75, mull = "grid" } },
      doors = { { 8.2, 9.9, 2.75, ramp = SHUT_R, glass = true } }, pipes = { 10.6 }, grime = true } },
    { h0 = 3.4, h1 = 6.5, off = 0.4, wall = { infill = "plaster", ramp = PL_BUTTER, posts = { 0.15, 5, 10, 15, 19.85 }, beams = { 3.5, 6.4 },
      braces = "k", bz = { 3.6, 6.3 }, wins = row({ 2.5, 7.5, 12.5, 17.5 }, 1.3, 4.2, 5.8, { shut = SHUT_B, box = true }), patch = { 9.8, 4.4, 0.7, 0.45 } } },
    { h0 = 6.5, h1 = 9.5, off = 0.7, wall = { infill = "plaster", ramp = PL_BUTTER, posts = { 0.15, 10, 19.85 }, beams = { 6.6, 9.4 },
      braces = "x", bz = { 6.7, 9.3 }, wins = row({ 5, 15 }, 1.3, 7.2, 8.6), gable = { infill = "batten", ramp = BOARD_W, win = true } } } },
  roof = { kind = "gable", ridge = 15, zm = 44, ov = 0.6, ramp = SH_TEAL, style = "shingle" },
  chimneys = { { x = 15.6, z = 50, w = 1.2, d = 1.2, b = 11, t = 16.4, ramp = BRICK } },
  awnings = { { za0 = 34.6, za1 = 53.4, h = 3.2, proj = 1.6, drop = 0.8, A = AW_GREEN, B = AW_CREAM } } }
building{ id = 8, side = 1, z0 = 54, z1 = 66, xs = 12.2,
  floors = {
    { h0 = 0, h1 = 3.2, wall = { infill = "brick", ramp = BRICK, foot = 0.4, beams = { 3.1 }, doors = { { 1.4, 2.9, 2.6, ramp = SHUT_G, arch = true } }, wins = { { 4.5, 10.5, 0.9, 2.6, mull = "grid" } } } },
    { h0 = 3.2, h1 = 6.2, off = 0.3, wall = { infill = "plaster", ramp = PL_CREAM, timber = TIMBER_R, posts = { 0.15, 4, 8, 11.85 }, beams = { 3.3, 6.1 },
      braces = "v", bz = { 3.4, 6.0 }, wins = row({ 2, 6, 10 }, 1.2, 3.9, 5.4, { box = true }) } },
    { h0 = 6.2, h1 = 9.2, off = 0.6, wall = { infill = "plaster", ramp = PL_CREAM, timber = TIMBER_R, posts = { 0.15, 6, 11.85 }, beams = { 6.3, 9.1 },
      braces = "x", bz = { 6.4, 9.0 }, wins = row({ 3, 9 }, 1.2, 6.9, 8.3, { shut = SHUT_B }) } } },
  roof = { kind = "side", ridge = 13.6, dr = 3.3, ov = 0.5, ramp = SH_RED, style = "tile" },
  chimneys = { { x = 14.8, z = 61, w = 1.1, d = 1.1, b = 11, t = 15, ramp = BRICK } } }
building{ id = 9, side = 1, z0 = 66, z1 = 104, xs = 14.5,
  floors = {
    { h0 = 0, h1 = 3.6, wall = { infill = "batten", ramp = BOARD_W, foot = 0.45, posts = { 0.15, 12.5, 25, 37.85 }, beams = { 3.5 },
      doors = { { 5, 8.4, 3.0, kind = "barn", ramp = BOARD_RED }, { 28, 31.4, 3.0, kind = "barn", ramp = BOARD_RED } }, wins = row({ 15.5, 19, 22.5 }, 1.2, 1.4, 2.6, { glass = "dim" }) } },
    { h0 = 3.6, h1 = 6.0, wall = { infill = "batten", ramp = BOARD_W, posts = { 0.15, 12.5, 25, 37.85 }, beams = { 5.9 }, wins = row({ 6.7, 18.75, 29.7 }, 1.6, 4.0, 5.4, { glass = "dark" }) } } },
  roof = { kind = "side", ridge = 9.8, dr = 3.6, ov = 0.6, ramp = SH_CEDAR, style = "shingle", moss = true } }
building{ id = 10, side = 1, z0 = 104, z1 = 118, xs = 12,
  floors = {
    { h0 = 0, h1 = 3.2, wall = { infill = "plaster", ramp = PL_ROSE, foot = 0.4, posts = { 0.15, 13.85 }, beams = { 3.1 }, wins = { { 2, 6.5, 1, 2.6, mull = "grid" } }, doors = { { 8, 9.5, 2.6, ramp = SHUT_B } } } },
    { h0 = 3.2, h1 = 6.3, off = 0.4, wall = { infill = "plaster", ramp = PL_ROSE, posts = { 0.15, 4.6, 9.2, 13.85 }, beams = { 3.3, 6.2 }, braces = "x", bz = { 3.4, 6.1 }, wins = row({ 2.3, 6.9, 11.5 }, 1.2, 3.9, 5.4) } },
    { h0 = 6.3, h1 = 9.2, off = 0.6, wall = { infill = "plaster", ramp = PL_ROSE, posts = { 0.15, 7, 13.85 }, beams = { 6.4, 9.1 }, braces = "v", bz = { 6.5, 9 }, wins = row({ 3.5, 10.5 }, 1.2, 7, 8.4) } } },
  roof = { kind = "side", ridge = 13.2, dr = 3.2, ov = 0.5, ramp = SH_SLATE, style = "scale" } }

-- TOWN HALL (Z=120, faces the viewer) + leaning clock tower
local HZ = 120
local LEAN = 0.15
do
  local hallTex = wallTex{ L = 40, infill = "stone", ramp = STONE_W, beams = { 4.2, 8.5 },
    doors = { { 18.3, 21.7, 3.6, arch = true, ramp = TIMBER_R, glass = true } },
    wins = { { 5.1, 6.9, 1.0, 3.0, arch = true }, { 10.1, 11.9, 1.0, 3.0, arch = true }, { 28.1, 29.9, 1.0, 3.0, arch = true }, { 33.1, 34.9, 1.0, 3.0, arch = true },
      { 3.3, 4.7, 5.2, 7.4, shut = SHUT_B }, { 8.3, 9.7, 5.2, 7.4, shut = SHUT_B }, { 13.3, 14.7, 5.2, 7.4, shut = SHUT_B },
      { 25.3, 26.7, 5.2, 7.4, shut = SHUT_B }, { 30.3, 31.7, 5.2, 7.4, shut = SHUT_B }, { 35.3, 36.7, 5.2, 7.4, shut = SHUT_B },
      { 18.4, 21.6, 5.0, 7.9, arch = true, mull = "grid" } }, seed = 40 }
  local upTex = wallTex{ L = 40, infill = "plaster", ramp = PL_BUTTER, posts = { 0.15, 2.5, 5.5, 11.5, 16.5, 23.5, 28.5, 34.5, 37.5, 39.85 }, beams = { 4.3, 8.5 }, braces = "x", bz = { 4.4, 8.4 },
    wins = { { 3.3, 4.7, 5.2, 7.4, shut = SHUT_B, box = true }, { 8.3, 9.7, 5.2, 7.4, shut = SHUT_B, box = true }, { 13.3, 14.7, 5.2, 7.4, shut = SHUT_B, box = true },
      { 25.3, 26.7, 5.2, 7.4, shut = SHUT_B, box = true }, { 30.3, 31.7, 5.2, 7.4, shut = SHUT_B, box = true }, { 35.3, 36.7, 5.2, 7.4, shut = SHUT_B, box = true },
      { 18.4, 21.6, 5.0, 7.9, arch = true, mull = "grid" } }, seed = 41 }
  addPrim({ { -20, 0, HZ }, { 20, 0, HZ }, { 20, 4.25, HZ }, { -20, 4.25, HZ } }, { tex = hallTex, bid = 20, O = { -20, 0, HZ }, U = { 1, 0, 0 }, V = { 0, 1, 0 } })
  addPrim({ { -20, 4.25, HZ }, { 20, 4.25, HZ }, { 20, 8.6, HZ }, { -20, 8.6, HZ } }, { tex = upTex, bid = 20, O = { -20, 0, HZ }, U = { 1, 0, 0 }, V = { 0, 1, 0 } })
  local he, ridge, zr = 8.2, 14, 125.5
  local vy, vz = ridge - he, zr - (HZ - 0.5)
  local Lv = sqrt(vy * vy + vz * vz)
  addPrim({ { -20.6, he, HZ - 0.5 }, { 20.6, he, HZ - 0.5 }, { 20.6, ridge, zr }, { -20.6, ridge, zr } },
    { tex = roofTex{ ramp = SH_RED, Lu = 41.2, Lv = Lv, style = "scale", seed = 21, barge0 = true, barge1 = true }, bid = 20, O = { -20.6, he, HZ - 0.5 }, U = { 1, 0, 0 }, V = { 0, vy / Lv, vz / Lv } })
  -- tower front (leans right)
  local TZ, tb, tt = 121.6, 9.6, 22
  local function lx(x, h) return x + LEAN * (h - tb) end
  local towerTex = function(u, v, fu, fv)
    local uu = u - LEAN * (v - tb)
    if v > tt - 1.0 then return TIMBER, (v > tt - 0.25) and 1 or ((v < tt - 0.8) and -1 or 0) end
    if uu < 0.4 or uu > 4.4 then
      local k = floor((v - tb) / 0.5)
      if (k % 2 == 0) == (uu < 0.4) then return STONE_W, 1 end
      return STONE_W, (fr((v - tb) / 0.5) < 0.12) and -1 or 0
    end
    if v > 18.6 and v < 20.8 and uu > 1.0 and uu < 3.8 then
      local r = 1.4
      if v < 20.8 - r or (uu - 2.4)^2 + (v - (20.8 - r))^2 <= r * r then
        if v < 19.6 and abs(uu - 2.4) < 0.25 + (19.6 - v) * 0.45 and v > 18.85 then return GOLD6, 1 end
        return nil, nil, "#2c2440"
      end
    end
    if lnd(v, 18.3, 0.2, fv) then return TIMBER, 0 end
    return infill("plaster", PL_CREAM, u, v, fu, fv, 44)
  end
  addPrim({ { lx(-2.4, tb), tb, TZ }, { lx(2.4, tb), tb, TZ }, { lx(2.4, tt), tt, TZ }, { lx(-2.4, tt), tt, TZ } },
    { tex = towerTex, bid = 21, O = { -2.4, tb, TZ }, U = { 1, 0, 0 }, V = { 0, 1, 0 } })
  local ax, ah = lx(0, 29.5), 29.5
  local function spTex(u, v, fu, fv)
    if v < max(0.2, fv) then return TIMBER, 1 end
    local k = floor(v / 0.4)
    if fr(v / 0.4) > 1 - max(0.15, fv / 0.4) then return SH_SLATE, -1 end
    local uu = u / 0.45 + (k % 2) * 0.5
    if fu < 0.2 and fr(uu) < max(0.1, fu / 0.45) then return SH_SLATE, -1 end
    return SH_SLATE, (hash(k, floor(uu), 8) < 0.15) and -1 or 0
  end
  local p1, p2, p3 = { lx(-2.8, tt), tt, TZ - 0.4 }, { lx(2.8, tt), tt, TZ - 0.4 }, { ax, ah, TZ + 2.2 }
  local vx2, vy2, vz2 = p3[1] - lx(0, tt), p3[2] - tt, p3[3] - p1[3]
  local l2 = sqrt(vx2 * vx2 + vy2 * vy2 + vz2 * vz2)
  addPrim({ p1, p2, p3 }, { tex = spTex, bid = 21, O = p1, U = { 1, 0, 0 }, V = { vx2 / l2, vy2 / l2, vz2 / l2 } })
end

-- invisible shadow casters: gate, fountain, stalls
addPrim({ { -12, 8.6, 17.2 }, { 12, 8.6, 17.2 }, { 12, 9.9, 17.2 }, { -12, 9.9, 17.2 } }, { hide = true, tex = ledgeTex })
addPrim({ { -10.7, 0, 17.2 }, { -8.8, 0, 17.2 }, { -8.8, 9.9, 17.2 }, { -10.7, 9.9, 17.2 } }, { hide = true, tex = ledgeTex })
addPrim({ { 8.8, 0, 17.2 }, { 10.7, 0, 17.2 }, { 10.7, 9.9, 17.2 }, { 8.8, 9.9, 17.2 } }, { hide = true, tex = ledgeTex })
addPrim({ { -1.6, 0, 22.6 }, { 1.6, 0, 22.6 }, { 1.6, 0.9, 22.6 }, { -1.6, 0.9, 22.6 } }, { hide = true, tex = ledgeTex })
addPrim({ { -0.6, 0, 24 }, { 0.6, 0, 24 }, { 0.6, 3.3, 24 }, { -0.6, 3.3, 24 } }, { hide = true, tex = ledgeTex })
addPrim({ { 4.4, 0, 53 }, { 9.8, 0, 53 }, { 9.8, 4.4, 53 }, { 4.4, 4.4, 53 } }, { hide = true, tex = ledgeTex })

------------------------------------------------------------------ BACKGROUND (2D): sky, clouds, hills, the great maple behind the hall
c:stripes(0, 111, { "#7fb4e4", "#9ccaec", "#bfdcf0", "#e2dfee", "#f6dcc4" }, { 3, 3, 3, 2, 2 })
c:cloud(118, 52, 58, "#fff0d8", "#f0c8bc")
c:cloud(150, 44, 30, "#fff0d8", "#f0c8bc")
c:cloud(296, 40, 46, "#fbeedc", "#e8c4c4")
c:cloud(352, 70, 34, "#fbeedc", "#e8c4c4")
c:cloud(196, 80, 22, "#f6e6dc", "#e2c0c6")
for _, g in ipairs({ { 300, 50 }, { 306, 53 }, { 312, 56 }, { 306, 47 }, { 312, 44 }, { 180, 60 }, { 186, 63 } }) do
  px(g[1] - 1, g[2], "#5a4a6e") px(g[1], g[2] + 1, "#5a4a6e") px(g[1] + 1, g[2], "#5a4a6e")
end
c:terrain(function(x) return 90 + 5 * sin(x / 37) + 2 * sin(x / 11) end, "#bca8d8", 111)
c:terrain(function(x) return 99 + 3 * sin(x / 23 + 1) + 1.5 * sin(x / 7) end, "#a08ac8", 111)
for x = 0, W - 1 do local y = floor(99 + 3 * sin(x / 23 + 1) + 1.5 * sin(x / 7) + 0.5) if x % 5 < 2 then px(x, y, "#b49ed4") end end
c:terrain(function(x) return 105 + 2 * sin(x / 6) + 1.5 * sin(x / 2.7) end, "#9a6a92", 111)

local function crown(shape, pick, o)
  o = o or {}
  local seed = o.seed or 1
  local x0, y0, x1, y1 = shape:bbox()
  local step = o.step or 10
  local cl = {}
  local i = 0
  for yy = y0, y1, step - 2 do for xx = x0, x1, step do
    i = i + 1
    local rowo = (floor((yy - y0) / (step - 2)) % 2) * step * 0.5
    local cx = floor(xx + rowo + hash(i, 3, seed) * step * 0.6 - step * 0.3)
    local cy = floor(yy + hash(i, 5, seed) * 3 - 1.5)
    if shape:has(cx, cy) then
      cl[#cl + 1] = { cx, cy, (o.r or 7) * (0.75 + 0.5 * hash(i, 7, seed)) }
    end
  end end
  table.sort(cl, function(a, b) return a[2] < b[2] end)
  local all = HP.mask()
  for _, k in ipairs(cl) do all:add(E(k[1], k[2], k[3], k[3] * 0.85)) end
  fm(all, o.inner or "#4a1838")
  for j, k in ipairs(cl) do
    local m = E(k[1], k[2], k[3], k[3] * 0.85)
    local cut, add = HP.mask(), HP.mask()
    m:edge():each(function(x, y)
      local hq = hash(x, y, j + seed)
      if hq < 0.3 then cut:set(x, y) elseif hq > 0.84 then
        add:set(x + ((x > k[1]) and 1 or -1), y + ((y > k[2]) and 1 or -1))
      end
    end)
    m:cut(cut) m:add(add)
    local n = HX.sphere(k[1] - 1, k[2] - 1, k[3], m)
    local v = HX.light(n, { amb = 0.1, wrap = 0.35 })
    local R = pick(k[1], k[2])
    local b = (o.dark and o.dark(k[1], k[2])) and -1 or 0
    local bias = {}
    if b ~= 0 then m:each(function(x, y) bias[HX.K(x, y)] = b end) end
    HX.tone(c, m, v, R, { cuts = { 0.16, 0.34, 0.55, 0.76 }, bias = bias })
    for qn = 0, floor(k[3] * k[3] / 9) do
      local lx = floor(k[1] - k[3] + hash(j * 13 + qn, 21, seed) * 2 * k[3])
      local ly = floor(k[2] - k[3] + hash(qn, j * 7 + 23, seed) * 2 * k[3])
      if m:has(lx - 1, ly) and m:has(lx + 1, ly) and m:has(lx, ly + 1) then
        local lit = (lx - k[1]) + (ly - k[2]) < 0
        local col = lit and R[5] or R[2]
        px(lx - 1, ly, col) px(lx, ly + 1, col) px(lx + 1, ly, col)
      end
    end
  end
  return all
end
local function mapleRamp(x, y)
  local v = sin(x / 23 + y / 17) + cos(x / 31 - y / 13)
  return v > 0.6 and MG or (v < -0.4 and MR or MO)
end
do -- the great red-and-gold maple behind the town hall
  for _, br in ipairs({ { { 244, 110 }, { 240, 80 }, { 222, 52 } }, { { 242, 90 }, { 270, 58 } }, { { 238, 84 }, { 200, 70 } }, { { 246, 96 }, { 296, 76 } } }) do
    fm(c:line(br, 3), "#4a2a36")
  end
  local sh = E(244, 54, 74, 34):add(E(184, 70, 34, 22)):add(E(306, 70, 34, 22)):add(E(244, 30, 46, 22))
  crown(sh, mapleRamp, { r = 9, step = 12, seed = 3, inner = "#5a1c38", dark = function(x, y) return y > 74 or x > 318 end })
end

------------------------------------------------------------------ RAY CAST
local TS = 16
local TW, TH = ceil(W / TS), ceil(H / TS)
local TILES = {}
for _, p in ipairs(PR) do
  local sb = p.sb
  for ty = max(0, sb[2] // TS), min(TH - 1, sb[4] // TS) do
    for tx = max(0, sb[1] // TS), min(TW - 1, sb[3] // TS) do
      local key = ty * TW + tx
      TILES[key] = TILES[key] or {}
      table.insert(TILES[key], p)
    end
  end
end

local ROW = {}
do
  local y, k = 112, 0
  while y < H do
    local s = max(1, floor(1 + (y - 112) * 0.072))
    for yy = y, min(H - 1, y + s - 1) do ROW[yy] = { k, y, s } end
    y, k = y + s, k + 1
  end
end
local RB, XB, EB, TB, IB, GB, SB = {}, {}, {}, {}, {}, {}, {}
local GATE_Y, RW = 229, 4.2
local PUD = { { X = -6.5, Z = 55, rx = 1.4, rz = 2.6 }, { X = 7.8, Z = 30, rx = 1.3, rz = 1.0 }, { X = -1.2, Z = 80, rx = 1.2, rz = 3.0 }, { X = 1.6, Z = 14.2, rx = 1.2, rz = 0.45 } }

local function cobble(x, y, Xw, Zw, base)
  local r = ROW[y]
  local s = r[3]
  local yy = y - r[2]
  local wpx = max(2, floor(1.8 * s + 0.5))
  local Wst = wpx * Zw / F
  local ro = hash(r[1], 17, 2)
  local function colOf(xx) return floor((xx + 0.5 - VX) * Zw / F / Wst + ro) end
  local col = colOf(x)
  local mort = (s >= 2 and yy == s - 1) or colOf(x - 1) ~= col
  if s >= 4 and (yy == 0 or yy == s - 2) and (colOf(x - 2) ~= col or colOf(x + 1) ~= col) then mort = true end
  if mort then
    if hash(x, y, 3) < 0.16 then return MOSS, base - 2 end
    return COBBLE, base - 2
  end
  local hs = hash(r[1], col, 11)
  local R = COBBLE
  if hs > 0.93 then R = COB_W elseif hs < 0.06 then R = COB_B end
  local off = (hs < 0.22) and -1 or ((hs > 0.84) and 1 or 0)
  if s >= 3 then
    if yy == 0 then off = off + 1 end
    if yy == s - 2 then off = off - 1 end
    if colOf(x + 1) ~= col then off = off - 1 end
  elseif s == 1 then off = off + ((r[1] % 2 == 0) and 0 or -1) end
  return R, base - 1 + off
end
local function flags(x, y, Xw, Zw, base)
  local r = ROW[y]
  local rr = r[1] // 2
  if r[1] % 2 == 1 and y == r[2] + r[3] - 1 then return FLAG, base - 2 end
  local o = hash(rr, 9, 1)
  local function cl(xx) return floor((xx + 0.5 - VX) * Zw / F / 0.9 + o) end
  local col = cl(x)
  if cl(x - 1) ~= col then return FLAG, base - 2 end
  local hs = hash(rr, col, 13)
  return FLAG, base - 1 + ((hs < 0.25) and -1 or (hs > 0.85 and 1 or 0))
end
local function verge(x, y)
  local qq = hash(x, y, 21)
  local g = sin(x * 0.13 + y * 0.05) + sin(x * 0.041 - y * 0.11)
  if g > 0.1 then
    if hash(x, y // 2, 22) < 0.22 then return GRASS, 6 end
    if qq < 0.4 then return GRASS, 4 end
    return GRASS, 5
  end
  if qq < 0.08 then return EARTH, 3 elseif qq > 0.95 then return EARTH, 6 end
  return EARTH, 5
end
local function reflectCol(Xw, Zw, dx, dy)
  local bt, bp, qx, qy, qz = 1e9
  for i = 1, #PR do
    local t, a, b, cc = hitPrim(PR[i], Xw, 0, Zw, dx, -dy, 1, bt)
    if t then bt, bp, qx, qy, qz = t, PR[i], a, b, cc end
  end
  if not bp then return nil end
  local u, v = luv(bp, qx, qy, qz)
  local R, idx, emi = shadeHit(bp, qx, qy, qz, dx, -dy, 1, u, v, 0.12, 0.12, false)
  if emi then return emi end
  return R[max(1, min(6, idx - 1))]
end
local function ground(x, y, k, dx, dy, t)
  local Xw, Zw = t * dx, t
  GB[k] = true
  local R, idx
  if y >= GATE_Y then
    if abs(Xw) <= RW then
      local edge = RW - abs(Xw)
      if edge < 0.28 then R, idx = STONE_W, (edge < 0.12) and 3 or 5
      else R, idx = cobble(x, y, Xw, Zw, 6) end
    elseif Xw < 0 then R, idx = verge(x, y)
    else R, idx = EARTH, (y < GATE_Y + 3) and 3 or 4 end
    SB[k] = true
  else
    local lit = not shadowed(Xw, 0, Zw, nil)
    SB[k] = lit
    local base = lit and 6 or 3
    local aX = abs(Xw)
    if aX >= 10.65 then R, idx = flags(x, y, Xw, Zw, base)
    elseif aX >= 10.3 then R, idx = FLAG, (aX < 10.4) and base - 3 or base
    elseif aX >= 9.9 then R, idx = COBBLE, base - 2
    else R, idx = cobble(x, y, Xw, Zw, base) end
  end
  for _, pd in ipairs(PUD) do
    local e = ((Xw - pd.X) / pd.rx)^2 + ((Zw - pd.Z) / pd.rz)^2
    if e < 1 then
      if e > 0.78 then R, idx = COBBLE, 2
      else
        local col = reflectCol(Xw, Zw, dx, dy)
        if not col then col = "#b8cce6" end
        if (y % 3 == 0 and hash(x // 4, y, 6) < 0.35) then col = "#e4eef8" end
        EB[k] = col
        return
      end
    end
  end
  RB[k], XB[k] = R, idx
end

for y = 0, H - 1 do
  local dy = -(y + 0.5 - VY) / F
  for x = 0, W - 1 do
    local dx = (x + 0.5 - VX) / F
    local k = y * W + x
    local tl = TILES[(y // TS) * TW + (x // TS)]
    local bt, bp, qx, qy, qz = 1e9
    if tl then
      for i = 1, #tl do
        local p = tl[i]
        local sb = p.sb
        if x >= sb[1] and x <= sb[3] and y >= sb[2] and y <= sb[4] then
          local t, a, b, cc = hitPrim(p, 0, EYE, 0, dx, dy, 1, bt)
          if t then bt, bp, qx, qy, qz = t, p, a, b, cc end
        end
      end
    end
    local gt = (dy < 0) and (EYE / -dy) or 1e9
    if bp and bt < gt then
      local u0, v0 = luv(bp, qx, qy, qz)
      local fu, fv = 0.05, 0.05
      local ax, ay, az = planeAt(bp, 0, EYE, 0, dx + 1 / F, dy, 1)
      local bx, by, bz = planeAt(bp, 0, EYE, 0, dx, dy - 1 / F, 1)
      if ax and bx then
        local u1, v1 = luv(bp, ax, ay, az)
        local u2, v2 = luv(bp, bx, by, bz)
        fu = min(20, max(abs(u1 - u0), abs(u2 - u0)))
        fv = min(20, max(abs(v1 - v0), abs(v2 - v0)))
      end
      local R, idx, emi = shadeHit(bp, qx, qy, qz, dx, dy, 1, u0, v0, fu, fv, true)
      TB[k], IB[k] = bt, bp.bid
      if emi then EB[k] = emi
      else
        if bt > 85 and idx <= 2 then idx = idx + 1 end
        if bt > 100 and idx >= 6 then idx = 5 end
        RB[k], XB[k] = R, idx
      end
    elseif dy < 0 then
      ground(x, y, k, dx, dy, gt)
    end
  end
end
print(string.format("raycast %.1fs, prims %d", os.clock() - T0, #PR))

-- 1px dark edge in each surface's own darker tone (buildings only)
do
  local EDGE = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local k = y * W + x
    if IB[k] and RB[k] then
      local t = TB[k]
      for _, o in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local xx, yy = x + o[1], y + o[2]
        if xx >= 0 and xx < W and yy >= 0 and yy < H then
          local kk = yy * W + xx
          local tt = TB[kk]
          if not tt then
            if not GB[kk] then EDGE[k] = true end
          elseif tt > t + ((IB[kk] == IB[k]) and 3 or 1.2) then EDGE[k] = true end
        end
      end
    end
  end end
  for k in pairs(EDGE) do XB[k] = min(XB[k], 4) - 2 end
end
for k, R in pairs(RB) do
  if not EB[k] then c:put(k % W, k // W, R[max(1, min(#R, XB[k]))]) end
end
for k, hex in pairs(EB) do c:put(k % W, k // W, hex) end

------------------------------------------------------------------ 2D OVERLAYS (depth-clipped against the cast buildings)
local ZCLIP
local rawput = c.put
function c:put(x, y, hex, o)
  if ZCLIP then
    local t = TB[y * W + x]
    if t and t < ZCLIP then return end
  end
  return rawput(self, x, y, hex, o)
end
local function T(R, i) return R[max(1, min(#R, i))] end
local STAND = { { 196, 170 }, { 286, 166 }, { 168, 216 }, { 300, 226 }, { 120, 186 }, { 380, 186 } }
local function nearStand(x, y, rx, ry)
  for _, s in ipairs(STAND) do if ((x - s[1]) / (rx or 16))^2 + ((y - s[2]) / (ry or 11))^2 < 1 then return true end end
  return false
end
local function calm(x, y) return x >= 376 and y >= 228 end

local function sph(m, cx, cy, r, R, o)
  o = o or {}
  local n = HX.sphere(cx, cy, r, m)
  local v = HX.light(n, { amb = o.amb or 0.2, wrap = o.wrap or 0.3 })
  local cuts = {}
  for i = 1, #R - 1 do cuts[i] = (o.lo or 0.12) + (i - 1) * (0.8 / (#R - 1)) end
  return HX.tone(c, m, v, R, { cuts = cuts })
end
local function pillow(m, R, rad)
  local n = HX.pillow(m, rad or 2)
  local v = HX.light(n, { amb = 0.3, wrap = 0.2 })
  local cuts = {}
  for i = 1, #R - 1 do cuts[i] = 0.12 + (i - 1) * (0.8 / (#R - 1)) end
  return HX.tone(c, m, v, R, { cuts = cuts })
end
local function cylMask(m, x0, x1, R, lo)
  local cx, hw = (x0 + x1) / 2, (x1 - x0) / 2 + 0.5
  m:each(function(x, y)
    local t = (x + 0.5 - cx) / hw
    local nz = sqrt(max(0.05, 1 - t * t))
    local lv = 0.22 + 0.78 * max(0, -0.62 * t + 0.78 * nz)
    px(x, y, T(R, floor(lv * #R * 0.999) + 1 + (lo or 0)))
  end)
end
local function barrel(cx, ytop, w, h, R)
  local x0, x1 = cx - floor(w / 2), cx + floor(w / 2)
  local m = HP.mask()
  for y = ytop, ytop + h - 1 do
    local b = floor(1.2 * sin((y - ytop) / (h - 1) * PI) + 0.5)
    for x = x0 - b + 1, x1 + b - 1 do m:set(x, y) end
  end
  c:rim(m, R[1])
  cylMask(m, x0, x1, R)
  m:each(function(x, y)
    local yy = y - ytop
    if (x - x0) % 3 == 0 then px(x, y, c:get(x, y) == R[6] and R[5] or T(R, 2)) end
    if yy == 2 or yy == h - 3 or (h > 9 and yy == floor(h / 2)) then px(x, y, T(STONE, (x < cx) and 4 or 2)) end
  end)
  local lid = E(cx, ytop, floor(w / 2) - 1, 1)
  fm(lid, R[5]) px(cx - 1, ytop, R[6])
  return m
end
local function mapleLeaf(cx, cy, R, sc)
  local pat = sc and sc > 1 and { "...x...", ".x.x.x.", ".xxxxx.", "xxxxxxx", ".xxxxx.", "...x...", "...x..." }
    or { "..x..", "x.x.x", "xxxxx", ".xxx.", "..x.." }
  local hh = #pat
  local ww = #pat[1]
  for j = 1, hh do for i = 1, ww do
    if pat[j]:sub(i, i) == "x" then
      local x, y = cx - ww // 2 + i - 1, cy - hh // 2 + j - 1
      local tone = (i + j < ww * 0.7) and 5 or ((i + j > ww + 1) and 3 or 4)
      if i == (ww + 1) // 2 and j > 2 then tone = 2 end
      px(x, y, T(R, tone))
    end
  end end
end
local function mitten(cx, cy, R)
  local pat = { ".xx..", "xxxx.", "xxxxx", "xxxxx", ".xxxx", ".cccc" }
  for j = 1, #pat do for i = 1, 5 do
    local ch = pat[j]:sub(i, i)
    if ch == "x" then px(cx - 2 + i - 1, cy - 3 + j - 1, T(R, (i + j < 5) and 5 or ((j > 4 or i > 4) and 3 or 4)))
    elseif ch == "c" then px(cx - 2 + i - 1, cy - 3 + j - 1, (i % 2 == 0) and AW_CREAM[5] or AW_CREAM[4]) end
  end end
end
local function puff(x, y, r, a, b)
  local m = E(x, y, r, r * 0.8):add(E(x + r * 0.7, y + 1, r * 0.7, r * 0.6)):add(E(x - r * 0.6, y + 1, r * 0.6, r * 0.5))
  fm(m, a or "#e8e2ea")
  m:each(function(xx, yy) if not m:has(xx + 1, yy + 1) or not m:has(xx, yy + 2) then px(xx, yy, b or "#c4bccc") end end)
  m:each(function(xx, yy) if not m:has(xx - 1, yy - 1) and hash(xx, yy, 2) < 0.6 then px(xx, yy, "#fbf4ec") end end)
end
local function smoke(x, y, n, s)
  for i = 0, n - 1 do
    puff(x + i * 3 + floor(1.5 * sin(i * 1.3)), y - i * 4, (s or 2) + i * 0.6, nil, nil)
  end
end
local function bracketSign(wx, wy, ox, w, h, R, icon, shape)
  local dir = (ox > wx) and 1 or -1
  fm(c:line({ { wx, wy }, { ox, wy } }, 1), INKW)
  fm(c:line({ { wx, wy + floor(h * 0.4) }, { wx + dir * floor(abs(ox - wx) * 0.45), wy } }, 1), INKW)
  px(ox, wy - 1, INKW) px(ox - dir, wy - 2, INKW)
  local cx = floor((wx + ox) / 2 + dir * 1)
  local x0 = cx - floor(w / 2)
  local y0 = wy + 3
  px(x0 + 2, wy + 1, INKW) px(x0 + 2, wy + 2, INKW) px(x0 + w - 3, wy + 1, INKW) px(x0 + w - 3, wy + 2, INKW)
  local m
  if shape == "shield" then
    m = c:poly{ { x0, y0 }, { x0 + w, y0 }, { x0 + w, y0 + h * 0.6 }, { x0 + w / 2, y0 + h }, { x0, y0 + h * 0.6 } }
  else
    m = c:rrect(x0, y0, x0 + w - 1, y0 + h - 1, 2)
  end
  c:rim(m, R[1])
  pillow(m, R, 2)
  m:shrink(1):edge():each(function(x, y) if (x + y) % 2 == 0 then px(x, y, R[2]) end end)
  icon(cx, y0 + floor(h / 2))
  return cx, y0
end

-- icons (no text)
local function iconJug(cx, cy, s)
  s = s or 1
  local body = E(cx, cy + 2 * s, 4.5 * s, 4.5 * s)
  local neck = Rm(cx - 1.5 * s, cy - 5 * s, cx + 1 * s, cy - 1 * s)
  local hand = E(cx + 4 * s, cy - 1 * s, 2.5 * s, 3 * s):cut(E(cx + 4 * s, cy - 1 * s, 1.2 * s, 1.6 * s)):cut(body)
  local all = body:copy():add(neck):add(hand)
  c:rim(all, AMBER[1])
  sph(body, cx - 1, cy + s, 4.5 * s, AMBER)
  cylMask(neck, floor(cx - 1.5 * s), floor(cx + s), AMBER)
  fm(hand, AMBER[3])
  fm(Rm(cx - 1.5 * s, cy - 6 * s, cx + 1 * s, cy - 5 * s), TIMBER[5])
  mapleLeaf(cx, cy + 3 * s, MR, s > 1.2 and 2 or 1)
  px(cx - 3 * s, cy, GL[6]) px(cx - 3 * s, cy + 1, GL[5])
end
local function iconPie(cx, cy, s)
  s = s or 1
  local dish = c:poly{ { cx - 7 * s, cy + 2 * s }, { cx + 7 * s, cy + 2 * s }, { cx + 5 * s, cy + 4 * s }, { cx - 5 * s, cy + 4 * s } }
  local crust = E(cx, cy + 2 * s, 7 * s, 5 * s):clip(Rm(cx - 9 * s, cy - 6 * s, cx + 9 * s, cy + 2 * s))
  c:rim(dish:copy():add(crust), INKW)
  fm(dish, STONE[4]) fm(Rm(cx - 7 * s, cy + 2 * s, cx + 7 * s, cy + 2 * s):clip(dish), STONE[6])
  sph(crust, cx - 2, cy - 1, 7 * s, GOLD6)
  crust:each(function(x, y) if (x + y) % 4 == 0 or (x - y) % 4 == 0 then px(x, y, GOLD6[3]) end end)
  for i = 0, 2 do px(cx - 3 + i * 3, cy - 5 * s - 2, "#e8e2ea") px(cx - 2 + i * 3, cy - 5 * s - 3, "#e8e2ea") end
end
local function iconMug(cx, cy, s)
  s = s or 1
  local body = Rm(cx - 4 * s, cy - 3 * s, cx + 2 * s, cy + 5 * s)
  local hand = Rm(cx + 3 * s, cy - 1 * s, cx + 5 * s, cy + 3 * s):cut(Rm(cx + 3 * s, cy, cx + 4 * s, cy + 2 * s))
  local foam = E(cx - 1, cy - 4 * s, 4 * s, 1.8 * s)
  local all = body:copy():add(hand):add(foam)
  c:rim(all, TIMBER[1])
  cylMask(body, floor(cx - 4 * s), floor(cx + 2 * s), TIMBER)
  fm(hand, TIMBER[4])
  fm(Rm(cx - 4 * s, cy - 1, cx + 2 * s, cy - 1), STONE[4]) fm(Rm(cx - 4 * s, cy + 3 * s, cx + 2 * s, cy + 3 * s), STONE[4])
  fm(foam, AW_CREAM[5]) px(cx - 3, cy - 5 * s, AW_CREAM[6]) px(cx + 1, cy - 3 * s, AW_CREAM[3])
  px(cx - 4 * s, cy - 2 * s, AW_CREAM[5])
end
local function iconHerb(cx, cy, s)
  s = s or 1
  for i = -2, 2 do
    local tip = { cx + i * 2 * s, cy - 5 * s - abs(i) * -0.5 }
    fm(c:line({ { cx, cy + 5 * s }, { cx + i * 0.5, cy + 1 }, tip }, 1), SHUT_G[3])
    local lm = E(tip[1], tip[2], 1.5 * s, 2 * s)
    fm(lm, (i % 2 == 0) and LEAFG[4] or LEAFG[3]) px(tip[1] - 1, tip[2] - 1, LEAFG[5])
    if i == -1 or i == 2 then px(tip[1], tip[2] - 2 * s, SH_PLUM[5]) px(tip[1], tip[2] - 2 * s - 1, SH_PLUM[6]) end
  end
  fm(Rm(cx - 2, cy + 2 * s, cx + 1, cy + 3 * s), GOLD6[4]) px(cx - 2, cy + 2 * s, GOLD6[6])
end
local function iconApple(cx, cy, s)
  s = s or 1
  local m = E(cx - 1.5 * s, cy, 3 * s, 3.5 * s):add(E(cx + 1.5 * s, cy, 3 * s, 3.5 * s))
  c:rim(m, APPLE[1])
  sph(m, cx - 1, cy - 1, 4.5 * s, APPLE)
  fm(Rm(cx, cy - 5 * s, cx, cy - 3 * s), TIMBER[3])
  local lf = E(cx + 2 * s, cy - 4 * s, 2 * s, 1)
  fm(lf, LEAFG[4]) px(cx - 2 * s, cy - 2 * s, AW_CREAM[6])
end

-- town hall extras (clock dial, banners, weathervane)
ZCLIP = 119
do
  local cx, cy = proj(LEAN * (16.3 - 9.6), 16.3, 121.6)
  cx, cy = floor(cx), floor(cy)
  local dial = c:rrect(cx - 4, cy - 4, cx + 4, cy + 4, 2)
  c:rim(dial, GOLD6[2])
  fm(dial, "#fbefd0")
  dial:edge():each(function(x, y) px(x, y, GOLD6[4]) end)
  for _, t in ipairs({ { 0, -3 }, { 3, 0 }, { 0, 3 }, { -3, 0 } }) do px(cx + t[1], cy + t[2], INKW) end
  px(cx, cy, INKW) px(cx, cy - 1, INKW) px(cx, cy - 2, INKW) px(cx + 1, cy, INKW) px(cx + 2, cy + 1, INKW)
  local ax, ay = proj(LEAN * (29.5 - 9.6), 29.5, 123.8)
  ax, ay = floor(ax), floor(ay)
  fm(Rm(ax, ay - 4, ax, ay), INKW)
  mapleLeaf(ax + 1, ay - 6, GOLD6)
  for _, bx in ipairs({ -6.5, 6.5 }) do
    local x, y = proj(bx, 8.2, HZ - 0.2)
    x, y = floor(x), floor(y)
    local bm = Rm(x - 2, y, x + 2, y + 8):cut(c:poly{ { x - 1, y + 9 }, { x, y + 7 }, { x + 1, y + 9 } })
    c:rim(bm, AW_RED[1]) fm(bm, AW_RED[4]) fm(Rm(x - 2, y, x - 2, y + 8), AW_RED[5]) fm(Rm(x + 2, y, x + 2, y + 8), AW_RED[3])
    px(x, y + 3, GOLD6[5]) px(x - 1, y + 4, GOLD6[4]) px(x + 1, y + 4, GOLD6[4]) px(x, y + 4, GOLD6[5]) px(x, y + 5, GOLD6[3])
  end
end

-- gold maple behind the barn (right)
ZCLIP = 95
do
  fm(c:line({ { 318, 134 }, { 319, 100 }, { 314, 88 } }, 3), "#4a2a36")
  local sh = E(320, 80, 22, 17):add(E(306, 90, 12, 9))
  crown(sh, function(x, y) return (sin(x / 9 + y / 7) > 0.3) and MO or MG end, { r = 6, step = 8, seed = 9, inner = "#6a3434", dark = function(x, y) return y > 88 end })
end

-- chimney smoke (far to near)
for _, ch in ipairs({ { 14.6, 101, 15, -1 }, { 14.6, 80, 15.6, -1 }, { 14.8, 61, 15, 1 }, { 15.6, 50, 16.4, 1 }, { 16, 52, 16.2, -1 }, { 14.5, 29, 13.2, 1 }, { 13.25, 31, 11.2, -1 } }) do
  ZCLIP = ch[2] - 1
  local x, y = proj(ch[4] * ch[1], ch[3] + 0.3, ch[2])
  local n = (ch[2] < 40) and 5 or 3
  smoke(floor(x), floor(y) - 3, n, (ch[2] < 40) and 2 or 1)
end

-- tavern sign (mug) + barrels
ZCLIP = 86
do
  local wx, wy = proj(-11.45, 3.15, 89)
  local ox = proj(-9.3, 3.15, 89)
  bracketSign(floor(wx), floor(wy), floor(ox), 15, 14, BOARD_W, function(x, y) iconMug(x, y, 1) end, "shield")
  for _, z in ipairs({ 80, 83.5 }) do
    local x, y = proj(-11.0, 0, z)
    barrel(floor(x), floor(y) - 8, 6, 8, TIMBER)
  end
end

-- maple growing through the narrow house roof (quirk)
ZCLIP = 64
do
  local bx, by = proj(-13.6, 11.4, 65)
  bx, by = floor(bx), floor(by)
  local hole = E(bx, by + 1, 5, 2)
  fm(hole, SH_GOLD[1])
  hole:edge():each(function(x, y) if hash(x, y, 4) < 0.5 then px(x, y - 1, SH_GOLD[4]) end end)
  local tr = c:line({ { bx, by + 1 }, { bx + 1, by - 10 }, { bx + 3, by - 22 } }, 4)
  tr:add(c:line({ { bx + 1, by - 12 }, { bx - 9, by - 22 } }, 2)):add(c:line({ { bx + 2, by - 16 }, { bx + 12, by - 26 } }, 2))
  c:rim(tr, TIMBER[1])
  cylMask(tr, bx - 2, bx + 3, TIMBER)
  local sh = E(bx + 4, by - 34, 25, 16):add(E(bx - 10, by - 24, 12, 9)):add(E(bx + 18, by - 24, 12, 9))
  crown(sh, mapleRamp, { r = 7, step = 9, seed = 5, inner = "#5a1c38", dark = function(x, y) return y > by - 22 and x > bx end })
  for _, s in ipairs({ { bx - 6, by }, { bx + 6, by - 1 } }) do px(s[1], s[2], SH_GOLD[5]) px(s[1] + 1, s[2] - 1, SH_GOLD[4]) end
end

-- lantern string across the street (Z=62)
ZCLIP = 60
do
  local x0, y0 = proj(-11.2, 8.3, 62)
  local x1 = proj(11.2, 8.3, 62)
  local pts = {}
  local LC = { AW_RED, AW_GOLD, MO, AW_RED, AW_GOLD }
  for i = 0, 40 do
    local t = i / 40
    pts[#pts + 1] = { x0 + (x1 - x0) * t, y0 + 6 * sin(t * PI) }
  end
  fm(c:line(pts, 1), INKW)
  for i = 1, 9 do
    local t = i / 10
    local x, y = floor(x0 + (x1 - x0) * t), floor(y0 + 6 * sin(t * PI))
    if abs(x - 240) > 14 then
      local R = LC[i % #LC + 1]
      local m = E(x, y + 3, 1.5, 2)
      fm(m, R[4]) px(x - 1, y + 2, T(R, 6)) px(x + 1, y + 4, R[3])
      px(x, y + 1, INKW) px(x, y + 6, INKW)
    end
  end
end

-- MARKET STALLS (spot 296,128): produce stall behind, syrup stall in front with a pumpkin wearing a gnome hat
ZCLIP = 50
local function stall(x0, x1, yTop, yAw, yC, yB, A, B, goods)
  local posts = Rm(x0 + 1, yAw, x0 + 2, yB):add(Rm(x1 - 2, yAw, x1 - 1, yB))
  c:rim(posts, TIMBER[1]) fm(posts, TIMBER[4])
  fm(Rm(x0 + 1, yAw, x0 + 1, yB), TIMBER[5])
  fm(Rm(x0 + 3, yAw + 1, x1 - 3, yC - 1), "#4a3a52")
  for y = yAw + 4, yC - 2, 4 do fm(Rm(x0 + 3, y, x1 - 3, y), TIMBER[3]) end
  for x = x0 + 4, x1 - 4, 3 do for y = yAw + 2, yC - 3, 4 do
    local R = ({ AMBER, GOLD6, SHUT_B, AMBER })[(x + y) % 4 + 1]
    px(x, y, R[4]) px(x, y + 1, R[3]) px(x, y - 1, R[6])
  end end
  local aw = c:poly{ { x0 - 1, yTop }, { x1 + 1, yTop }, { x1 + 4, yAw }, { x0 - 4, yAw } }
  local scal = HP.mask()
  for x = x0 - 4, x1 + 4 do
    local t = ((x - (x0 - 4)) % 4) / 3
    local dd = floor(2.4 * sqrt(max(0, 1 - (2 * t - 1)^2)) + 0.5)
    for y = yAw + 1, yAw + 1 + dd do scal:set(x, y) end
  end
  local all = aw:copy():add(scal)
  c:rim(all, A[1])
  all:each(function(x, y)
    local st = floor((x - x0 + 4) / 4) % 2 == 0
    local R = st and A or B
    local tone = (y < yTop + 2) and 6 or ((y <= yAw) and 5 or 4)
    if y > yAw + 1 then tone = 3 end
    px(x, y, R[tone])
  end)
  local ctr = Rm(x0, yC, x1, yB)
  c:rim(ctr, TIMBER[1])
  ctr:each(function(x, y)
    local tone = (y == yC) and 6 or ((y == yC + 1) and 3 or 4)
    if y > yC + 1 and (x - x0) % 4 == 0 then tone = 3 end
    if y > yC + 1 and x < x0 + 2 then tone = 5 end
    if y == yB then tone = 2 end
    px(x, y, TIMBER[tone])
  end)
  goods(x0, x1, yC)
end
stall(268, 292, 110, 117, 134, 146, AW_GOLD, AW_CREAM, function(x0, x1, yC)
  for i, p in ipairs({ { 272, yC - 3, PUMP }, { 279, yC - 3, APPLE }, { 286, yC - 3, PUMP }, { 276, yC - 6, APPLE }, { 283, yC - 6, APPLE } }) do
    local m = E(p[1], p[2], 3, 2.5)
    c:rim(m, p[3][1]) sph(m, p[1] - 1, p[2] - 1, 3, p[3])
    px(p[1], p[2] - 3, LEAFG[3])
  end
end)
ZCLIP = 48
stall(284, 322, 104, 114, 131, 150, AW_RED, AW_CREAM, function(x0, x1, yC)
  for i = 0, 3 do
    local bx = 289 + i * 4
    local m = Rm(bx, yC - 7, bx + 2, yC - 1):add(Rm(bx + 1, yC - 9, bx + 1, yC - 8))
    c:rim(m, AMBER[1])
    cylMask(m, bx, bx + 2, AMBER)
    px(bx + 1, yC - 4, MR[4]) px(bx, yC - 6, GL[6])
  end
  for j, rowd in ipairs({ { 305, 3 }, { 307, 2 }, { 309, 1 } }) do
    for i = 0, rowd[2] - 1 do
      local tx, ty = rowd[1] + i * 4, yC - 1 - (j - 1) * 4
      local m = Rm(tx, ty - 3, tx + 2, ty)
      c:rim(m, SHUT_R[1])
      cylMask(m, tx, tx + 2, SHUT_R)
      px(tx + 1, ty - 2, GOLD6[5]) px(tx + 1, ty - 1, GOLD6[3])
    end
  end
  -- pumpkin wearing a tiny gnome hat
  local pm = E(317, yC - 4, 4, 3)
  c:rim(pm, PUMP[1]) sph(pm, 316, yC - 5, 4, PUMP)
  px(315, yC - 4, PUMP[3]) px(315, yC - 3, PUMP[3]) px(319, yC - 4, PUMP[3])
  local hat = c:poly{ { 313, yC - 7 }, { 321, yC - 7 }, { 319, yC - 11 }, { 316, yC - 15 }, { 315, yC - 11 } }
  c:rim(hat, AW_RED[1]) fm(hat, AW_RED[4])
  hat:each(function(x, y) if x > 317 then px(x, y, AW_RED[3]) elseif x < 316 then px(x, y, AW_RED[5]) end end)
  fm(Rm(313, yC - 7, 321, yC - 7), AW_RED[2])
  px(316, yC - 16, GOLD6[5])
end)

-- general store sign (apple) + crates
ZCLIP = 40
do
  local wx, wy = proj(11.55, 3.9, 42.5)
  local ox = proj(9.4, 3.9, 42.5)
  bracketSign(floor(wx), floor(wy), floor(ox), 18, 17, BOARD_W, function(x, y) iconApple(x, y, 1.3) end)
end
local function crate(x0, y0, w, h, goods, R)
  R = R or TIMBER
  local m = Rm(x0, y0, x0 + w - 1, y0 + h - 1)
  c:rim(m, R[1])
  m:each(function(x, y)
    local yy = y - y0
    local tone = (yy % 3 == 2) and 2 or ((x == x0 or x == x0 + w - 1) and 3 or 5)
    if yy % 3 == 0 then tone = tone + 1 end
    if x == x0 + w - 1 then tone = tone - 1 end
    px(x, y, T(R, tone))
  end)
  if goods then
    local gR = goods
    for i = 0, floor(w / 3) - 1 do
      local gm = E(x0 + 1 + i * 3, y0 - 1, 1.5, 1.5)
      c:rim(gm, gR[1]) fm(gm, gR[4]) px(x0 + i * 3, y0 - 2, gR[6]) px(x0 + 2 + i * 3, y0, gR[3])
    end
  end
end
local function shadowBlob(cx, cy, rx, ry)
  local m = E(cx, cy, rx, ry)
  m:each(function(x, y) if GB[y * W + x] then px(x, y, COBBLE[2]) end end)
end
do
  local x, y = proj(10.4, 0, 38)
  shadowBlob(floor(x) + 2, floor(y), 9, 2)
  crate(floor(x) - 7, floor(y) - 9, 13, 9, APPLE)
  crate(floor(x) - 3, floor(y) - 17, 10, 7, GOLD6)
  local x2, y2 = proj(10.6, 0, 46)
  barrel(floor(x2), floor(y2) - 11, 8, 11, TIMBER)
end

-- bakery sign (pie), pies cooling on the sills (quirk), pumpkins + syrup barrel by the kerb
ZCLIP = 40
do
  local wx, wy = proj(-11.95, 3.1, 42.5)
  local ox = proj(-9.6, 3.1, 42.5)
  bracketSign(floor(wx), floor(wy), floor(ox), 20, 18, BOARD_W, function(x, y) iconPie(x, y + 1, 1) end)
  for _, z in ipairs({ 37.5, 42.5 }) do
    local x, y = proj(-11.2, 4.12, z)
    x, y = floor(x), floor(y)
    local pm = E(x, y - 1, 3, 1.5):clip(Rm(x - 4, y - 3, x + 4, y - 1))
    fm(Rm(x - 3, y, x + 3, y), STONE[4]) fm(pm, GOLD6[4]) px(x - 2, y - 2, GOLD6[6]) px(x + 1, y - 1, GOLD6[3])
    px(x, y - 4, "#e8e2ea") px(x + 1, y - 5, "#e8e2ea") px(x, y - 6, "#e8e2ea") px(x + 1, y - 7, "#d8d2dc")
  end
  local x, y = proj(-10.6, 0, 37)
  x, y = floor(x), floor(y)
  shadowBlob(x + 4, y, 10, 2)
  crate(x - 6, y - 8, 12, 8)
  for _, p in ipairs({ { x - 3, y - 10, 3 }, { x + 3, y - 10, 3 }, { x, y - 13, 3 } }) do
    local m = E(p[1], p[2], p[3], p[3] * 0.75)
    c:rim(m, PUMP[1]) sph(m, p[1] - 1, p[2] - 1, p[3], PUMP)
    px(p[1], p[2] - 3, MOSS[3])
  end
  local bx, by = proj(-10.8, 0, 40.5)
  barrel(floor(bx), floor(by) - 11, 8, 11, TIMBER)
  mapleLeaf(floor(bx), floor(by) - 5, MR)
end

-- bunting across the street at Z=40: maple leaves and tiny mittens (quirk)
ZCLIP = 38
do
  local x0, y0 = proj(-11.1, 9.5, 40)
  local x1 = proj(11.1, 9.5, 40)
  local function by(t) return y0 + 8 * sin(t * PI) end
  local pts = {}
  for i = 0, 60 do pts[#pts + 1] = { x0 + (x1 - x0) * i / 60, by(i / 60) } end
  fm(c:line(pts, 1), INKW)
  local LR = { MR, MO, MG, MR }
  local MT = { AW_RED, SHUT_B, AW_GREEN, AW_GOLD }
  local n = 0
  for x = floor(x0) + 7, floor(x1) - 6, 9 do
    if abs(x - 242) > 15 then
      n = n + 1
      local t = (x - x0) / (x1 - x0)
      local y = floor(by(t))
      if n % 3 == 0 then mitten(x, y + 4, MT[(n // 3) % 4 + 1])
      else mapleLeaf(x, y + 3, LR[n % 4 + 1]) end
    end
  end
  -- two lanterns
  for _, t in ipairs({ 0.27, 0.73 }) do
    local x, y = floor(x0 + (x1 - x0) * t), floor(by(t))
    fm(Rm(x, y, x, y + 2), INKW)
    local lg = Rm(x - 2, y + 4, x + 2, y + 8)
    fm(Rm(x - 3, y + 3, x + 3, y + 3), INKW) fm(Rm(x - 2, y + 9, x + 2, y + 9), INKW)
    fm(lg, GL[4]) fm(Rm(x - 1, y + 5, x, y + 6), GL[6]) fm(Rm(x + 2, y + 4, x + 2, y + 8), GL[2])
  end
end

-- herbalist: hanging herb bundles under the jetty, sign, pots
ZCLIP = 22
do
  for _, z in ipairs({ 19.5, 21, 22.5, 24, 25.5 }) do
    local x, y = proj(11.7, 3.35, z)
    x, y = floor(x), floor(y)
    fm(Rm(x, y, x, y + 1), INKW)
    local m = c:poly{ { x - 2, y + 2 }, { x + 2, y + 2 }, { x + 1, y + 8 }, { x - 1, y + 8 } }
    fm(m, LEAFG[3]) px(x - 1, y + 3, LEAFG[5]) px(x + 1, y + 5, LEAFG[2]) px(x, y + 4, LEAFG[4]) px(x - 1, y + 6, SH_PLUM[5])
    fm(Rm(x - 1, y + 2, x + 1, y + 2), GOLD6[4])
  end
  local wx, wy = proj(11.95, 3.3, 27.5)
  local ox = proj(9.8, 3.3, 27.5)
  bracketSign(floor(wx), floor(wy), floor(ox), 22, 20, BOARD_W, function(x, y) iconHerb(x, y, 1.3) end)
  for i, p in ipairs({ { 418, 196 }, { 428, 194 }, { 438, 196 } }) do
    local pot = c:poly{ { p[1] - 4, p[2] - 6 }, { p[1] + 4, p[2] - 6 }, { p[1] + 3, p[2] }, { p[1] - 3, p[2] } }
    c:rim(pot, BRICK[1]) cylMask(pot, p[1] - 4, p[1] + 4, BRICK)
    fm(Rm(p[1] - 4, p[2] - 6, p[1] + 4, p[2] - 6), BRICK[6])
    local leaves = E(p[1], p[2] - 9, 4, 3):add(E(p[1] - 2, p[2] - 12, 2, 2)):add(E(p[1] + 2, p[2] - 11, 2, 2))
    c:rim(leaves, LEAFG[1]) sph(leaves, p[1] - 1, p[2] - 11, 5, LEAFG)
    if i == 2 then px(p[1], p[2] - 13, SH_PLUM[5]) px(p[1] + 1, p[2] - 14, SH_PLUM[6]) end
  end
end

-- sugar shack sign (syrup jug), firewood, cupola + maple-leaf steam puff (quirk)
ZCLIP = 24
do
  local wx, wy = proj(-11.95, 3.85, 26.8)
  local ox = proj(-9.9, 3.85, 26.8)
  bracketSign(floor(wx), floor(wy), floor(ox), 24, 22, BOARD_W, function(x, y) iconJug(x, y, 1.4) end)
  -- firewood stack against the shack (near the gate post)
  local fx, fy = proj(-10.8, 0, 21.2)
  fx, fy = floor(fx), floor(fy)
  for rI, n in ipairs({ 5, 4, 3 }) do
    for k = 0, n - 1 do
      local lx, ly = fx + (rI - 1) * 2 + k * 5, fy - 3 - (rI - 1) * 4
      local m = E(lx, ly, 2.5, 2)
      c:rim(m, TIMBER[1]) fm(m, TIMBER[6])
      m:edge():each(function(x, y) px(x, y, ((x + y) % 3 == 0) and TIMBER[4] or TIMBER[5]) end)
      px(lx, ly, TIMBER[4])
    end
  end
  -- cupola on the ridge
  local cx, cy = proj(-13.2, 9.5, 25.5)
  cx, cy = floor(cx), floor(cy)
  local box = Rm(cx - 4, cy - 6, cx + 4, cy)
  local cap = c:poly{ { cx - 6, cy - 6 }, { cx, cy - 11 }, { cx + 6, cy - 6 } }
  c:rim(box:copy():add(cap), SH_CEDAR[1])
  fm(box, BOARD_W[4]) for x = cx - 3, cx + 3, 2 do fm(Rm(x, cy - 5, x, cy - 1), "#2a1c30") end
  fm(Rm(cx - 4, cy - 6, cx - 4, cy), BOARD_W[5])
  fm(cap, SH_CEDAR[4]) cap:each(function(x, y) if x > cx then px(x, y, SH_CEDAR[3]) end end)
  -- steam puffs rising, the top one shaped like a maple leaf
  ZCLIP = nil
  puff(cx + 3, cy - 15, 3) puff(cx + 7, cy - 20, 3.5)
  local lx, ly = cx + 14, cy - 28
  local pat = { "....x....", "..x.x.x..", "x.xxxxx.x", "xxxxxxxxx", ".xxxxxxx.", "..xxxxx..", "xxxxxxxxx", "....x....", "....x...." }
  for j = 1, #pat do for i = 1, 9 do if pat[j]:sub(i, i) == "x" then
    local tone = (i + j < 8) and "#fbf4ec" or ((i + j > 12) and "#c4bccc" or "#e8e2ea")
    px(lx - 4 + i - 1, ly - 4 + j - 1, tone)
  end end end
end

-- syrup pipeline: shack loft hatch -> trestle -> fountain barrel tap (quirk)
ZCLIP = nil
local PIPE_A, PIPE_B = { 54, 92 }, { 233, 153 }
do
  local tx = 146
  local ty = PIPE_A[2] + (PIPE_B[2] - PIPE_A[2]) * (tx - PIPE_A[1]) / (PIPE_B[1] - PIPE_A[1])
  local gy = 112 + 2000 / 25.5
  local legs = c:line({ { tx, ty }, { tx - 8, gy } }, 2):add(c:line({ { tx, ty }, { tx + 8, gy } }, 2)):add(c:line({ { tx - 5, gy - 18 }, { tx + 5, gy - 18 } }, 1))
  c:rim(legs, TIMBER[1]) fm(legs, TIMBER[4])
  fm(c:line({ { tx - 1, ty + 2 }, { tx - 8, gy } }, 1), TIMBER[5])
  shadowBlob(tx + 4, floor(gy) + 1, 10, 1)
  local pts = { PIPE_A, PIPE_B }
  local core = c:line(pts, 3)
  c:rim(core, COPPER[1])
  fm(core, COPPER[4])
  fm(c:line({ { PIPE_A[1], PIPE_A[2] - 1 }, { PIPE_B[1], PIPE_B[2] - 1 } }, 1), COPPER[6])
  fm(c:line({ { PIPE_A[1], PIPE_A[2] + 1 }, { PIPE_B[1], PIPE_B[2] + 1 } }, 1), COPPER[3])
  for i = 1, 11 do
    local t = i / 12
    local x, y = floor(PIPE_A[1] + (PIPE_B[1] - PIPE_A[1]) * t + 0.5), floor(PIPE_A[2] + (PIPE_B[2] - PIPE_A[2]) * t + 0.5)
    fm(Rm(x, y - 2, x, y + 2), COPPER[2]) px(x, y - 2, COPPER[5])
  end
  -- valve wheel near the shack
  local vx, vy = 72, floor(PIPE_A[2] + (PIPE_B[2] - PIPE_A[2]) * (72 - PIPE_A[1]) / (PIPE_B[1] - PIPE_A[1]))
  fm(Rm(vx, vy - 5, vx, vy - 2), INKW)
  local wh = E(vx, vy - 7, 2.5, 2.5):cut(E(vx, vy - 7, 1, 1))
  fm(wh, AW_RED[4]) px(vx - 1, vy - 9, AW_RED[6]) px(vx, vy - 7, INKW)
  -- drip
  px(110, floor(PIPE_A[2] + (PIPE_B[2] - PIPE_A[2]) * (110 - PIPE_A[1]) / (PIPE_B[1] - PIPE_A[1])) + 3, AMBER[4])
  px(110, floor(PIPE_A[2] + (PIPE_B[2] - PIPE_A[2]) * (110 - PIPE_A[1]) / (PIPE_B[1] - PIPE_A[1])) + 4, AMBER[5])
end

-- ground leaves (scattered, shade-aware, denser in gutters)
do
  local LEAFC = { MR, MO, MG, { "#3a2232", "#5a3036", "#83463a", "#ad6440", "#c87a48" } }
  for i = 0, 1600 do
    local x, y = floor(hash(i, 3, 61) * W), 113 + floor(hash(i, 5, 61) * (H - 113))
    local k = y * W + x
    if GB[k] and not nearStand(x, y, 17, 12) and not calm(x, y) and c:get(x, y) and not EB[k] then
      local t = EYE / ((y + 0.5 - VY) / F)
      local Xw = (x + 0.5 - VX) * t / F
      local aX = abs(Xw)
      local keep = (aX > 9.6 and aX < 10.5) or hash(i, 7, 61) < 0.38
      if y >= GATE_Y and Xw > 0 then keep = false end
      if keep then
        local R = LEAFC[floor(hash(i, 9, 61) * 4) + 1]
        local sh = SB[k] and 0 or -2
        if y > 196 then
          px(x, y, T(R, 4 + sh)) px(x + 1, y, T(R, 3 + sh)) px(x, y - 1, T(R, 5 + sh)) px(x + 1, y + 1, T(R, 2 + sh))
          if hash(i, 11, 61) < 0.5 then px(x - 1, y, T(R, 4 + sh)) end
        elseif y > 140 then
          px(x, y, T(R, 4 + sh)) px(x + 1, y, T(R, 3 + sh))
        else
          px(x, y, T(R, 3 + sh))
        end
      end
    end
  end
end

-- FOUNTAIN (spot 240,190): octagon basin, pillar, bowl, syrup barrel with tap
do
  local cx, cy = 240, 194
  local function oct(x, y, hw, hh) local pts = {} for i = 0, 7 do local a = (i + 0.5) * PI / 4 pts[#pts + 1] = { x + hw * cos(a), y + hh * sin(a) } end return pts end
  local depth = 10
  -- cast shadow back-right on the cobbles
  local shp = c:poly{ { cx + 14, cy - 6 }, { cx + 30, cy - 8 }, { cx + 44, cy - 14 }, { cx + 36, cy + 2 }, { cx + 22, cy + 4 } }
  shp:each(function(x, y) if GB[y * W + x] and not nearStand(x, y, 15, 10) then px(x, y, COBBLE[2]) end end)
  local step = c:poly(oct(cx, cy + depth + 1, 31, 10))
  c:rim(step, STONE_W[1])
  step:each(function(x, y) px(x, y, T(STONE_W, (y > cy + depth + 4) and 2 or ((x < cx - 10) and 4 or 3))) end)
  local top = c:poly(oct(cx, cy, 27, 8))
  local wall = HP.mask()
  for dy = 0, depth do wall:add(top:shift(0, dy)) end
  c:rim(wall, STONE_W[1])
  wall:each(function(x, y)
    local tt = (x - cx) / 27
    local idx = tt < -0.42 and 5 or (tt < 0.42 and 4 or 3)
    local yy = y - cy
    if yy % 5 == 0 then idx = idx - 1 end
    if (x + (floor(yy / 5) % 2) * 4) % 9 == 0 then idx = idx - 1 end
    if hash(x, y, 7) < 0.05 then idx = idx - 1 end
    px(x, y, T(STONE_W, idx))
  end)
  for _, mx in ipairs({ cx - 18, cx - 6, cx + 9, cx + 20 }) do
    if hash(mx, 1, 3) < 0.7 then px(mx, cy + depth + 1, MOSS[4]) px(mx + 1, cy + depth + 1, MOSS[3]) px(mx, cy + depth, MOSS[5]) end
  end
  fm(top, STONE_W[5])
  top:edge():each(function(x, y) px(x, y, (y < cy) and STONE_W[6] or STONE_W[4]) end)
  local water = c:poly(oct(cx, cy, 23, 5.5))
  water:each(function(x, y)
    local col = (y < cy - 2) and "#3a86b0" or "#5fc4c8"
    if (y + floor(x / 6)) % 3 == 0 and hash(x // 3, y, 9) < 0.4 then col = "#b6f0e0" end
    if x > cx + 1 and x < cx + 9 and y > cy - 3 and hash(x, y, 2) < 0.6 then col = (hash(x, y, 4) < 0.5) and AMBER[4] or AMBER[5] end
    px(x, y, col)
  end)
  water:edge():each(function(x, y) if y < cy then px(x, y, "#2a4a7a") end end)
  mapleLeaf(cx - 12, cy + 1, MO)
  -- pillar
  local pil = Rm(cx - 3, cy - 19, cx + 3, cy)
  c:rim(pil, STONE_W[1]) cylMask(pil, cx - 3, cx + 3, STONE_W)
  for y = cy - 16, cy, 4 do fm(Rm(cx - 3, y, cx + 3, y), STONE_W[2]) end
  -- bowl
  local bowl = c:poly(oct(cx, cy - 20, 12, 3.5)):add(E(cx, cy - 20, 10, 4):clip(Rm(cx - 12, cy - 20, cx + 12, cy - 15)))
  c:rim(bowl, STONE_W[1])
  bowl:each(function(x, y) px(x, y, T(STONE_W, (y < cy - 20) and 6 or ((x < cx - 4) and 5 or ((x > cx + 5) and 3 or 4)))) end)
  fm(c:poly(oct(cx, cy - 21, 9, 2)), "#5fc4c8")
  -- falling water from the bowl lip
  for _, sx in ipairs({ cx - 11, cx + 11 }) do
    for y = cy - 17, cy - 1 do px(sx + ((y % 4 == 0) and 0 or 0), y, (y % 3 == 0) and "#e4f6ff" or "#b6f0e0") end
    px(sx - 1, cy - 1, "#e4f6ff") px(sx + 1, cy - 1, "#e4f6ff")
  end
  -- syrup barrel on top
  barrel(cx, cy - 40, 17, 18, TIMBER)
  mapleLeaf(cx - 2, cy - 31, MR, 2)
  -- tap + syrup stream into the bowl
  fm(Rm(cx + 4, cy - 27, cx + 7, cy - 26), STONE[5]) px(cx + 7, cy - 28, STONE[6]) px(cx + 7, cy - 25, STONE[3])
  for y = cy - 25, cy - 21 do px(cx + 7, y, (y % 2 == 0) and AMBER[5] or AMBER[4]) end
  px(cx + 6, cy - 21, AMBER[3]) px(cx + 8, cy - 21, AMBER[3])
  -- pipeline joint into the barrel top
  fm(Rm(PIPE_B[1] - 1, PIPE_B[2] - 2, PIPE_B[1] + 2, PIPE_B[2] + 2), COPPER[2]) px(PIPE_B[1], PIPE_B[2] - 2, COPPER[6])
end

-- falling leaves in the air
do
  local LR = { MR, MO, MG }
  for i = 0, 38 do
    local x, y = 40 + floor(hash(i, 1, 81) * 400), 30 + floor(hash(i, 2, 81) * 175)
    if not nearStand(x, y, 18, 14) and not calm(x, y) and not (abs(x - 240) < 14 and y < 90) then
      local R = LR[i % 3 + 1]
      if hash(i, 3, 81) < 0.4 then
        mapleLeaf(x, y, R)
      else
        px(x, y, R[4]) px(x + 1, y, R[3]) px(x, y - 1, R[5]) px(x - 1, y + 1, R[2])
      end
    end
  end
end

-- NOTICE BOARD (spot 132,214): little shingled roof, cork board, blank notes with pictograms
do
  local x0, x1, yTop, yB = 119, 149, 196, 236
  local posts = Rm(x0 + 2, yTop + 4, x0 + 4, yB):add(Rm(x1 - 4, yTop + 4, x1 - 2, yB))
  c:rim(posts, TIMBER[1]) cylMask(posts, x0 + 2, x0 + 4, TIMBER) cylMask(Rm(x1 - 4, yTop + 4, x1 - 2, yB), x1 - 4, x1 - 2, TIMBER)
  local board = Rm(x0, yTop + 7, x1, yTop + 30)
  c:rim(board, TIMBER[1])
  board:each(function(x, y)
    local tone = (x == x0 or y == yTop + 7) and 5 or ((x == x1 or y == yTop + 30) and 3 or 4)
    px(x, y, T(TIMBER, tone))
  end)
  local cork = Rm(x0 + 2, yTop + 9, x1 - 2, yTop + 28)
  cork:each(function(x, y) px(x, y, (hash(x, y, 5) < 0.2) and "#b07a4a" or "#c89058") end)
  fm(Rm(x0 + 2, yTop + 9, x1 - 2, yTop + 9), "#8a5634")
  local roof = c:poly{ { x0 - 4, yTop + 7 }, { (x0 + x1) / 2, yTop }, { x1 + 4, yTop + 7 } }
  c:rim(roof, SH_CEDAR[1])
  roof:each(function(x, y)
    local tone = ((y - yTop) % 3 == 2) and 3 or ((x < (x0 + x1) / 2) and 5 or 4)
    if (y - yTop) % 3 ~= 2 and (x + (y // 3) * 2) % 5 == 0 then tone = tone - 1 end
    px(x, y, SH_CEDAR[tone])
  end)
  local notes = { { x0 + 4, yTop + 11, 7, 8, AW_CREAM, "leaf" }, { x0 + 13, yTop + 12, 6, 7, PL_BUTTER, "pie" }, { x0 + 21, yTop + 10, 6, 8, PL_ROSE, "apple" },
    { x0 + 6, yTop + 21, 8, 6, PL_BLUE, "mitten" }, { x0 + 17, yTop + 21, 9, 6, AW_CREAM, "lines" } }
  for _, n in ipairs(notes) do
    local m = Rm(n[1], n[2], n[1] + n[3] - 1, n[2] + n[4] - 1)
    fm(m, n[5][5]) fm(Rm(n[1] + n[3] - 1, n[2] + 1, n[1] + n[3] - 1, n[2] + n[4] - 1), n[5][3])
    fm(Rm(n[1] + 1, n[2] + n[4] - 1, n[1] + n[3] - 1, n[2] + n[4] - 1), n[5][4])
    px(n[1] + n[3] // 2, n[2], AW_RED[4])
    local mx, my = n[1] + n[3] // 2, n[2] + n[4] // 2
    if n[6] == "leaf" then px(mx, my - 1, MR[4]) px(mx - 1, my, MR[4]) px(mx, my, MR[4]) px(mx + 1, my, MR[4]) px(mx, my + 1, MR[2])
    elseif n[6] == "pie" then fm(Rm(mx - 2, my, mx + 1, my + 1), GOLD6[4]) px(mx - 1, my - 1, GOLD6[5]) px(mx, my - 1, GOLD6[5])
    elseif n[6] == "apple" then px(mx, my, APPLE[4]) px(mx - 1, my, APPLE[4]) px(mx, my + 1, APPLE[3]) px(mx - 1, my + 1, APPLE[3]) px(mx, my - 1, LEAFG[4])
    elseif n[6] == "mitten" then px(mx, my - 1, AW_RED[4]) px(mx - 1, my, AW_RED[4]) px(mx, my, AW_RED[4]) px(mx + 1, my - 1, AW_RED[4]) px(mx, my + 1, AW_CREAM[3])
    else for j = 0, 2 do fm(Rm(n[1] + 2, n[2] + 1 + j * 2, n[1] + n[3] - 3 - (j % 2) * 2, n[2] + 1 + j * 2), n[5][2]) end end
  end
end

-- ORCHARD (spot 372,218): apple tree in a half-barrel tub + stacked apple crates
do
  local tx = 361
  local tub = HP.mask()
  for y = 224, 237 do local b = (y < 226) and 0 or 1 for x = tx - 10 + b, tx + 10 - b do tub:set(x, y) end end
  c:rim(tub, TIMBER[1]) cylMask(tub, tx - 10, tx + 10, TIMBER)
  tub:each(function(x, y) if (x - tx) % 4 == 0 then px(x, y, TIMBER[3]) end if y == 227 or y == 234 then px(x, y, T(STONE, (x < tx) and 4 or 2)) end end)
  fm(Rm(tx - 9, 224, tx + 9, 224), EARTH[3])
  local tr = c:line({ { tx, 224 }, { tx, 214 }, { tx - 2, 208 } }, 3):add(c:line({ { tx, 214 }, { tx + 6, 208 } }, 2))
  c:rim(tr, TIMBER[1]) cylMask(tr, tx - 2, tx + 1, TIMBER)
  local sh = E(tx, 207, 12, 8):add(E(tx - 7, 211, 6, 4)):add(E(tx + 7, 211, 6, 4))
  crown(sh, function(x, y) return (hash(x, y, 3) < 0.25) and MG or LEAFG end, { r = 4, step = 6, seed = 12, inner = "#1f3a3c", dark = function(x, y) return y > 211 and x > tx end })
  for i, a in ipairs({ { tx - 7, 205 }, { tx + 3, 203 }, { tx + 8, 209 }, { tx - 3, 211 }, { tx - 10, 210 }, { tx + 1, 208 } }) do
    local m = E(a[1], a[2], 1.5, 1.5)
    c:rim(m, APPLE[1]) fm(m, APPLE[4]) px(a[1] - 1, a[2] - 1, APPLE[6]) px(a[1] + 1, a[2] + 1, APPLE[3])
  end
  crate(376, 219, 16, 10, APPLE)
  crate(379, 210, 12, 8, { "#24544a", "#3f9150", "#5aa856", "#7cc35a", "#a6d468", "#c4e07a" })
  px(392, 228, TIMBER[2])
end

------------------------------------------------------------------ GATE (foreground frame, own darker edge)
do
  local function stoneBlocks(x0, x1, y0, y1, R, shift, seed)
    local y, rowi = y0, 0
    while y <= y1 do
      local ch = 8 + floor(hash(rowi, 1, seed) * 3)
      local yb = min(y1, y + ch - 1)
      local x = x0 - floor(hash(rowi, 2, seed) * 8)
      local j = 0
      while x <= x1 do
        local bw = 9 + floor(hash(rowi, j, seed + 1) * 8)
        local bx0, bx1 = max(x0, x), min(x1, x + bw - 1)
        if bx1 >= bx0 then
          local hs = hash(rowi, j, seed + 2)
          local tone = 4 + shift + ((hs < 0.3) and -1 or (hs > 0.85 and 1 or 0))
          for yy = y, yb do for xx = bx0, bx1 do
            local t = tone
            if yy == yb or xx == bx0 then t = 2 + shift
            elseif yy == y or xx == bx0 + 1 then t = tone + 1
            elseif xx == bx1 or yy == yb - 1 then t = tone - 1 end
            if t == tone and hash(xx, yy, seed + 4) < 0.06 then t = tone - 1 end
            px(xx, yy, T(R, t))
          end end
          if hash(rowi, j, seed + 5) < 0.25 then
            for xx = bx0 + 2, min(bx1, bx0 + 5) do px(xx, y, (xx % 2 == 0) and MOSS[5] or MOSS[4]) end
          end
        end
        x, j = x + bw, j + 1
      end
      y, rowi = yb + 1, rowi + 1
    end
  end
  local function wood(x0, y0, x1, y1, R, shift, vertical)
    for y = y0, y1 do for x = x0, x1 do
      local t = 4 + shift
      if vertical then
        if x == x0 + 1 then t = t + 1 elseif x >= x1 - 1 then t = t - 1 end
        if hash(x, y // 6, 31) < 0.18 then t = t - 1 end
      else
        if y == y0 + 1 then t = t + 1 elseif y >= y1 - 1 then t = t - 1 end
        if hash(x // 7, y, 33) < 0.16 then t = t - 1 end
      end
      px(x, y, T(R, t))
    end end
    fm(c:rim(Rm(x0, y0, x1, y1), R[1]):clip(Rm(0, 0, W - 1, H - 1)), R[1])
  end
  -- knee braces (behind posts and lintel)
  for _, s in ipairs({ -1, 1 }) do
    local bx = (s < 0) and 27 or 452
    local pts = (s < 0) and { { bx, 72 }, { bx + 6, 72 }, { 78, 25 }, { 64, 25 } } or { { bx - 6, 72 }, { bx, 72 }, { 416, 25 }, { 402, 25 } }
    local m = c:poly(pts)
    c:rim(m, TIMBER[1])
    m:each(function(x, y) px(x, y, T(TIMBER, ((x + y) % 7 == 0) and 3 or ((s < 0) and 4 or 5))) end)
    m:edge():each(function(x, y) px(x, y, TIMBER[2]) end)
  end
  -- timber posts
  wood(4, 25, 27, 114, TIMBER, 0, true)
  wood(28, 25, 33, 114, TIMBER, -2, true)
  wood(452, 25, 475, 114, TIMBER, 1, true)
  wood(446, 25, 451, 114, TIMBER, 0, true)
  -- stone pillars + caps
  stoneBlocks(0, 30, 120, 227, STONE_W, 0, 1)
  stoneBlocks(31, 36, 120, 227, STONE_W, -2, 2)
  stoneBlocks(449, 479, 120, 227, STONE_W, 0, 3)
  stoneBlocks(443, 448, 120, 227, STONE_W, 0, 4)
  fm(Rm(37, 120, 37, 227), STONE_W[1]) fm(Rm(442, 120, 442, 227), STONE_W[1])
  for _, cp in ipairs({ { 0, 39 }, { 440, 479 } }) do
    local cap = Rm(cp[1], 114, cp[2], 119)
    cap:each(function(x, y) px(x, y, T(STONE_W, (y == 114) and 6 or ((y == 119) and 2 or 5))) end)
    fm(c:rim(cap, STONE_W[1]):clip(Rm(0, 0, W - 1, H - 1)), STONE_W[1])
  end
  -- threshold slabs
  local thr = Rm(38, 224, 441, 228)
  thr:each(function(x, y)
    local t = (y == 224) and 6 or ((y >= 227) and 3 or 5)
    if (x - 38) % 23 == 0 then t = 2 end
    if hash(x, y, 9) < 0.05 then t = t - 1 end
    px(x, y, T(STONE_W, t))
  end)
  fm(Rm(38, 229, 375, 229), STONE_W[1])
  -- lintel + shingle cap + carved maple plaque
  wood(0, 8, 479, 25, TIMBER, 0, false)
  for x = 20, 460, 44 do fm(Rm(x, 14, x + 1, 15), TIMBER[2]) px(x, 14, TIMBER[5]) end
  for y = 0, 7 do for x = 0, W - 1 do
    local rr = y // 3
    local t = (y % 3 == 2) and 2 or ((y % 3 == 0) and 5 or 4)
    if y % 3 ~= 2 and (x + rr * 3) % 7 == 0 then t = 2 end
    if hash(x // 7, rr, 14) < 0.15 and t > 2 then t = t - 1 end
    px(x, y, SH_CEDAR[t])
  end end
  fm(Rm(0, 7, W - 1, 7), SH_CEDAR[1])
  local pl = c:rrect(226, 9, 254, 24, 3)
  c:rim(pl, TIMBER[1]) pillow(pl, TIMBER_R, 2)
  mapleLeaf(240, 16, GOLD6, 2)
  mapleLeaf(240, 16, GOLD6, 2)
  -- bunting swags of maple leaves and mittens from the lintel
  local LR = { MR, MO, MG }
  local MT = { AW_RED, SHUT_B, AW_GREEN, AW_GOLD }
  local n = 0
  for _, sw in ipairs({ { 40, 168, 15 }, { 168, 312, 10 }, { 312, 440, 15 } }) do
    local x0, x1, sag = sw[1], sw[2], sw[3]
    local pts = {}
    for i = 0, 40 do local t = i / 40 pts[#pts + 1] = { x0 + (x1 - x0) * t, 26 + sag * sin(t * PI) } end
    fm(c:line(pts, 1), INKW)
    for x = x0 + 7, x1 - 6, 10 do
      if abs(x - 240) > 16 then
        n = n + 1
        local t = (x - x0) / (x1 - x0)
        local y = floor(26 + sag * sin(t * PI))
        if n % 4 == 2 then mitten(x, y + 4, MT[(n // 4) % 4 + 1]) else mapleLeaf(x, y + 4, LR[n % 3 + 1], 2) end
      end
    end
  end
  -- gate lantern (left brace)
  local lx = 56
  fm(Rm(lx, 26, lx, 42), INKW)
  local cap = c:poly{ { lx - 5, 47 }, { lx, 42 }, { lx + 5, 47 } }
  fm(cap, INKW) px(lx - 1, 44, "#5a4a6e")
  local glassm = Rm(lx - 4, 48, lx + 4, 58)
  c:rim(glassm, INKW)
  glassm:each(function(x, y)
    local dd = abs(x - lx) + abs(y - 53) * 0.7
    px(x, y, dd < 2 and GL[6] or (dd < 4 and GL[5] or (x > lx + 2 and GL[2] or GL[4])))
  end)
  fm(Rm(lx, 48, lx, 58), "#5a4a6e")
  fm(Rm(lx - 5, 59, lx + 5, 60), INKW) px(lx - 4, 59, "#5a4a6e")
  -- dried corn + sap bucket on the right brace
  local rx = 424
  fm(Rm(rx, 26, rx, 36), INKW)
  for i, dx in ipairs({ -3, 0, 3 }) do
    local cm = E(rx + dx, 44, 1.5, 5)
    fm(cm, GOLD6[4]) px(rx + dx - 1, 41, GOLD6[6]) px(rx + dx + 1, 47, GOLD6[2])
  end
  fm(c:poly{ { rx - 5, 37 }, { rx + 5, 37 }, { rx, 41 } }, BOARD_W[5])
end

------------------------------------------------------------------ FOREGROUND left: leaf pile, rake, stump with an overflowing sap bucket
do
  local pile = E(56, 258, 40, 12):add(E(42, 252, 20, 9)):add(E(70, 251, 18, 8)):add(E(58, 246, 12, 6))
  pile:clip(Rm(0, 236, W - 1, H - 1))
  fm(pile, "#4a1838")
  local LR = { MR, MO, MG, { "#3a2232", "#5a3036", "#83463a", "#ad6440", "#c87a48" } }
  local x0, y0, x1, y1 = pile:bbox()
  for i = 0, 700 do
    local x, y = x0 + floor(hash(i, 1, 91) * (x1 - x0)), y0 + floor(hash(i, 2, 91) * (y1 - y0))
    if pile:has(x, y) then
      local R = LR[floor(hash(i, 3, 91) * 4) + 1]
      local hgt = (y - y0) / (y1 - y0)
      local sh = (hgt > 0.7 or x > 84) and -1 or ((hgt < 0.3 and x < 60) and 1 or 0)
      if hash(i, 4, 91) < 0.35 then
        mapleLeaf(x, y, { R[1], R[2], T(R, 3 + sh), T(R, 4 + sh), T(R, 5 + sh) })
      else
        px(x, y, T(R, 4 + sh)) px(x + 1, y, T(R, 3 + sh)) px(x, y - 1, T(R, 5 + sh)) px(x + 1, y + 1, T(R, 2 + sh)) px(x - 1, y, T(R, 4 + sh))
      end
    end
  end
  -- rake leaning into the pile
  fm(c:line({ { 104, 214 }, { 82, 258 } }, 2), TIMBER[4])
  fm(c:line({ { 105, 214 }, { 83, 258 } }, 1), TIMBER[6])
  fm(c:line({ { 75, 257 }, { 91, 262 } }, 2), STONE[3])
  for i = 0, 5 do local tx = 76 + i * 3 fm(Rm(tx, 260 + i // 2, tx, 265 + i // 2), STONE[4]) px(tx, 260 + i // 2, STONE[6]) end
  -- stump
  local st = Rm(98, 244, 120, 262)
  c:rim(st, TIMBER[1]) cylMask(st, 98, 120, TIMBER)
  for x = 100, 119, 3 do fm(Rm(x, 246, x, 261), TIMBER[3]) end
  local stop = E(109, 244, 11, 3)
  c:rim(stop, TIMBER[1]) fm(stop, "#d8a870")
  stop:each(function(x, y) if (abs(x - 109) + abs(y - 244) * 3) % 4 == 0 then px(x, y, "#b4824e") end end)
  -- sap bucket (tapered, lidded) overflowing
  local bk = c:poly{ { 101, 228 }, { 117, 228 }, { 115, 243 }, { 103, 243 } }
  c:rim(bk, STONE[1]) cylMask(bk, 101, 117, STONE)
  for _, y in ipairs({ 231, 240 }) do fm(Rm(101, y, 117, y):clip(bk), STONE[2]) end
  local lid = c:poly{ { 99, 227 }, { 109, 221 }, { 119, 227 } }
  c:rim(lid, STONE[1]) fm(lid, STONE[5]) lid:each(function(x, y) if x > 109 then px(x, y, STONE[4]) end end)
  fm(Rm(102, 227, 116, 228), AMBER[4]) px(104, 227, AMBER[6])
  for y = 229, 262 do
    local x = 103 + floor(1.2 * sin(y / 3))
    if y < 244 or y > 246 then px(x, y, (y % 3 == 0) and AMBER[6] or AMBER[4]) px(x + 1, y, AMBER[3]) end
  end
  for y = 229, 236 do px(116, y, AMBER[4]) end
  local pud = E(103, 265, 7, 2)
  fm(pud, AMBER[4]) px(100, 264, AMBER[6]) px(101, 264, GL[6]) pud:edge():each(function(x, y) if y > 265 then px(x, y, AMBER[2]) end end)
end

ZCLIP = nil
c.put = rawput
c:finish{ outline = false }
HP.report(c)
HP.assertClean(c)
HP.cells(c, 6, 4)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(string.format("done %.1fs", os.clock() - T0))
