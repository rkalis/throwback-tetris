--- Copyright (c) 2016-2020 Rosco Kalis
---
--- Permission is hereby granted, free of charge, to any person obtaining a copy
--- of this software and associated documentation files (the "Software"), to
--- deal in the Software without restriction, including without limitation the
--- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
--- sell copies of the Software, and to permit persons to whom the Software is
--- furnished to do so, subject to the following conditions:
---
--- The above copyright notice and this permission notice shall be included in
--- all copies or substantial portions of the Software.
---
--- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
--- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
--- IN THE SOFTWARE.


--- Kalis Utility class containing general helpful Lua utilities
--- @class Kalis
local kalis = {}

--- Used to filter a table of objects that satisfy a certain condition.
--- Loops through the objects in t and checks whether the object contains
--- the passed key together with the passed value.
--- @param t table[] @ A table containing objects
--- @param key string @ The key that should be filtered on
--- @param value any @ The value that key should have
--- @return table[] @ A table containing the objects that satisfy the condition
function kalis.filter(t, key, value)
  local results = {}
  local tinsert = table.insert
  for _, object in pairs(t) do
    if type(object) == "table" then
      if object[key] == value then
        tinsert(results, object)
      end
    end
  end
  return results
end

--- Concatenates list `t2` to list `t1` and empties list`t2`. Any non-numeric
--- keys are unaffected.
--- @param t1 any[] @ The list that should be concatenated onto
--- @param t2 any[] @ The list that should be concatenated
function kalis.concat(t1, t2)
  if not t2 then return end
  if type(t1) ~= "table" or type(t2) ~= "table" then return end
  local tinsert = table.insert
  local tremove = table.remove
  for key, value in pairs(t2) do
    tinsert(t1, value)
    tremove(t2, key)
  end
end

--- Computes the distance between two points using the pythogorean theorem.
--- @param x1 integer @ The x coordinate of the first point
--- @param y1 integer @ The y coordinate of the first point
--- @param x2 integer @ The x coordinate of the second point
--- @param y2 integer @ The y coordinate of the second point
--- @return integer @ The distance between the two points
function kalis.distance(x1, y1, x2, y2)
  local a = x1 - x2
  local b = y1 - y2
  return math.sqrt(a^2 + b^2)
end

--- Copies a table (or value) and returns it. Works with recursive tables and tables as keys.
--- Preserves metatables.
--- @param obj any @ table/value to be copied
--- @return any @ copy of the table/value
function kalis.copy(obj)
  if type(obj) ~= "table" then return obj end
  local res = {}
  for key, value in pairs(obj) do
    res[kalis.copy(key)] = kalis.copy(value)
  end
  setmetatable(res, getmetatable(obj))
  return res
end

--- Checks whether an object with certain dimensions is clicked by a mouse
--- with coordinates x and y. The object table needs to have x and y coordinates,
--- and either a size (if square), width/height (if rectangle) or radius (if circle).
--- @param obj table @ object to be checked
--- @param x integer @ x coordinate of the mouse
--- @param y integer @ y coordinate of the mouse
--- @return boolean @ true if the object is clicked, false if not
function kalis.is_clicked(obj, x, y)
  local width, height, radius

  -- Getting object properties
  if type(obj) ~= "table" then return false end
  if not obj.x or not obj.y then return false end
  if obj.size then width = obj.size; height = obj.size end
  if obj.width and obj.height then width = obj.width; height = obj.height end
  if obj.radius then radius = obj.radius end

  if radius then
    return kalis.distance(x, y, obj.x, obj.y) < radius
  elseif width and height then
    if  x > obj.x and x < obj.x + width
    and y > obj.y and y < obj.y + height then
      return true
    end
  end
  return false
end

--- Inverts a table, swapping all keys and values
--- @param t table @ Table to be inverted
--- @return table @ Inverted table
function kalis.table_invert(t)
  local invert = {}
  for key, value in pairs(t) do
    invert[value] = key end
  return invert
end

--- Zero-based version of Lua ipairs, iterating over numerical keys in a table,
--- starting with 0.
--- @param t table @ Table to iterate over
--- @return fun(t: table): number, any @ Iterator over all entries in t with numeric keys of 0 or higher
function kalis.ipairs(t)
  local function ipairs_it(t, i)
    i = i + 1
    local v = t[i]
    if v ~= nil then
      return i, v
    else
      return nil
    end
  end
  return ipairs_it, t, -1
end

--- Returns a slice of table t.
--- @param t table @ Table to take a slice out of
--- @param first integer @ Start index of the slice (default 1)
--- @param last integer @ Last index of the slice (default #t)
--- @param step integer @ Step size to use when slicing (default 1)
--- @return table @ Slice of table t
function kalis.slice(t, first, last, step)
  local sliced = {}
  for i = first or 1, last or #t, step or 1 do
    sliced[#sliced + 1] = t[i]
  end
  return sliced
end

--- Returns all entries that an iterator would yield in a list.
--- Only works with iterators that return single values.
--- @vararg any @ Iterator call
--- @return any[] @ List with iterator contents
function kalis.iter_all(...)
    local table = {}
    for value in ... do
      table[#table + 1] = value
    end
    return table
end

--- Checks if an element/value is present in a table
--- @param t table @ Table to check for values
--- @element any @ Value to check for
--- @return boolean @ true if element is present, false if not
function kalis.contains(t, element)
  for _, value in pairs(t) do
    if kalis.deep_equals(value, element) then
      return true
    end
  end
  return false
end

--- Checks if two objects are deeply equal by recursively checking all members
--- @param o1 any @ First object to be compared
--- @param o2 any @ Second object to be compared
--- @param ignore_mt boolean @ Indicates whether metatable should be ignored in comparison
--- @return boolean @ true if o1 deeply equals o2, false if not
function kalis.deep_equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            -- compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or kalis.deep_equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

return kalis
