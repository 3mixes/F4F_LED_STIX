-- Versão Definitiva Corrigida e Sintaticamente Verificada
-- Caminho SD: /SCRIPTS/WIDGETS/f4ftelem/main.lua

local default_options = {
  { "Interval", VALUE, 5, 1, 30 },
  { "Control", SOURCE, 225 },
  { "ResetSw", SOURCE, 0 },
  { "BgColor", COLOR, 0 },
  { "PrimColor", COLOR, 1 },
  { "SecColor", COLOR, 0xFFFF },
  { "TitleColor", COLOR, 2 }
}

local function combineFlags(f1, f2, f3)
  return (f1 or 0) + (f2 or 0) + (f3 or 0)
end

local function safeRGB(r, g, b, fallback)
  if lcd and lcd.RGB then
    local ok, res = pcall(lcd.RGB, r, g, b)
    if ok and res then return res end
  end
  return fallback or 0
end

local function drawCutBox(x, y, w, h, c, color)
  lcd.setColor(CUSTOM_COLOR, color)
  lcd.drawLine(x + c, y, x + w - c, y, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x + w - c, y, x + w, y + c, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x + w, y + c, x + w, y + h - c, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x + w - c, y + h, x + c, y + h, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x + c, y + h, x, y + h - c, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x, y + h - c, x, y + c, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x, y + c, x + c, y, SOLID, CUSTOM_COLOR)
end

local function drawDoubleCutBox(x, y, w, h, c, color1, color2)
  drawCutBox(x, y, w, h, c, color1)
  drawCutBox(x + 2, y + 2, w - 4, h - 4, math.max(1, c - 2), color2)
end

local function drawIcon(icon_id, x, y, color)
  y = y + 4
  lcd.setColor(CUSTOM_COLOR, color)

  if icon_id == 1 then 
    lcd.drawRectangle(x, y + 2, 14, 9, CUSTOM_COLOR)
    lcd.drawFilledRectangle(x + 14, y + 4, 2, 5, CUSTOM_COLOR)
    lcd.drawFilledRectangle(x + 2, y + 4, 6, 5, CUSTOM_COLOR)
  elseif icon_id == 2 then 
    lcd.drawFilledRectangle(x,      y + 8, 2, 5, CUSTOM_COLOR)
    lcd.drawFilledRectangle(x + 3,  y + 5, 2, 8, CUSTOM_COLOR)
    lcd.drawFilledRectangle(x + 6,  y + 2, 2, 11, CUSTOM_COLOR)
    lcd.drawFilledRectangle(x + 9,  y,     2, 13, CUSTOM_COLOR)
  elseif icon_id == 3 then 
    lcd.drawRectangle(x, y, 12, 12, CUSTOM_COLOR)
    lcd.drawPoint(x + 6, y + 6, CUSTOM_COLOR)
    lcd.drawLine(x + 6, y + 2, x + 6, y + 6, SOLID, CUSTOM_COLOR)
    lcd.drawLine(x + 6, y + 6, x + 9, y + 6, SOLID, CUSTOM_COLOR)
  elseif icon_id == 4 then 
    lcd.drawLine(x, y, x, y + 13, SOLID, CUSTOM_COLOR)
    lcd.drawRectangle(x + 1, y, 10, 7, CUSTOM_COLOR)
    lcd.drawPoint(x + 3, y + 2, CUSTOM_COLOR)
    lcd.drawPoint(x + 7, y + 4, CUSTOM_COLOR)
  elseif icon_id == 5 then 
    lcd.drawLine(x + 6, y,     x + 2, y + 7,  SOLID, CUSTOM_COLOR)
    lcd.drawLine(x + 2, y + 7, x + 7, y + 7,  SOLID, CUSTOM_COLOR)
    lcd.drawLine(x + 7, y + 7, x + 2, y + 15, SOLID, CUSTOM_COLOR)
    lcd.drawLine(x + 10, y + 9,  x + 12, y + 12, SOLID, CUSTOM_COLOR)
    lcd.drawLine(x + 12, y + 12, x + 16, y + 4,  SOLID, CUSTOM_COLOR)
  end
