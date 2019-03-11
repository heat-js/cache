
import InMemoryCache from '../src/store/memory'
import DynamoDB from '../src/store/dynamodb'

describe 'Test In-Memory Cache', ->

	stores = [
		new InMemoryCache
		# new DynamoDB
	]

	it 'should set the cache', ->
		for store in stores
			result = await store.set 'key', 'value', 60
			expect result
				.toBe store

	it 'should get the cache', ->
		for store in stores
			result = await store.get 'key'
			expect result
				.toBe 'value'

	it 'should remember cache', ->
		for store in stores
			called = 0
			times = 3
			while times--
				result = await store.remember 'key-2', 60, ->
					called++
					return 'value-2'

				expect result
					.toBe 'value-2'

				result = await store.get 'key-2'

				expect result
					.toBe 'value-2'

			expect called
				.toBe 1

	it 'should cache method', ->
		for store in stores
			count = 0

			foo = {
				method: ->
					count++
					return 'value'
			}

			store.cacheMethod foo, 'method', 60

			times = 3
			while times--
				result = await foo.method()

				expect result
					.toBe 'value'

			expect count
				.toBe 1
