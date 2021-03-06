describe "EventEmitter", ->

  it "should work with a single callback registered", ->
    eventEmitter = new hx.EventEmitter
    received = null
    eventEmitter.on('test-event', (data) -> received = data)
    eventEmitter.emit('test-event', "some-data")
    received.should.equal("some-data")

  it "should work with multiple callbacks registered to the same name", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    eventEmitter.on('test-event', (data) -> received1 = data)
    eventEmitter.on('test-event', (data) -> received2 = data)
    eventEmitter.emit('test-event', "some-data")
    received1.should.equal("some-data")
    received2.should.equal("some-data")

  it "should work with multiple callbacks registered to different names", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    eventEmitter.on('test-event1', (data) -> received1 = data)
    eventEmitter.on('test-event2', (data) -> received2 = data)
    eventEmitter.emit('test-event1', "some-data-1")
    eventEmitter.emit('test-event2', "some-data-2")
    received1.should.equal("some-data-1")
    received2.should.equal("some-data-2")

  it "should work with multiple events being emmitted to a single callback", ->
    eventEmitter = new hx.EventEmitter
    received = 0
    eventEmitter.on('test-event', (data) -> if data is "some-data" then received++)
    eventEmitter.emit('test-event', "some-data") for _ in [1..7]
    received.should.equal(7)

  it "should be able to emit an event to a name with no listeners registered", ->
    eventEmitter = new hx.EventEmitter
    (-> eventEmitter.emit('test-event', "some-data")).should.not.throw()

  it "should not receive events for a different name", ->
    eventEmitter = new hx.EventEmitter
    received = "nothing"
    eventEmitter.on('not-test-event', (data) -> received = data)
    eventEmitter.emit('test-event', "some-data")
    received.should.equal("nothing")

  it "should know which handlers are registered", ->
    eventEmitter = new hx.EventEmitter
    eventEmitter.on('test-event', (data) -> received = data)
    eventEmitter.has('test-event').should.equal(true)

  it "should know which handlers are registered when no name is used", ->
    eventEmitter = new hx.EventEmitter
    eventEmitter.on(null, (data) -> received = data)
    eventEmitter.has('test-event').should.equal(true)

  it "should allow listening to all events", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    eventEmitter.on('test-event1', (data) -> received1 = data)
    eventEmitter.on(null, (name, data) -> received2 = data)
    eventEmitter.emit('test-event1', "some-data-1")
    received2.should.equal("some-data-1")
    eventEmitter.emit('test-event2', "some-data-2")
    received1.should.equal("some-data-1")
    received2.should.equal("some-data-2")

  it "should supply the name correctly when listening to all events", ->
    eventEmitter = new hx.EventEmitter
    received = null
    eventEmitter.on(null, (name, data) -> received = name)
    eventEmitter.emit('test-event-1', "some-data-1")
    received.should.equal("test-event-1")

  it "should be able to de-register a named handler", ->
    eventEmitter = new hx.EventEmitter
    received = null
    handler = (data) -> received = data
    eventEmitter.on('test-event-1', handler)
    eventEmitter.emit('test-event-1', "some-data-1")
    received.should.equal("some-data-1")
    eventEmitter.off('test-event-1', handler)
    eventEmitter.emit('test-event-1', "some-data-2")
    received.should.equal("some-data-1")

  it "should be fine de-registering a handler that doesn't exist", ->
    eventEmitter = new hx.EventEmitter
    received = null
    handler = (data) -> received = data
    eventEmitter.on('test-event-1', handler)
    eventEmitter.emit('test-event-1', "some-data-1")
    received.should.equal("some-data-1")
    eventEmitter.off('test-event-2', ->)
    eventEmitter.emit('test-event-1', "some-data-2")
    received.should.equal("some-data-2")

  it "should be fine de-registering a handler that doesn't exist for non named events", ->
    eventEmitter = new hx.EventEmitter
    received = null
    handler = (data) -> received = data
    eventEmitter.on('test-event-1', handler)
    eventEmitter.emit('test-event-1', "some-data-1")
    received.should.equal("some-data-1")
    eventEmitter.off('test-event-2')
    eventEmitter.emit('test-event-1', "some-data-2")
    received.should.equal("some-data-2")

  it "should be able to de-register a non named handler", ->
    eventEmitter = new hx.EventEmitter
    received = null
    handler = (name, data) -> received = data
    eventEmitter.on(null, handler)
    eventEmitter.emit('test-event-1', "some-data-1")
    received.should.equal("some-data-1")
    eventEmitter.off(null, handler)
    eventEmitter.emit('test-event-1', "some-data-2")
    received.should.equal("some-data-1")

  it "should be able to de-register multiple handlers", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    handler1 = (data) -> received1 = data
    handler2 = (data) -> received2 = data
    eventEmitter.on('test-event-1', handler1)
    eventEmitter.on('test-event-1', handler2)
    eventEmitter.emit('test-event-1', "some-data-1")
    received1.should.equal("some-data-1")
    received2.should.equal("some-data-1")
    eventEmitter.off('test-event-1')
    eventEmitter.emit('test-event-1', "some-data-2")
    received1.should.equal("some-data-1")
    received2.should.equal("some-data-1")

  it "should be able to de-register multiple handlers", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    received3 = null
    handler1 = (data) -> received1 = data
    handler2 = (data) -> received2 = data
    handler3 = (data) -> received3 = data
    eventEmitter.on('test-event-1', handler1)
    eventEmitter.on('test-event-1', handler2)
    eventEmitter.on('test-event-2', handler3)
    eventEmitter.emit('test-event-1', "some-data-1")
    eventEmitter.emit('test-event-2', "some-data-10")
    received1.should.equal("some-data-1")
    received2.should.equal("some-data-1")
    received3.should.equal("some-data-10")
    eventEmitter.off()
    eventEmitter.emit('test-event-1', "some-data-2")
    eventEmitter.emit('test-event-2', "some-data-12")
    received1.should.equal("some-data-1")
    received2.should.equal("some-data-1")
    received3.should.equal("some-data-10")



  it "should do standard piping correctly 1", ->
    ee1 = new hx.EventEmitter
    ee2 = new hx.EventEmitter
    received = null

    ee1.pipe(ee2)

    ee2.on('name', (value) -> received = value)
    ee1.emit('name', 'data')
    received.should.equal('data')

  it "should do standard piping correctly 2", ->
    ee1 = new hx.EventEmitter
    ee2 = new hx.EventEmitter
    received = null

    ee1.pipe(ee2)

    ee2.on(null, (name, value) -> received = name)
    ee1.emit('name', 'data')
    received.should.equal('name')

    ee2.off()

    ee2.on(null, (name, value) -> received = value)
    ee1.emit('name', 'data')
    received.should.equal('data')


  it "should do namespaced piping correctly 1", ->
    ee1 = new hx.EventEmitter
    ee2 = new hx.EventEmitter
    received = null

    ee1.pipe(ee2, 'namespace')

    ee2.on('namespace.test', (value) -> received = value)
    ee1.emit('test', 'data')
    received.should.equal('data')


  it "should do namespaced piping correctly 2", ->
    ee1 = new hx.EventEmitter
    ee2 = new hx.EventEmitter
    received = null

    ee1.pipe(ee2)

    ee2.on(null, (name, value) -> received = name)
    ee1.emit('test', 'data')
    received.should.equal('test')

    ee2.off()

    ee2.on(null, (name, value) -> received = value)
    ee1.emit('test', 'data')
    received.should.equal('data')

  it "should do filtered piping correctly 1", ->
    ee1 = new hx.EventEmitter
    ee2 = new hx.EventEmitter
    received = null

    ee1.pipe(ee2, undefined, ['event'])

    ee2.on('event', (value) -> received = value)
    ee2.on('event-2', (value) -> received = value)
    ee1.emit('event', 'data1')
    ee1.emit('event-2', 'data2')
    received.should.equal('data1')


  it "should do filtered piping correctly 2", ->
    ee1 = new hx.EventEmitter
    ee2 = new hx.EventEmitter
    received = null

    ee1.pipe(ee2, undefined, ['event'])

    ee2.on(null, (name, value) -> received = name)
    ee1.emit('event', 'data1')
    ee1.emit('event-2', 'data2')
    received.should.equal('event')

    ee2.off()

    ee2.on(null, (name, value) -> received = value)
    ee1.emit('event', 'data1')
    ee1.emit('event-2', 'data2')
    received.should.equal('data1')

  it "should do filtered namespaced piping correctly 1", ->
    ee1 = new hx.EventEmitter
    ee2 = new hx.EventEmitter
    received = null

    ee1.pipe(ee2, 'namespace', ['event'])

    ee2.on('namespace.event', (value) -> received = value)
    ee2.on('namespace.event-2', (value) -> received = value)
    ee1.emit('event', 'data1')
    ee1.emit('event-2', 'data2')
    received.should.equal('data1')


  it "should do filtered namespaced piping correctly 2", ->
    ee1 = new hx.EventEmitter
    ee2 = new hx.EventEmitter
    received = null

    ee1.pipe(ee2, 'namespace', ['event'])

    ee2.on(null, (name, value) -> received = name)
    ee1.emit('event', 'data1')
    ee1.emit('event-2', 'data2')
    received.should.equal('namespace.event')

    ee2.off()

    ee2.on(null, (name, value) -> received = value)
    ee1.emit('event', 'data1')
    ee1.emit('event-2', 'data2')
    received.should.equal('data1')

  it "registering a namespaced handler should work", ->
    eventEmitter = new hx.EventEmitter
    received = null
    eventEmitter.on('test-event', 'my-namespace', (data) -> received = data)
    eventEmitter.emit('test-event', "some-data")
    received.should.equal("some-data")

  it "registering a namespaced handler should work with a default handler", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    eventEmitter.on('test-event', 'my-namespace', (data) -> received1 = data)
    eventEmitter.on('test-event', (data) -> received2 = data)
    eventEmitter.emit('test-event', "some-data")
    received1.should.equal("some-data")
    received2.should.equal("some-data")

  it "removing a namespaced handler should work for a specific function", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    f1 = (data) -> received1 = data
    f2 = (data) -> received2 = data
    eventEmitter.on('test-event', 'my-namespace', f1)
    eventEmitter.on('test-event', 'my-namespace', f2)
    eventEmitter.emit('test-event', "some-data")
    eventEmitter.off('test-event', 'my-namespace', f1)
    eventEmitter.emit('test-event', "some-data2")
    received1.should.equal("some-data")
    received2.should.equal("some-data2")

  it "removing a namespaced handler by name and namespace should work", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    received3 = null
    f1 = (data) -> received1 = data
    f2 = (data) -> received2 = data
    f3 = (data) -> received3 = data
    eventEmitter.on('test-event', 'my-namespace', f1)
    eventEmitter.on('test-event', 'my-namespace', f2)
    eventEmitter.on('test-event', f3)
    eventEmitter.emit('test-event', "some-data")
    eventEmitter.off('test-event', 'my-namespace')
    eventEmitter.emit('test-event', "some-data2")
    received1.should.equal("some-data")
    received2.should.equal("some-data")
    received3.should.equal("some-data2")

  it "removing from the default namespace should work", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    received3 = null
    f1 = (data) -> received1 = data
    f2 = (data) -> received2 = data
    f3 = (data) -> received3 = data
    eventEmitter.on('test-event', 'my-namespace', f1)
    eventEmitter.on('test-event', 'my-namespace', f2)
    eventEmitter.on('test-event', f3)
    eventEmitter.emit('test-event', "some-data")
    eventEmitter.off('test-event', 'default')
    eventEmitter.emit('test-event', "some-data2")
    received1.should.equal("some-data2")
    received2.should.equal("some-data2")
    received3.should.equal("some-data")


  it "removing all handlers by name (even namespaced) should work", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    received3 = null
    f1 = (data) -> received1 = data
    f2 = (data) -> received2 = data
    f3 = (data) -> received3 = data
    eventEmitter.on('test-event', 'my-namespace', f1)
    eventEmitter.on('test-event', 'my-namespace', f2)
    eventEmitter.on('test-event', f3)
    eventEmitter.emit('test-event', "some-data")
    eventEmitter.off('test-event')
    eventEmitter.emit('test-event', "some-data2")
    received1.should.equal("some-data")
    received2.should.equal("some-data")
    received3.should.equal("some-data")

  it "removing all handlers (even namespaced) should work", ->
    eventEmitter = new hx.EventEmitter
    received1 = null
    received2 = null
    received3 = null
    f1 = (data) -> received1 = data
    f2 = (data) -> received2 = data
    f3 = (data) -> received3 = data
    eventEmitter.on('test-event', 'my-namespace', f1)
    eventEmitter.on('test-event', 'my-namespace', f2)
    eventEmitter.on('test-event', f3)
    eventEmitter.emit('test-event', "some-data")
    eventEmitter.off()
    eventEmitter.emit('test-event', "some-data2")
    received1.should.equal("some-data")
    received2.should.equal("some-data")
    received3.should.equal("some-data")

  it 'suppressed works', ->
    ee = new hx.EventEmitter
    received = 0
    ee.on 'test-event', -> received++
    ee.emit('test-event')
    received.should.equal(1)
    ee.suppressed('test-event', true)
    ee.emit('test-event')
    received.should.equal(1)
    ee.suppressed('test-event', false)
    ee.emit('test-event')
    received.should.equal(2)

  it 'suppressed works with namespaces', ->
    ee = new hx.EventEmitter
    received = 0
    ee.on 'test-event', 'namespace', -> received++
    ee.emit('test-event')
    received.should.equal(1)
    ee.suppressed('test-event', true)
    ee.emit('test-event')
    received.should.equal(1)
    ee.suppressed('test-event', false)
    ee.emit('test-event')
    received.should.equal(2)

  it 'suppressed returns the right types', ->
    ee = new hx.EventEmitter
    ee.suppressed('test-event').should.equal(false)
    ee.suppressed('test-event', true).should.equal(ee)
    ee.suppressed('test-event').should.equal(true)
    ee.suppressed('test-event', false).should.equal(ee)
    ee.suppressed('test-event').should.equal(false)