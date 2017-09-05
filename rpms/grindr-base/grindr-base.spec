%global _hardened_build 1

# variables
%define package_name grindr-base
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
Summary: Base packages and configuration for machines in Atlas.

# runtime requirements
Requires: less
Requires: tree
Requires: vim-enhanced

%description
Base packages and configuration for machines in Atlas.
