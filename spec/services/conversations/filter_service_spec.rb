# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conversations::FilterService do
  describe '#conversations' do
    it 'orders by last_activity_at desc and paginates' do
      user = instance_double(User)
      service = described_class.new({}, user)

      relation = double('Relation')
      service.instance_variable_set(:@conversations, relation)

      expect(relation).to receive(:sort_on_last_activity_at).with(:desc).and_return(relation)
      expect(relation).to receive(:page).with(1).and_return(relation)

      service.conversations
    end
  end

  describe '#filter_payload (key aliasing)' do
    let(:user) { instance_double(User) }
    let(:rows) do
      [{ 'attribute_key' => 'status', 'filter_operator' => 'equal_to', 'values' => ['open'], 'query_operator' => nil }]
    end

    it 'reads rows from :payload (upstream Chatwoot contract)' do
      service = described_class.new({ payload: rows }, user)
      expect(service.send(:filter_payload)).to eq(rows)
    end

    it 'reads rows from :filters as a compat alias for the evo frontend' do
      service = described_class.new({ filters: rows }, user)
      expect(service.send(:filter_payload)).to eq(rows)
    end

    it 'returns an empty array when neither key is provided, avoiding NoMethodError' do
      service = described_class.new({}, user)
      expect(service.send(:filter_payload)).to eq([])
      expect { service.send(:validate_query_operator) }.not_to raise_error
    end
  end
end
