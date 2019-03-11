
export default class Abstract

	constructor: (@namespace = 'default') ->
		@promises = new Map

	cache: (key, ttl, callback) ->
		key 	= [ @namespace, key ].join '-'
		promise = @promises.get key

		if not promise
			promise = Promise.resolve =>
				value = @get key
				if not value
					value = await callback()
					await @set key, value, ttl

				return value

			@promises.set key, promise

		return promise
