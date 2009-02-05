package REA::WWW::M::DB;
use strict;
use warnings;
use parent 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'REA::Storage',
    connect_info => [
        'dbi:Pg:dbname=rea',
        undef,
        undef,
        {
            pg_enable_utf8 => 1
        }
    ]
    
);

=head1 NAME

REA::WWW::M::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<REA::WWW>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<REA::Storage>

=head1 AUTHOR

Toby Wintermute,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
