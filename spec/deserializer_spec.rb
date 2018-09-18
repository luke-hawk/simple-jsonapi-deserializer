require 'spec_helper'
require 'simple_jsonapi_deserializer'

describe SimpleJSONAPIDeserializer do
  it 'should have a VERSION constant' do
    expect(subject.const_get('VERSION')).to_not be_empty
  end
end
