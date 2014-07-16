class ipRangeValidator

  noCollisions: (newRange, existingRanges) ->
    @_noPublicIpCollisions(newRange, existingRanges) and
    @_noRangeCollisions(newRange, existingRanges)

  _noPublicIpCollisions: (newRange, existingRanges) ->
    @dot2num(newRange.publicIp) not in
      (@dot2num(range.publicIp) for range in existingRanges)

  _noRangeCollisions: (newRange, existingRanges) ->
    for existing in existingRanges

      startIp = @dot2num existing.startIp
      endIp = @dot2num existing.endIp
      newStartIp = @dot2num newRange.startIp
      newEndIp = @dot2num newRange.endIp

      if startIp <= newStartIp <= endIp then return false
      if startIp <= newEndIp <= endIp then return false
    true

  num2dot: (num) ->
    d = num % 256
    for [1..3]
      num = Math.floor(num/256)
      d = num%256 + '.' + d
    d

  dot2num: (dot) ->
    d = dot.split('.')
    ((((((+d[0])*256)+(+d[1]))*256)+(+d[2]))*256)+(+d[3])


window.ipRangeValidator = ipRangeValidator
