
set -ex

# Parse options.
while getopts "b:r:" options; do
  case "${options}" in
    b)
      branch=${OPTARG}
      ;;
    r)
      repo=${OPTARG}
      ;;
    esac
done

git clone $repo -b $branch /tmp/repo

cd /tmp/repo

python3 -m pytest test_main.py -v
