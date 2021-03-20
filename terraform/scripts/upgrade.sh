function upgrade {
# requires terraform 0.13
find . -name '*.tf' | xargs -n1 dirname | uniq | xargs -n1 terraform 0.13upgrade -yes
}
