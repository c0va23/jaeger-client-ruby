require 'spec_helper'

RSpec.describe Jaeger::Client::SpanContext do
  describe '.create_from_parent_context' do
    let(:parent) do
      described_class.new(
        trace_id: trace_id,
        parent_id: nil,
        span_id: parent_span_id,
        flags: parent_flags
      )
    end
    let(:trace_id) { 'trace-id' }
    let(:parent_span_id) { 'span-id' }
    let(:parent_flags) { described_class::Flags::SAMPLED }

    it 'has same trace ID' do
      context = described_class.create_from_parent_context(parent)
      expect(context.trace_id).to eq(trace_id)
    end

    it 'has same parent span id as parent id' do
      context = described_class.create_from_parent_context(parent)
      expect(context.parent_id).to eq(parent_span_id)
    end

    it 'has same its own span id' do
      context = described_class.create_from_parent_context(parent)
      expect(context.span_id).not_to eq(parent_span_id)
    end

    it 'has parent flags' do
      context = described_class.create_from_parent_context(parent)
      expect(context.flags).to eq(parent_flags)
    end
  end

  describe '.create_from_parent_context' do
    context 'when sampler returns true' do
      let(:sampler) { Jaeger::Client::Samplers::Const.new(true) }

      it 'marks context as sampled' do
        context = described_class.create_parent_context(sampler)
        expect(context).to be_sampled
      end
    end

    context 'when sampler returns false' do
      let(:sampler) { Jaeger::Client::Samplers::Const.new(false) }

      it 'marks context as not sampled' do
        context = described_class.create_parent_context(sampler)
        expect(context).not_to be_sampled
      end
    end
  end

  describe '#to_trace_id' do
    it 'returns trace id in hex format' do
      span_context = build_span_context(trace_id: 67_667_974_448_284_343)
      expect(span_context.to_trace_id).to eq('f067aa0ba902b7')
    end
  end

  describe '#to_span_id' do
    it 'returns span id in hex format' do
      span_context = build_span_context(span_id: 67_667_974_448_284_343)
      expect(span_context.to_span_id).to eq('f067aa0ba902b7')
    end
  end

  def build_span_context(opts)
    described_class.new({
      trace_id: Jaeger::Client::TraceId.generate,
      span_id: Jaeger::Client::TraceId.generate,
      flags: 0
    }.merge(opts))
  end
end
