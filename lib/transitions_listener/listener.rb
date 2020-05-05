# frozen_string_literal: true

module TransitionsListener
  class Listener
    attr_accessor :attr
    def initialize(attr, &block)
      @attr = attr
      instance_eval(&block)
    end

    # @param states: (Array) Array of transitions [{ from:, to: }, {}, ...]
    #   Multiple transitions: [{ from: [..], to: [..] }, ...]
    #   Single transitions: [{ from: :state, to: :new_state }, ...]
    #   Single transition: { from: :state, to: :new_state }
    # @param args (Hash): { callback: nil, if: nil, unless: nil }
    #   callback: (Sym) Method name to be used as the callback
    #   if: (Sym) conditional methods
    #   else: (Sym) conditional methods
    def before_transition(states, args = {}, &block)
      args[:callback] ||= block if block
      before_transitions(states: parse_states(states), args: args)
    end

    # @param states (Array): Same as before transitions
    # @param args (Hash): Same as before args
    def after_transition(states, args = {}, &block)
      args[:callback] ||= block if block
      after_transitions(states: parse_states(states), args: args)
    end

    def filter_transitions(kind, model, from:, to:)
      transitions = kind == :before ? before_transitions : after_transitions
      transitions.select do |transition|
        match_conditions?(model, transition) &&
          match_states?(transition, from, to)
      end
    end

    private

    def match_states?(transition, from_state, to_state)
      transition[:states].any? do |state|
        t_from = state[:from]
        t_to = state[:to]
        (t_from == [any] || t_from.include?(from_state.to_s)) &&
          (t_to == [any] || t_to.include?(to_state.to_s))
      end
    end

    def match_conditions?(model, transition)
      args = transition[:args]
      yes_actions = Array(args[:if])
      no_actions = Array(args[:unless])
      return false unless yes_actions.all? { |action| model.send(action) }
      return false unless no_actions.all? { |action| !model.send(action) }

      true
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
      is_shorter_definition = states.is_a?(Hash) && !states[:from]
      states = states.map { |k, v| { from: k, to: v } } if is_shorter_definition
      is_single_definition = !states.is_a?(Array)
      states = [states] if is_single_definition
      states.map do |trans|
        from = Array(trans[:from]).map(&:to_s)
        to = Array(trans[:to]).map(&:to_s)
        { from: from, to: to }
      end
    end
  end
end
