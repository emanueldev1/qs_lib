--- Converts a boolean allow value to 'allow' or 'deny' string.
--- @param allow boolean Whether the ACE is allowed (true) or denied (false).
--- @return string 'allow' if true, 'deny' if false.
local function toAcePermission(allow)
   return allow and 'allow' or 'deny'
end

--- Formats a principal identifier, converting numbers to 'player.<id>' format.
--- @param principal string|number The principal identifier (e.g., 'player.1' or 1).
--- @return string The formatted principal identifier.
local function getFormattedPrincipal(principal)
   if type(principal) == 'number' then
       return ('player.%d'):format(principal)
   end
   return principal
end

--- Executes a formatted command with the given arguments.
--- @param template string The command template (e.g., 'add_ace %s %s %s').
--- @param ... any Arguments to format into the template.
local function runCommand(template, ...)
   ExecuteCommand(template:format(...))
end

--- Adds an ACE (Access Control Entry) to a principal.
--- @param principal string|number The principal identifier (e.g., 'player.1' or 1).
--- @param ace string The ACE to add (e.g., 'command.kick').
--- @param allow boolean Whether the ACE is allowed (true) or denied (false).
function lib.addAce(principal, ace, allow)
   local formattedPrincipal = getFormattedPrincipal(principal)
   local permission = toAcePermission(allow)
   runCommand('add_ace %s %s %s', formattedPrincipal, ace, permission)
end

--- Removes an ACE (Access Control Entry) from a principal.
--- @param principal string|number The principal identifier (e.g., 'player.1' or 1).
--- @param ace string The ACE to remove (e.g., 'command.kick').
--- @param allow boolean Whether the ACE is allowed (true) or denied (false).
function lib.removeAce(principal, ace, allow)
   local formattedPrincipal = getFormattedPrincipal(principal)
   local permission = toAcePermission(allow)
   runCommand('remove_ace %s %s %s', formattedPrincipal, ace, permission)
end

--- Adds a child principal to a parent principal for inheritance.
--- @param child string|number The child principal identifier (e.g., 'player.1' or 1).
--- @param parent string The parent principal (e.g., 'group.admin').
function lib.addPrincipal(child, parent)
   local formattedChild = getFormattedPrincipal(child)
   runCommand('add_principal %s %s', formattedChild, parent)
end

--- Removes a child principal from a parent principal.
--- @param child string|number The child principal identifier (e.g., 'player.1' or 1).
--- @param parent string The parent principal (e.g., 'group.admin').
function lib.removePrincipal(child, parent)
   local formattedChild = getFormattedPrincipal(child)
   runCommand('remove_principal %s %s', formattedChild, parent)
end

--- Checks if a player has a specific ACE.
--- @param source string The player's server ID.
--- @param ace string The ACE to check (e.g., 'command.kick').
--- @return boolean True if the player has the ACE, false otherwise.
lib.callback.register('qs_lib:checkPlayerAce', function(source, ace)
   return IsPlayerAceAllowed(source, ace)
end)
