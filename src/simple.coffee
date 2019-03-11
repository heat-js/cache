
cacheSymbol = Symbol 'cache'

export default (scope, callback, ttl = Infinity) ->
	return (...args) ->
		token = JSON.stringify args

		if cacheSymbol not of callback
			callback[cacheSymbol] = {}

		if (
			token not of callback[cacheSymbol] or
			(callback[cacheSymbol][token].creation + ttl) < (Date.now() / 1000)
		)
			callback[cacheSymbol][token] =
				creation: Date.now() / 1000
				value: callback.apply scope, args

		return callback[cacheSymbol][token].value
