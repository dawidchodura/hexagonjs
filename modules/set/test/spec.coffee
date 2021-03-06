describe "set", ->

  Set = hx.Set

  it "can be intialized using an array", ->
    set = new Set [1, 2, 3]
    set.size.should.equal(3)

  it "can contain things with the same toString", ->
    set = new Set([1, '1'])
    set.size.should.equal(2)
    set.has(1).should.be.ok
    set.has('1').should.be.ok

  it "can distinguish things with the same toString when looking up", ->
    set = new Set([1])
    set.has(1).should.be.ok
    set.has('1').should.not.be.ok

  it "can choose the right thing to delete when the elements have the same toString", ->
    a = [1]
    set = new Set([1, a, '1'])
    set.size.should.equal(3)
    set.has(1).should.be.ok
    set.has('1').should.be.ok
    set.has(a).should.be.ok
    set.delete(a)
    set.has(1).should.be.ok
    set.has('1').should.be.ok
    set.has(a).should.not.be.ok

  it "contains nothing when initialised",  ->
    (new Set).values().should.eql([])

  it "contains stuff when initialsed with a non empty array",  ->
    (new Set([2, 3, 1]).values()).should.eql([2, 3, 1])

  it "size should be reported as 0 for a newly initialsed set",  ->
    (new Set).size.should.equal(0)

  it "add should work",  ->
    set = new Set
    set.add(2)
    set.add(4)
    set.add(7)
    set.values().should.eql([2, 4, 7])
    set.size.should.equal(3)

  it "clear should work", ->
    set = new Set
    [8, 7, 6, 5].forEach((d) -> set.add d)
    set.clear()
    set.values().should.eql []
    set.size.should.equal 0

  it "delete should work",  ->
    set = new Set
    [8, 7, 6, 5].forEach((d) -> set.add d)
    set.delete 6
    set.values().should.eql [8, 7, 5]
    set.size.should.equal 3

  it "delete for non existant entry should do nothing",  ->
    set = new Set
    [8, 7, 6, 5].forEach((d) -> set.add d)
    set.delete 20000
    set.values().should.eql [8, 7, 6, 5]
    set.size.should.equal 4

  it "forEach should work",  ->
    set = new Set
    [3, 3, 2, 1, 3].forEach((d) -> set.add d)
    items = []
    set.forEach (d) -> items.push d
    items.should.eql [3, 2, 1]

  it "forEach should work with a different this",  ->
    set = new Set
    [3, 3, 2, 1, 3].forEach((d) -> set.add d)
    items = []
    set.forEach(((d) -> this.push d), items)
    items.should.eql [3, 2, 1]

  it "has should work",  ->
    set = new Set
    [3, 3, 2, 1, 3].forEach((d) -> set.add d)
    set.has(-1).should.equal false
    set.has(0).should.equal false
    set.has(1).should.equal true
    set.has(2).should.equal true
    set.has(3).should.equal true
    set.has(4).should.equal false
    set.has(5).should.equal false
    set.has(NaN).should.equal false

  it "entries should return the same data as values (albeit duplicated)", ->
    set = new Set
    [3, 2, 1].forEach((d) -> set.add d)
    set.entries().should.eql set.values().map((d) -> [d, d])
    set.values().should.eql [3, 2, 1]

  it "keys should return the same data as values", ->
    set = new Set
    [3, 2, 1].forEach((d) -> set.add d)
    set.keys().should.eql set.values()
    set.keys().should.eql [3, 2, 1]

  it "size should be correct after adding and removing several items",  ->
    set = new Set
    set.size.should.equal 0
    set.add 42
    set.size.should.equal 1
    set.add 43
    set.size.should.equal 2
    set.add 42
    set.size.should.equal 2
    set.add 44
    set.size.should.equal 3
    set.add 45
    set.size.should.equal 4
    set.delete 42
    set.size.should.equal 3
    set.delete 0
    set.size.should.equal 3
    set.clear()
    set.size.should.equal 0

  it "adding a value to a set repeatedly should have no effect", ->
    set = new Set
    set.add(1)
    set.add(2)
    set.size.should.equal 2
    set.add(1)
    set.add(2)
    set.add(1)
    set.add(3)
    set.size.should.equal 3

  it "NaN should work", ->
    set = new Set
    set.add(52)
    set.add(NaN)
    set.keys().should.eql [52, NaN]

  it "using NaN should update the size correctly", ->
    set = new Set
    set.add(NaN)
    set.add(52)
    set.size.should.equal 2
    set.delete(NaN)
    set.size.should.equal 1

