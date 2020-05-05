# frozen_string_literal: true

RSpec.describe TransitionsListener::Listener do
  let(:inst) { described_class.new(:state) {} }
  let(:states) { { active: :inactive } }
  let(:model) { double('Model') }

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
        inst.before_transition(from: any, to: any) {}
        trans = filter_transitions(:active, :inactive)
        expect(trans.any?).to be_truthy
      end

      it 'filter state to another state' do
        inst.before_transition(from: :active, to: :inactive) {}
        trans = filter_transitions(:active, :inactive)
        expect(trans.any?).to be_truthy
      end

      it 'filter state to any' do
        inst.before_transition(from: :active, to: any) {}
        trans = filter_transitions(:active, :inactive)
        expect(trans.any?).to be_truthy
      end

      it 'filter any to state' do
        inst.before_transition(from: any, to: :inactive) {}
        trans = filter_transitions(:active, :inactive)
        expect(trans.any?).to be_truthy
      end

      it 'filter multiple states' do
        states = [{ from: :active, to: :inactive },
                  { from: :inactive, to: :deleted }]
        inst.before_transition(states) {}
        trans = filter_transitions(:active, :inactive)
        expect(trans.any?).to be_truthy
        trans = filter_transitions(:inactive, :deleted)
        expect(trans.any?).to be_truthy
      end

      it 'filter many to many states' do
        states = [{ from: %i[active inactive], to: %i[deleted restored] }]
        inst.before_transition(states) {}
        expect(filter_transitions(:active, :deleted).any?).to be_truthy
        expect(filter_transitions(:inactive, :restored).any?).to be_truthy
        expect(filter_transitions(:invalid, :deleted).any?).to be_falsey
        expect(filter_transitions(:active, :invalid).any?).to be_falsey
      end

      it 'shorter state definitions' do
        states = { active: :inactive, deleted: :restored }
        inst.before_transition(states) {}
        expect(filter_transitions(:active, :inactive).any?).to be_truthy
        expect(filter_transitions(:deleted, :restored).any?).to be_truthy
        expect(filter_transitions(:active, :restored).any?).to be_falsey
      end

      describe 'conditions' do
        describe ':if' do
          it 'true' do
            allow(model).to receive(:success?).and_return(true)
            inst.before_transition({ from: any, to: any }, if: :success?) {}
            trans = filter_transitions(:active, :inactive)
            expect(trans.any?).to be_truthy
          end

          it 'false' do
            allow(model).to receive(:success?).and_return(false)
            inst.before_transition({ from: any, to: any }, if: :success?) {}
            trans = filter_transitions(:active, :inactive)
            expect(trans.any?).to be_falsey
          end
        end

        describe ':unless' do
          it 'true' do
            allow(model).to receive(:success?).and_return(false)
            inst.before_transition({ from: any, to: any }, unless: :success?) {}
            trans = filter_transitions(:active, :inactive)
            expect(trans.any?).to be_truthy
          end

          it 'false' do
            allow(model).to receive(:success?).and_return(true)
            inst.before_transition({ from: any, to: any }, unless: :success?) {}
            trans = filter_transitions(:active, :inactive)
            expect(trans.any?).to be_falsey
          end
        end
      end
    end

    describe 'after transitions' do
      it 'filter any to any' do
        inst.after_transition(any => any) {}
        trans = filter_transitions(:active, :inactive, kind: :after)
        expect(trans.any?).to be_truthy
      end
    end
  end

  def any
    inst.send(:any)
  end

  private

  def filter_transitions(from, to, kind: :before)
    inst.filter_transitions(kind, model, from: from, to: to)
  end
end
