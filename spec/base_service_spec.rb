require 'spec_helper'
require 'pry'

RSpec.describe NiftyServices::BaseService, type: :service do

  let(:base_service) { NiftyServices::BaseService.new }

  it 'must be valid' do
    base_service.valid?
  end

  it 'must have error handle methods' do
    NiftyServices::Configuration.response_errors_list.each do |method, response_status|
      expect(base_service.respond_to?("#{method}_error", true)).to be true
    end
  end

  it 'must call callback after initialize' do
    expect(base_service.callback_fired?(:after_initialize)).to be true
  end

  it 'must register and fire new callbacks for instance callbacks' do
    base_service.register_callback_action(:do_actions_before_success) do
      # puts 'print something pretty before success'
    end

    base_service.register_callback_action(:do_actions_after_success) do
      # puts 'print something pretty after success'
    end

    base_service.register_callback(:before_success, :do_actions_before_success)
    base_service.register_callback(:after_success, :do_actions_after_success)

    base_service.send(:success_response)

    expect(base_service.callback_fired?(:do_actions_before_success)).to be true
    expect(base_service.callback_fired?(:do_actions_after_success)).to be true
  end

  it 'must propagate callbacks to children services' do
    NiftyServices::BaseCreateService.register_callback(:after_success, :write_to_log) do
      # puts 'All classes that inherit from NiftyServices::BaseCreateService will call this callback'
    end

    service = NiftyServices::BaseCreateService.new(Object.new)
    service.send(:success_response)

    expect(service.callback_fired?(:write_to_log)).to be true
  end

  it 'must call before and after callbacks after success response' do
    expect(base_service.callback_fired?(:before_success)).to be false
    expect(base_service.callback_fired?(:after_success)).to be false

    base_service.send(:success_response)

    expect(base_service.callback_fired?(:before_success)).to be true
    expect(base_service.callback_fired?(:after_success)).to be true
  end

  it 'must call callbacks before and after error' do
    expect(base_service.callback_fired?(:before_error)).to be false
    expect(base_service.callback_fired?(:after_error)).to be false

    base_service.send(:not_authorized_error, 'spec')

    expect(base_service.callback_fired?(:before_error)).to be true
    expect(base_service.callback_fired?(:after_error)).to be true
  end

  it 'must use correct error namespace key' do
    base_service.send(:not_authorized_error, '__not_existent_key__')

    error_namespace = NiftyServices::Configuration::DEFAULT_I18N_NAMESPACE
    error = base_service.errors.last

    expect(error).to match error_namespace
  end

  it 'must change response_status when error method is called' do
    expect(base_service.response_status).to be 400
    base_service.send(:not_found_error, 'spec')
    expect(base_service.response_status).to be 404
  end

  it 'must have 201 response_status after success_created_response' do
    expect(base_service.response_status).to be 400
    base_service.send(:success_created_response)
    expect(base_service.response_status).to be 201
  end

  it 'must have 200 response_status after success_response' do
    expect(base_service.response_status).to be 400
    base_service.send(:success_response)
    expect(base_service.response_status).to be 200
  end

  it 'must have method to check if options value is enabled/disabled' do
    base_service = NiftyServices::BaseService.new(send_push_notification: true, create_users: false)

    expect(base_service.option_enabled?(:send_push_notification)).to be true
    expect(base_service.option_enabled?(:create_users)).to be false

    expect(base_service.option_disabled?(:send_push_notification)).to be false
    expect(base_service.option_disabled?(:create_users)).to be true
  end

  it 'must have generic error method do create new errors' do
    expect(base_service.response_status).to be 400

    base_service.send(:error, 422, 'unprocessable_entity')

    expect(base_service.response_status).to be 422
    expect(base_service.errors.last).to match /unprocessable_entity$/
  end

  it 'must return false when error bang method is called' do
    error_response_with_bang = base_service.send(:not_found_error!, 'spec')
    error_response = base_service.send(:not_found_error, 'spec')

    expect(error_response_with_bang).to be false
    expect(error_response).to be_a(String)
  end

  it 'must be invalid after any error' do
    expect(base_service.valid?).to be true
    base_service.send(:not_found_error!, 'spec')
    expect(base_service.valid?).to be false
  end

  it 'must be success ONLY when success_response method is called' do
    expect(base_service.success?).to be false
    base_service.send(:success_response)
    expect(base_service.success?).to be true
    expect(base_service.fail?).to be false
  end

  it 'must not have success response if has any error' do
    expect(base_service.success?).to be false

    base_service.send(:success_response)
    expect(base_service.success?).to be true

    base_service.send(:not_found_error, 'spec')

    base_service.send(:success_response)
    expect(base_service.success?).to be false
    expect(base_service.fail?).to be true
  end

  it 'ust allow initial response status' do
    base_service = NiftyServices::BaseService.new({}, 422)
    expect(base_service.response_status).to be 422
  end

  # it 'must translate error message' do
  #   current_locale = I18n.locale

  #   error = base_service.send(:not_authorized_error, 'teste_spec')

  #   expect(error).not_to be == 'Not authorized'
  #   expect(error).to match(/translation missing/)

  #   I18n.backend.store_translations current_locale, :nifty_services => { :errors => { 'teste_spec' => 'Not authorized' } }

  #   error = base_service.send(:not_authorized_error, 'teste_spec')

  #   expect(error).to be == 'Not authorized'
  # end

  # it 'must handle when ActiveModel::Errors is provided to error method' do
  #   errors = ActiveModel::Errors.new(:base_service)
  #   errors.add('test', 'not valid')

  #   error = base_service.send(:bad_request_error, errors)

  #   expect(error).to be_a(Hash)
  #   expect(base_service.errors.last).to be == { test: [ 'not valid' ] }

  #   errors.add('test', 'not valid again')

  #   expect(base_service.errors.last).to be == { test: [ 'not valid', 'not valid again' ] }
  # end

  it 'must handle when array of hash is provided to error method' do
    errors = [
      {
        email: 'email not_valid',
      },
      {
        username: 'username already been taken'
      }
    ]

    error = base_service.send(:bad_request_error, errors)
    expect(error).to be_a(Array)
  end

  it 'must have method to validate objects classes and presence' do
    expect(base_service.send(:valid_object?, { } , Hash)).to be false
    expect(base_service.send(:valid_object?, { key: :value } , Hash)).to be true

    expect(base_service.send(:valid_object?, [] , Hash)).to be false
    expect(base_service.send(:valid_object?, { key: :value } , Array)).to be false
  end

  it 'must clear invalid hash keys' do
    whitelist = [:name, :age]

    hash = { name: 'Tom Rowlands' , email: 'tom@thechemicalbrothers.com', age: 44 }

    filtered_hash = base_service.send(:filter_hash, hash, whitelist)

    expect(filtered_hash.keys).to be == whitelist
    expect(filtered_hash[:email]).to be_nil
  end
end
