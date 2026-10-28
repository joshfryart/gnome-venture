-- Puzzles cast for scenes: Jeff (jeff-v2), Ffej (ffej-v1), Old Wizard (wizard-v1) redrawn from the approved
-- sticker geometry at any scale `s` (1 = the 64 px sticker), centred on (ox, oy). Scene mode, ol=1/olx=1.
-- Usage: local CAST = dofile(D .. "extras-pixel/scripts/cast-lib.lua")(GV)
--        CAST.jeff(c, ox, oy, s, { pose = "hold"|"cheer"|"watch", dark = bool })
return function(GV)
  local M = {}
  local floor, max, min = math.floor, math.max, math.min
  local function rnd(v) return floor(v + 0.5) end

  -- dusk tint for the dark scenes (same recipe as tools/darken.py)
  local function dim(hex, dark)
    if not dark then return hex end
    local r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
    return string.format("#%02x%02x%02x", floor(r * .88), floor(g * .9), min(255, floor(b * .95) + 6))
  end
  M.dim = dim
  local UMB, CREAM = "#2a1a10", "#f1ece0"

  -- transform helpers for a sticker drawn in 64-space
  local function T(c, ox, oy, s)
    local t = {}
    t.X = function(x) return ox + (x - 32) * s end
    t.Y = function(y) return oy + (y - 32) * s end
    t.P = function(pts) local o = {} for i, p in ipairs(pts) do o[i] = { t.X(p[1]), t.Y(p[2]) } end return o end
    t.R = function(x0, y0, x1, y1, r) return c:rrect(t.X(x0), t.Y(y0), t.X(x1), t.Y(y1), max(1, rnd((r or 0) * s))) end
    t.E = function(cx, cy, rx, ry) return c:ellipse(t.X(cx), t.Y(cy), rx * s, (ry or rx) * s) end
    t.L = function(pts, w) return c:line(t.P(pts), max(2, rnd(w * s))) end
    t.W = function(w) return max(1, rnd(w * s)) end
    t.eye = function(x, y) -- 64-space top-left of a locked 5x5 eye; small eye under s 0.7
      local small = s < 0.7
      local ex, ey = rnd(t.X(x + 2)), rnd(t.Y(y + 2))
      if small then c:eye(ex - 1, ey - 1, true) else c:eye(ex - 2, ey - 2) end
    end
    return t
  end

  local function piece(c, m, ramp, o) o = o or {}; return c:part(m, ramp, o) end

  ---------------------------------------------------------------- Jeff
  function M.jeff(c, ox, oy, s, o)
    o = o or {}
    local t = T(c, ox, oy, s)
    local pose, dark = o.pose or "hold", o.dark
    local body = c:poly(t.P({ { 16, 25 }, { 45, 22 }, { 46, 50 }, { 18, 52 } }))
    body:add(t.R(26, 14, 35, 26, 2)); body:add(t.E(30.5, 12, 7.5, 6))
    body:cut(t.E(32, 53, 6, 4.5))
    local armL, armR, extra
    if pose == "cheer" then
      armL = t.L({ { 19, 34 }, { 12, 26 }, { 10, 18 } }, 4); armL:add(t.E(10, 16, 3, 3))
      armR = t.L({ { 44, 32 }, { 51, 24 }, { 53, 16 } }, 4); armR:add(t.E(53, 14, 3, 3))
    elseif pose == "watch" then
      armL = t.R(10, 33, 19, 40, 2); armL:add(t.E(10, 36.5, 3, 4.5)); armL:cut(c:rect(t.X(17), t.Y(26), 9999, 9999))
      armR = t.L({ { 44, 36 }, { 50, 32 }, { 52, 26 } }, 4); armR:add(t.E(52, 24, 3, 3))
    else
      armL = t.R(10, 33, 19, 40, 2); armL:add(t.E(10, 36.5, 3, 4.5)); armL:cut(c:rect(t.X(17), t.Y(26), 9999, 9999))
      armR = t.L({ { 44, 38 }, { 49, 40 }, { 51, 43 } }, 4); armR:add(t.E(50, 45, 3, 3))
    end
    armL:cut(body:grow(1)); armR:cut(body:grow(1))
    local G1, G2 = GV.ramp(dim("#2cc97c", dark)), GV.ramp(dim("#1fb86b", dark))
    piece(c, armL, G1, { flat = true })
    piece(c, armR, G1, { flat = true })
    piece(c, body, G2, { stitch = { side = "lit" }, gloss = { rnd(t.X(20)), rnd(t.Y(24)) } })
    if pose == "hold" then
      local mini = t.R(47, 33, 53, 40, 1)
      mini:add(t.E(50, 31, 2.5, 2.5)); mini:add(t.E(54, 36.5, 2, 2)); mini:cut(t.E(50, 41, 2, 2))
      piece(c, mini, GV.ramp(dim("#8a5fd0", dark)), { gloss = { rnd(t.X(48)), rnd(t.Y(35)) } })
    elseif pose == "watch" then
      -- stopwatch: silver disc on a short stem, gold button, umber hand
      local wx, wy = t.X(52), t.Y(16)
      local rr = max(4, rnd(7 * s))
      c:part(c:rect(wx - 1, wy - rr - 2, wx + 1, wy - rr), GV.ramp("#8b8f96"), { flat = true })
      c:part(c:ellipse(wx, wy, rr, rr), GV.ramp(dim("#c9c5bc", dark)), { gloss = { rnd(wx - rr * .6), rnd(wy - rr * .6) } })
      c:fill(c:ellipse(wx, wy, rr - 2, rr - 2), dim("#f1ece0", dark))
      c:fill(c:line({ { wx, wy }, { wx, wy - rr + 3 } }, 1), UMB)
      c:fill(c:line({ { wx, wy }, { wx + rr - 3, wy } }, 1), UMB)
      c:px(wx, wy, "#dd3a2a")
      c:px(wx, wy - rr - 2, "#f5cf6a"); c:px(wx + 1, wy - rr - 2, "#e8a317")
    end
    local bx, by = rnd(t.X(29)), rnd(t.Y(15))
    if s >= 0.6 then c:button(bx, by) else c:px(bx, by, "#f5cf6a"); c:px(bx + 1, by + 1, "#e8a317") end
    c:seam({ { rnd(t.X(21)), rnd(t.Y(47)) }, { rnd(t.X(25)), rnd(t.Y(47)) } })
    c:seam({ { rnd(t.X(39)), rnd(t.Y(47)) }, { rnd(t.X(43)), rnd(t.Y(47)) } })
    t.eye(20, 28); t.eye(36, 27)
    c:fill(c:line({ { t.X(36), t.Y(24) }, { t.X(39), t.Y(24) } }, 1), UMB) -- raised brow
    -- grin: umber bowl with a cream tooth row
    local gy = rnd(t.Y(41))
    local grin = c:line({ { t.X(25), t.Y(38) }, { t.X(27), gy }, { t.X(33), gy }, { t.X(35), t.Y(38) } }, 1)
    c:fill(grin, UMB)
    if gy - 1 > rnd(t.Y(38)) then
      for x = rnd(t.X(27)) + 1, rnd(t.X(33)) - 1 do c:px(x, gy - 1, CREAM) end
    end
    return body
  end

  ---------------------------------------------------------------- Ffej
  function M.ffej(c, ox, oy, s, o)
    o = o or {}
    local t = T(c, ox, oy, s)
    local dark = o.dark
    local body = t.R(16, 13, 47, 41, 3)
    body:add(t.R(26, 39, 37, 52, 2)); body:add(t.E(31.5, 50, 7, 5.5))
    body:cut(c:rect(t.X(28), t.Y(10), t.X(35), t.Y(17)))
    body:cut(t.E(31.5, 14, 6, 4.5))
    local arms
    if o.pose == "sneak" then -- one arm forward, fingers spread, the other tucked
      arms = t.L({ { 45, 27 }, { 54, 22 } }, 5); arms:add(t.E(55, 20, 3, 3))
      arms:add(t.L({ { 18, 30 }, { 12, 34 } }, 5)); arms:add(t.E(11, 36, 3, 3))
    else
      arms = t.L({ { 18, 27 }, { 11, 21 } }, 5); arms:add(t.L({ { 45, 27 }, { 52, 21 } }, 5))
      arms:add(t.E(10, 19, 3, 3)); arms:add(t.E(53, 19, 3, 3))
    end
    arms:cut(body:shrink(1))
    piece(c, arms, GV.ramp(dim("#3c8f4a", dark)), { flat = true })
    piece(c, body, GV.ramp(dim("#2f7a3e", dark)), { stitch = { side = "lit" }, gloss = { rnd(t.X(20)), rnd(t.Y(17)) } })
    -- claws
    local function claw(x, y) c:px(x, y, UMB); c:px(x + 2, y, UMB); c:px(x + 1, y + 1, UMB) end
    if o.pose == "sneak" then claw(rnd(t.X(54)), rnd(t.Y(18))); claw(rnd(t.X(10)), rnd(t.Y(34)))
    else claw(rnd(t.X(9)), rnd(t.Y(17))); claw(rnd(t.X(52)), rnd(t.Y(17))) end
    c:seam({ { rnd(t.X(19)), rnd(t.Y(39)) }, { rnd(t.X(26)), rnd(t.Y(39)) } })
    c:seam({ { rnd(t.X(37)), rnd(t.Y(39)) }, { rnd(t.X(44)), rnd(t.Y(39)) } })
    local bx, by = rnd(t.X(30)), rnd(t.Y(43))
    if s >= 0.6 then c:button(bx, by) else c:px(bx, by, "#f5cf6a"); c:px(bx + 1, by + 1, "#e8a317") end
    -- face: patch on the left eye, good eye right, angry brow, smirk
    t.eye(35, 24)
    c:fill(t.R(22, 24, 28, 29, 1), UMB)
    c:fill(c:line({ { t.X(20), t.Y(21) }, { t.X(24), t.Y(24) } }, 1), UMB)
    c:fill(c:line({ { t.X(28), t.Y(24) }, { t.X(32), t.Y(21) } }, 1), UMB)
    c:fill(c:line({ { t.X(23.5), t.Y(26) }, { t.X(26), t.Y(26) } }, 1), "#4a3a6a")
    c:fill(c:line({ { t.X(33), t.Y(21) }, { t.X(39), t.Y(19) } }, 1), UMB)   -- brow slanting in
    c:fill(c:line({ { t.X(24), t.Y(35) }, { t.X(32), t.Y(35) }, { t.X(34), t.Y(33) } }, 1), UMB)
    c:px(rnd(t.X(29)), rnd(t.Y(36)), "#c8d77a")                             -- glinting tooth
    return body
  end

  ---------------------------------------------------------------- Old Wizard
  function M.wizard(c, ox, oy, s, o)
    o = o or {}
    local t = T(c, ox, oy, s)
    local dark, pose = o.dark, o.pose or "staff"
    local dy = 4
    local function R(x0, y0, x1, y1, r) return t.R(x0, y0 + dy, x1, y1 + dy, r) end
    local body = R(17, 26, 46, 49, 3)
    body:add(R(26, 14, 37, 28, 2)); body:add(t.E(31.5, 15 + dy, 7, 5.5))
    body:cut(c:rect(t.X(27), t.Y(44 + dy), t.X(36), t.Y(50 + dy)))
    local arms
    if pose == "clap" then
      arms = t.L({ { 18, 36 + dy }, { 24, 44 + dy }, { 30, 44 + dy } }, 5)
      arms:add(t.L({ { 45, 36 + dy }, { 39, 44 + dy }, { 33, 44 + dy } }, 5))
      arms:add(t.E(29, 45 + dy, 3.5, 3.5)); arms:add(t.E(35, 44 + dy, 3.5, 3.5))
      arms:cut(body:shrink(1))
    else
      arms = R(11, 33, 52, 39, 2); arms:add(t.E(12, 36 + dy, 3, 4)); arms:add(t.E(51, 36 + dy, 3, 4))
      arms:cut(R(18, 28, 45, 45))
    end
    local hat = c:poly(t.P({ { 29, 6 }, { 37, 10 }, { 41, 20 }, { 22, 20 }, { 27, 11 } }))
    hat:add(t.R(18, 19, 45, 22, 1))
    local beard = t.E(31.5, 44, 11, 8):clip(c:rect(-9, t.Y(40), 9999, t.Y(52))):cut(c:rect(t.X(27), t.Y(48), t.X(36), t.Y(54)))
    beard:add(t.R(24, 38, 39, 42, 2))
    if pose == "staff" then
      local staff = c:rect(t.X(52), t.Y(15), t.X(53.5), t.Y(54))
      c:part(staff, GV.ramp(dim("#b07a45", dark)), { flat = true })
      c:part(t.E(52.5, 12, 3, 3), GV.ramp(dim("#e8a317", dark)), {})
    end
    piece(c, arms, GV.ramp(dim("#f08a24", dark)), { flat = true })
    piece(c, body, GV.ramp(dim("#e0501f", dark)), { stitch = { side = "lit" }, gloss = { rnd(t.X(20)), rnd(t.Y(30)) } })
    piece(c, beard, GV.ramp(dim("#f4ecd8", dark), { pale = true }), { gloss = { rnd(t.X(26)), rnd(t.Y(41)) } })
    piece(c, hat, GV.ramp(dim("#5a3f9e", dark)), { gloss = { rnd(t.X(29)), rnd(t.Y(10)) } })
    if pose == "clap" then -- hands meet in front of the beard
      local hands = t.E(28.5, 46 + dy, 3.5, 3.5):add(t.E(34.5, 45 + dy, 3.5, 3.5))
      piece(c, hands, GV.ramp(dim("#f08a24", dark)), { gloss = false, cres = 2, deep = 1 })
      c:px(rnd(t.X(31.5)), rnd(t.Y(45 + dy)), UMB)
    end
    if pose == "staff" then
      c:fill(c:rect(t.X(50), t.Y(38 + dy - 2), t.X(53), t.Y(40 + dy - 2)), dim("#f08a24", dark))
    end
    -- star on the hat
    local sx, sy = rnd(t.X(33)), rnd(t.Y(13))
    if s >= 0.6 then
      c:paint({ "..s..", ".sss.", "sssss", ".sss.", "s...s" }, sx - 2, sy - 2, { s = "#f5cf6a" }); c:px(sx, sy - 1, "#fff1c8")
    else
      c:paint({ ".s.", "sss", ".s." }, sx - 1, sy - 1, { s = "#f5cf6a" })
    end
    c:seam({ { rnd(t.X(21)), rnd(t.Y(20)) }, { rnd(t.X(42)), rnd(t.Y(20)) } })
    -- brows then eyes
    local by = rnd(t.Y(30 + dy - 3))
    c:fill(c:line({ { t.X(20), by }, { t.X(26), by } }, 1), "#c4c4c4"); c:fill(c:line({ { t.X(34), by }, { t.X(40), by } }, 1), "#c4c4c4")
    c:fill(c:line({ { t.X(21), by + 1 }, { t.X(26), by + 1 } }, 1), "#9a9a9a"); c:fill(c:line({ { t.X(34), by + 1 }, { t.X(39), by + 1 } }, 1), "#9a9a9a")
    t.eye(21, 29 + dy); t.eye(35, 29 + dy)
    c:fill(c:line({ { t.X(28), t.Y(40) }, { t.X(30), t.Y(41) }, { t.X(34), t.Y(41) }, { t.X(35), t.Y(40) } }, 1), UMB)
    return body
  end

  ---------------------------------------------------------------- props
  -- jigsaw piece lying flat: (x,y) top-left, size n, knob sides via string of "tblr", colour hex
  function M.piece(c, x, y, n, knobs, hex, dark, o)
    local m = c:rrect(x, y, x + n - 1, y + n - 1, 1)
    local k = max(1.5, n * 0.22)
    if knobs:find("t") then m:add(c:ellipse(x + (n - 1) / 2, y - 1, k, k)) end
    if knobs:find("b") then m:add(c:ellipse(x + (n - 1) / 2, y + n, k, k)) end
    if knobs:find("l") then m:add(c:ellipse(x - 1, y + (n - 1) / 2, k, k)) end
    if knobs:find("r") then m:add(c:ellipse(x + n, y + (n - 1) / 2, k, k)) end
    if knobs:find("T") then m:cut(c:ellipse(x + (n - 1) / 2, y - 1, k, k)) end
    if knobs:find("B") then m:cut(c:ellipse(x + (n - 1) / 2, y + n, k, k)) end
    if knobs:find("L") then m:cut(c:ellipse(x - 1, y + (n - 1) / 2, k, k)) end
    if knobs:find("R") then m:cut(c:ellipse(x + n, y + (n - 1) / 2, k, k)) end
    o = o or {}
    o.cres = o.cres or 2; o.deep = o.deep or 1
    if o.gloss == nil then o.gloss = n >= 7 and { x + 1, y + 1 } or false end
    c:part(m, GV.ramp(dim(hex, dark)), o)
    return m
  end

  -- gold trophy cup with handles on a plinth, centred at cx with its base at y1, height h
  function M.trophy(c, cx, y1, h, dark)
    local G = GV.ramp(dim("#e8a317", dark))
    local pw = rnd(h * 0.36)
    local plinth = c:rrect(cx - pw, y1 - rnd(h * 0.12), cx + pw, y1, 1)
    c:part(plinth, GV.ramp(dim("#5e2f1e", dark)), { gloss = false, cres = 2, deep = 1 })
    local stem = c:rect(cx - 1, y1 - rnd(h * 0.3), cx + 1, y1 - rnd(h * 0.12))
    local foot = c:ellipse(cx, y1 - rnd(h * 0.28), rnd(h * 0.2), 1.5)
    c:part(stem:add(foot), G, { flat = true })
    local cy, cr = y1 - rnd(h * 0.62), rnd(h * 0.3)
    local cup = c:ellipse(cx, cy, cr, cr * 1.1):clip(c:rect(cx - cr, cy - cr * .5, cx + cr, y1))
    cup:add(c:rect(cx - cr, cy - rnd(cr * 1.0), cx + cr, cy - rnd(cr * .5)))
    local handles = c:ellipse(cx - cr - 2, cy - rnd(cr * .5), 3.5, 4):cut(c:ellipse(cx - cr - 2, cy - rnd(cr * .5), 1.5, 2))
    handles:add(c:ellipse(cx + cr + 2, cy - rnd(cr * .5), 3.5, 4):cut(c:ellipse(cx + cr + 2, cy - rnd(cr * .5), 1.5, 2)))
    handles:cut(cup)
    c:part(handles, G, { flat = true })
    c:part(cup, G, { gloss = { cx - cr + 2, cy - cr + 1 }, cres = 3, deep = 1 })
    c:seam({ { cx - cr + 1, cy - rnd(cr * .5) + 1 }, { cx + cr - 1, cy - rnd(cr * .5) + 1 } })
    c:px(cx - 1, cy + 1, "#fff1c8"); c:px(cx, cy + 1, "#fff1c8"); c:px(cx - 1, cy + 2, "#fff1c8")
    return cup
  end

  return M
end