end

local function drawTabHeader(x, y, w, title_text, index_text, tab_bg, border_color, text_color, accent_color, icon_id)
  local tab_h = 21
  local tab_w = math.floor(w * 0.72)
  local slant = 8

  lcd.setColor(CUSTOM_COLOR, tab_bg)
  lcd.drawFilledRectangle(x + 3, y + 3, tab_w - slant, tab_h, CUSTOM_COLOR)
  for row = 0, tab_h - 1 do
    local dx = math.floor((tab_h - 1 - row) * slant / tab_h)
    lcd.drawLine(x + 3 + tab_w - slant, y + 3 + row, x + 3 + tab_w - slant + dx, y + 3 + row, SOLID, CUSTOM_COLOR)
  end

  lcd.setColor(CUSTOM_COLOR, border_color)
  lcd.drawLine(x + 3, y + 3, x + 3 + tab_w - slant, y + 3, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x + 3, y + 3 + tab_h, x + 3 + tab_w, y + 3 + tab_h, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x + 3 + tab_w - slant, y + 3, x + 3 + tab_w, y + 3 + tab_h, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x + 3, y + 3, x + 3, y + 3 + tab_h, SOLID, CUSTOM_COLOR)

  local f_mid = MIDSIZE or BOLD or 0
  lcd.setColor(CUSTOM_COLOR, border_color)
  lcd.drawText(x + 8, y + 5, "//", combineFlags(f_mid, CUSTOM_COLOR, 0))

  local text_x = x + 24
  if icon_id and icon_id > 0 then
    drawIcon(icon_id, x + 22, y + 6, accent_color)
    text_x = x + 42
  end

  lcd.setColor(CUSTOM_COLOR, text_color)
  lcd.drawText(text_x, y + 5, title_text, combineFlags(f_mid, CUSTOM_COLOR, 0))

  if index_text then
    lcd.setColor(CUSTOM_COLOR, accent_color)
    lcd.drawText(x + w - 48, y + 5, index_text, combineFlags(f_mid, CUSTOM_COLOR, 0))
  end
end

local function drawSegmentedBar(x, y, w, h, pct, total_seg, active_color, bg_color)
  pct = math.max(0, math.min(100, pct))
  local active_seg = math.floor((pct / 100) * total_seg)
  local slant = 6
  local spacing = 3
  local seg_w = math.max(2, math.floor((w - slant - (total_seg - 1) * spacing) / total_seg))
  
  for i = 0, total_seg - 1 do
    local sx = x + i * (seg_w + spacing)
    local col = (i < active_seg) and active_color or bg_color
    lcd.setColor(CUSTOM_COLOR, col)
    for row = 0, h - 1 do
      local dx = math.floor((h - 1 - row) * slant / h)
      lcd.drawLine(sx + dx, y + row, sx + dx + seg_w - 1, y + row, SOLID, CUSTOM_COLOR)
    end
  end
end

local function create(zone, options)
  return { 
    zone = zone, 
    options = options,
    wasConnected = false,
    connectTime = 0,
    indice = 1,
    last_state = 0,
    last_auto_time = 0,
    min_volt = 0,
    min_rqly = 0,
    min_rssi = 0,
    max_capa = 0,
    last_volt = 0,
    flight_dur = 0,
    has_report = false,
    report_time = 0,
    timer_offset = 0,
    is_holding_reset = false,
    reset_start_time = 0,
    reset_triggered = false,
    show_reset_popup = false,
    reset_popup_time = 0
  }
end

local function update(w, options)
  if w then w.options = options end
end

local function background(w)
end

