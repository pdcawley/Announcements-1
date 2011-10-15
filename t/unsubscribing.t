use Test::More;
use strict;
use warnings;
use Announcements::Subscription;
use Test::Fatal;

{
    package PushedButton;
    use Moose;
    extends 'Announcements::Announcement';
    with 'Announcements::Announcing';

    sub push {
        my $self = shift;

        $self->announce(PushedButton->new);
    }
}

subtest "Basic unsubscription" => sub {
    my $nuke = PushedButton->new;
    my $announcement_count = 0;

    ok my $subscription = $nuke->add_subscription(
        when => 'PushedButton',
        do => sub {
            $announcement_count++;
        }
    );

    isa_ok $subscription, 'Announcements::Subscription', '$nuke->add_subscription(...)';

    $nuke->push;

    is $announcement_count, 1;

    $subscription->unsubscribe;

    $nuke->push;

    is $announcement_count, 1;
};

subtest "do_once" => sub {
    my $nuke = PushedButton->new;
    my $announcement_count = 0;

    ok $nuke->add_subscription(
        when => 'PushedButton',
        do_once => sub {
            $announcement_count++;
        }
    );

    $nuke->push;
    $nuke->push;

    is $announcement_count, 1;
};

subtest "Do, or do_once, there is no confusion" => sub {
    isnt(
        exception {
            Announcements::Subscription->new(
                when => 'PushedButton',
                do => sub { 'one thing' },
                do_once => sub { 'or the other' },
            )
        },
        undef,
        "Two params enter, one param leaves"
    )
};

subtest "Double subscription is wrong, m'kay?" => sub {
    my $nuke = PushedButton->new;
    my $announcement_count = 0;

    ok my $subscription = $nuke->add_subscription(
        when => 'PushedButton',
        do => sub {
            $announcement_count++;
        }
    );

    isa_ok $subscription, 'Announcements::Subscription', '$nuke->add_subscription(...)';
    $nuke->add_subscription($subscription);

    $nuke->push;
    is $announcement_count, 1, "Subscriptions only fire once per announcement";
};

subtest "One Subscription can subscribe to multiple announcers" => sub {
    my $red_button = PushedButton->new;
    my $green_button = PushedButton->new;

    my $guilty_party;

    my $subscription = Announcements::Subscription->new(
        when => 'PushedButton',
        do => sub {
            my($announcement, $announcer) = @_;
            $guilty_party = $announcer;
        },
    );

    $red_button->add_subscription($subscription);
    $green_button->add_subscription($subscription);

    $red_button->push;
    is $guilty_party, $red_button, "RED";
    $green_button->push;
    is $guilty_party, $green_button, "GREEN";

    $guilty_party = "NOTHING";

    $subscription->unsubscribe;
    $red_button->push;
    is $guilty_party, "NOTHING", "I got nothing";

    $guilty_party = "NOTHING";
    $green_button->push;
    is $guilty_party, "NOTHING", "Still nothing";
};

subtest "Unsubscribing from one announcer at a time" => sub {
    local $TODO = "Wouldn't it be cool if this worked?";
    
    my $red_button = PushedButton->new;
    my $green_button = PushedButton->new;

    my $guilty_party;

    my $subscription = Announcements::Subscription->new(
        when => 'PushedButton',
        do => sub {
            my($announcement, $announcer, $subscription) = @_;
            $guilty_party = $announcer;
            $subscription->unsubscribe_from($announcer);
        },
    );

    $red_button->add_subscription($subscription);
    $green_button->add_subscription($subscription);

    $red_button->push;
    is $guilty_party, $red_button, "RED";

    $guilty_party = "NOTHING";

    $red_button->push;

    is $guilty_party, "NOTHING", "The Red button only works once!";

    $green_button->push;
    is $guilty_party, $green_button, "GREEN";

    $guilty_party = "NOTHING";

    $red_button->push;
    is $guilty_party, "NOTHING", "Nope, Red still doesn't work!";

    $guilty_party = "NOTHING";
    $green_button->push;
    is $guilty_party, "NOTHING", "And nor does green. This machine sucks!";
};


done_testing;


