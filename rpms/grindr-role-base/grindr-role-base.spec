%global _hardened_build 1

# variables
%define package_name grindr-role-base
%define package_version 1.0.0
%define package_release 1

# root package
Name: %{package_name}
Version: %{package_version}
Release: %{package_release}
License: All Rights Reserved
Vendor: Grindr, LLC
Packager: Naftuli Kay <me@naftuli.wtf>
Group: System Environment/Base
Summary: The base role which all other role packages inherit from.

# runtime requirements
Requires: grindr-base

%description
The base role which all other role packages inherit from.
