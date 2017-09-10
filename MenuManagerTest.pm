package MenuManagerTest;
use strict;
use warnings;
use base 'TestCase';

use MenuManager;

sub testReturnTrueOnAddMenu
{
    my $self = shift;

    my $manager = $self->_buildMenuManager();

    $self->assert($manager->addMenu("My menu", [{title => "Submenu", url => 'abc'}]), "Check menu added");
}

sub testReturnCompleteMenu
{
    my $self = shift;

    my $manager = $self->_buildMenuManager();

    $manager->addMenu("My menu", [{ title => "Submenu", url => 'abc' }]);

    $self->assert_deep_equals(
        [
            {
                title   => "My menu",
                url     => '',
                submenu => [
                    { title => "Submenu", url => 'abc' }
                ]
            }
        ],
        [$manager->getMenu()]
    );
}

sub testAddMenuAfter
{
    my $self = shift;

    my $manager = $self->_buildMenuManager();

    $manager->addMenu("My menu1", [{ title => "Submenu1", url => 'abc' }]);
    $manager->addMenu("My menu2", [{ title => "Submenu2", url => 'abc2' }]);

    $manager->addMenuAfter("My menu1", "My menu3", [{ title => "Submenu3", url => 'abc3' }]);

    $self->assert_deep_equals(
        [
            {
                title => "My menu1",
                url => '',
                submenu => [
                    { title => "Submenu1", url => 'abc' }
                ]
            },
            {
                title => "My menu3",
                url => '',
                submenu => [
                    { title => "Submenu3", url => 'abc3' }
                ]
            },
            {
                title => "My menu2",
                url => '',
                submenu => [
                    { title => "Submenu2", url => 'abc2' }
                ]
            }
        ],
        [$manager->getMenu()]
    );
}

sub testAddMenuBefore
{
    my $self = shift;

    my $manager = $self->_buildMenuManager();

    $manager->addMenu("My menu1", [{ title => "Submenu1", url => 'abc' }]);
    $manager->addMenu("My menu2", [{ title => "Submenu2", url => 'abc' }]);

    $manager->addMenuBefore("My menu1", "My menu3", [{ title => "Submenu3", url => 'abc' }]);

    $self->assert_deep_equals(
        [
            {
                title => "My menu3",
                url => '',
                submenu => [
                    { title => "Submenu3", url => 'abc' }
                ]
            },
            {
                title => "My menu1",
                url => '',
                submenu => [
                    { title => "Submenu1", url => 'abc' }
                ]
            },
            {
                title => "My menu2",
                url => '',
                submenu => [
                    { title => "Submenu2", url => 'abc' }
                ]
            }
        ],
        [$manager->getMenu()]
    );
}

sub testAddSubMenuBefore
{
    my $self = shift;

    my $manager = $self->_buildMenuManager();

    $manager->addMenu("My menu", [{ title => "Submenu1", url => 'abc1' }, { title => "Submenu2", url => 'abc2' }]);

    $manager->addSubmenuBefore("My menu", "Submenu2", { title => "Submenu3", url => 'abc3' });

    $self->assert_deep_equals(
        [
            {
                title => "My menu",
                url => '',
                submenu => [
                    { title => "Submenu1", url => 'abc1' },
                    { title => "Submenu3", url => 'abc3' },
                    { title => "Submenu2", url => 'abc2' }
                ]
            }
        ],
        [$manager->getMenu()]
    );
}

sub testAddSubMenuAfter
{
    my $self = shift;

    my $manager = $self->_buildMenuManager();

    $manager->addMenu("My menu", [{ title => "Submenu1", url => 'abc1' }, { title => "Submenu2", url => 'abc2' }]);

    $manager->addSubmenuAfter("My menu", "Submenu1", { title => "Submenu3", url => 'abc3' });

    $self->assert_deep_equals(
        [
            {
                title => "My menu",
                url => '',
                submenu => [
                    { title => "Submenu1", url => 'abc1' },
                    { title => "Submenu3", url => 'abc3' },
                    { title => "Submenu2", url => 'abc2' }
                ]
            }
        ],
        [$manager->getMenu()]
    );
}

sub testThrowOnUnkonwAnchorForAddMenu
{
    my $self = shift;

    my $manager = $self->_buildMenuManager();

    $self->assert_raises_matches(
        'Error::Simple',
        sub { $manager->addMenuBefore("Some unknown menu", "My menu3", [{ title => "Submenu3", url => 'abc' }]) },
        qr/Anchor menu not found/
    );
}

sub testThrowOnUnknownAnchorForAddSubmenu
{
    my $self = shift;

    my $manager = $self->_buildMenuManager();

    $self->assert_raises_matches(
        'Error::Simple',
        sub { $manager->addSubmenuBefore("Some unknown menu", "Some unknown submenu", { title => "Submenu3", url => 'abc' }) },
        qr/Anchor menu not found/
    );
}

sub testThrowOnUnknownSubanchorForAddSubmenu
{
    my $self = shift;

    my $manager = $self->_buildMenuManager();

    $manager->addMenu("My menu", [{ title => "Submenu1", url => 'abc1' }]);

    $self->assert_raises_matches(
        'Error::Simple',
        sub { $manager->addSubmenuBefore("My menu", "Some unknown submenu", { title => "Submenu3", url => 'abc' }) },
        qr/Anchor submenu not found/
    );
}

sub _buildMenuManager
{
    my $self = shift;

    return MenuManager->new(@_);
}

1;
