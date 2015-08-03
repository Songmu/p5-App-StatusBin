package App::StatusBin;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Puncheur::Lite;
use Imager;
use Plack::MIME;

my %StatusCode = (
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Request Entity Too Large',
    414 => 'Request-URI Too Large',
    415 => 'Unsupported Media Type',
    416 => 'Request Range Not Satisfiable',
    417 => 'Expectation Failed',
    418 => 'I\'m a teapot',            # RFC 2324
    422 => 'Unprocessable Entity',            # RFC 2518 (WebDAV)
    423 => 'Locked',                          # RFC 2518 (WebDAV)
    424 => 'Failed Dependency',               # RFC 2518 (WebDAV)
    425 => 'No code',                         # WebDAV Advanced Collections
    426 => 'Upgrade Required',                # RFC 2817
    428 => 'Precondition Required',
    429 => 'Too Many Requests',
    431 => 'Request Header Fields Too Large',
    449 => 'Retry with',                      # unofficial Microsoft
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Timeout',
    505 => 'HTTP Version Not Supported',
    506 => 'Variant Also Negotiates',         # RFC 2295
    507 => 'Insufficient Storage',            # RFC 2518 (WebDAV)
    509 => 'Bandwidth Limit Exceeded',        # unofficial
    510 => 'Not Extended',                    # RFC 2774
    511 => 'Network Authentication Required',
);

get '/example' => sub {
    my $c = shift;
    my $body = '';
    for my $status (qw/400 401 403 404 500 503/) {
        $body .= sprintf '<img src="%s" /><br />', "$status.png";
    }
    $c->create_response(200, ['Content-Type' => 'text/html'], [$body]);
};

get '/{status:[0-9]+}.{ext:[a-z0-9]+}' => sub {
    my ($c, $args) = @_;

    my $ext    = $args->{ext};
    my $status = $args->{status};
    my $text   = $StatusCode{$args->{status}};
    unless ($text) {
        $c->create_response(404, ['Content-Type' => 'text/plain'], ['NOT FOUND']);
    }

    my $string = sprintf '%s: %s', $status, $text;
    my ($data, $content_type) = ($string, 'text/plain');
    if ( $ext =~ /^(?:jpe?g|gif|png)$/ ) {
        $content_type = $Plack::MIME::MIME_TYPES->{".$ext"};
        my $type = $content_type;
           $type =~ s!image/!!;
        my $font = Imager::Font->new(
            file  => 'share/dodge.ttf',
            color => '#000000',
            size  => 32,
        );
        my $bbox = $font->bounding_box(string => $string);
        my $img = Imager->new(xsize => $bbox->total_width + 20, ysize => $bbox->font_height + 20);
        $img->box(color => '#ffffff', filled => 1);
        $img->string(
            font => $font,
            text => $string,
            x => 10,
            y => $bbox->font_height + $bbox->descent + 10,
            aa => 1,
        );
        $img->write(data => \$data, type => $type);
    }
    $c->create_response($args->{status}, ['Content-Type' => $content_type], [$data]);
};


1;
__END__

=encoding utf-8

=head1 NAME

App::StatusBin - It's new $module

=head1 SYNOPSIS

    use App::StatusBin;

=head1 DESCRIPTION

App::StatusBin is ...

=head1 LICENSE

Copyright (C) Songmu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Songmu E<lt>y.songmu@gmail.comE<gt>

=cut

