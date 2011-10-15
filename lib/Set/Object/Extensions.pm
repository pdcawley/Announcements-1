package Set::Object::Extensions;
# Monkey patching is bad, m'kay?
use Set::Object;

unless ( Set::Object->can('grep') ) {
    *Set::Object::grep = sub {
        my($self, $selector) = @_;
        ref($self)->new(
            grep { $_->$selector() } $self->members
        )
    }
}

unless ( Set::Object->can('each') ) {
    *Set::Object::each = sub {
        my($self, $code) = @_;
        $_->$code() foreach $self->members
    }
}

unless ( Set::Object->can('map') ) {
    *Set::Object::map = sub {
        my($self, $code) = @_;
        ref($self)->new(
            map { $_->code() } $self->members
        )
    }
}

1;
