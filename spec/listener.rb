# frozen_string_literal: true

RSpec.describe TransitionsListener::Listener do
  let(:inst) { described_class.new(:state) {} }
  let(:states) { { active: :inactive } }

  describe '.before_transition' do
    it 'add transition' do
      inst.before_transition(states) {}
      expect(inst.send(:before_transitions).count).to eq 1
    end
  end

  describe '.after_transition' do
    it 'add transition' do
      inst.after_transition(states) {}
      expect(inst.send(:after_transitions).count).to eq 1
    end
  end

  describe '.filter_transitions' do
    describe 'before transitions' do
      it 'filter any to any' do
        inst.before_transition(any => any) {}
        trans = inst.filter_transitions(:before, from: :active, to: :inactive)
        expect(trans.any?).to be_truthy
      end

      it 'filter active to inactive' do
        inst.before_transition(active: :inactive) {}
        trans = inst.filter_transitions(:before, from: :active, to: :inactive)
        expect(trans.any?).to be_truthy
      end

      it 'filter active to any' do
        inst.before_transition(active: any) {}
        trans = inst.filter_transitions(:before, from: :active, to: :inactive)
        expect(trans.any?).to be_truthy
      end

      it 'filter any to inactive' do
        inst.before_transition(any => :inactive) {}
        trans = inst.filter_transitions(:before, from: :active, to: :inactive)
        expect(trans.any?).to be_truthy
      end

      it 'filter many to many states' do
        inst.before_transition(%i[active inactive] => %i[deleted restored]) {}
        trans = inst.filter_transitions(:before, from: :active, to: :deleted)
        expect(trans.any?).to be_truthy
        trans = inst.filter_transitions(:before, from: :inactive, to: :restored)
        expect(trans.any?).to be_truthy
        trans = inst.filter_transitions(:before, from: :invalid, to: :deleted)
        expect(trans.any?).to be_falsey
        trans = inst.filter_transitions(:before, from: :active, to: :invalid)
        expect(trans.any?).to be_falsey
      end
    end

    describe 'after transitions' do
      it 'filter any to any' do
        inst.after_transition(any => any) {}
        trans = inst.filter_transitions(:after, from: :active, to: :inactive)
        expect(trans.any?).to be_truthy
      end
    end
  end

  def any
    inst.send(:any)
  end
end
