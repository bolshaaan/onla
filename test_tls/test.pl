#!/usr/bin/perl
use strict;
use warnings;

use Carp qw(croak);

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

# Для всех коннектов требуется использовать какой-нибудь HTTPS-proxy
$ENV{HTTPS_PROXY} = 'https://localhost:8888';

# В зависимости от версий модулей LWP, Crypt-SSLeay и IO::Socket::SSL
# может отличаться порядок их загрузки и модуль по-умолчанию.
use Net::HTTPS;
$Net::HTTPS::SSL_SOCKET_CLASS = 'Net::SSL';
use Net::SSL;
use IO::Socket::SSL;

use TestModule1;
use TestModule2;
use TestModule3;

changeNetHTTPSBase('Net::SSL');

no warnings 'redefine';
my $con2 = \&TestModule2::connect;

*TestModule2::connect = sub {
    changeNetHTTPSBase('IO::Socket::SSL');
    my $res = $con2->(@_);
    changeNetHTTPSBase('Net::SSL');

    $res
};

use warnings 'redefine';

sub changeNetHTTPSBase
{
    my ($new_base) = shift;

    my $net_ssl = 'Net::SSL';
    my $io_ssl = 'IO::Socket::SSL';
    croak("Net::SSL or IO::Socket::SSL must be passed")
        unless $new_base =~ m/^($net_ssl|$io_ssl)$/;

    my $current = '';
    for (@Net::HTTPS::ISA) {
        if (
                $_ eq $net_ssl && $new_base eq $io_ssl
            ||
                $_ eq $io_ssl && $new_base eq $net_ssl
        ) {
            $_ = $new_base;
            last;
        }
    }
}

# Сервер поддерживает старые SSL-протоколы, исторически используется Net::SSL
print TestModule1->connect('https://api.ipify.org/');

# Сервер поддерживает только TLS 1.2, требуется использовать IO::Socket::SSL
print TestModule2->connect('https://fancyssl.hboeck.de/');

# Сервер поддерживает старые SSL-протоколы, требуется использовать Net::SSL
print TestModule3->connect('https://api.ipify.org/');

print "\nDone\n";
