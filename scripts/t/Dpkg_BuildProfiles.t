#!/usr/bin/perl
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

use strict;
use warnings;

use Test::More tests => 11;

BEGIN {
    use_ok('Dpkg::BuildProfiles', qw(parse_build_profiles
                                     set_build_profiles
                                     get_build_profiles));
}

# TODO: Add actual test cases.

# Check stock things
$ENV{DEB_VENDOR} = 'Debian';

my $formula;

$formula = [ ];
is_deeply([ parse_build_profiles('') ], $formula,
    'parse build profiles formula empty');

$formula = [ [ qw(nocheck) ] ];
is_deeply([ parse_build_profiles('<nocheck>') ], $formula,
    'parse build profiles formula single');

$formula = [ [ qw(nocheck nodoc stage1) ] ];
is_deeply([ parse_build_profiles('<nocheck nodoc stage1>') ], $formula,
    'parse build profiles formula AND');

$formula = [ [ qw(nocheck) ], [ qw(nodoc) ] ];
is_deeply([ parse_build_profiles('<nocheck> <nodoc>') ], $formula,
    'parse build profiles formula OR');

$formula = [ [ qw(nocheck nodoc) ], [ qw(stage1) ] ];
is_deeply([ parse_build_profiles('<nocheck nodoc> <stage1>') ], $formula,
    'parse build profiles formula AND, OR');

{
    local $ENV{DEB_BUILD_PROFILES} = 'cross nodoc profile.name';
    is_deeply([ get_build_profiles() ], [ qw(cross nodoc profile.name) ],
        'get active build profiles from environment');
}

set_build_profiles(qw(nocheck stage1));
is_deeply([ get_build_profiles() ], [ qw(nocheck stage1) ],
    'get active build profiles explicitly set');

# Check Ubuntu vendor hook
$ENV{DEB_VENDOR} = 'Ubuntu';

set_build_profiles(qw(nocheck stage1));
is_deeply([ get_build_profiles() ], [ qw(noudeb nocheck stage1) ],
    'get active build profiles explicitly set');

set_build_profiles(qw(!noudeb nocheck stage1));
is_deeply([ get_build_profiles() ], [ qw(nocheck stage1) ],
    'get active build profiles explicitly set');

{
    local $ENV{DEB_BUILD_PROFILES} = 'cross nodoc profile.name';

    # dpkg-buildpackage.pl calls set_build_profiles with an empty array by
    # default (unless --build-profiles is used), ensure the env var is still
    # parsed
    set_build_profiles(qw());
    is_deeply([ get_build_profiles() ], [ qw(noudeb cross nodoc profile.name) ],
        'get active build profiles from environment');
}


1;
