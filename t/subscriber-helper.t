use strict;
use warnings;

{
    package PushedButton;
    use Moose;

    package Button;
    use Moose;
    with 'Announcements::Announcing';

    sub push {
        my $self = shift;

        $self->announce(PushedButton->new);
    }

}

use Test::Routine;
use Test::Routine::Util;

use Test::More;

with 'Announcements::Subscribing';

test "Subscribing using the subscriber helper methods sets 'for'" => sub {
    my $self = shift;

    my $button = Button->new;

    $self->subscribe(
        to   => 'PushedButton',
        from => $button,
        do   => sub {
            my($announcement, $announcer, $subscription) = @_;
            is $subscription->subscriber, $self
        },
    );
    $button->push;
};

run_me;
done_testing;
