-- Pass 2 (smaller BUILD signs) helpers for quail_coop, silk_shelf, tortoise_run, butterfly_bush.
local S = dofile("/tmp/ase/states2/q4signs_common.lua")
local K, HP, P = S.K, S.HP, S.P
local px, R = S.px, S.R

-- 1-px corner stake, h tall, foot at y1; returns the y where the string ties
function S.stake1(x, y1, h)
  local cv = S.c
  local m = cv:rect(x, y1 - h + 1, x, y1)
  K.ink(m)
  cv:fillMask(m, P.wood.base)
  px(x, y1 - h + 1, P.wood.hi)
  px(x, y1, P.wood.shade)
  return y1 - h + 2
end
function S.back(bxL, bxR, by, fxL, fxR, fy, h)
  local tb = S.stake1(bxL, by, h); S.stake1(bxR, by, h)
  local tf = fy - h + 2
  S.string({ { bxL + 1, tb }, { bxR - 1, tb } })
  S.string({ { bxR, tb + 1 }, { fxR, tf - 1 } })
  S.string({ { bxL, tb + 1 }, { fxL, tf - 1 } })
  S.string({ { fxL + 1, tf }, { fxR - 1, tf } })
end
function S.front(fxL, fxR, fy, h) S.stake1(fxL, fy, h); S.stake1(fxR, fy, h) end
-- the small plot with its staked string footprint (back half), call S.front after the sign
function S.smallPlot(AX, AY, seed)
  S.plot(AX - 12, AY - 6, AX + 12, AY + 3, seed)
  S.back(AX - 9, AX + 9, AY - 4, AX - 10, AX + 10, AY + 1, 3)
end
return S
