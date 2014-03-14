module ObservableRoles

  module Subscriber

    module ClassMethods
      def set_observed_publisher_callbacks(callbacks)
        @observed_publisher_callbacks = callbacks
      end
      def get_observed_publisher_callbacks
        @observed_publisher_callbacks
      end
    end

    def self.included(base)
      attr_accessor :subscriber_lock
      attr_reader   :captured_observable_events
      base.extend(ClassMethods)
    end

    def capture_observable_event(role, event_name, data={})
      return     if role.nil? || event_name.nil?
      role       = role.to_sym
      event_name = event_name.to_sym
      if self.class.get_observed_publisher_callbacks.nil? || self.class.get_observed_publisher_callbacks[role].nil? || self.class.get_observed_publisher_callbacks[role][event_name].nil?
        return
      end

      @captured_observable_events ||= []
      @captured_observable_events.push({ callback: self.class.get_observed_publisher_callbacks[role][event_name], data: data })
      release_captured_events unless @subscriber_lock
    end


    private

      def release_captured_events
        @subscriber_lock = true
        while !@captured_observable_events.empty?
          e = @captured_observable_events.shift
          e[:callback].call(self, e[:data])
        end
        @subscriber_lock = false
      end

  end


  module Publisher

    def self.included(base)
      attr_accessor :role
    end

    def subscribe(s)
      @observing_subscriber = [] unless @observing_subscriber
      @observing_subscriber << s
    end

    def unsubscribe(s)
      unless @observing_subscriber.blank?
        @observing_subscriber.delete(s)
      end
    end

    def publish_event(event_name, data={})
      return unless @observing_subscriber
      @observing_subscriber.each do |s|
        if !block_given? || yield(s)
          s.capture_observable_event(role, event_name, data)
        end
      end
    end

  end

end
