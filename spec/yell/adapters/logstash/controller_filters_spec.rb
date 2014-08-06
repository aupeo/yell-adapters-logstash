require 'spec_helper'

describe Yell::Adapters::Logstash::ControllerFilters do

  class FakeController

  end

  class OverrideController

    def yell_adapter_logstash_fields_before(_)
      {
          '_custom_field_1' => 1,
          '_custom_field_2' => 2
      }
    end

    def yell_adapter_logstash_tags_before(_)
      {
          '_custom_tag_1' => 1,
          '_custom_tag_2' => 2
      }
    end

    def yell_adapter_logstash_fields_after(_)
      {
          '_custom_field_3' => 3,
          '_custom_field_4' => 4
      }
    end

    def yell_adapter_logstash_tags_after(_)
      {
          '_custom_tag_3' => 3,
          '_custom_tag_4' => 4
      }
    end
  end

  before(:each) do
    Thread.current[:yell_adapter_logstash_fields] = nil
    Thread.current[:yell_adapter_logstash_tags] = nil
  end

  context 'default behaviour' do
    let(:ctrlr){ FakeController.new }

    it 'stores default values for before filter' do
      allow(Yell::Adapters::Logstash::ControllerFilters).to receive(:yell_adapter_logstash_fields_before).and_return({})
      allow(Yell::Adapters::Logstash::ControllerFilters).to receive(:yell_adapter_logstash_tags_before).and_return({})

      expect(ctrlr).to receive(:respond_to?).exactly(2).times.and_call_original

      Yell::Adapters::Logstash::ControllerFilters.send(:before, ctrlr)

      expect(Thread.current[:yell_adapter_logstash_fields]).not_to be_nil
      expect(Thread.current[:yell_adapter_logstash_fields]).to be_a_kind_of(Hash)
      expect(Thread.current[:yell_adapter_logstash_fields].keys).to be_empty

      expect(Thread.current[:yell_adapter_logstash_tags]).not_to be_nil
      expect(Thread.current[:yell_adapter_logstash_tags]).to be_a_kind_of(Hash)
      expect(Thread.current[:yell_adapter_logstash_tags].keys).to be_empty
    end

    it 'stores default values for after filter' do

      allow(Yell::Adapters::Logstash::ControllerFilters).to receive(:yell_adapter_logstash_fields_after).and_return({})
      allow(Yell::Adapters::Logstash::ControllerFilters).to receive(:yell_adapter_logstash_tags_after).and_return({})

      expect(ctrlr).to receive(:respond_to?).exactly(2).times.and_call_original

      Yell::Adapters::Logstash::ControllerFilters.send(:after, ctrlr)

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

    it 'stores overridden values for before filter' do
      expect(ctrlr).to receive(:respond_to?).exactly(2).times.and_call_original

      Yell::Adapters::Logstash::ControllerFilters.send(:before, ctrlr)

      expect(Thread.current[:yell_adapter_logstash_fields]).not_to be_nil
      expect(Thread.current[:yell_adapter_logstash_fields]).to be_a_kind_of(Hash)
      expect(Thread.current[:yell_adapter_logstash_fields].keys).to eq(%w(_custom_field_1 _custom_field_2))

      expect(Thread.current[:yell_adapter_logstash_tags]).not_to be_nil
      expect(Thread.current[:yell_adapter_logstash_tags]).to be_a_kind_of(Hash)
      expect(Thread.current[:yell_adapter_logstash_tags].keys).to eq(%w(_custom_tag_1 _custom_tag_2))
    end

    it 'stores overridden values for after filter' do
      expect(ctrlr).to receive(:respond_to?).exactly(2).times.and_call_original

      Yell::Adapters::Logstash::ControllerFilters.send(:after, ctrlr)

      expect(Thread.current[:yell_adapter_logstash_fields]).not_to be_nil
      expect(Thread.current[:yell_adapter_logstash_fields]).to be_a_kind_of(Hash)
      expect(Thread.current[:yell_adapter_logstash_fields].keys).to eq(%w(_custom_field_3 _custom_field_4))

      expect(Thread.current[:yell_adapter_logstash_tags]).not_to be_nil
      expect(Thread.current[:yell_adapter_logstash_tags]).to be_a_kind_of(Hash)
      expect(Thread.current[:yell_adapter_logstash_tags].keys).to eq(%w(_custom_tag_3 _custom_tag_4))
    end
  end

end