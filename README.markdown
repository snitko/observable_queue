Observable Roles
===============================================================================
Thread safe implementation of the Observable pattern which also supports roles.


## Installation

    gem install observable_roles


## Usage

Let's start with an example. First, create two classes:

    class DummySubscriber
      include ObservableRoles::Subscriber
    end

    class DummyPublisher
      include ObservableRoles::Publisher
    end

And now create objects out of them and connect them:

    subscriber     = DummySubscriber.new
    publisher      = DummyPublisher.new
    publisher.role = :kitty
    publisher.subscribe(subscriber)

Let's try triggering an event:

    publisher.publish_event(:myau, "saying myau")

And nothing is going to happen. Why? Because `subscriber` cannot yet handle kitty events.
He knows nothing about kittens, so even though he is subscribed to that kitty, he ignores it.
Let's help him learn:

    class DummySubscriber
      set_observed_publisher_callbacks(
        kitty: { myau: -> (me, data) { puts data }}
      )
    end

`me` in this case is a reference to the object which you might or might not need and `data`
holds some arbitrary data that an event passes (in this case, a String). Now let's see if it works:

    publisher.publish_event(:myau, "saying myau") # => saying myau 

You can also control which subscriber are getting notified from the publisher itself. Of course,
the publisher doesn't need to who the subscribers are, but may simply rely on some characteristics,
essentially using polymorphism. Suppose we only want women to be notified when a kitten myaus, because
men are too busy hunting. We'll then do this:


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
    publisher.role     = :kitty
    subscriber1.gender = 'female'
    subscriber2.gender = 'male'

    publisher.subscribe(subscriber1)
    publisher.subscribe(subscriber1)

    publisher.publish_event(:myau, "saying myau") { |subscriber| subscriber.gender == 'female' }

This will result in only output:

    I'm a female, I hear kitten said myau


Both of these examples can be found in `/examples`.

## The following will be a short, but somewhat deeper explanation of the implementation

You have two objects: one is a Subscriber, another one is a Publisher.
You subscribe a Subscriber to the Publisher events with a Publisher#subscribe.
However the Subscriber would still ignore anything that Publisher publishes.

In order for it to be notified of the events, you must define callbacks with
Subscriber.set_observed_publisher_callbacks. These callbacks have the following form:

    role_name: { event_name: -> (me, data) { } }

where `me` is a reference to the Subscriber object and `data` is a hash of some info
that is passed from the Publisher.

Now `role_name` is a role of the Pubslisher, which can be set as follows:

    publisher.role = :good_cop

Obviously, each role may have many different events and those events may come from various
publishers who play the same role. This approach is more flexible than the standard Observer pattern,
since it allows easy many-to-many relationship to be established.

## Thread safety

Each new event that has a callback doesn't execute this callback immediately after said event is caught.
Instead, it is added into a queue of events, which are then executed one by one. This ensures that each event callback execution doesn't interfere with the other.
