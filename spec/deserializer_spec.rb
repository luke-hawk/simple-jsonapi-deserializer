require 'spec_helper'
require 'simple/jsonapi/deserializer'

describe Simple::Jsonapi::Deserializer do
  it "should have a VERSION constant" do
    expect(subject.const_get('VERSION')).to_not be_empty
  end
end
