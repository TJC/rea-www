package REA::WWW::C::Properties;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

REA::WWW::C::Properties

=head1 DESCRIPTION

Display properties.

=head1 METHODS

=cut

=head2 properties

Initial chain point..

=cut

sub properties :Chained CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub postcode :Chained('properties') PathPart('postcode') CaptureArgs(1) {
    my ($self, $c, $code) = @_;
    if ($code !~ /^\d{4}$/) {
        return $c->error("Invalid postcode: $code");
    }
    $c->stash->{properties} = $c->model('DB::Properties')->search(
        { postcode => $code },
        { order_by => 'created DESC' }
    );
    $c->stash->{location} = "$code";
}

sub suburb :Chained('properties') PathPart('suburb') CaptureArgs(1) {
    my ($self, $c, $suburb) = @_;
    if ($suburb !~ /^[a-zA-Z ]+$/) {
        return $c->error("Invalid suburb: $suburb");
    }
    $c->stash->{properties} = $c->model('DB::Properties')->search(
        { suburb => uc($suburb) },
        { order_by => 'created DESC' }
    );
    $c->stash->{location} = "$suburb";
}

sub list :Chained('postcode') PathPart('') :Args(0) {
    my ($self, $c) = @_;
}

# Ugh, WTF, there must be a way to link this to both suburb AND postcode?
sub list2 :Chained('suburb') PathPart('') :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{template} = 'properties/list.tt';
}

sub rss :Chained('postcode') PathPart('rss') :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{current_view} = 'RSS';
}

sub rss2 :Chained('suburb') PathPart('rss') :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{current_view} = 'RSS';
}

sub property :Chained CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $id = int($id);
    $c->stash->{property} = $c->model('DB::Properties')->find($id)
        or $c->forward('/fourohfour');
}

sub details :Chained('property') PathPart('') :Args(0) {
    my ($self, $c) = @_;

}

=head1 AUTHOR

Toby Corkindale

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
