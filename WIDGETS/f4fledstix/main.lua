-- ============================================================================
-- WIDGET F4FLEDSTIX - EDGETX (360x240) - SCROLL INVERTIDO VERDE E THROTTLE
-- ============================================================================

local ARMED_SOURCE          = "SA"       
local AUX_SOURCE            = "SB"       
local ARMED_THRESHOLD       = 0          
local BEEPER_FLASH_COUNT    = 3          
local BEEPER_FLASH_DURATION = 150        
local LED_STRIP_LENGTH      = 8 

-- Helper universal para compatibilidade de cores RGB no EdgeTX
local function colorRGB(r, g, b)
    if lcd.RGB then
        return lcd.RGB(r, g, b)
    end
    return (r * 65536) + (g * 256) + b
end

-- Extração de RGB por matemática pura (Evita erros de bibliotecas de bits no LuaJIT)
local function extractRGB(color)
    if not color then return 0, 0, 0 end
    local r = math.floor(color / 65536) % 256
    local g = math.floor(color / 256) % 256
    local b = color % 256
    return r, g, b
end

local TRAIL_TIMES = { 50, 100, 150, 200, 0 }

local options = {
    { "BgColor",     COLOR, colorRGB(15, 15, 18)   },
    { "StickColor",  COLOR, colorRGB(255, 255, 255) },
    { "GimbalColor", COLOR, colorRGB(248, 0, 0)     },
    { "RingColor",   COLOR, colorRGB(235, 35, 120)  },
    { "TrailColor",  COLOR, colorRGB(0, 255, 120)   },
    { "TrailTime",   CHOICE, 2, { "0.5 Seg", "1.0 Seg", "1.5 Seg", "2.0 Seg", "Desligado" } },
    { "Op1",         CHOICE, 0, { "Desligado", "P1", "P2", "S1", "S2", "LS", "RS" } },
    { "Op2",         CHOICE, 0, { "Desligado", "P1", "P2", "S1", "S2", "LS", "RS" } }
}

local POT_SOURCES = { "", "P1", "P2", "S1", "S2", "LS", "RS" }

local COLOR_CONN    = colorRGB(0, 255, 120)
local COLOR_DISCONN = colorRGB(248, 0, 0)
local COLOR_ARMED   = colorRGB(255, 0, 100)

local function safeColor(val, default)
    if val and val > 0 then return val end
    return default
end

local function drawBatteryIcon(x, y, pct, color)
    lcd.drawRectangle(x, y, 20, 10, color)
    lcd.drawFilledRectangle(x + 20, y + 3, 2, 4, color)
    local fillWidth = math.floor((pct / 100) * 16)
    if fillWidth > 16 then fillWidth = 16 end
    if fillWidth > 0 then
        lcd.drawFilledRectangle(x + 2, y + 2, fillWidth, 6, color)
    end
end

