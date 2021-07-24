#!/bin/sh

echo "Executing create_dist_pkg.sh..."

cd $path_module
pwd

echo "Cloning git repo..."
git clone https://github.com/Snowflake-Labs/geff.git

echo "Source code path is $source_code_upload_dir"

install_path_dir=./$source_code_dist_dir_path/$source_code_upload_dir/site-packages/
mkdir -p $install_path_dir
requirements_file_path=$path_cwd/$path_module/$source_code_repo_dir_path/requirements.txt

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

# Copies only python files from lambda_code_dir_path to pkg dir
cp -R ./geff/lambda_src/* ./$source_code_dist_dir_path/$source_code_upload_dir/
