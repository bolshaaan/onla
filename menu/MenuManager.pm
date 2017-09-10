package MenuManager;
use strict;
use warnings;

use Carp qw(croak);

sub new
{
    my $class = shift;
    my (%config) = @_;

    my $self = { menu => [] };
    bless $self, $class;

    return $self;
}

sub addMenu
{
    my $self = shift;
    my (@menu) = @_;

    while (@menu) {
        my $root    = shift @menu;
        my $submenu = shift @menu;

        next unless $root && $submenu;
        push @{$self->{menu}}, { title => $root, submenu => $submenu };
    }

    return 1;
}

sub addMenuAfter
{
    my $self = shift;
    my ($anchor, @menu) = @_;

    $self->_addMenuInPosition('after', $anchor, @menu);

    return 1;
}

sub addMenuBefore
{
    my $self = shift;
    my ($anchor, @menu) = @_;

    $self->_addMenuInPosition('before', $anchor, @menu);

    return 1;
}

sub _addMenuInPosition
{
    my $self = shift;
    my ($type, $anchor, @menu) = @_;

    my @old = @{$self->{menu}};
    my @new;

    my $added = 0;
    foreach my $m (@old) {
        push(@new, $m) if $type eq 'after';

        if ($m->{title} eq $anchor) {
            $added = 1;
            while (@menu) {
                push(@new, { title => shift @menu, submenu => shift @menu });
            }
        }

        push(@new, $m) if $type eq 'before';
    }

    croak("Anchor menu not found") unless $added;

    $self->{menu} = \@new;

    return 1;
}

sub addSubmenuBefore
{
    my $self = shift;
    my ($anchor, $subanchor, @new_submenu) = @_;

    return $self->_addSubmenuInPosition('before', $anchor, $subanchor, @new_submenu);
}

sub addSubmenuAfter
{
    my $self = shift;
    my ($anchor, $subanchor, @new_submenu) = @_;

    return $self->_addSubmenuInPosition('after', $anchor, $subanchor, @new_submenu);
}

sub _addSubmenuInPosition
{
    my $self = shift;
    my ($type, $anchor, $subanchor, @new_submenu) = @_;

    my @found_anchor = grep { $_->{title} eq $anchor } @{$self->{menu}};
    croak("Anchor menu not found") unless @found_anchor;

    my $found_subanchor = 0;

    foreach my $found ( @found_anchor ) {
        my $submenu = $found->{submenu};

        next unless $submenu && @$submenu;

        my @old_items = @{$submenu};
        my @new_items;

        for my $item (@old_items) {
            push(@new_items, $item) if $type eq 'after';
            if ($item->{title} eq $subanchor) {
                $found_subanchor = 1;
                push(@new_items, @new_submenu);
            }
            push(@new_items, $item) if $type eq 'before';
        }

        $found->{submenu} = \@new_items;
    }

    croak("Anchor submenu not found") unless $found_subanchor;

    return 1;
}

sub getMenu
{
    return map { +{ %$_, url => '' } } @{$_[0]->{menu}};
}

1;
