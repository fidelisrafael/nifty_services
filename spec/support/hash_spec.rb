require 'spec_helper'
RSpec.describe NiftyServices::BaseService, type: :service do
  describe '#symbolize_keys' do
    let(:symbols)  { { 'nhe' => 'bar', 'buiir': 'mor', lol: :hue, blo: { 'asd': 123 } } }
    let(:sample_output) { { nhe: 'bar', buiir: 'mor', lol: :hue, blo: { asd: 123 } } }

    it { expect(symbols.symbolize_keys).to eq(sample_output) }
  end
end