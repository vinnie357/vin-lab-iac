function gitleaks {
# dir=$(dirname $(pwd))
docker run --rm --name=gitleaks -v $(pwd):/code/ zricethezav/gitleaks -v --path=/code/
}
