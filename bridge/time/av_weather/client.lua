-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

return {
   syncTime = function(state)
      TriggerEvent('av_weather:freeze', state)
      exports['av_weather']:setRain(false)
      return true
   end
}
