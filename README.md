# simple-jsonapi-deserializer

Painless, zero config JSON API deserialization.

## Installation

Add to you application's Gemfile

```ruby
gem 'simple-jsonapi-deserializer'
```

and install

```sh
$ bundle
```

or install it directly

```shell
$ gem install 'simple-jsonapi-deserializer'
```

## Usage

```ruby
SimpleJSONAPIDeserializer.deserialize(json_api_hash)
```

## Examples

```ruby
json_api_hash = {
  'data' => {
    'id' => '1234',
    'type' => 'planets',
    'attributes' => {
      'name' => 'Earth'
    },
    'relationships' => {
      'satellites' => {
        'data' => [
          {
            'id' => '914',
            'type' => 'satellites'
          }
        ]
      }
    }
  },
  'included' => [
    {
      'id' => '914',
      'type' => 'satellites',
      'attributes' => {
        'name' => 'Moon'
      }
    }
  ]
}

SimpleJSONAPIDeserializer.deserialize(json_api_hash)

# =>
# {
#   "id" => "1234",
#   "type" => "planets",
#   "name" => "Earth",
#   "satellites" => [
#     {
#       "id" => "914",
#       "type" => "satellites",
#       "name" => "Moon"
#     }
#   ]
# }
```

## License

MIT
