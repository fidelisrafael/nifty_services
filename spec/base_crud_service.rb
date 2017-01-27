require 'spec_helper'
require 'pry'

RSpec.describe NiftyServices::BaseCrudService, type: :service do

  context 'class methods' do
    it 'must allow set whitelist attributes using class method' do
      MyResource = Class.new do
        attr_reader :data

        def initialize
          @data = { color: 'blue', size: '10cm', type: 'object' }
        end

        def update(attributes)
          @data.merge!(attributes.symbolize_keys)

          self
        end

        def valid?
          true
        end
      end

      class UpdateMyResourceService < NiftyServices::BaseUpdateService

        record_type MyResource

        WHITELIST_ATTRIBUTES = [:color, :size]

        whitelist_attributes WHITELIST_ATTRIBUTES

        def can_update_record?
          true
        end

        def record_attributes_hash
          @options[:data] || @options
        end

        def update_record
          @record.update(record_allowed_attributes)
        end
      end

      record = MyResource.new
      new_data = { color: 'green', size: '11cm', type: 'new_object' }
      service = UpdateMyResourceService.new(record, data: new_data)
      service.execute

      expect(service.success?).to be_truthy
      expect(service.record.data).to eq({ color: 'green', size: '11cm', type: 'object' })
      expect(service.record.data[:type]).to eq('object')

      expect(UpdateMyResourceService.get_whitelist_attributes).to eq(UpdateMyResourceService::WHITELIST_ATTRIBUTES)
    end
  end
end
