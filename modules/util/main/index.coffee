hxSet = require('modules/set/main')
hxMap = require('modules/map/main')
hxList = require('modules/list/main')
selection = require('modules/selection/main')

deprecatedWarning = (deprecatedItem, messages...) ->
  heading = "Deprecation Warning: #{deprecatedItem}"
  messages = ['Alternatives:'].concat messages.map (d) -> '  ' + d
  messages = messages.map (d) -> '  ' + d
  console.warn [heading].concat(messages).join('\n')
  console.trace('Stack Trace')

consoleWarning = (heading, messages...) ->
  console.warn.apply(console, [heading].concat(messages))
  console.trace('Stack Trace')

# consistent string to int hashing
hash = (str, max) ->
  res = 0
  len = str.length-1
  for i in [0..len] by 1
    res = res * 31 + str.charCodeAt(i)
    res = res & res
  if max then Math.abs(res) % max else res

# transposes a 2d array
transpose = (data) ->
  if not data.length? then return undefined
  w = data.length
  if w==0 or not data[0].length? then return data
  h = data[0].length
  transposed = new Array(h)
  for i in [0...h] by 1
    transposed[i] = new Array(w)
    for j in [0...w] by 1
      transposed[i][j] = data[j][i]
  transposed

supportsTouch = undefined
supportsDate = undefined

supports = (name) ->
  switch name
    when 'touch'
      supportsTouch ?= 'ontouchstart' of window
    when 'date'
      if supportsDate is undefined
        input = document.createElement("input")
        input.setAttribute("type", "date")
        supportsDate = input.type != "text"
      supportsDate

debounce = (duration, fn) ->
  timeout = undefined
  return ->
    if timeout then clearTimeout(timeout)
    f = ->
      timeout = undefined
      fn()
    timeout = setTimeout(f, duration)

clamp = (min, max, value) -> Math.min(max, Math.max(min, value))

clampUnit = (value) -> clamp(0, 1, value)

randomId = (size=16, alphabet='ABCEDEF0123456789') ->
  chars = alphabet.split('')
  alphabetSize = chars.length
  v = (chars[Math.floor(Math.random() * alphabetSize)] for _ in [0...size] by 1)
  v.join('')

min = (values) -> Math.min.apply(null, values?.filter(defined))

minBy = (values, f) ->
  if not values? or values.length is 0 then return undefined

  if f
    min = values[0]
    minValue = f(min)
    for i in [1...values.length-1] by 1
      v = values[i]
      if v isnt undefined
        fv = f(v)
        if fv isnt undefined and fv < minValue
          min = v
          minValue = fv
    min
  else
    min = values[0]
    for v in values
      if v isnt undefined and v < min
        min = v
    min

max = (values) -> Math.max.apply(null, values?.filter(defined))

maxBy = (values, f) ->
  if not values? or values.length is 0 then return undefined

  if f
    max = values[0]
    maxValue = f(max)
    for i in [1...values.length-1] by 1
      v = values[i]
      if v isnt undefined
        fv = f(v)
        if fv isnt undefined and fv > maxValue
          max = v
          maxValue = fv
    max
  else
    max = values[0]
    for v in values
      if v isnt undefined and v > max
        max = v
    max

range = (length) -> (x for x in [0...length] by 1)

sum = (values, f) -> values.reduce(((a, b) -> a + b), 0)

flatten = (arr) -> [].concat.apply([], arr)

cycle = (list, i) -> list[i%list.length]

hashList = (list, str) -> list[hash(str, list.length)]

find = (arr, f) ->
  for d in arr
    if f(d) then return d
  undefined

isString = (x) -> typeof x == 'string' or x instanceof String

isFunction = (x) -> typeof x == "function"

#XXX: is this needed? should we just use Array.isArray?
isArray = (x) -> x instanceof Array

