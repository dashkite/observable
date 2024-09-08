import * as Arr from "@dashkite/joy/array"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"

class Observable

  @keep: 10

  @from: ( data ) ->
    Object.assign ( new @ ), { data, handlers: [], history: [] }

  get: -> structuredClone @data

  update: ( mutator ) ->
    do @push
    data = structuredClone @data
    @data = await mutator data
    data = structuredClone @data
    handler data for handler in @handlers
      
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