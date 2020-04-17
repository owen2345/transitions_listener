# frozen_string_literal: true

module TransitionsListener
  class Listener
    attr_accessor :attr
    def initialize(attr, &block)
      @attr = attr
      instance_eval(&block)
    end

    def before_transition(states, &block)
      before_transitions(states: states, block: block)
    end

    def after_transition(states, &block)
      after_transitions(states: states, block: block)
    end

    def filter_transitions(kind, from:, to:)
      transitions = kind == :before ? before_transitions : after_transitions
      transitions.select do |transition|
        match_states?(transition[:states], from, to)
      end
    end

    private

    def match_states?(states, from_state, to_state)
      parse_states(states).any? do |t_from, t_to|
        (t_from == [any] || t_from.include?(from_state.to_s)) &&
          (t_to == [any] || t_to.include?(to_state.to_s))
      end
    end

    def any
      'any_transition_key'
    end

    def before_transitions(transition = nil)
      @before_transitions ||= []
      @before_transitions << transition if transition
      @before_transitions
    end

    def after_transitions(transition = nil)
      @after_transitions ||= []
      @after_transitions << transition if transition
      @after_transitions
    end

    def parse_states(states)
      states.map do |from, to|
        from = [from] unless from.is_a? Array
        to = [to] unless to.is_a? Array
        [from.map(&:to_s), to.map(&:to_s)]
      end.to_h
    end
  end
end
