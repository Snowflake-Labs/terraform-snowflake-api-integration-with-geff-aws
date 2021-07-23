#!/bin/sh

echo "Executing create_dist_pkg.sh..."

cd $path_module
pwd

echo "Cloning git repo..."
git clone git@github.com:Snowflake-Labs/geff.git

echo "Source code path is $source_code_path"
source_code_dist_dir=./$source_code_dist_dir_name/
install_path_dir=./$source_code_dist_dir_name/site-packages/
mkdir $source_code_dist_dir
mkdir $install_path_dir
requirements_file_path=$path_cwd/$path_module/$source_code_path/requirements.txt

# Installing python dependencies...
if [ -f "$requirements_file_path" ]; then
  echo "Installing dependencies..."
  echo "requirements.txt file exists..."
  pip install -r $requirements_file_path --target $install_path_dir --upgrade
else
  echo "Error: $requirements_file_path does not exist!"
fi

# Create deployment package...
echo "Creating distribution package for deployment..."

# Copies only python files from source_code_path to pkg dir
cp -R $path_cwd/$path_module/$source_code_path/* ./$source_code_dist_dir/
