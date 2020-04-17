# frozen_string_literal: true

require 'transitions_listener/version'
require 'transitions_listener/listener'

module TransitionsListener
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      before_update do
        self.class.perform_transition_listeners(self, :before)
      end

      after_update_commit do
        self.class.perform_transition_listeners(self, :after)
      end
    end
  end

  module ClassMethods
    def listen_transitions(attr, &block)
      transition_listeners(TransitionsListener::Listener.new(attr, &block))
    end

    def perform_transition_listeners(model, kind = :before)
      transition_listeners.each do |listener|
        c_transition = current_transition_for(model, listener.attr)
        listener.filter_transitions(kind, c_transition).each do |transition|
          transition[:block].call(model, c_transition.merge(transition))
        end
      end
    end

    private

    def transition_listeners(listener = nil)
      @transition_listeners ||= []
      @transition_listeners << listener if listener
      @transition_listeners
    end

    def current_transition_for(model, attr)
      to = model.send(attr)
      from = model.send("#{attr}_was")
      unless model.changed?
        previous = model.send("#{attr}_previous_change")
        from = previous.nil? ? to : previous.first
      end
      { from: from, to: to }
    end
  end
end
