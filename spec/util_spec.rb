require 'spec_helper'
RSpec.describe NiftyServices::Util do
  subject { NiftyServices::Util }

  describe '#normalized_callback_name' do
    it do
      expect(subject.normalized_callback_name(:foo_warn)).to eq('foo_warn_callback')
    end
  end
end
