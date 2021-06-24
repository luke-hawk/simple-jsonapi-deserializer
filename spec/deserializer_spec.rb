require 'spec_helper'

describe SimpleJSONAPIDeserializer::Deserializer do
  describe '.deserialize' do
    subject { SimpleJSONAPIDeserializer::Deserializer.new(json_hash).deserialize }

    context 'with an invalid parameter' do
      let(:json_hash) { nil }

      it 'raises a custom error' do
        expect { subject }.to raise_error(SimpleJSONAPIDeserializer::ParseError)
      end
    end

    context 'with an invalid resource' do
      let(:json_hash) do
        {
          'data' => {
            'relationships' => {
              'test' => {}
            }
          },
          'include' => 5
        }
      end

      it 'raises a custom error' do
        expect { subject }.to raise_error(SimpleJSONAPIDeserializer::ParseError)
      end
    end

    context 'with a resource' do
      let(:json_hash) do
        {
          'data' => {
            'id' => '123',
            'type' => 'mice'
          }
        }
      end
      let(:expected_result) do
        {
          'id' => '123',
          'type' => 'mice'
        }
      end

      it { is_expected.to eq(expected_result) }
    end

    context 'with a resource with attributes' do
      let(:json_hash) do
        {
          'data' => {
            'id' => '123',
            'type' => 'mice',
            'attributes' => {
              'color' => 'white',
              'name' => 'Vinnie'
            }
          }
        }
      end
      let(:expected_result) do
        {
          'id' => '123',
          'type' => 'mice',
          'color' => 'white',
          'name' => 'Vinnie'
        }
      end

      it { is_expected.to eq(expected_result) }
    end

    context 'with a resource with unknown keys' do
      let(:json_hash) do
        {
          'data' => {
            'id' => '123',
            'type' => 'mice',
            'attributes' => {
              'name' => 'Vinnie'
            },
            'unknown_key' => 'unknown'
          }
        }
      end
      let(:expected_result) do
        {
          'id' => '123',
          'type' => 'mice',
          'name' => 'Vinnie'
        }
      end

      it { is_expected.to eq(expected_result) }
    end

    # An array is not allowed as a root level resource, but it can be used to
    # update relationships. In this case attributes will be ignored.
    # http://jsonapi.org/format/#crud-updating-relationships
    context 'with an array of resources' do
      let(:json_hash) do
        {
          'data' => [
            {
              'id' => '123',
              'type' => 'mice',
              'attributes' => {
                'name' => 'Vinnie'
              }
            },
            {
              'id' => '124',
              'type' => 'mice',
              'attributes' => {
                'name' => 'Rico'
              }
            }
          ]
        }
      end
      let(:expected_result) do
        [
          {
            'id' => '123',
            'type' => 'mice'
          },
          {
            'id' => '124',
            'type' => 'mice'
          }
        ]
      end

      it { is_expected.to eq(expected_result) }
    end

    describe 'relationships' do
      context 'with a single relationship' do
        let(:json_hash) do
          {
            'data' => {
              'id' => '123',
              'type' => 'mice',
              'attributes' => {
                'name' => 'Vinnie'
              },
              'relationships' => {
                'bike' => {
                  'data' => {
                    'id' => '5',
                    'type' => 'bikes'
                  }
                }
              }
            }
          }
        end
        let(:expected_result) do
          {
            'id' => '123',
            'type' => 'mice',
            'name' => 'Vinnie',
            'bike' => {
              'id' => '5',
              'type' => 'bikes'
            }
          }
        end

        it { is_expected.to eq(expected_result) }
      end

      context 'with multiple relationships' do
        let(:json_hash) do
          {
            'data' => {
              'id' => '123',
              'type' => 'mice',
              'attributes' => {
                'name' => 'Vinnie'
              },
              'relationships' => {
                'bike' => {
                  'data' => {
                    'id' => '5',
                    'type' => 'bikes'
                  }
                },
                'villain' => {
                  'data' => {
                    'id' => '9',
                    'type' => 'villains'
                  }
                }
              }
            }
          }
        end
        let(:expected_result) do
          {
            'id' => '123',
            'type' => 'mice',
            'name' => 'Vinnie',
            'bike' => {
              'id' => '5',
              'type' => 'bikes'
            },
            'villain' => {
              'id' => '9',
              'type' => 'villains'
            }
          }
        end

        it { is_expected.to eq(expected_result) }
      end

      context 'with to_many relationships' do
        let(:json_hash) do
          {
            'data' => {
              'id' => '123',
              'type' => 'mice',
              'attributes' => {
                'name' => 'Vinnie'
              },
              'relationships' => {
                'bike' => {
                  'data' => {
                    'id' => '5',
                    'type' => 'bikes'
                  }
                },
                'villains' => {
                  'data' => [
                    {
                      'id' => '9',
                      'type' => 'villains'
                    },
                    {
                      'id' => '15',
                      'type' => 'villains'
                    }
                  ]
                }
              }
            }
          }
        end
        let(:expected_result) do
          {
            'id' => '123',
            'type' => 'mice',
            'name' => 'Vinnie',
            'bike' => {
              'id' => '5',
              'type' => 'bikes'
            },
            'villains' => [
              {
                'id' => '9',
                'type' => 'villains'
              },
              {
                'id' => '15',
                'type' => 'villains'
              }
            ]
          }
        end

        it { is_expected.to eq(expected_result) }
      end
    end

    describe 'relationships with includes' do
      context 'with a single relationship' do
        let(:json_hash) do
          {
            'data' => {
              'id' => '123',
              'type' => 'mice',
              'attributes' => {
                'name' => 'Vinnie'
              },
              'relationships' => {
                'bike' => {
                  'data' => {
                    'id' => '5',
                    'type' => 'bikes'
                  }
                }
              }
            },
            'included' => [
              {
                'id' => '5',
                'type' => 'bikes',
                'attributes' => {
                  'color' => 'red'
                }
              }
            ]
          }
        end
        let(:expected_result) do
          {
            'id' => '123',
            'type' => 'mice',
            'name' => 'Vinnie',
            'bike' => {
              'id' => '5',
              'type' => 'bikes',
              'color' => 'red'
            }
          }
        end

        it { is_expected.to eq(expected_result) }
      end

      context 'with multiple relationships' do
        let(:json_hash) do
          {
            'data' => {
              'id' => '123',
              'type' => 'mice',
              'attributes' => {
                'name' => 'Vinnie'
              },
              'relationships' => {
                'bike' => {
                  'data' => {
                    'id' => '5',
                    'type' => 'bikes'
                  }
                },
                'villain' => {
                  'data' => {
                    'id' => '9',
                    'type' => 'villains'
                  }
                }
              }
            },
            'included' => [
              {
                'id' => '5',
                'type' => 'bikes',
                'attributes' => {
                  'color' => 'red'
                }
              },
              {
                'id' => '9',
                'type' => 'villains',
                'attributes' => {
                  'first_name' => 'Lawrence',
                  'last_name' => 'Limburger'
                }
              }
            ]
          }
        end
        let(:expected_result) do
          {
            'id' => '123',
            'type' => 'mice',
            'name' => 'Vinnie',
            'bike' => {
              'id' => '5',
              'type' => 'bikes',
              'color' => 'red'
            },
            'villain' => {
              'id' => '9',
              'type' => 'villains',
              'first_name' => 'Lawrence',
              'last_name' => 'Limburger'
            }
          }
        end

        it { is_expected.to eq(expected_result) }
      end

      context 'with to_many relationships' do
        let(:json_hash) do
          {
            'data' => {
              'id' => '123',
              'type' => 'mice',
              'attributes' => {
                'name' => 'Vinnie'
              },
              'relationships' => {
                'bike' => {
                  'data' => {
                    'id' => '5',
                    'type' => 'bikes'
                  }
                },
                'villains' => {
                  'data' => [
                    {
                      'id' => '9',
                      'type' => 'villains'
                    },
                    {
                      'id' => '15',
                      'type' => 'villains'
                    }
                  ]
                }
              }
            },
            'included' => [
              {
                'id' => '5',
                'type' => 'bikes',
                'attributes' => {
                  'color' => 'red'
                }
              },
              {
                'id' => '9',
                'type' => 'villains',
                'attributes' => {
                  'first_name' => 'Lawrence',
                  'last_name' => 'Limburger'
                }
              },
              {
                'id' => '15',
                'type' => 'villains',
                'attributes' => {
                  'first_name' => 'Grease',
                  'last_name' => 'Pit'
                }
              }
            ]
          }
        end
        let(:expected_result) do
          {
            'id' => '123',
            'type' => 'mice',
            'name' => 'Vinnie',
            'bike' => {
              'id' => '5',
              'type' => 'bikes',
              'color' => 'red'
            },
            'villains' => [
              {
                'id' => '9',
                'type' => 'villains',
                'first_name' => 'Lawrence',
                'last_name' => 'Limburger'
              },
              {
                'id' => '15',
                'type' => 'villains',
                'first_name' => 'Grease',
                'last_name' => 'Pit'
              }
            ]
          }
        end

        it { is_expected.to eq(expected_result) }
      end

      context 'with nested relationships' do
        let(:json_hash) do
          {
            'data' => {
              'id' => '123',
              'type' => 'mice',
              'attributes' => {
                'name' => 'Vinnie'
              },
              'relationships' => {
                'bike' => {
                  'data' => {
                    'id' => '5',
                    'type' => 'bikes'
                  }
                },
                'villains' => {
                  'data' => [
                    {
                      'id' => '9',
                      'type' => 'villains'
                    },
                    {
                      'id' => '15',
                      'type' => 'villains'
                    }
                  ]
                }
              }
            },
            'included' => [
              {
                'id' => '5',
                'type' => 'bikes',
                'attributes' => {
                  'color' => 'red'
                }
              },
              {
                'id' => '9',
                'type' => 'villains',
                'attributes' => {
                  'first_name' => 'Lawrence',
                  'last_name' => 'Limburger'
                },
                'relationships' => {
                  'assistants' => {
                    'data' => [
                      {
                        'id' => '24',
                        'type' => 'villains'
                      },
                      {
                        'id' => '15',
                        'type' => 'villains'
                      }
                    ]
                  }
                }
              },
              {
                'id' => '15',
                'type' => 'villains',
                'attributes' => {
                  'first_name' => 'Grease',
                  'last_name' => 'Pit'
                }
              },
              {
                'id' => '24',
                'type' => 'villains',
                'attributes' => {
                  'first_name' => 'Benjamin',
                  'last_name' => 'Karbunkle'
                }
              }
            ]
          }
        end
        let(:expected_result) do
          {
            'id' => '123',
            'type' => 'mice',
            'name' => 'Vinnie',
            'bike' => {
              'id' => '5',
              'type' => 'bikes',
              'color' => 'red'
            },
            'villains' => [
              {
                'id' => '9',
                'type' => 'villains',
                'first_name' => 'Lawrence',
                'last_name' => 'Limburger',
                'assistants' => [
                  {
                    'id' => '24',
                    'type' => 'villains',
                    'first_name' => 'Benjamin',
                    'last_name' => 'Karbunkle'
                  },
                  {
                    'id' => '15',
                    'type' => 'villains',
                    'first_name' => 'Grease',
                    'last_name' => 'Pit'
                  }
                ]
              },
              {
                'id' => '15',
                'type' => 'villains',
                'first_name' => 'Grease',
                'last_name' => 'Pit'
              }
            ]
          }
        end

        it { is_expected.to eq(expected_result) }
      end
    end

    context 'with cyclic relationships' do
      let(:json_hash) do
        {
          'data' => {
            'id' => '123',
            'type' => 'mice',
            'attributes' => {
              'name' => 'Vinnie'
            },
            'relationships' => {
              'bike' => {
                'data' => {
                  'id' => '5',
                  'type' => 'bikes'
                }
              },
              'villains' => {
                'data' => [
                  {
                    'id' => '9',
                    'type' => 'villains'
                  },
                  {
                    'id' => '15',
                    'type' => 'villains'
                  }
                ]
              },
              'episodes' => {
                'data' => [
                  {
                    'id' => '1',
                    'type' => 'episodes'
                  }
                ]
              }
            }
          },
          'included' => [
            {
              'id' => '5',
              'type' => 'bikes',
              'attributes' => {
                'color' => 'red'
              }
            },
            {
              'id' => '9',
              'type' => 'villains',
              'attributes' => {
                'first_name' => 'Lawrence',
                'last_name' => 'Limburger'
              },
              'relationships' => {
                'assistants' => {
                  'data' => [
                    {
                      'id' => '24',
                      'type' => 'villains'
                    },
                    {
                      'id' => '15',
                      'type' => 'villains'
                    }
                  ]
                }
              }
            },
            {
              'id' => '15',
              'type' => 'villains',
              'attributes' => {
                'first_name' => 'Grease',
                'last_name' => 'Pit'
              }
            },
            {
              'id' => '24',
              'type' => 'villains',
              'attributes' => {
                'first_name' => 'Benjamin',
                'last_name' => 'Karbunkle'
              },
              'relationships' => {
                'boss' => {
                  'data' => {
                    'id' => '9',
                    'type' => 'villains'
                  }
                }
              }
            },
            {
              'id' => '1',
              'type' => 'episodes',
              'attributes' => {
                'name' => 'Rock and Ride!'
              },
              'relationships' => {
                'characters' => {
                  'data' => [
                    {
                      'id' => '123',
                      'type' => 'mice'
                    },
                    {
                      'id' => '9',
                      'type' => 'villains'
                    }
                  ]
                }
              }
            }
          ]
        }
      end
      let(:expected_result) do
        {
          'id' => '123',
          'type' => 'mice',
          'name' => 'Vinnie',
          'bike' => {
            'id' => '5',
            'type' => 'bikes',
            'color' => 'red'
          },
          'villains' => [
            {
              'id' => '9',
              'type' => 'villains',
              'first_name' => 'Lawrence',
              'last_name' => 'Limburger',
              'assistants' => [
                {
                  'id' => '24',
                  'type' => 'villains',
                  'first_name' => 'Benjamin',
                  'last_name' => 'Karbunkle',
                  'boss' => {
                    'id' => '9',
                    'type' => 'villains',
                    'first_name' => 'Lawrence',
                    'last_name' => 'Limburger'
                  }
                },
                {
                  'id' => '15',
                  'type' => 'villains',
                  'first_name' => 'Grease',
                  'last_name' => 'Pit'
                }
              ]
            },
            {
              'id' => '15',
              'type' => 'villains',
              'first_name' => 'Grease',
              'last_name' => 'Pit'
            }
          ],
          'episodes' => [
            {
              'id' => '1',
              'name' => 'Rock and Ride!',
              'type' => 'episodes',
              'characters' => [
                {
                  'id' => '123',
                  'type' => 'mice'
                },
                {
                  'id' => '9',
                  'type' => 'villains',
                  'first_name' => 'Lawrence',
                  'last_name' => 'Limburger',
                  'assistants' => [
                    {
                      'id' => '24',
                      'type' => 'villains',
                      'first_name' => 'Benjamin',
                      'last_name' => 'Karbunkle',
                      'boss' => {
                        'id' => '9',
                        'type' => 'villains',
                        'first_name' => 'Lawrence',
                        'last_name' => 'Limburger'
                      }
                    },
                    {
                      'id' => '15',
                      'type' => 'villains',
                      'first_name' => 'Grease',
                      'last_name' => 'Pit'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it { is_expected.to eq(expected_result) }
    end
  end
end
