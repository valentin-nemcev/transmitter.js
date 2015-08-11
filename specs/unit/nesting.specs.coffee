'use strict'


Nesting = require 'transmitter/transmission/nesting'


describe 'Nesting', ->

  before ->
    @define = (name) ->
      this[name] = Nesting.createInitial()
      this[name].inspect = -> "#{name} #{@level}"


  describe 'containment', ->

    specify 'increasing level sets correct containment', ->
      @define 'n0'
      @n1 = @n0.increase()

      expect(Nesting.getIndependent([@n0, @n1]).length).to.equal(1)


    specify 'decreasing level sets correct containment', ->
      @define 'n1'
      @n0 = @n1.decrease()

      expect(Nesting.getIndependent([@n0, @n1]).length).to.equal(1)


    specify 'increasing then decreasing level sets correct containment', ->
      @define 'n0'
      @n1 = @n0.increase()
      @n0a = @n1.decrease()

      expect(Nesting.getIndependent([@n0, @n1, @n0a]).length).to.equal(1)


    specify 'decreasing then increasing level sets correct containment', ->
      @define 'n1'
      @n0 = @n1.decrease()
      @n1a = @n0.increase()

      expect(Nesting.getIndependent([@n0, @n1, @n1a]).length).to.equal(1)


    specify 'shifting level updates inner nestings', ->
      @define 'n0'
      @n1 = @n0.increase()

      @n0.shiftTo 2

      expect(@n1.level).to.equal(3)


    specify 'shifting level updates outer nestings', ->
      @define 'n1'
      @n0 = @n1.decrease()

      @n1.shiftTo 2

      expect(@n0.level).to.equal(1)



  describe 'equality', ->

    beforeEach ->
      @define 'na'
      @define 'nb'
      @define 'nc'

      Nesting.equalize([@na, @nb])
      Nesting.equalize([@nc, @nb])


    specify 'containment is same for equal nestings', ->
      na1 = @na.increase()

      expect(Nesting.getIndependent([@na, na1]).length).to.equal(1)
      expect(Nesting.getIndependent([@nb, na1]).length).to.equal(1)
      expect(Nesting.getIndependent([@nc, na1]).length).to.equal(1)


    specify 'containment is same for equal inner nestings', ->
      na1 = @na.increase()
      @define 'nd'
      nd1 = @nd.increase()
      Nesting.equalize([nd1, na1])

      expect(Nesting.getIndependent([@na, nd1]).length).to.equal(1)
      expect(Nesting.getIndependent([@nb, nd1]).length).to.equal(1)
      expect(Nesting.getIndependent([@nc, nd1]).length).to.equal(1)
      expect(Nesting.getIndependent([@na, @nd]).length).to.equal(1)


    specify 'shift affects all equal nestings', ->
      @nc.shiftTo(1)

      expect(@na.level).to.equal(1)
      expect(@nb.level).to.equal(1)
      expect(@nc.level).to.equal(1)
