
export default class Store

	constructor: (@cache) ->
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
