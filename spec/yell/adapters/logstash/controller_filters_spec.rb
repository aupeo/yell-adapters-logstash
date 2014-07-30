require 'spec_helper'

describe Yell::Adapters::Logstash::ControllerFilters do

  class FakeController

  end

  class OverrideController

    def yell_adapter_logstash_fields(_)
      {
          '_custom_field_1' => 1,
          '_custom_field_2' => 2
      }
    end

    def yell_adapter_logstash_tags(_)
      {
          '_custom_tag_1' => 1,
          '_custom_tag_2' => 2
      }
    end
  end

  context 'default behaviour' do
    let(:ctrlr){ FakeController.new }

    it 'stores default values' do
      allow(Yell::Adapters::Logstash::ControllerFilters).to receive(:yell_adapter_logstash_fields).and_return({})
      allow(Yell::Adapters::Logstash::ControllerFilters).to receive(:yell_adapter_logstash_tags).and_return({})

      expect(ctrlr).to receive(:respond_to?).exactly(2).times.and_call_original

      Yell::Adapters::Logstash::ControllerFilters.send(:before, ctrlr)

      expect(Thread.current[:yell_adapter_logstash_fields]).not_to be_nil
      expect(Thread.current[:yell_adapter_logstash_fields]).to be_a_kind_of(Hash)
      expect(Thread.current[:yell_adapter_logstash_fields].keys).to be_empty

      expect(Thread.current[:yell_adapter_logstash_tags]).not_to be_nil
      expect(Thread.current[:yell_adapter_logstash_tags]).to be_a_kind_of(Hash)
      expect(Thread.current[:yell_adapter_logstash_tags].keys).to be_empty
    end
  end

  context 'overriden behaviour' do
    let(:ctrlr){ OverrideController.new }

    it 'stores default values' do
      expect(ctrlr).to receive(:respond_to?).exactly(2).times.and_call_original

      Yell::Adapters::Logstash::ControllerFilters.send(:before, ctrlr)

      expect(Thread.current[:yell_adapter_logstash_fields]).not_to be_nil
      expect(Thread.current[:yell_adapter_logstash_fields]).to be_a_kind_of(Hash)
      expect(Thread.current[:yell_adapter_logstash_fields].keys).to eq(%w(_custom_field_1 _custom_field_2))

      expect(Thread.current[:yell_adapter_logstash_tags]).not_to be_nil
      expect(Thread.current[:yell_adapter_logstash_tags]).to be_a_kind_of(Hash)
      expect(Thread.current[:yell_adapter_logstash_tags].keys).to eq(%w(_custom_tag_1 _custom_tag_2))
    end
  end

end