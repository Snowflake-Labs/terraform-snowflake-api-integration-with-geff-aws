#!/bin/bash

echo "Executing clean_dist_pkg.sh..."

cd $path_module

dir_to_delete=./$source_code_dist_dir_name/
file_to_delete=./$dist_archive_file_name

echo "Removing distribution file..."
rm -rf $dir_to_delete $file_to_delete
