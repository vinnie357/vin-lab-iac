#https://www.terraform.io/docs/backends/types/gcs.html
terraform {
  backend "gcs" {
    bucket  = "tf-state-prod"
    prefix  = "terraform/state"
  }
}

data "terraform_remote_state" "foo" {
  backend = "gcs"
  config = {
    bucket  = "terraform-state"
    prefix  = "prod"
  }
}

resource "template_file" "bar" {
  template = "${greeting}"

  vars {
    greeting = "${data.terraform_remote_state.foo.greeting}"
  }
}

#https://www.terraform.io/docs/backends/types/http.html
terraform {
  backend "http" {
    address = "http://myrest.api.com/foo"
    lock_address = "http://myrest.api.com/foo"
    unlock_address = "http://myrest.api.com/foo"
  }
}

data "terraform_remote_state" "foo" {
  backend = "http"
  config = {
    address = "http://my.rest.api.com"
  }
}
#
# https://www.terraform.io/docs/backends/types/consul.html
terraform {
  backend "consul" {
    address = "demo.consul.io"
    scheme  = "https"
    path    = "full/path"
  }
}

data "terraform_remote_state" "foo" {
  backend = "consul"
  config = {
    path = "full/path"
  }
}
# vars
TF_VAR_AWS_ACCESS_KEY_ID - your AWS access key
TF_VAR_AWS_SECRET_ACCESS_KEY - your AWS secret key
TF_VAR_AWS_DEFAULT_REGION - AWS default region
GITLAB_USER_EMAIL - your personal gitlab email address. this is used when pushing terraform state into your private repo
IAC_ACTION - the value will determine if deploying or destroying. values are deploy / destroy
IAC_STATE_REPO_WITH_PASS - used to store state - your private repo in the format of https://git_username:git_password@gitlab.com/your_username/iac_state.git
TF_VAR_BIGIP_PWD - password for the bigip admin account
TF_VAR_PUBLIC_KEY - your public ssh key for creating a key-pair in AWS.
TF_VAR_USERNAME - a username used to tag your resources
#


get_state() {
    git config --global user.email $GITLAB_USER_EMAIL
    git config --global user.name $GITLAB_USER_NAME
    git config --global http.sslVerify false
    git clone $IAC_STATE_REPO_WITH_PASS
    cp iac_state/* ./
    mkdir -p ~/.ssh
    cp id_rsa ~/.ssh/ >> error.log 2>&1 || echo "no rsa key found"
    chmod og-rwx ~/.ssh/id_rsa >> error.log 2>&1 || echo "no rsa key found"
    echo "copied state to current directory $PWD"
    ls
    return 0
}

store_state() {
    ls
    cp *.tfstate iac_state/
    cd iac_state
    ls
    git add *
    git commit -m "updated state file" >> error.log 2>&1 || echo "nothing to commit"
    git push -f >> error.log 2>&1 || echo "push failed"
    echo "updated state file in remote repo"
    cd ..
    return 0
}
