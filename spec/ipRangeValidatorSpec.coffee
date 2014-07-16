describe "ipRangeValidator", () ->

  beforeEach ->
    @validator = new ipRangeValidator()

  it "should be defined", ->
    expect(@validator).toBeDefined()

  it "should have a noCollisions method", ->
    expect(@validator.noCollisions).toBeDefined()

  it "should have a _noPublicIpCollisions method", ->
    expect(@validator._noPublicIpCollisions).toBeDefined()

  it "should have a _noRangeCollisions method", ->
    expect(@validator._noRangeCollisions).toBeDefined()

  it "should have a dot2num method", ->
    expect(@validator.dot2num).toBeDefined()

  it "should have a num2dot method", ->
    expect(@validator.num2dot).toBeDefined()


  describe "dot2num", ->

    it "should take an ip address in the form 10.0.0.1 and output a number", ->
      expect(@validator.dot2num('192.168.0.1')).toBe 3232235521

  describe "num2dot", ->

    it "should take a number and output an ip address in the form 10.0.0.1", ->
      expect(@validator.num2dot(3232235521)).toBe '192.168.0.1'


  describe "collision detection", ->

    beforeEach ->
      @existingRanges = [
        startIp: '10.10.1.1'
        endIp: '10.10.1.255'
        publicIp: '8.8.8.8'
      ,
        startIp: '10.10.1.1'
        endIp: '10.10.1.255'
        publicIp: '8.8.8.4'
      ,
        startIp: '10.11.1.1'
        endIp: '10.11.1.255'
        publicIp: '8.8.8.8'
      ]

    afterEach ->
      @existingRanges = []


    describe "_noPublicIpCollisions", ->
      it "should return false if publicIp is present in existing ranges", ->
        newRange =
          publicIp: '8.8.8.4'
        expect(@validator._noPublicIpCollisions(newRange, @existingRanges))
          .toBe false

      it "should return true if publicIp is absent from existing ranges", ->
        newRange =
          publicIp: '8.8.8.5'
        expect(@validator._noPublicIpCollisions(newRange, @existingRanges))
          .toBe true


    describe "_noRangeCollisions", ->
      it "should return false if startIp is in an existing range", ->
        newRange =
          startIp: '10.10.1.20'
          endIp: '10.10.1.100'
        expect(@validator._noRangeCollisions(newRange, @existingRanges))
          .toBe false

      it "should return true if startIp is not in an existing range", ->
        newRange =
          startIp: '10.10.2.20'
          endIp: '10.10.2.100'
        expect(@validator._noRangeCollisions(newRange, @existingRanges))
          .toBe true

      it "should return false if endIp is in an existing range", ->
        newRange =
          startIp: '10.10.1.20'
          endIp: '10.10.1.100'
        expect(@validator._noRangeCollisions(newRange, @existingRanges))
          .toBe false

      it "should return true if endIp is not in an existing range", ->
        newRange =
          startIp: '10.10.2.20'
          endIp: '10.10.2.100'
        expect(@validator._noRangeCollisions(newRange, @existingRanges))
          .toBe true

    describe "noCollisions", ->

      beforeEach ->
        @newRange =
          startIp: '192.168.0.1'
          endIp: '192.168.0.255'
          publicIp: '3.4.5.200'

      afterEach ->
        @newRange = {}

      it "should call _noPublicIpCollisions and _noRangeCollisions", ->
        spyOn(@validator, '_noPublicIpCollisions').andCallThrough()
        spyOn(@validator, '_noRangeCollisions').andCallThrough()

        @validator.noCollisions @newRange, @existingRanges
        expect(@validator._noPublicIpCollisions)
          .toHaveBeenCalledWith @newRange, @existingRanges
        expect(@validator._noRangeCollisions)
          .toHaveBeenCalledWith @newRange, @existingRanges


      it "should be true if _noPublicIpCollisions and _noRangeCollisions are", ->
        spyOn(@validator, '_noPublicIpCollisions').andReturn true
        spyOn(@validator, '_noRangeCollisions').andReturn true
        expect(@validator.noCollisions(@newRange, @existingRanges)).toBe true


      it "should be false if _noPublicIpCollisions is", ->
        spyOn(@validator, '_noPublicIpCollisions').andReturn false
        spyOn(@validator, '_noRangeCollisions').andReturn true
        expect(@validator.noCollisions(@newRange, @existingRanges)).toBe false

      it "should be false if _noRangeCollisions is", ->
        spyOn(@validator, '_noPublicIpCollisions').andReturn true
        spyOn(@validator, '_noRangeCollisions').andReturn false
        expect(@validator.noCollisions(@newRange, @existingRanges)).toBe false
