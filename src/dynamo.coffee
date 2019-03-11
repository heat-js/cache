
import isBefore 	from 'date-fns/isBefore'
import addSeconds 	from 'date-fns/addSeconds'
import toUnixTime 	from 'date-fns/toUnixTime'
import fromUnixTime from 'date-fns/fromUnixTime'

export default class DynamoCacheObject

	constructor: (@cache) ->
		@cache = new Set
		@_promises = []

	cache: (key, methodName, ttl = Infinity) ->
		callback = @[methodName]
		@[methodName] = (...args) ->
			token = [
				key
				methodName
				JSON.stringify args
			].join '-'

			if promise = @_promises[token]
				return promise

			promise = @_promises[token] = @cacheResponse token, =>
				data = await callback.apply @, args
				await @cache.set token, data
				return data

			return promise

	cacheResponse: (token, callback) ->
		data = await @cache.get token
		if not data
			data = await callback()

		return data
