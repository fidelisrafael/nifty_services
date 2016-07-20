require 'spec_helper'
require 'pry'

RSpec.describe NiftyServices::BaseService, type: :service do

  it { expect(subject.valid?).to be_truthy }

  it 'must have error handle methods' do
    NiftyServices::Configuration.response_errors_list.each do |method, response_status|
      expect(subject.respond_to?("#{method}_error", true)).to be_truthy
    end
  end

  it 'must call callback after initialize' do
    expect(subject.callback_fired?(:after_initialize)).to be_truthy
  end

  context 'register and fire new callbacks for instance callbacks' do
    before(:each) do
      subject.register_callback_action(:do_actions_before_success) do
        # puts 'print something pretty before success'
      end

      subject.register_callback_action(:do_actions_after_success) do
        # puts 'print something pretty after success'
      end

      subject.register_callback(:before_success, :do_actions_before_success)
      subject.register_callback(:after_success, :do_actions_after_success)

      subject.send(:success_response)
    end

    it { expect(subject.callback_fired?(:do_actions_before_success)).to be_truthy }
    it { expect(subject.callback_fired?(:do_actions_after_success)).to be_truthy }
  end

  it 'must propagate callbacks to children services' do
    NiftyServices::BaseCreateService.register_callback(:after_success, :write_to_log) do
      # puts 'All classes that inherit from NiftyServices::BaseCreateService will call this callback'
    end

    service = NiftyServices::BaseCreateService.new(Object.new)
    service.send(:success_response)

    expect(service.callback_fired?(:write_to_log)).to be_truthy
  end

  context 'call before and after callbacks after success response' do
    it do
      expect { subject.send(:success_response) }.to change {
        subject.callback_fired?(:before_success)
      }.from(false).to(true)
    end

    it do
      expect { subject.send(:success_response) }.to change {
        subject.callback_fired?(:after_success)
      }.from(false).to(true)
    end
  end

  context 'call callbacks before and after error' do

    it do
      expect { subject.send(:not_authorized_error, 'spec') }.to change {
       subject.callback_fired?(:before_error)
      }.from(false).to(true)
    end

    it do
      expect { subject.send(:not_authorized_error, 'spec') }.to change {
       subject.callback_fired?(:after_error)
      }.from(false).to(true)
    end
  end

  context 'use correct error namespace key' do
    before(:each) do
      subject.send(:not_authorized_error, '__not_existent_key__')
    end

    it { expect(subject.errors.last).to match(NiftyServices::Configuration::DEFAULT_I18N_NAMESPACE) }
  end

  context 'change response_status when error method is called' do
    it do
      expect { subject.send(:not_found_error, 'spec') }.to change {
        subject.response_status_code
      }.from(400).to(404)
    end

    it do
      expect { subject.send(:not_found_error, 'spec') }.to change {
        subject.response_status
      }.from(:bad_request).to(:not_found)
    end
  end

  context 'have 201 response_status after success_created_response' do
    it do
      expect { subject.send(:success_created_response) }.to change {
        subject.response_status_code
      }.from(400).to(201)
    end

    it do
      expect { subject.send(:success_created_response) }.to change {
        subject.response_status
      }.from(:bad_request).to(:created)
    end
  end

  context 'have 200 response_status after success_response' do
    it do
      expect { subject.send(:success_response) }.to change {
        subject.response_status_code
      }.from(400).to(200)
    end

    it do
      expect { subject.send(:success_response) }.to change {
        subject.response_status
      }.from(:bad_request).to(:ok)
    end
  end

  context 'have method to check if options value is enabled/disabled' do
    subject { NiftyServices::BaseService.new(send_push_notification: true, create_users: false) }

    it { expect(subject.option_enabled?(:send_push_notification)).to be_truthy }
    it { expect(subject.option_enabled?(:create_users)).to be_falsey }

    it { expect(subject.option_disabled?(:send_push_notification)).to be_falsey }
    it { expect(subject.option_disabled?(:create_users)).to be_truthy }
  end

  context 'have generic error method do create new errors' do
    it do
      expect { subject.send(:error, 422, 'unprocessable_entity') }.to change {
        subject.response_status
      }.from(:bad_request).to(:unprocessable_entity)
    end

    it do
      expect { subject.send(:error, 422, 'unprocessable_entity') }.to change {
        subject.response_status_code
      }.from(400).to(422)
    end

    it do
      subject.send(:error, 422, 'unprocessable_entity')
      expect(subject.errors.last).to match /unprocessable_entity$/
    end
  end

  context 'return false when error bang method is called' do
    it { expect(subject.send(:not_found_error!, 'spec')).to be_falsey }
    it { expect(subject.send(:not_found_error, 'spec')).to be_a(String) }
  end

  context 'be invalid after any error' do
    it do
      expect { subject.send(:not_found_error!, 'spec') }.to change {
        subject.valid?
      }.from(true).to(false)
    end
  end

  context 'be success ONLY when success_response method is called' do
    it do
      expect { subject.send(:success_response) }.to change {
        subject.success?
      }.from(false).to(true)
    end

    context 'when call fail?' do
      before { subject.send(:success_response) }
      it { expect(subject.fail?).to be_falsey }
    end
  end

  context 'must not have success response if has any error' do
    it do
      expect { subject.send(:success_response) }.to change {
        subject.success?
      }.from(false).to(true)
    end

    context 'when send some error' do
      before do
        subject.send(:success_response)
        subject.send(:not_found_error, 'spec')
        subject.send(:success_response)
      end

      it { expect(subject.success?).to be_falsey }
      it { expect(subject.fail?).to be_truthy }
    end
  end

  context 'allow initial response status' do
    subject { NiftyServices::BaseService.new({}, 422) }
    it { expect(subject.response_status_code).to eq(422) }
    it { expect(subject.response_status).to eq(:unprocessable_entity) }
  end

  xit 'must translate error message' do
    current_locale = I18n.locale

    error = subject.send(:not_authorized_error, 'teste_spec')

    expect(error).not_to be == 'Not authorized'
    expect(error).to match(/translation missing/)

    I18n.backend.store_translations current_locale, :nifty_services => { :errors => { 'teste_spec' => 'Not authorized' } }

    error = subject.send(:not_authorized_error, 'teste_spec')

    expect(error).to be == 'Not authorized'
  end

  xit 'must handle when ActiveModel::Errors is provided to error method' do
    errors = ActiveModel::Errors.new(:subject)
    errors.add('test', 'not valid')

    error = subject.send(:bad_request_error, errors)

    expect(error).to be_a(Hash)
    expect(subject.errors.last).to be == { test: [ 'not valid' ] }

    errors.add('test', 'not valid again')

    expect(subject.errors.last).to be == { test: [ 'not valid', 'not valid again' ] }
  end

  it 'must handle when array of hash is provided to error method' do
    errors = [
      {
        email: 'email not_valid',
      },
      {
        username: 'username already been taken'
      }
    ]

    error = subject.send(:bad_request_error, errors)
    expect(error).to be_a(Array)
  end

  context 'have method to validate objects classes and presence' do
    it { expect(subject.send(:valid_object?, { } , Hash)).to be_falsey }
    it { expect(subject.send(:valid_object?, { key: :value } , Hash)).to be_truthy }

    it { expect(subject.send(:valid_object?, [] , Hash)).to be_falsey }
    it { expect(subject.send(:valid_object?, { key: :value } , Array)).to be_falsey }
  end

  context 'clear invalid hash keys' do
    let(:whitelist) { [:name, :age] }
    let(:hash) { { name: 'Tom Rowlands' , email: 'tom@thechemicalbrothers.com', age: 44 } }
    let(:filtered_hash) { subject.send(:filter_hash, hash, whitelist) }

    it { expect(filtered_hash.keys).to match_array(whitelist) }
    it { expect(filtered_hash[:email]).to be_nil }
  end
end
