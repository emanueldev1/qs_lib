-- requestWeaponAsset.lua: Loads a weapon asset in FiveM, ensuring it is ready for use.
-- This module validates the weapon type, animation flags, and component flags, checks if the asset is loaded,
-- and handles the loading process, yielding in a thread until the asset is available or a timeout occurs.

---@alias WeaponResourceFlags
---| 1 WRF_REQUEST_BASE_ANIMS
---| 2 WRF_REQUEST_COVER_ANIMS
---| 4 WRF_REQUEST_MELEE_ANIMS
---| 8 WRF_REQUEST_MOTION_ANIMS
---| 16 WRF_REQUEST_STEALTH_ANIMS
---| 32 WRF_REQUEST_ALL_MOVEMENT_VARIATION_ANIMS
---| 31 WRF_REQUEST_ALL_ANIMS

---@alias ExtraWeaponComponentFlags
---| 0 WEAPON_COMPONENT_NONE
---| 1 WEAPON_COMPONENT_FLASH
---| 2 WEAPON_COMPONENT_SCOPE
---| 4 WEAPON_COMPONENT_SUPP
---| 8 WEAPON_COMPONENT_SCLIP2
---| 16 WEAPON_COMPONENT_GRIP

-- Validates the input parameters for the weapon asset request.
---@param weaponId string | number
---@param resourceFlags WeaponResourceFlags | nil
---@param extraFlags ExtraWeaponComponentFlags | nil
local function checkParameters(weaponId, resourceFlags, extraFlags)
   local idType = type(weaponId)
   if idType ~= "string" and idType ~= "number" then
      error(string.format("weaponType must be a string or number, got %s", idType))
   end
   if resourceFlags and type(resourceFlags) ~= "number" then
      error(string.format("weaponResourceFlags must be a number, received %s", type(resourceFlags)))
   end
   if extraFlags and type(extraFlags) ~= "number" then
      error(string.format("extraWeaponComponentFlags must be a number, received %s", type(extraFlags)))
   end
end

-- Requests the loading of a weapon asset with the specified parameters.
---@param weaponId string | number
---@param waitTime number
---@param resourceFlags WeaponResourceFlags
---@param extraFlags ExtraWeaponComponentFlags
---@return string | number
local function loadWeapon(weaponId, waitTime, resourceFlags, extraFlags)
   return lib.streamingRequest(RequestWeaponAsset, HasWeaponAssetLoaded, "weaponHash", weaponId, waitTime, resourceFlags, extraFlags)
end

---Load a weapon asset. When called from a thread, it will yield until it has loaded.
---@param weaponType string | number
---@param timeout number? Approximate milliseconds to wait for the asset to load. Default is 9600.
---@param weaponResourceFlags WeaponResourceFlags? Default is 31.
---@param extraWeaponComponentFlags ExtraWeaponComponentFlags? Default is 0.
---@return string | number weaponType
function lib.requestWeaponAsset(weaponType, timeout, weaponResourceFlags, extraWeaponComponentFlags)
   -- Check if the weapon asset is already loaded
   if HasWeaponAssetLoaded(weaponType) then
      return weaponType
   end

   -- Validate the input parameters
   checkParameters(weaponType, weaponResourceFlags, extraWeaponComponentFlags)

   -- Request the weapon asset with the specified settings
   local waitTime = timeout or 9600
   local resourceFlags = weaponResourceFlags or 31
   local extraFlags = extraWeaponComponentFlags or 0
   return loadWeapon(weaponType, waitTime, resourceFlags, extraFlags)
end

return lib.requestWeaponAsset