local function refresh(w)
  if not w or not w.zone then return end

  w.indice = w.indice or 1
  w.last_state = w.last_state or 0
  w.last_auto_time = w.last_auto_time or getTime()
  w.min_volt = w.min_volt or 0
  w.min_rqly = w.min_rqly or 0
  w.min_rssi = w.min_rssi or 0
  w.max_capa = w.max_capa or 0
  w.last_volt = w.last_volt or 0
  w.flight_dur = w.flight_dur or 0
  w.has_report = w.has_report or false
  w.timer_offset = w.timer_offset or 0

  local C_CYAN = safeRGB(0, 240, 255, 0x07FF)
  local C_YELLOW = safeRGB(255, 195, 0, 0xFFE0)
  local C_RED = safeRGB(255, 35, 35, 0xF800)
  local C_GREEN = safeRGB(50, 255, 100, 0x07E0)
  local C_DARK_RED = safeRGB(90, 10, 20, 0x5800)
  local C_DARK_GREEN = safeRGB(10, 90, 40, 0x02C0)
  local C_DARK_BG = safeRGB(18, 24, 38, 0x10A5)
  local C_WHITE = WHITE or safeRGB(255, 255, 255, 0xFFFF)
  local C_BLACK_BG = BLACK or safeRGB(10, 14, 23, 0x0000)

  local x = w.zone.x
  local y = w.zone.y
  local w_w = w.zone.w
  local w_h = w.zone.h

  local F_DBL = DBLSIZE or 0
  local F_MID = MIDSIZE or BOLD or 0
  local F_CUST = CUSTOM_COLOR or 0
  local F_CENTER = CENTER or 0

  local C_BG_CUSTOM = (w.options and w.options.BgColor) or C_BLACK_BG
  local C_LABEL = (w.options and w.options.PrimColor) or C_CYAN
  local C_VALUE = (w.options and w.options.SecColor) or C_YELLOW
  local C_TITLE = (w.options and w.options.TitleColor) or C_RED

  local rxbt = getValue("RxBt") or getValue("Bat") or 0
  local bat_pct = getValue("Bat%") or 0
  local curr = getValue("Curr") or 0
  local capa = getValue("Capa") or getValue("Fuel") or 0
  local rqly = getValue("RQly") or getValue("RQLY") or 0
  local rss1 = getValue("1RSS") or 0
  local rsnr = getValue("RSNR") or 0
  local trss = getValue("TRSS") or 0
  local tpwr = getValue("TPWR") or 0
  
  local raw_timer = getValue("timer1") or getValue("t1") or 0
  local timerSeconds = math.max(0, raw_timer - w.timer_offset)

  local hasTelemetry = (rqly > 0) or (rxbt > 0)
  local now = getTime()

  -- Leitura do ResetSw utilizando exatamente o mesmo método seguro do Control
  local reset_opt = (w.options and w.options.ResetSw)
  local reset_val = 0
  if reset_opt ~= nil then
    local ok, res = pcall(getValue, reset_opt)
    if ok and res then
      reset_val = res
    end
  end

  if reset_val > 100 or reset_val < -100 then
    reset_val = (reset_val / 1024) * 100
  end

  local is_active = (reset_val > 50 or reset_val < -50)

  if is_active then
    if not w.is_holding_reset then
      w.is_holding_reset = true
      w.reset_start_time = now
      w.reset_triggered = false
    elseif not w.reset_triggered then
      if (now - w.reset_start_time) >= 300 then
        w.timer_offset = raw_timer
        w.flight_dur = 0
        w.show_reset_popup = true
        w.reset_popup_time = now
        w.reset_triggered = true
      end
    end
  else
    w.is_holding_reset = false
    w.reset_triggered = false
  end

  if w.show_reset_popup and (now - w.reset_popup_time) >= 200 then
    w.show_reset_popup = false
  end

  local interval_sec = (w.options and w.options.Interval) or 5
  local interval_ticks = interval_sec * 100

  local control_opt = (w.options and w.options.Control)
  local control_val = 0
  if control_opt ~= nil then
    local ok, res = pcall(getValue, control_opt)
    if ok and res then
      control_val = res
    end
  else
    control_val = getValue(225) or 0
  end
  
  if control_val > 100 or control_val < -100 then
    control_val = (control_val / 1024) * 100
  end

  local manual_changed = false
  if control_val >= 95 then
    if w.last_state == 0 then
      w.indice = w.indice + 1
      if w.indice > 4 then w.indice = 1 end
      w.last_state = 1
      manual_changed = true
    end
  elseif control_val <= -95 then
    if w.last_state == 0 then
      w.indice = w.indice - 1
      if w.indice < 1 then w.indice = 4 end
      w.last_state = -1
      manual_changed = true
    end
  else
    if control_val > -50 and control_val < 50 then
      w.last_state = 0
    end
  end

  if manual_changed then
    w.last_auto_time = now
  else
    if (now - w.last_auto_time) >= interval_ticks then
      w.indice = w.indice + 1
      if w.indice > 4 then w.indice = 1 end
      w.last_auto_time = now
    end
  end

  if hasTelemetry then
    if not w.wasConnected then
      w.wasConnected = true
      w.connectTime = now
      w.min_volt = rxbt
      w.min_rqly = rqly
      w.min_rssi = rss1
      w.max_capa = capa
      w.last_volt = rxbt
      w.flight_dur = 0
      w.has_report = false
    else
      if rxbt > 0 and (w.min_volt == 0 or rxbt < w.min_volt) then w.min_volt = rxbt end
      if rqly > 0 and (w.min_rqly == 0 or rqly < w.min_rqly) then w.min_rqly = rqly end
      if rss1 ~= 0 and (w.min_rssi == 0 or rss1 < w.min_rssi) then w.min_rssi = rss1 end
      if capa > w.max_capa then w.max_capa = capa end
      if rxbt > 0 then w.last_volt = rxbt end
      w.flight_dur = math.abs(timerSeconds)
    end
  else
    if w.wasConnected then
      w.wasConnected = false
      w.has_report = true
      w.report_time = now
    end
  end

  if w.has_report and (now - w.report_time) >= 1500 then
    w.has_report = false
  end

  lcd.setColor(CUSTOM_COLOR, C_BG_CUSTOM)
  lcd.drawFilledRectangle(x, y, w_w, w_h, CUSTOM_COLOR)

  local box_x, box_y = x + 2, y + 2
  local box_w, box_h = w_w - 4, w_h - 4
  local col1_x = box_x + 8
  local col2_x = box_x + math.floor(box_w * 0.52)

  drawDoubleCutBox(box_x, box_y, box_w, box_h, 7, C_LABEL, C_TITLE)

  if w.indice == 1 then
    drawTabHeader(box_x, box_y, box_w, "POWER CORE", string.format("[%d/4]", w.indice), C_DARK_BG, C_TITLE, C_WHITE, C_YELLOW, 1)
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col1_x, box_y + 27, "Bat:", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_VALUE)
    lcd.drawText(col1_x + 45, box_y + 27, string.format("%d %%", bat_pct), combineFlags(F_MID, F_CUST, 0))
    local pct = math.max(0, math.min(100, bat_pct))
    drawSegmentedBar(col1_x, box_y + 48, math.floor(box_w * 0.44), 22, pct, 10, (pct < 20) and C_RED or C_LABEL, C_DARK_BG)
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col1_x, box_y + 74, "Cap:", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_VALUE)
    lcd.drawText(col1_x + 45, box_y + 74, string.format("%d mAh", capa), combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col2_x, box_y + 27, "Volt:", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_VALUE)
    lcd.drawText(col2_x + 50, box_y + 27, string.format("%.2fV", rxbt), combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col2_x, box_y + 50, "Curr:", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_VALUE)
    lcd.drawText(col2_x + 50, box_y + 50, string.format("%.1fA", curr), combineFlags(F_MID, F_CUST, 0))

  elseif w.indice == 2 then
    drawTabHeader(box_x, box_y, box_w, "RF LINK [ELRS]", string.format("[%d/4]", w.indice), C_DARK_BG, C_TITLE, C_WHITE, C_YELLOW, 2)
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col1_x, box_y + 27, "RQly:", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, (rqly < 70) and C_RED or C_VALUE)
    lcd.drawText(col1_x + 50, box_y + 27, string.format("%d %%", rqly), combineFlags(F_MID, F_CUST, 0))
    drawSegmentedBar(col1_x, box_y + 48, math.floor(box_w * 0.44), 22, rqly, 10, (rqly < 70) and C_RED or C_VALUE, C_DARK_BG)
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col1_x, box_y + 74, "1RSS:", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_VALUE)
    lcd.drawText(col1_x + 50, box_y + 74, string.format("%ddBm", rss1), combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col2_x, box_y + 27, "RSNR:", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_VALUE)
    lcd.drawText(col2_x + 55, box_y + 27, string.format("%ddB", rsnr), combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col2_x, box_y + 50, "TRSS:", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_VALUE)
    lcd.drawText(col2_x + 55, box_y + 50, string.format("%ddBm", trss), combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col2_x, box_y + 72, "TPWR:", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_VALUE)
    lcd.drawText(col2_x + 55, box_y + 72, string.format("%dmW", tpwr), combineFlags(F_MID, F_CUST, 0))

  elseif w.indice == 3 then
    drawTabHeader(box_x, box_y, box_w, "MISSION & STATUS", string.format("[%d/4]", w.indice), C_DARK_BG, C_TITLE, C_WHITE, C_YELLOW, 3)
    local t_min = math.floor(timerSeconds / 60)
    local t_sec = math.floor(timerSeconds % 60)
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col1_x, box_y + 27, "Flight Time:", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, (timerSeconds < 0) and C_RED or C_WHITE)
    lcd.drawText(col1_x, box_y + 47, string.format("%02d:%02d", t_min, t_sec), combineFlags(F_DBL, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_LABEL)
    lcd.drawText(col2_x, box_y + 27, "SYS STATUS:", combineFlags(F_MID, F_CUST, 0))
    if (math.floor(now / 50) % 2 == 0) and hasTelemetry then
      lcd.setColor(CUSTOM_COLOR, C_LABEL)
      lcd.drawFilledRectangle(col2_x, box_y + 51, 8, 8, CUSTOM_COLOR)
    end
    lcd.setColor(CUSTOM_COLOR, hasTelemetry and C_VALUE or C_RED)
    lcd.drawText(col2_x + 12, box_y + 47, hasTelemetry and "ONLINE" or "NO LINK", combineFlags(F_MID, F_CUST, 0))

  elseif w.indice == 4 then
    drawTabHeader(box_x, box_y, box_w, "RACING TEAM", string.format("[%d/4]", w.indice), C_DARK_BG, C_TITLE, C_WHITE, C_YELLOW, 4)
    local b_x, b_y = box_x + 10, box_y + 28
    local b_w = box_w - 20
    local b_h = math.max(28, box_h - 89)
    lcd.setColor(CUSTOM_COLOR, C_YELLOW)
    lcd.drawFilledRectangle(b_x, b_y, b_w, b_h, CUSTOM_COLOR)
    local split_x = b_x + math.floor(b_w * 0.38)
    local slant = math.floor(b_h * 0.35)
    lcd.setColor(CUSTOM_COLOR, C_BLACK_BG)
    lcd.drawFilledRectangle(b_x, b_y, split_x - b_x, b_h, CUSTOM_COLOR)
    for r = 0, b_h - 1 do
      local dx = math.floor((b_h - 1 - r) * slant / b_h)
      lcd.drawLine(split_x, b_y + r, split_x + dx, b_y + r, SOLID, CUSTOM_COLOR)
    end
    local sq = 4
    local cols = 3
    local rows = math.floor(b_h / sq)
    for r = 0, rows - 1 do
      local ry = b_y + r * sq
      local rh = math.min(sq, b_y + b_h - ry)
      local dx = math.floor((b_h - ((r * sq) + (sq / 2))) * slant / b_h)
      for c = 0, cols - 1 do
        local cx = split_x + dx + (c * sq)
        lcd.setColor(CUSTOM_COLOR, ((r + c) % 2 == 0) and C_WHITE or C_BLACK_BG)
        lcd.drawFilledRectangle(cx, ry, sq, rh, CUSTOM_COLOR)
      end
    end
    
    lcd.setColor(CUSTOM_COLOR, C_WHITE)
    lcd.drawText(b_x + 12, b_y + 4, "FPV", combineFlags(F_MID, F_CUST, 0))
    lcd.setColor(CUSTOM_COLOR, C_BLACK_BG)
    lcd.drawText(split_x + 24, b_y + 4, "4.FUN", combineFlags(F_MID, F_CUST, 0))

    drawCutBox(b_x, b_y, b_w, b_h, 5, C_BLACK_BG)
    lcd.setColor(CUSTOM_COLOR, C_CYAN)
    lcd.drawText(box_x + math.floor(box_w / 2), b_y + b_h + 4, "WWW.FPV4.FUN", combineFlags(F_MID, F_CENTER, F_CUST))
  end

  local dot_y = box_y + box_h - 7
  for p = 1, 4 do
    local dot_x = box_x + math.floor(box_w / 2) - 20 + (p * 8)
    if p == w.indice then
      lcd.setColor(CUSTOM_COLOR, C_TITLE)
      lcd.drawFilledRectangle(dot_x, dot_y, 4, 4, CUSTOM_COLOR)
    else
      lcd.setColor(CUSTOM_COLOR, C_DARK_BG)
      lcd.drawRectangle(dot_x, dot_y, 4, 4, CUSTOM_COLOR)
    end
  end

  if w.show_reset_popup then
    local pop_w, pop_h = box_w - 12, 36
    local pop_x, pop_y = box_x + 6, box_y + box_h - 42
    local blink = (math.floor(now / 20) % 2 == 0)
    lcd.setColor(CUSTOM_COLOR, C_BLACK_BG)
    lcd.drawFilledRectangle(pop_x, pop_y, pop_w, pop_h, CUSTOM_COLOR)
    drawDoubleCutBox(pop_x, pop_y, pop_w, pop_h, 4, blink and C_GREEN or C_DARK_GREEN, blink and C_CYAN or C_DARK_GREEN)
    drawIcon(3, pop_x + 10, pop_y + 8, C_YELLOW)
    lcd.setColor(CUSTOM_COLOR, blink and C_GREEN or C_WHITE)
    lcd.drawText(pop_x + 32, pop_y + 8, "TIMER RESETED", combineFlags(F_MID, F_CUST, 0))
  elseif not hasTelemetry then
    if w.has_report then
      local rep_w, rep_h = box_w - 4, box_h - 4
      local rep_x, rep_y = box_x + 2, box_y + 2
      local rem_sec = math.max(0, math.ceil((1500 - (now - w.report_time)) / 100))
      lcd.setColor(CUSTOM_COLOR, C_BLACK_BG)
      lcd.drawFilledRectangle(rep_x, rep_y, rep_w, rep_h, CUSTOM_COLOR)
      drawDoubleCutBox(rep_x, rep_y, rep_w, rep_h, 6, C_CYAN, C_TITLE)
      drawTabHeader(rep_x, rep_y, rep_w, "FLIGHT DEBRIEF", string.format("[%ds]", rem_sec), C_DARK_BG, C_CYAN, C_WHITE, C_YELLOW, 5)
      local c1_x = rep_x + 8
      local c2_x = rep_x + math.floor(rep_w * 0.51)
      local r1_y = rep_y + 28
      local r2_y = rep_y + 50
      local r3_y = rep_y + 72
      
      drawIcon(1, c1_x, r1_y, C_CYAN)
      lcd.setColor(CUSTOM_COLOR, C_VALUE)
      lcd.drawText(c1_x + 24, r1_y - 2, string.format("%d mAh", w.max_capa), combineFlags(F_MID, F_CUST, 0))
      
      drawIcon(5, c1_x, r2_y, C_RED)
      lcd.setColor(CUSTOM_COLOR, C_VALUE)
      lcd.drawText(c1_x + 24, r2_y - 2, string.format("%.2f V", w.min_volt), combineFlags(F_MID, F_CUST, 0))
      
      drawIcon(5, c1_x, r3_y, C_YELLOW)
      lcd.setColor(CUSTOM_COLOR, C_VALUE)
      lcd.drawText(c1_x + 24, r3_y - 2, string.format("%.2f V", w.last_volt), combineFlags(F_MID, F_CUST, 0))
      
      drawIcon(2, c2_x, r1_y, C_CYAN)
      lcd.setColor(CUSTOM_COLOR, C_VALUE)
      lcd.drawText(c2_x + 20, r1_y - 2, string.format("%d %%", w.min_rqly), combineFlags(F_MID, F_CUST, 0))
      
      drawIcon(2, c2_x, r2_y, C_YELLOW)
      lcd.setColor(CUSTOM_COLOR, C_VALUE)
      lcd.drawText(c2_x + 20, r2_y - 2, string.format("%d dBm", w.min_rssi), combineFlags(F_MID, F_CUST, 0))
      
      drawIcon(3, c2_x, r3_y, C_CYAN)
      lcd.setColor(CUSTOM_COLOR, C_VALUE)
      lcd.drawText(c2_x + 20, r3_y - 2, string.format("%02d:%02d", math.floor(w.flight_dur / 60), math.floor(w.flight_dur % 60)), combineFlags(F_MID, F_CUST, 0))
    else
      local pop_w, pop_h = box_w - 12, 36
      local pop_x, pop_y = box_x + 6, box_y + box_h - 42
      local blink = (math.floor(now / 35) % 2 == 0)
      local dots = { "", ".", "..", "..." }
      lcd.setColor(CUSTOM_COLOR, C_BLACK_BG)
      lcd.drawFilledRectangle(pop_x, pop_y, pop_w, pop_h, CUSTOM_COLOR)
      drawDoubleCutBox(pop_x, pop_y, pop_w, pop_h, 4, blink and C_RED or C_DARK_RED, blink and C_TITLE or C_DARK_RED)
      lcd.setColor(CUSTOM_COLOR, blink and C_RED or C_WHITE)
      lcd.drawText(pop_x + math.floor(pop_w / 2), pop_y + 8, "WAITING FOR AIRCRAFT" .. dots[(math.floor(now / 25) % 4) + 1], combineFlags(F_MID, F_CENTER, F_CUST))
    end
  elseif w.wasConnected and (now - w.connectTime) < 300 then
    local pop_w, pop_h = box_w - 12, 36
    local pop_x, pop_y = box_x + 6, box_y + box_h - 42
    local blink = (math.floor(now / 20) % 2 == 0)
    lcd.setColor(CUSTOM_COLOR, C_BLACK_BG)
    lcd.drawFilledRectangle(pop_x, pop_y, pop_w, pop_h, CUSTOM_COLOR)
    drawDoubleCutBox(pop_x, pop_y, pop_w, pop_h, 4, blink and C_GREEN or C_DARK_GREEN, blink and C_CYAN or C_DARK_GREEN)
    lcd.setColor(CUSTOM_COLOR, blink and C_GREEN or C_WHITE)
    lcd.drawText(pop_x + math.floor(pop_w / 2), pop_y + 8, "CONNECTED", combineFlags(F_MID, F_CENTER, F_CUST))
  end
end

return { 
  name = "F4Ftelem", 
  options = default_options, 
  create = create, 
  update = update, 
  background = background, 
  refresh = refresh 
}