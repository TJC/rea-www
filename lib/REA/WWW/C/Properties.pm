package REA::WWW::C::Properties;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use REA::Scraper;

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

    $c->forward('check_cache');
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

=head2 check_cache

Check that the cache for this location is fresh.

=cut

sub check_cache :Private {
    my ($self, $c) = @_;

    my $count = $c->stash->{properties}->count;
    if ($count == 0) {
        $c->log->info('Cache is empty, refreshing');
        $c->forward('refresh_cache');
        return;
    }

    # Check timestamp of first property, then reset the iterator.
    my $newest = $c->stash->{properties}->next->created;
    if ($newest < DateTime->now->subtract(hours => 8)) {
        $c->log->info('Cache is out of date, refreshing');
        $c->forward('refresh_cache');
        $c->stash->{properties}->reset;
        return;
    }
    $c->log->debug('Cache seems up to date.');
}

=head2 refresh_cache

Update the cache for this area..

=cut

sub refresh_cache :Private {
    my ($self, $c) = @_;
    return unless $c->stash->{location} =~ /^(\d{4}$)/;
    # Only works with postcodes for the moment..

    my $scraper = REA::Scraper->new( storage => $c->model('DB')->schema );
    $scraper->postcode($c->stash->{location});
    my $count = $scraper->scrape;
    $c->log->info("Scraped $count properties");
}


=head1 AUTHOR

Toby Corkindale

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
