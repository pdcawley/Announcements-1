package Announcements::SubscriptionRegistry;
use Moose;
use Announcements::Subscription;
use Announcements::Types qw(SubscriptionSet);

has _subscriptions => (
    is      => '',
    isa     => SubscriptionSet,
    default => sub { to_SubscriptionSet([]) },
    coerce  => 1,
    lazy    => 1,
    handles => {
        _add_subscription      => 'insert',
        _delete_subscription   => 'remove',
        _foreach_subscription  => 'each',
    },
);

sub add_subscription {
    my $self = shift;
    my $subscription = $_[0];

    # autoreify add_subscription(foo => 1, bar => 2)
    if (!ref($subscription)) {
        $subscription = Announcements::Subscription->new(@_);
    }

    $self->_add_subscription($subscription);
    $subscription->_join_registry($self);

    return $subscription;
}

sub announce {
    my $self         = shift;
    my $announcement = shift;
    my $announcer    = shift;

    # autoreify an announcement class name
    $announcement = $announcement->new if !ref($announcement);

    $self->_foreach_subscription(sub {
        $_->send($announcement, $announcer);
    });
}

sub _subscriptions_for {
    my $self = shift;
    my $subscriber = shift;

    my @subs = @_;
    $self->_foreach_subscription(sub {
        my $for = $_->for;
        push @subs, $_ if $for && $for == $subscriber;
    });
    return @subs;
}

sub _to_subscriptions {
    my $self = shift;
    return @_ if blessed $_[0] && $_[0]->isa('Announcements::Subscription');
    my $subscriber = shift;
    $self->_subscriptions_for($subscriber);
}

sub unsubscribe {
    my $self = shift;
    my @subscriptions = $self->_to_subscriptions(shift);

    foreach my $subscription (@subscriptions) {
        $self->_delete_subscription( $subscription );
        $subscription->_leave_registry($self);
    }
}

1;

__END__

=head1 NAME

Announcements::SubscriptionRegistry - a registry for an object's subscriptions

=cut

