import * as Arr from "@dashkite/joy/array"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"

byPriority = ( a, b ) -> a.priority - b.priority

class Observable

  @keep: 10

  @from: ( data ) ->
    Object.assign ( new @ ), { data, plans: [], handlers: [], history: [] }

  get: -> structuredClone @data

  set: ( data ) -> @data = structuredClone data

  plan: ( mutator, priority = 0 ) ->
    @plans.push { mutator, priority }
    @

  commit: ->
    do @push
    data = do @get
    for { mutator } in ( @plans.sort byPriority )
      data = await mutator data
    @plans = []
    @set data
    for handler in @handlers
      handler do @get
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
    data = structuredClone @data
    handler data for handler in @handlers
    data


export default Observable