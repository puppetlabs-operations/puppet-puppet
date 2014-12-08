#!/bin/bash
# This script runs the deploy process for travis-ci builds
# Travis-ci will call the script after builds are successful
#
# In order to trigger a module build and deployment to puppet forge, the
# following conditions must be met:
# - Git commit is in master branch
# - Git commit is tagged and the tag is the same version as in metadata.json
# - All builds in travis were successful
# - The current build is not for a pull request

# Additionally, a few other sanity checks are in place to prevent unwanted
# deployments or deployment attempts

# Only deploy if this is being built for puppetlabs-operations/puppet-puppet
# this is to avoid deploy attempts when forks run through travis-ci
# if you really do want to deploy your fork to the forge, just disable this
if [ "$TRAVIS_REPO_SLUG" != "puppetlabs-operations/puppet-puppet" ]; then
  echo 'this build is not being built on puppetlabs-operations/puppet-puppet'
  echo 'no deploy scheduled'
fi

# Only deploy if this is not being built for a pull request
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo 'this build is for a pull request; no deploy scheduled'
  exit 0
fi

# Only deploy for builds of the master branch
if [ "$TRAVIS_BRANCH" != "master" ]; then
  echo 'this build is not for the master branch; no deploy scheduled'
  exit 0
fi

# Only deploy if this is the build leader in travis
if [ "$BUILD_LEADER" != "YES" ]; then
  echo "not build leader, no deploy scheduled"
  exit 0
fi

# Only deploy if all other builds succeeded
if [ "$BUILD_AGGREGATE_STATUS" != "others_succeeded" ]; then
  echo "Some Failed, no deploy scheduled"
  exit 0
fi

# Only deploy if the current commit was tagged in git
if [ -z "$TRAVIS_TAG" ]; then
  echo "TRAVIS_TAG is nil, no deploy scheduled because the commit lacks a tag"
  exit 0
else
  echo "detected tag: ${TRAVIS_TAG}, continuing with deploy"
fi

compare_versions() {
  # Only deploy if current tag equals the version in metadata.json
  # If we forgot to update metadata.json, bail and do not deploy
  echo "Verifying that version in TRAVIS_TAG matches version in metadata.json"
  sudo apt-get update
  sudo apt-get install -y jq
  METADATA_VERSION="$(jq -r .version < metadata.json)"
  if [ "$TRAVIS_TAG" != "$METADATA_VERSION" ]; then
    echo "Error: Git tag does not equal version in metadata.json! Exiting."
    exit 1
  else
    return 0
  fi
}

create_blacksmith_auth_file() {
  if [ -z "$FORGE_USERNAME" ] || [ -z "$FORGE_PASSWORD" ]; then
    echo "FORGE_USERNAME and/or FORGE_PASSWORD are unset, exiting"
    exit 0
  fi

  cat > ~/.puppetforge.yml << EOF
url: https://forgeapi.puppetlabs.com
username: ${FORGE_USERNAME}
password: ${FORGE_PASSWORD}
EOF
}

deploy_module() {
  echo "All Succeded! PUBLISHING..."
  bundle install
  bundle exec rake build
  bundle exec rake module:push
}

create_blacksmith_auth_file
compare_versions
deploy_module
