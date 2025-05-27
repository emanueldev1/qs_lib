-- Copyright (C) 2025 emanueldev1. Licensed under the GNU Lesser General Public License v3.0 (LGPL-3.0). See https://www.gnu.org/licenses/lgpl-3.0.html for details.

local crypto = {}

-- Helper function for SHA256 (unchanged)
local function rightRotate(x, n)
   return ((x >> n) | (x << (32 - n))) & 0xffffffff
end

-- Helper function for SHA256 (unchanged)
local function preprocess(msg)
   local len = #msg * 8
   msg = msg .. "\128"
   while (#msg + 8) % 64 ~= 0 do
      msg = msg .. "\0"
   end
   for i = 7, 0, -1 do
      msg = msg .. string.char((len >> (i * 8)) & 0xff)
   end
   return msg
end

-- Computes the SHA-256 hash of a message (unchanged)
function crypto.SHA256(msg)
   local H = {
      0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
      0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
   }
   local K = {
      0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
      0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
      0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
      0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
      0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
      0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
      0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
      0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
   }

   local function digestBlock(chunk)
      local w = {}
      for i = 1, 16 do
         w[i] = 0
         for j = 0, 3 do
            w[i] = w[i]| (string.byte(chunk, (i - 1) * 4 + j + 1) << ((3 - j) * 8))
         end
      end

      for i = 17, 64 do
         local s0 = rightRotate(w[i - 15], 7) ~ rightRotate(w[i - 15], 18) ~ (w[i - 15] >> 3)
         local s1 = rightRotate(w[i - 2], 17) ~ rightRotate(w[i - 2], 19) ~ (w[i - 2] >> 10)
         w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff
      end

      local a, b, c, d, e, f, g, h = table.unpack(H)

      for i = 1, 64 do
         local S1 = rightRotate(e, 6) ~ rightRotate(e, 11) ~ rightRotate(e, 25)
         local ch = (e & f) ~ ((~e) & g)
         local temp1 = (h + S1 + ch + K[i] + w[i]) & 0xffffffff
         local S0 = rightRotate(a, 2) ~ rightRotate(a, 13) ~ rightRotate(a, 22)
         local maj = (a & b) ~ (a & c) ~ (b & c)
         local temp2 = (S0 + maj) & 0xffffffff

         h = g
         g = f
         f = e
         e = (d + temp1) & 0xffffffff
         d = c
         c = b
         b = a
         a = (temp1 + temp2) & 0xffffffff
      end

      H[1] = (H[1] + a) & 0xffffffff
      H[2] = (H[2] + b) & 0xffffffff
      H[3] = (H[3] + c) & 0xffffffff
      H[4] = (H[4] + d) & 0xffffffff
      H[5] = (H[5] + e) & 0xffffffff
      H[6] = (H[6] + f) & 0xffffffff
      H[7] = (H[7] + g) & 0xffffffff
      H[8] = (H[8] + h) & 0xffffffff
   end

   msg = preprocess(msg)
   for i = 1, #msg, 64 do
      digestBlock(msg:sub(i, i + 63))
   end

   return string.format("%08x%08x%08x%08x%08x%08x%08x%08x",
      H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8])
end

