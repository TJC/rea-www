package REA::WWW::V::RSS;
use strict;
use warnings;
use parent 'Catalyst::View';
use XML::RSS;
use DateTime;

sub process {
    my ($self, $c) = @_;

    my $rss = $self->make_rss($c);

    $c->response->body( $rss->as_string );
    $c->response->headers->header(
        'Content-type' => 'application/rss+xml'
    );
}

sub make_rss {
    my ($self, $c) = @_;

    my $rss = XML::RSS->new;
    $rss->channel(
        title => "REAProps in " . $c->stash->{location},
        link => 'http://realestate.com.au/',
        description => "REAProps from " . $c->stash->{location},
        syn => {
            updatePeriod => 'daily',
            updateFrequency => '1',
            updateBase => '2009-01-01T00:00+00:00',
        },
    );

    # Only return props that were created recently..
    my $day_ago = DateTime->now->subtract( hours => 24 );
    my $props = $c->stash->{properties}->search(
        {
           created => { '>=' => $day_ago },
        # created => { '>=' => \"(CURRENT_TIMESTAMP - '24 hours'::INTERVAL)" },
        },
    );

    while (my $prop  = $props->next) {
        my $title = $prop->address . ' ' . $prop->suburb;
        my $desc = join("\n", $title, $prop->price, $prop->description);
        $rss->add_item(
            title => $title,
            description => $desc,
            link => $prop->make_url,
        );
    }

    return $rss;
}


=head1 NAME

REA::WWW::V::RSS

=head1 DESCRIPTION

RSS View for REA::WWW. 

=head1 AUTHOR

Toby Corkindale

=head1 SEE ALSO

L<REA::WWW>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
