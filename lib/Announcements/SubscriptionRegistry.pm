package Announcements::SubscriptionRegistry;
use Moose;
use Announcements::Subscription;
use Announcements::Types qw(SubscriptionSet);

has _subscriptions => (
    is      => 'ro',
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

    $announcement = $announcement->as_announcement;

    $self->_foreach_subscription(sub {
        $_->send($announcement, $announcer);
    });
}

sub unsubscribe {
    my $self = shift;
    my $subscription = shift;
    $self->_delete_subscription( $subscription );
    $subscription->_leave_registry($self);
}

1;

__END__

=head1 NAME

Announcements::SubscriptionRegistry - a registry for an object's subscriptions

=cut

