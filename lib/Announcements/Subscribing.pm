package Announcements::Subscribing;
use Moose::Role;

sub subscribe {
    my($self, %params) = @_;
    $params{from}->add_subscription(
        when => $params{to},
        do   => $params{do},
        for  => $self,
    );
}

1;
