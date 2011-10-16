use Test::More;
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

subtest "A subscription made through the helper goes away when the subscriber does" => sub {
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

done_testing;
