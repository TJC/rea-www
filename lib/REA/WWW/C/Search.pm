package REA::WWW::C::Search;

use strict;
use warnings;
use parent 'Catalyst::Controller';

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

    if ($search =~ /^(\d{4})/) {
        $c->response->redirect("/properties/postcode/$1");
        return;
    }

    if ($search =~ /^([\w ]+)$/) {
        $c->response->redirect("/properties/suburb/$1");
        return;
    }

    if ($search =~ /^(\d{5,})$/) {
        $c->response->redirect("/property/$1");
        return;
    }
    $c->error("Invalid search: $search");
}

=head1 AUTHOR

Toby Corkindale

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