# returns true if the thing passed in is an object, except for arrays
# which technically are objects, but in the eyes of this function are not
# objects
isObject = (obj) -> typeof obj is 'object' and not isArray(obj) and obj isnt null

isBoolean = (x) -> x is true or x is false or typeof x is 'boolean'

# Not plain objects:
# - Anything created with new (or equivalent)
# - DOM nodes
# - window
isPlainObject = (obj) ->
  (typeof obj is 'object') and
  (obj isnt null) and
  (not obj.nodeType) and
  obj.constructor and
  obj.constructor.prototype.hasOwnProperty('isPrototypeOf')

groupBy = (arr, f) ->
  map = new hxMap
  for x in arr
    category = f(x)
    if not map.has(category) then map.set(category, new hxList)
    map.get(category).add(x)
  values = map.entries()
  values.forEach((d) -> d[1] = d[1].entries())
  values

unique = (list) -> new hxSet(list).values()

endsWith  = (string, suffix) ->
  string.indexOf(suffix, string.length - suffix.length) != -1

startsWith = (string, substring) -> string.lastIndexOf(substring, 0) is 0

tween = (start, end, amount) -> start + (end - start) * amount

defined = (x) -> x isnt undefined

zip = (arrays) ->
  if arrays
    if arrays.length > 0
      length = min(arrays.map (d) -> d.length or 0)
      if length > 0
        for i in [0...length] by 1
          arrays.map((arr) -> arr[i])
      else []
    else []
  else []

# gets all the things from the second object and plonks them into the first
# this does mutation, which is why it is not exposed
extend = (target, overlay, retainUndefined) ->
  for k, v of overlay
    if isPlainObject(v)
      target[k] ?= {}
      extend(target[k], v, retainUndefined)
    else
      if v isnt undefined or retainUndefined
        target[k] = clone(v)

mergeImpl = (deep, retainUndefined, objects) ->
  if deep
    res = {}
    for obj in objects
      if isPlainObject(obj)
        extend(res, obj, retainUndefined)
    res
  else
    res = {}
    for obj in objects
      if isPlainObject(obj)
        for k, v of obj
          if v isnt undefined or retainUndefined
            res[k] = v
    res

merge = (objects...) ->
  mergeImpl(true, true, objects)

merge.defined = (objects...) ->
  mergeImpl(true, false, objects)

shallowMerge = (objects...) ->
  mergeImpl(false, true, objects)

shallowMerge.defined = (objects...) ->
  mergeImpl(false, false, objects)

