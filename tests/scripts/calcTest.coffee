calc = require './calc'

describe 'calc', ->
  it 'should add correctly', ->
    expect(calc.add 1, 2)
      .toBe 3
