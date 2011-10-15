package Announcements::Subscription;
use Moose;

use Announcements::Types qw(RegistrySet to_SubscriptionRegistry);

has when => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
    documentation => 'a class or role name to filter announcements',
);

has do => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

has for => (
    is => 'ro',
    isa => 'Ref',
);

has _registry => (
    is       => 'rw',
    isa      => RegistrySet,
    coerce   => 1,
    init_arg => undef,
    default  => sub { to_RegistrySet([]) },
    handles  => {
        _foreach_registry => 'each',
        _leave_registry   => 'remove',
        _join_registry    => 'insert',
        is_in             => 'member',
    }
);

sub BUILDARGS {
    my $class = shift;
    my $params = $class->SUPER::BUILDARGS(@_);

    if (my $oneshot = delete $params->{do_once}) {
        die "You can use 'do', or you can use 'do_once'. You cannot use both"
            if $params->{do};

        $params->{do} = sub {
            $_[2]->unsubscribe;
            $oneshot->(@_);
        };
    }
    return $params;
}



sub send {
    my $self         = shift;
    my $announcement = shift;
    my $announcer    = shift;

    return unless $self->matches($announcement, $announcer);

    $self->do->(
        $announcement,
        $announcer,
        $self,
    );
}

sub matches {
    my $self         = shift;
    my $announcement = shift;

    # in perl 5.10+, ->DOES defaults to just ->isa. but Moose enhances ->DOES
    # (and provides that default on 5.8) to include ->does_role
    return $announcement->DOES($self->when);
}

sub unsubscribe {
    my $self = shift;
    $self->_foreach_registry(sub { $self->unsubscribe_from($_) });
}

sub unsubscribe_from {
    my $self = shift;
    my $registry = to_SubscriptionRegistry shift;

    $registry->unsubscribe($self);
}

1;

__END__

=head1 NAME

Announcements::Subscription - a subscription to a class of announcements

=cut