clone = (obj) ->
  if isArray(obj)
    obj.map(clone)
  else if isPlainObject(obj)
    merge({}, obj)
  else if obj instanceof hxList
    new hxList(obj.entries().map(clone))
  else if obj instanceof hxMap
    new hxMap(obj.entries().map(([k, v]) -> [clone(k), clone(v)]))
  else if obj instanceof hxSet
    new hxSet(obj.keys().map(clone))
  else if obj instanceof Date
    new Date obj.getTime()
  else if isObject(obj) and obj isnt null
    consoleWarning("Trying to clone #{obj} with constructor
                       #{obj?.constructor?.name},
                       it isn't really cloneable! Carrying on anyway.")
    {}
  else obj

shallowClone = (obj) ->
  if isArray(obj)
    obj.slice()
  else if isPlainObject(obj)
    shallowMerge({}, obj)
  else if obj instanceof hxList
    new hxList obj.entries()
  else if obj instanceof hxMap
    new hxMap obj.entries()
  else if obj instanceof hxSet
    new hxSet obj.keys()
  else if obj instanceof Date
    new Date obj.getTime()
  else if isObject(obj) and obj isnt null
    consoleWarning("Trying to shallow clone #{obj} with constructor
                       #{obj?.constructor?.name},
                       it isn't really cloneable! Carrying on anyway.")
    {}
  else obj

vendorPrefixes = ["webkit", "ms", "moz", "Moz", "o", "O"]

vendor = (obj, prop) ->
  if prop of obj then return obj[prop]
  for p in vendorPrefixes
    if (prefixedProp = p + prop.charAt(0) + prop.slice(1)) of obj
      return obj[prefixedProp]

identity = (d) -> d

cachedParseHtml = null
parseHTML = (html) ->
  if not cachedParseHtml
    # This try/catch is only run once, the first time parseHTML is called.
    # Subsequent calls use the cached cachedParseHtml function
    try
      document.createRange().createContextualFragment('')
      cachedParseHtml = (html) ->
        document.createRange().createContextualFragment(html)
    catch e
      cachedParseHtml = (html) ->
        docFrag = document.createDocumentFragment()
        template = document.createElement('div')
        template.innerHTML = html
        while child = template.firstChild
          docFrag.appendChild(child)
        docFrag
  cachedParseHtml(html)

cleanNode = (node, recurse = true) ->
  n = node.childNodes.length - 1
  while n >= 0
    child = node.childNodes[n]
    if child.nodeType is 3 and /\s/.test child.nodeValue
      node.removeChild child
    else if child.nodeType is 1 and recurse
      cleanNode child
    n -= 1
  return node


cachedScrollbarSize = undefined
scrollbarSize = ->
  if not cachedScrollbarSize?
    inner = document.createElement('p')
    inner.style.width = '100%'
    inner.style.height = '200px'
    outer = document.createElement('div')

    inner = selection.detached('p')
      .style('width', '100%')
      .style('height', '200px')

    outer = selection.detached('div')
      .style('position', 'absolute')
      .style('top', '0')
      .style('left', '0')
      .style('visiblity', 'hidden')
      .style('width', '200px')
      .style('height', '150px')
      .style('overflow', 'hidden')

    outer.append(inner)

    selection.select('body').append(outer)

    w1 = inner.node().offsetWidth
    outer.style('overflow', 'scroll')
    w2 = inner.node().offsetWidth

    if w1 is w2
      w2 = outer.node().clientWidth

    outer.remove()

    w1 - w2

    cachedScrollbarSize = w1 - w2

  cachedScrollbarSize


parentZIndex = (node, findMax) ->
  check = (node) ->
    index = Number selection.select(node).style('z-index')
    if !isNaN(index) and index > 0 then index

  res = checkParents(node, check, findMax)

  if findMax then max(res) else res


checkParents = (node, check, returnArray) ->
  if node?
    checkNode = node
    resultArr = []
    while checkNode.nodeType isnt 9
      result = check(checkNode)
      if returnArray
        if result? then resultArr.push result
      else if result? then return result
      checkNode = checkNode.parentNode
      if not checkNode?
        break
      if returnArray and checkNode.nodeType is 9
        return resultArr
    if returnArray then [] else false

# expose
module.exports = {
  deprecatedWarning: deprecatedWarning
  consoleWarning: consoleWarning
  hash: hash
  transpose: transpose
  supports: supports
  debounce: debounce
  clamp: clamp
  clampUnit: clampUnit
  randomId: randomId
  min: min
  minBy: minBy
  max: max
  maxBy: maxBy
  range: range
  sum: sum
  flatten: flatten
  cycle: cycle
  hashList: hashList
  find: find
  isString: isString
  isFunction: isFunction
  isArray: isArray
  isObject: isObject
  isBoolean: isBoolean
  isPlainObject: isPlainObject
  groupBy: groupBy
  unique: unique
  endsWith: endsWith
  startsWith: startsWith
  tween: tween
  defined: defined
  zip: zip
  merge: merge
  shallowMerge: shallowMerge
  clone: clone
  shallowClone: shallowClone
  vendor: vendor
  identity: identity
  parseHTML: parseHTML
  cleanNode: cleanNode
  scrollbarSize: scrollbarSize
  parentZIndex: parentZIndex
  checkParents: checkParents
}

# backwards compatibility
module.exports.hx = module.exports
