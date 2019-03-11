
export default class Abstract

	constructor: (@namespace = 'default') ->
		@promises = new Map

	remember: (key, ttl, callback) ->
		nsKey 	= [ @namespace, key ].join '-'
		promise = @promises.get nsKey

		if not promise
			promise = new Promise (resolve) =>
				value = await @get key

				if not value
					value = await callback()
					await @set key, value, ttl

				resolve value

			@promises.set nsKey, promise

		return promise

	cacheMethod: (scope, methodName, ttl) ->
		callback = scope[methodName]

		scope[methodName] = (...args) =>
			token = [
				methodName
				JSON.stringify args
			].join '-'

			return @remember token, ttl, ->
				return callback.apply scope, args
