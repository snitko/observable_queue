require_relative '../lib/observable_roles'

class DummySubscriber
  include ObservableRoles::Subscriber
  set_observed_publisher_callbacks(
    kitty: { myau: -> (me, data) { puts data }}
  )
end

class DummyPublisher
  include ObservableRoles::Publisher
end

subscriber     = DummySubscriber.new
publisher      = DummyPublisher.new
publisher.role = :kitty
publisher.subscribe(subscriber)


publisher.publish_event(:myau, "saying myau")
