package Announcements::Types;
use MooseX::Types -declare => [qw(SubscriptionSet RegistrySet SubscriptionRegistry)];
use MooseX::Types::Moose qw(ArrayRef);

use Set::Object qw(set weak_set);
use Set::Object::Extensions; # Add grep/map/each methods to Set::Object

class_type SubscriptionSet, { class => 'Set::Object' };
class_type RegistrySet, { class => 'Set::Object::Weak' };

coerce SubscriptionSet,
    from ArrayRef,
    via { set( @$_ ) };

coerce RegistrySet,
    from ArrayRef,
    via { weak_set @$_ };

class_type SubscriptionRegistry,
    { class => 'Announcements::SubscriptionRegistry' };

role_type 'Announcements::Announcing';
coerce SubscriptionRegistry,
    from 'Announcements::Announcing',
    via { $_->_subscription_registry };

1;
