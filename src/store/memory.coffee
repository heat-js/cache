
import Abstract 	from './abstract'
import isBefore 	from 'date-fns/isBefore'
import addSeconds 	from 'date-fns/addSeconds'

export default class Memory extends Abstract

	constructor: (namespace) ->
		super namespace
		@store = new Map

	get: (key) ->
		key 	= [@namespace, key].join '-'
		data 	= @store.get key

		if not data
			return

		if isBefore data.ttl, new Date
			return

		return data.value

	set: (key, value, ttl) ->
		key = [@namespace, key].join '-'
		ttl = addSeconds new Date, ttl

		@store.set key, { value, ttl }

		return @
