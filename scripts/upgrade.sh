function upgrade {
  #pass a list of module folders
  version=0.14
  list=$1
  for folder in $list
   do
    cd $folder && terraform ${version}upgrade && cd ..
   done;
}
