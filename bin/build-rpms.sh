#!/bin/bash

set -e

for i in recipes/*; do
    if [ -d $i ]; then
        cd $i
        if [ -e recipe.rb ]; then
            echo Building $(basename $i)
            if [ -e build.sh ]; then
                ./build.sh
            else
                bundle exec 'fpm-cook clean'
                bundle exec 'fpm-cook package --no-deps'
            fi
        fi
        cd /vagrant/
    fi
done
