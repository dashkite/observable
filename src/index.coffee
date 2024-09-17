import * as Arr from "@dashkite/joy/array"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"

byPriority = ( a, b ) -> a.priority - b.priority

class Observable

  @keep: 10

  @from: ( data, { clone }) ->
    clone ?= structuredClone
    Object.assign ( new @ ), 
      { data, clone, plans: [], handlers: [], history: [] }

  get: -> @clone @data

  set: ( data ) -> @data = @clone data

  plan: ( mutator, priority = 0 ) ->
    @plans.push { mutator, priority }
    @

  abort: ->
    @plans = []

  commit: ->
    do @push
    data = do @get
    for { mutator } in ( @plans.sort byPriority )
      data = await mutator data
    @plans = []
    @set data
    ( handler do @get ) for handler in @handlers
    @

  update: ( mutator ) ->
    @plan mutator
    do @commit
      
  observe: ( handler ) ->
    @handlers.push handler
    handler

  cancel: ( handler ) ->
    @handlers = Arr.remove handler, @handlers

  push: ->
    @history.push @data
    if @history.length > Observable.keep
      do @history.shift

  pop: ->
    @data = @history.pop()
    data = @clone @data
    handler data for handler in @handlers
    data


export default Observable