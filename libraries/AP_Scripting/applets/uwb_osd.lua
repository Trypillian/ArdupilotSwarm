-- uwb_osd.lua
-- Телеметрія рою / UWB у величини PARAM1..PARAM8 для полів OSD CST1..CST12.
-- Джерело даних поки - симулятор у read_source(); пізніше його замінять
-- реальні дані від колеги, решту скрипта змінювати не потрібно.

local UPDATE_MS = 200    -- як часто оновлювати OSD, мс
local STALE_MS  = 1000   -- величина, не оновлена довше, вважається застарілою
local STALE     = "---"  -- що показувати замість застарілого значення

local MAV_SEVERITY_WARNING = 4
local MAV_SEVERITY_INFO    = 6

-- Опис величин.
-- idx   - номер для osd:set_custom_text (0 = PARAM1 ... 7 = PARAM8)
-- key   - назва величини в даних з read_source()
-- label - підпис перед значенням
-- fmt   - перетворює значення на текст
local PARAMS = {
  { idx = 0, key = "uwb_ok",   label = "UWB:", fmt = function(v) return v and "OK" or "ERR" end },
  { idx = 1, key = "fw1_dist", label = "FW1:", fmt = function(v) return string.format("%.1fm", v) end },
  { idx = 2, key = "fw2_dist", label = "FW2:", fmt = function(v) return string.format("%.1fm", v) end },
  { idx = 3, key = "bat_pct",  label = "B:",   fmt = function(v) return string.format("%d%%", v) end },
  -- PARAM5..PARAM8 (idx 4..7) поки вільні
}

local values = {}   -- останнє значення кожної величини
local stamps = {}   -- час (мс), коли величину оновлено востаннє
local last_uwb = nil

-- ===== Джерело даних =====
-- Тимчасовий симулятор. Повертає таблицю з тими величинами, які прийшли
-- в цьому циклі; відсутня величина = "дані не прийшли".
local function read_source(now)
  local t = now / 1000.0
  local data = {}
  data.uwb_ok  = (math.floor(t) % 20) < 17          -- 3 с з кожних 20 UWB втрачено
  data.bat_pct = math.max(0, 98 - math.floor(t / 10))
  if data.uwb_ok then                                 -- без UWB відстаней немає
    data.fw1_dist = 15 + 5 * math.sin(t / 3)
    data.fw2_dist = 12 + 4 * math.cos(t / 4)
  end
  return data
end

-- Запам'ятати значення, що прийшли, разом з часом
local function store(data, now)
  for key, v in pairs(data) do
    values[key] = v
    stamps[key] = now
  end
end

-- Події: повідомлення в MESSAGE тільки при зміні стану UWB
local function check_events()
  local ok = values.uwb_ok
  if ok ~= nil and ok ~= last_uwb then
    local severity = ok and MAV_SEVERITY_INFO or MAV_SEVERITY_WARNING
    gcs:send_text(severity, "UWB " .. (ok and "OK" or "LOST"))
    last_uwb = ok
  end
end

-- Записати всі величини в OSD
local function update_osd(now)
  for _, p in ipairs(PARAMS) do
    local v = values[p.key]
    local text
    if v == nil or (now - stamps[p.key]) > STALE_MS then
      text = p.label .. STALE
    else
      text = p.label .. p.fmt(v)
    end
    osd:set_custom_text(p.idx, text)
  end
end

local function update()
  local now = millis():tofloat()
  store(read_source(now), now)
  check_events()
  update_osd(now)
end

-- Захист: помилка не зупиняє скрипт назавжди
local function protected_update()
  local ok, err = pcall(update)
  if not ok then
    gcs:send_text(MAV_SEVERITY_WARNING, "uwb_osd: " .. tostring(err))
    return protected_update, 1000
  end
  return protected_update, UPDATE_MS
end

return protected_update()
