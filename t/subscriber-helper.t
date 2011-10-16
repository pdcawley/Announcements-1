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

    package ButtonWatcher;
    use Moose;
    with 'Announcements::Subscribing';
}

use Test::Routine;
use Test::Routine::Util;

use Test::More;

with 'Announcements::Subscribing';

test "Subscribing using the subscriber helper methods sets 'for'" => sub {
    my $self = shift;

    my $button = Button->new;
    my $count = 0;

    my $subscriber = ButtonWatcher->new;

    $subscriber->subscribe(
        to   => 'PushedButton',
        from => $button,
        do   => sub { $count++ },
    );

    $button->push;
    is $count, 1;
    $subscriber = undef;
    $button->push;
    is $count, 1;
};

run_me;
done_testing;