local function updateTrail(trail, x, y, now, maxDuration)
    if maxDuration <= 0 then trail = {} return end
    table.insert(trail, { x = x, y = y, t = now })
    while (#trail > 0) and ((now - trail[1].t) > maxDuration) do
        table.remove(trail, 1)
    end
end

local function drawTrail(trail, now, trailColor, maxDuration)
    if maxDuration <= 0 or #trail < 2 then return end
    local r1, g1, b1 = extractRGB(trailColor)

    local len = #trail
    for i = 2, len do
        local p1 = trail[i-1]
        local p2 = trail[i]
        local ratio = 1 - (( (now - p1.t) + (now - p2.t) ) / 2 / maxDuration)
        if ratio > 0 then
            local brightness = 0.3 + ratio * 0.7
            local color = colorRGB(math.floor(r1 * brightness), math.floor(g1 * brightness), math.floor(b1 * brightness))
            for step = 0, 4 do
                local t = step / 4
                lcd.drawFilledCircle(math.floor(p1.x + (p2.x - p1.x) * t), math.floor(p1.y + (p2.y - p1.y) * t), 2, color)
            end
        end
    end
end

local function drawGimbal(widget, cx, cy, hVal, vVal, trail, armed, now, isConnected)
    local ringC   = safeColor(widget.options.RingColor, colorRGB(235, 35, 120))
    local stickC  = safeColor(widget.options.StickColor, colorRGB(255, 255, 255))
    local gimbalC = safeColor(widget.options.GimbalColor, colorRGB(248, 0, 0))
    local trailC  = safeColor(widget.options.TrailColor, colorRGB(0, 255, 120))
    local bgC     = safeColor(widget.options.BgColor, colorRGB(15, 15, 18))
    local trailDuration = TRAIL_TIMES[widget.options.TrailTime] or 100

    local r_g, g_g, b_g = extractRGB(gimbalC)
    local gridC    = colorRGB(math.floor(r_g * 0.8), math.floor(g_g * 0.8), math.floor(b_g * 0.8))
    local darkGimb = colorRGB(math.floor(r_g * 0.5), math.floor(g_g * 0.5), math.floor(b_g * 0.5))

    if armed and isConnected then
        local sine = (math.sin(now / 15) + 1) / 2
        local r_r, g_r, b_r = extractRGB(ringC)
        ringC = colorRGB(math.floor(r_r * 0.4), math.floor(g_r * 0.4 + 255 * 0.6 * sine), math.floor(b_r * 0.4 + 120 * 0.6 * sine))
    elseif armed then
        ringC = COLOR_ARMED
    end

    lcd.drawFilledCircle(cx, cy, 54, ringC)
    lcd.drawFilledCircle(cx - 35, cy - 35, 3, bgC)
    lcd.drawFilledCircle(cx + 35, cy - 35, 3, bgC)
    lcd.drawFilledCircle(cx - 35, cy + 35, 3, bgC)
    lcd.drawFilledCircle(cx + 35, cy + 35, 3, bgC)

    lcd.drawFilledCircle(cx, cy, 44, gimbalC)
    lcd.drawCircle(cx, cy, 44, darkGimb)
    lcd.drawCircle(cx, cy, 43, darkGimb)
    lcd.drawCircle(cx, cy, 42, darkGimb)

    lcd.drawLine(cx - 34, cy, cx + 34, cy, SOLID, gridC)
    lcd.drawLine(cx, cy - 34, cx, cy + 34, SOLID, gridC)

    local hx = math.max(-1, math.min(1, hVal / 1024))
    local vy = math.max(-1, math.min(1, vVal / 1024))
    local px = cx + math.floor(hx * 30)
    local py = cy - math.floor(vy * 30)

    if armed then
        updateTrail(trail, px, py, now, trailDuration)
        drawTrail(trail, now, trailC, trailDuration)
    end

    lcd.drawFilledCircle(px, py, 10, stickC)
    lcd.drawFilledCircle(px, py, 7, gimbalC)
    lcd.drawFilledCircle(px, py, 3, stickC)
    lcd.drawFilledCircle(px, py, 1, gimbalC)
end

local function drawCenterInfo(widget, cx, cy, armed, isConnected, now, led_buffer, num_leds_real, bright)
    local txVolts = getValue("tx-voltage") or 0
    local batColor = COLOR_CONN
    local batPct = math.max(0, math.min(100, math.floor(((txVolts - 6.4) / 2.0) * 100)))

    if txVolts > 0 and txVolts < 6.8 then
        batColor = COLOR_DISCONN
    elseif txVolts >= 6.8 and txVolts <= 7.4 then
        batColor = colorRGB(255, 180, 0)
    end

    drawBatteryIcon(cx - 11, cy - 54, batPct, batColor)

    local batStr = string.format("%.1fV", txVolts)
    lcd.drawText(cx - math.floor(#batStr * 3), cy - 40, batStr, SMLSIZE + batColor)

    local radius = 16
    local rssiBorderColor = isConnected and COLOR_CONN or COLOR_DISCONN
    local isBlinkOn = (now % 10) < 5

    for rOffset = 6, 10 do
        lcd.drawCircle(cx, cy, radius + rOffset, rssiBorderColor)
    end

    if armed then
        if isBlinkOn or not isConnected then
            lcd.drawFilledCircle(cx, cy, radius, COLOR_CONN)
            lcd.drawText(cx - 3, cy - 8, "A", BOLD + BLACK)
        else
            lcd.drawCircle(cx, cy, radius, COLOR_CONN)
            lcd.drawText(cx - 3, cy - 8, "A", BOLD + COLOR_CONN)
        end
    else
        lcd.drawFilledCircle(cx, cy, radius, COLOR_DISCONN)
        lcd.drawText(cx - 3, cy - 8, "D", BOLD + WHITE)
    end

    local preview_count = 6
    local rect_w = 10
    local rect_h = 28
    local gap_intra_grupo = 2
    local gap_grupo = 8
    
    local total_w = (preview_count * rect_w) + (4 * gap_intra_grupo) + gap_grupo
    local start_x = cx - math.floor(total_w / 2)
    local start_y = cy + 32

    local white_color = safeColor(widget.options.StickColor, colorRGB(255, 255, 255))

    for i = 1, preview_count do
        local sampled_idx = math.floor((i - 1) * (num_leds_real / preview_count)) + 1
        local cell = led_buffer[sampled_idx] or {r = 0, g = 0, b = 0}

        local pr = math.floor((cell.r or 0) * bright)
        local pg = math.floor((cell.g or 0) * bright)
        local pb = math.floor((cell.b or 0) * bright)

        local extra_offset = 0
        if i > 3 then extra_offset = gap_grupo end

        local rx = start_x + extra_offset + ((i - 1) * (rect_w + gap_intra_grupo))
        local core_color = colorRGB(pr, pg, pb)
        local glow_color = colorRGB(math.floor(pr * 0.45), math.floor(pg * 0.45), math.floor(pb * 0.45))

        lcd.drawRectangle(rx - 1, start_y - 1, rect_w + 2, rect_h + 2, glow_color)
        lcd.drawFilledRectangle(rx, start_y, rect_w, rect_h, core_color)
        lcd.drawRectangle(rx, start_y, rect_w, rect_h, white_color)
    end
end

local function processPotScroll(val, state, now, num_leds_real, led_buffer)
    local deadzone = 100
    if math.abs(val) < deadzone then return false end
    
    local magnitude = math.abs(val)
    local speedInterval = math.max(2, math.floor(20 - (magnitude / 1024) * 18))
    
    if (now - state.scrollTime) > speedInterval then
        state.scrollTime = now
        if val > 0 then
            state.scrollCycle = state.scrollCycle + 1
            if state.scrollCycle > (num_leds_real * 2 - 2) then
                state.scrollCycle = 1
            end
        else
            state.scrollCycle = state.scrollCycle - 1
            if state.scrollCycle < 1 then
                state.scrollCycle = num_leds_real * 2 - 2
            end
        end
    end

    local pos = state.scrollCycle
    if pos > num_leds_real then
        pos = 2 * num_leds_real - pos
    end

    for i = 1, num_leds_real do
        if i == pos then
            led_buffer[i] = {r = 255, g = 255, b = 255}
        elseif math.abs(i - pos) == 1 then
            led_buffer[i] = {r = 255, g = 140, b = 0}
        else
            led_buffer[i] = {r = 25, g = 14, b = 0}
        end
    end
    return true
end

local function create(zone, options)
    return {
        zone = zone, options = options,
        leftTrail = {}, rightTrail = {},
        telemetryConnected = false,
        beeperStartTime = 0, beeperType = nil,
        isArmed = false, armedFlashStartTime = 0,
        scroll_oldtime = 0,
        scroll_cycle = 1, 
        p1State = { scrollTime = 0, scrollCycle = 1 },
        p2State = { scrollTime = 0, scrollCycle = 1 }
    }
end

local function update(widget, options)
    if widget then widget.options = options end
end

local function background(widget) end

local function refresh(widget, event, touchState)
    if not widget or not widget.zone then return end

    local w, h = widget.zone.w, widget.zone.h
    local now = getTime()
    
    local rssi = getRSSI() or 0
    local isConnected = (rssi > 0)

    if isConnected ~= widget.telemetryConnected then
        widget.telemetryConnected = isConnected
        widget.beeperStartTime = now
        widget.beeperType = isConnected and "CONNECT" or "DISCONNECT"
    end

    local bgColor = safeColor(widget.options.BgColor, colorRGB(15, 15, 18))

    if widget.beeperType then
        local elapsed = now - widget.beeperStartTime
        if elapsed <= BEEPER_FLASH_DURATION then
            local flashCycle = math.floor((elapsed / BEEPER_FLASH_DURATION) * (BEEPER_FLASH_COUNT * 2))
            if (flashCycle % 2) == 0 then
                bgColor = (widget.beeperType == "CONNECT") and COLOR_CONN or COLOR_DISCONN
            end
        else
            widget.beeperType = nil
        end
    end

    lcd.drawFilledRectangle(0, 0, w, h, bgColor)

    local ail, ele, thr, rud = getValue("ail") or 0, getValue("ele") or 0, getValue("thr") or 0, getValue("rud") or 0
    local armedVal = getValue(ARMED_SOURCE) or 0
    local armed = armedVal > ARMED_THRESHOLD

    local auxVal = getValue(AUX_SOURCE) or 0
    local isTurtle = (auxVal < -500)
    local isBeeper = (auxVal >= -500 and auxVal <= 500)
    local isPreArm = (auxVal > 500)

    local op1Idx = (widget.options.Op1 or 0) + 1
    local op2Idx = (widget.options.Op2 or 0) + 1
    local op1Source = POT_SOURCES[op1Idx] or ""
    local op2Source = POT_SOURCES[op2Idx] or ""
    local op1Val = (op1Source ~= "") and (getValue(op1Source) or 0) or 0
    local op2Val = (op2Source ~= "") and (getValue(op2Source) or 0) or 0

    if armed ~= widget.isArmed then
        widget.isArmed = armed
        if armed then widget.armedFlashStartTime = now end
    end

    local num_leds_real = LED_STRIP_LENGTH
    local led_buffer = {}
    local flightModeVal = getValue("FMod") or getValue("Mode") or 0

    if not isConnected and armed then
        local is_red = (math.floor(now / 20) % 2 == 0)
        local col = is_red and {r = 255, g = 0, b = 0} or {r = 0, g = 255, b = 0}
        for i = 1, num_leds_real do led_buffer[i] = col end
    elseif not isConnected then
        if (now - widget.scroll_oldtime) > 12 then
            widget.scroll_oldtime = now
            widget.scroll_cycle = widget.scroll_cycle + 1
            if widget.scroll_cycle > (num_leds_real * 2 - 2) then widget.scroll_cycle = 1 end
        end
        local pos = widget.scroll_cycle
        if pos > num_leds_real then pos = 2 * num_leds_real - pos end
        for i = 1, num_leds_real do
            if i == pos then led_buffer[i] = {r = 100, g = 200, b = 255}
            elseif math.abs(i - pos) == 1 then led_buffer[i] = {r = 20, g = 80, b = 180}
            else led_buffer[i] = {r = 0, g = 15, b = 50} end
        end
    elseif armed then
        local armedDuration = now - widget.armedFlashStartTime
        local scrollDuration = 50 -- 1 segundo de scroll invertido antes de entrar o throttle
        
        if armedDuration < scrollDuration then
            -- SCROLL INVERTIDO VERDE COM RASTO APAGADO
            if (now - widget.scroll_oldtime) > 6 then
                widget.scroll_oldtime = now
                widget.scroll_cycle = widget.scroll_cycle - 1
                if widget.scroll_cycle < 1 then widget.scroll_cycle = num_leds_real end
            end
            local pos = widget.scroll_cycle
            for i = 1, num_leds_real do
                if i == pos then
                    led_buffer[i] = {r = 0, g = 255, b = 0} -- Cabeça verde brilhante
                elseif i == ((pos % num_leds_real) + 1) then
                    led_buffer[i] = {r = 0, g = 60, b = 0}  -- Rasto atenuado
                else
                    led_buffer[i] = {r = 0, g = 0, b = 0}   -- Resto completamente apagado
                end
            end
        else
            -- ANIMAÇÃO DO THROTTLE (Mantida exatamente como estava)
            local normThr = math.max(0, math.min(1, (thr + 1024) / 2048))
            local activeLeds = math.floor(normThr * num_leds_real + 0.5)
            for i = 1, num_leds_real do
                if i <= activeLeds then
                    led_buffer[i] = { r = 0, g = 255, b = 0 } -- Verde
                else
                    led_buffer[i] = { r = 0, g = 0, b = 0 }   -- Preto (desligado)
                end
            end
        end
    elseif op1Source ~= "" and processPotScroll(op1Val, widget.p1State, now, num_leds_real, led_buffer) then
        local _ = 1
    elseif op2Source ~= "" and processPotScroll(op2Val, widget.p2State, now, num_leds_real, led_buffer) then
        local _ = 1
    elseif isPreArm then
        if (now - widget.scroll_oldtime) > 6 then
            widget.scroll_oldtime = now
            widget.scroll_cycle = widget.scroll_cycle - 1
            if widget.scroll_cycle < 1 then widget.scroll_cycle = num_leds_real * 2 - 2 end
        end
        local pos = widget.scroll_cycle
        if pos > num_leds_real then pos = 2 * num_leds_real - pos end
        for i = 1, num_leds_real do
            if i == pos then led_buffer[i] = {r = 255, g = 0, b = 0}
            elseif math.abs(i - pos) == 1 then led_buffer[i] = {r = 0, g = 0, b = 255}
            else led_buffer[i] = {r = 10, g = 0, b = 10} end
        end
    elseif isTurtle then
        local breath = (math.sin(now / 6) + 1) / 2
        local g_val = math.floor(255 * breath)
        for i = 1, num_leds_real do led_buffer[i] = {r = 0, g = g_val, b = 0} end
    elseif isBeeper then
        local strobe_state = math.floor(now / 8) % 2
        for i = 1, num_leds_real do
            if strobe_state == 0 then
                if (i % 2 == 0) then led_buffer[i] = {r = 255, g = 0, b = 0} else led_buffer[i] = {r = 0, g = 0, b = 255} end
            else
                if (i % 2 == 0) then led_buffer[i] = {r = 0, g = 0, b = 255} else led_buffer[i] = {r = 255, g = 0, b = 0} end
            end
        end
    elseif flightModeVal > 500 then
        for i = 1, num_leds_real do
            local pos = math.floor(((i - 1) * 256 / num_leds_real) + (now / 2)) % 256
            local r, g, b = 0, 0, 0
            if pos < 85 then r = 255 - pos * 3; g = 0; b = pos * 3
            elseif pos < 170 then pos = pos - 85; r = 0; g = pos * 3; b = 255 - pos * 3
            else pos = pos - 170; r = pos * 3; g = 255 - pos * 3; b = 0 end
            led_buffer[i] = {r = r, g = r, b = b}
        end
    else
        for i = 1, num_leds_real do led_buffer[i] = {r = 0, g = 100, b = 255} end
    end

    -- Envio físico dos dados para os LEDs do rádio (API nativa do EdgeTX)
    if setRGBLedColor and applyRGBLedColors then
        for phys_idx = 0, 7 do
            local logical_idx = phys_idx + 1
            if logical_idx <= num_leds_real then
                local col = led_buffer[logical_idx] or {r = 0, g = 0, b = 0}
                local cr = math.floor(col.r or 0)
                local cg = math.floor(col.g or 0)
                local cb = math.floor(col.b or 0)
                
                if cr == 0 and cg == 0 and cb == 0 then
                    setRGBLedColor(phys_idx, 1, 1, 1)
                else
                    setRGBLedColor(phys_idx, cg, cr, cb)
                end
            else
                setRGBLedColor(phys_idx, 1, 1, 1)
            end
        end
        applyRGBLedColors()
    end

    local cy = 58
    local leftCx   = 58
    local rightCx  = w - 58
    local centerCx = math.floor(w * 0.50)

    drawGimbal(widget, leftCx, cy, rud, thr, widget.leftTrail, armed, now, isConnected)
    drawGimbal(widget, rightCx, cy, ail, ele, widget.rightTrail, armed, now, isConnected)
    drawCenterInfo(widget, centerCx, cy, armed, isConnected, now, led_buffer, num_leds_real, 1.0)
end

return {
    name = "f4fledstix", options = options,
    create = create, update = update, refresh = refresh, background = background
}
