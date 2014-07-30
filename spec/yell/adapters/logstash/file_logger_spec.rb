require 'spec_helper'

describe Yell::Adapters::Logstash::FileLogger do

  let(:logger) { Yell::Logger.new }

  context 'a new instance' do
    subject { Yell::Adapters::Logstash::FileLogger.new }

    it 'has sync defaulted to true' do
      expect(subject.sync).to eq(true)
    end
  end

  context :write do
    let(:event) { Yell::Event.new(logger, 1, 'Hello World') }
    let(:adapter) { Yell::Adapters::Logstash::FileLogger.new }

    after(:each) {
      adapter.write(event)
    }

    it 'contains the appropriate structure' do
      expect(LogStash::Event).to receive(:new) do |data|
        expect(data.keys).to  eq(%w(@version @timestamp fields tags))
        expect(data['fields']).to include('message', 'severity', 'hostname', 'progname', 'pid', 'thread_id', '_file', '_line', '_method')
        expect(data['tags']).to include('environment', 'severity')
      end
    end

    it 'contains the appropriate data' do
      expect(LogStash::Event).to receive(:new) do |data|
        expect(data['fields']['severity']).to eq(Yell::Severities[event.level])
        expect(data['fields']['message']).to eq(event.messages.first)
        expect(data['fields']['hostname']).to eq(event.hostname)
        expect(data['fields']['progname']).to eq(event.progname)
        expect(data['fields']['pid']).to eq(event.pid)
        expect(data['fields']['thread_id']).to eq(event.thread_id)
        expect(data['fields']['_file']).to eq(event.file)
        expect(data['fields']['_line']).to eq(event.line)
        expect(data['fields']['_method']).to eq(event.method)
        expect(data['tags']['environment']).to eq(Yell.env)
        expect(data['tags']['severity']).to eq(Yell::Severities[event.level])
        expect(data['@version']).to eq(1)
        expect(data['@timestamp']).to eq(event.time)
      end
    end

    context 'with a hash' do
      let(:event) { Yell::Event.new(logger, 1, { 'message' => 'This', '_custom_field' => 'is Hash'}) }

      it 'contains the appropriate structure' do
        expect(LogStash::Event).to receive(:new) do |data|
          expect(data['fields']).to include('_custom_field')
        end
      end

      it 'contains the appropriate data' do
        expect(LogStash::Event).to receive(:new) do |data|
          expect(data['fields']['message']).to eq('This')
          expect(data['fields']['_custom_field']).to eq('is Hash')
        end
      end

    end

    context 'with exception' do
      let(:exception) { StandardError.new('This is an error') }
      let(:event) { Yell::Event.new(logger, 1, exception) }

      before {
        allow(exception).to receive(:backtrace).and_return([:back, :trace])
      }

      it 'contains the appropriate structure' do
        expect(LogStash::Event).to receive(:new) do |data|
          expect(data['fields']).to include('backtrace')
        end
      end


      it 'contains the appropriate data' do
        expect(LogStash::Event).to receive(:new) do |data|
          expect(data['fields']['message']).to eq(%Q(#{exception.class}: #{exception.message}))
          expect(data['fields']['backtrace']).to eq(%Q(back\ntrace))
        end
      end

    end
  end

end