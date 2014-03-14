require_relative '../lib/observable_roles'

class DummyPublisher
  include ObservableRoles::Publisher
end

class DummySubscriber
  attr_accessor :gender
  include ObservableRoles::Subscriber
  set_observed_publisher_callbacks(
    kitty: { myau: -> (me, data) { puts "I'm a #{me.gender}, I hear kitten said #{data}" }}
  )
end

subscriber1        = DummySubscriber.new
subscriber2        = DummySubscriber.new
publisher          = DummyPublisher.new
publisher.role = :kitty
subscriber1.gender = 'female'
subscriber2.gender = 'male'

publisher.subscribe(subscriber1)
publisher.subscribe(subscriber2)

publisher.publish_event(:myau, "saying myau") { |subscriber| subscriber.gender == 'female' }
