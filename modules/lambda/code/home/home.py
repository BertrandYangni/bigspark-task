


def lambda_handler(event, context):

  name = event['name'] if 'name' in event else ''
  abc = 1.3

  return {
    'statusCode': 200,
    'message': 'hello {}'.format(name)
  }