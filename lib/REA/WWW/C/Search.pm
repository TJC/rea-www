package REA::WWW::C::Search;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use REA::Searcher;

=head1 NAME

REA::WWW::C::Search

=head1 DESCRIPTION

Handles searching of the properties.

=head1 METHODS

=cut

=head2 search

Perform a search based on the CGI params.
(Actually, does very little except redirect right now..)

=cut

sub index :Path('/search') :Args(0) {
    my ( $self, $c ) = @_;

    my $search = $c->request->params->{q};
    my $proptype = $c->request->params->{proptype} || 'residential';

    if ($c->request->params->{ft}) {
        $c->detach('fulltext');
    }

    if ($search =~ /^(\d{4})/) {
        $c->response->redirect("/properties/$proptype/postcode/$1");
        return;
    }

    if ($search =~ /^([\w ]+)$/) {
        $c->response->redirect("/properties/$proptype/suburb/$1");
        return;
    }

    if ($search =~ /^(\d{5,})$/) {
        $c->response->redirect("/property/$1");
        return;
    }
    $c->error("Invalid search: $search");
}

=head2 fulltext

Perform full-text search.

=cut

sub fulltext :Private {
    my ( $self, $c ) = @_;
    my $query = $c->request->params->{ft};

    my $searcher = REA::Searcher->new;
    my $results = $searcher->find( query => $query );

    my (@proplist, %excerpts);
    for my $hit (@$results) {
        my $prop = $c->model('DB::Properties')->find($hit->{id});
        next unless $prop;

        $excerpts{$prop->id} = $hit->{excerpt};
        push @proplist, $prop;
    }

    $c->stash->{template} = 'search/fulltext.tt';
    $c->stash->{search_query} = $query;
    $c->stash->{properties} = \@proplist;
    $c->stash->{excerpts} = \%excerpts;
}

=head1 AUTHOR

Toby Corkindale

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
