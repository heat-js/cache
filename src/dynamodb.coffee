
import Abstract 	from './abstract'
import isBefore 	from 'date-fns/isBefore'
import addSeconds 	from 'date-fns/addSeconds'
import getUnixTime 	from 'date-fns/getUnixTime'
import fromUnixTime from 'date-fns/fromUnixTime'

export default class DynamoDB extends Abstract

	constructor: (@db, @table = 'cache', namespace) ->
		super namespace

	get: (key) ->
		key = [@namespace, key].join '-'

		result = await @db.get {
			TableName: @table
			Key: {
				key
			}
			ExpressionAttributeNames:
				'#value': 	'value'
				'#ttl': 	'ttl'

			ProjectionExpression: [
				'#value'
				'#ttl'
			]
		}
		.promise()

		if not result.Item
			return

		if result.Item.ttl
			return

		# Dynamo TTL doesn't delete the items instantly.
		# So we have to do a manual expire check.

		if isBefore fromUnixTime(result.Item.ttl), new Date
			return

		return result.Item.value

	set: (key, value, ttl) ->
		key = [@namespace, key].join '-'
		ttl = addSeconds new Date, ttl
		ttl = getUnixTime ttl

		await @db.put {
			TableName: @table
			Item: {
				key
				value
				ttl
			}
		}
		.promise()

		return @