-- Computes HMAC-SHA256 for a message using a key, useful for message authentication
-- @param key string The secret key for HMAC
-- @param msg string The message to hash
-- @return string The HMAC-SHA256 hash as a hexadecimal string
function crypto.HMACSHA256(key, msg)
   local blockSize = 64 -- SHA256 block size in bytes
   local opad = string.rep("\x5c", blockSize)
   local ipad = string.rep("\x36", blockSize)

   -- If key is longer than block size, hash it first
   if #key > blockSize then
      key = crypto.SHA256(key)
      -- Convert hex string back to binary
      key = key:gsub("(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
   end

   -- Pad the key to the block size
   key = key .. string.rep("\0", blockSize - #key)

   -- XOR key with opad and ipad
   local okeypad = ""
   local ikeypad = ""
   for i = 1, blockSize do
      local k = string.byte(key, i)
      okeypad = okeypad .. string.char(k ~ string.byte(opad, i))
      ikeypad = ikeypad .. string.char(k ~ string.byte(ipad, i))
   end

   -- Compute HMAC: SHA256(okeypad || SHA256(ikeypad || msg))
   local innerHash = crypto.SHA256(ikeypad .. msg)
   -- Convert hex string back to binary
   innerHash = innerHash:gsub("(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
   return crypto.SHA256(okeypad .. innerHash)
end

-- AES Helper Functions (moved to outer scope for reuse)
local function sbox(byte)
   local sboxTable = {
      0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
      0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
      0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
      0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
      0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
      0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
      0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
      0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
      0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
      0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
      0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
      0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
      0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
      0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
      0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
      0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
   }
   return sboxTable[byte + 1]
end

local function invSbox(byte)
   local invSboxTable = {
      0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
      0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
      0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
      0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
      0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
      0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
      0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
      0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
      0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
      0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
      0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
      0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
      0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
      0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
      0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
      0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
   }
   return invSboxTable[byte + 1]
end

local function mixColumns(state, inverse)
   local function gmul(a, b)
      local p = 0
      for _ = 1, 8 do
         if (b & 1) ~= 0 then
            p = p ~ a
         end
         local hiBitSet = (a & 0x80) ~= 0
         a = (a << 1) & 0xff
         if hiBitSet then
            a = a ~ 0x1b
         end
         b = b >> 1
      end
      return p
   end

   for col = 1, 4 do
      local s0, s1, s2, s3 = state[col], state[col + 4], state[col + 8], state[col + 12]
      if inverse then
         state[col]      = gmul(s0, 0x0e) ~ gmul(s1, 0x0b) ~ gmul(s2, 0x0d) ~ gmul(s3, 0x09)
         state[col + 4]  = gmul(s0, 0x09) ~ gmul(s1, 0x0e) ~ gmul(s2, 0x0b) ~ gmul(s3, 0x0d)
         state[col + 8]  = gmul(s0, 0x0d) ~ gmul(s1, 0x09) ~ gmul(s2, 0x0e) ~ gmul(s3, 0x0b)
         state[col + 12] = gmul(s0, 0x0b) ~ gmul(s1, 0x0d) ~ gmul(s2, 0x09) ~ gmul(s3, 0x0e)
      else
         state[col]      = gmul(s0, 2) ~ gmul(s1, 3) ~ s2 ~ s3
         state[col + 4]  = s0 ~ gmul(s1, 2) ~ gmul(s2, 3) ~ s3
         state[col + 8]  = s0 ~ s1 ~ gmul(s2, 2) ~ gmul(s3, 3)
         state[col + 12] = gmul(s0, 3) ~ s1 ~ s2 ~ gmul(s3, 2)
      end
   end
end

local function subBytes(state, inverse)
   for i = 1, 16 do
      state[i] = inverse and invSbox(state[i]) or sbox(state[i])
   end
end

local function shiftRows(state, inverse)
   if inverse then
      -- Inverse ShiftRows
      local temp
      -- Row 1: Shift right by 1
      temp = state[2]
      state[2] = state[14]
      state[14] = state[10]
      state[10] = state[6]
      state[6] = temp
      -- Row 2: Shift right by 2
      temp = state[3]
      state[3] = state[11]
      state[11] = temp
      temp = state[7]
      state[7] = state[15]
      state[15] = temp
      -- Row 3: Shift right by 3
      temp = state[4]
      state[4] = state[8]
      state[8] = state[12]
      state[12] = state[16]
      state[16] = temp
   else
      -- ShiftRows
      local temp
      -- Row 1: Shift left by 1
      temp = state[2]
      state[2] = state[6]
      state[6] = state[10]
      state[10] = state[14]
      state[14] = temp
      -- Row 2: Shift left by 2
      temp = state[3]
      state[3] = state[11]
      state[11] = temp
      temp = state[7]
      state[7] = state[15]
      state[15] = temp
      -- Row 3: Shift left by 3
      temp = state[4]
      state[4] = state[16]
      state[16] = state[12]
      state[12] = state[8]
      state[8] = temp
   end
end

local function addRoundKey(state, keySchedule, round)
   for i = 1, 16 do
      state[i] = state[i] ~ keySchedule[(round - 1) * 16 + i]
   end
end

local function expandKey(keyBytes)
   local keySchedule = {}
   local rcon = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36 }

   -- Copy the initial key
   for i = 1, 32 do
      keySchedule[i] = keyBytes[i]
   end

   for i = 33, 240, 4 do
      local t = { keySchedule[i - 4], keySchedule[i - 3], keySchedule[i - 2], keySchedule[i - 1] }
      if (i - 1) % 32 == 0 then
         -- Rotate
         local temp = t[1]
         t[1], t[2], t[3], t[4] = t[2], t[3], t[4], temp
         -- SubBytes
         for j = 1, 4 do
            t[j] = sbox(t[j])
         end
         -- XOR with Rcon
         t[1] = t[1] ~ rcon[(i - 1) // 32]
      elseif (i - 1) % 32 == 16 then
         for j = 1, 4 do
            t[j] = sbox(t[j])
         end
      end
      for j = 1, 4 do
         keySchedule[i + j - 1] = keySchedule[i - 32 + j - 1] ~ t[j]
      end
   end
   return keySchedule
end

-- Encrypts a message using AES-256-CBC with a key and IV
-- @param msg string The message to encrypt
-- @param key string The encryption key (must be 32 bytes)
-- @param iv string The initialization vector (must be 16 bytes)
-- @return string|nil The encrypted message as a hex string, or nil if parameters are invalid
function crypto.AESEncrypt(msg, key, iv)
   if #key ~= 32 then
      print("Error: AES key must be 32 bytes")
      return nil
   end
   if #iv ~= 16 then
      print("Error: AES IV must be 16 bytes")
      return nil
   end

   -- Pad the message to a multiple of 16 bytes (PKCS#5/PKCS#7 padding)
   local padLen = 16 - (#msg % 16)
   msg = msg .. string.char(padLen):rep(padLen)

   -- Convert key, iv, and msg to byte arrays
   local keyBytes = { key:byte(1, 32) }
   local ivBytes = { iv:byte(1, 16) }
   local msgBytes = { msg:byte(1, -1) }

   local state = {}
   local keySchedule = expandKey(keyBytes)

   -- XOR message with IV for CBC mode
   for i = 1, 16 do
      state[i] = msgBytes[i] ~ ivBytes[i]
   end

   -- AES-256-CBC encryption rounds
   for round = 1, 14 do
      addRoundKey(state, keySchedule, round)
      subBytes(state, false)
      shiftRows(state, false)
      if round < 14 then
         mixColumns(state, false)
      end
   end
   addRoundKey(state, keySchedule, 15)

   -- Convert state to hex string
   local result = {}
   for i = 1, 16 do
      result[i] = string.format("%02x", state[i])
   end
   return table.concat(result)
end

-- Decrypts a message using AES-256-CBC with a key and IV
-- @param encrypted string The encrypted message as a hex string
-- @param key string The decryption key (must be 32 bytes)
-- @param iv string The initialization vector (must be 16 bytes)
-- @return string|nil The decrypted message, or nil if parameters are invalid
function crypto.AESDecrypt(encrypted, key, iv)
   if #key ~= 32 then
      print("Error: AES key must be 32 bytes")
      return nil
   end
   if #iv ~= 16 then
      print("Error: AES IV must be 16 bytes")
      return nil
   end
   if #encrypted ~= 32 then -- Expected hex string length for 16 bytes
      print("Error: Encrypted data must be 16 bytes (32 hex chars)")
      return nil
   end

   -- Convert hex string to bytes
   local encryptedBytes = {}
   for i = 1, 32, 2 do
      encryptedBytes[#encryptedBytes + 1] = tonumber(encrypted:sub(i, i + 1), 16)
   end

   -- Convert key and iv to byte arrays
   local keyBytes = { key:byte(1, 32) }
   local ivBytes = { iv:byte(1, 16) }

   -- AES-256-CBC decryption
   local state = {}
   for i = 1, 16 do
      state[i] = encryptedBytes[i]
   end

   local keySchedule = expandKey(keyBytes)

   -- AES-256-CBC decryption rounds
   addRoundKey(state, keySchedule, 15)
   for round = 14, 1, -1 do
      shiftRows(state, true)
      subBytes(state, true)
      addRoundKey(state, keySchedule, round)
      if round > 1 then
         mixColumns(state, true)
      end
   end

   -- XOR with IV for CBC mode
   for i = 1, 16 do
      state[i] = state[i] ~ ivBytes[i]
   end

   -- Remove padding (PKCS#5/PKCS#7)
   local padLen = state[16]
   if padLen < 1 or padLen > 16 then
      print("Error: Invalid padding length")
      return nil
   end
   for i = 16 - padLen + 1, 16 do
      if state[i] ~= padLen then
         print("Error: Invalid padding")
         return nil
      end
   end

   -- Convert state to string
   local result = {}
   for i = 1, 16 - padLen do
      result[i] = string.char(state[i])
   end
   return table.concat(result)
end

return crypto
