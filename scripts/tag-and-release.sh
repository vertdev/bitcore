#!/bin/bash
set -e

######### Adjust these variables as needed ################

insightApiDir="${HOME}/source/insight-api"
insightUIDir="${HOME}/source/insight-ui"
vertcoreDir="${HOME}/source/vertcore"
vertcoreNodeDir="${HOME}/source/vertcore-node"

###########################################################

# given a string tag, make signed commits, push to relevant repos, create signed tags and publish to npm

bump_version () {
  sed -i '' -e "s/\"version\"\: .*$/\"version\"\: \"${shortTag}\",/g" package.json
}

set_deps () {
  sed -i '' -e "s/\"vertcore-node\"\: .*$/\"vertcore-node\"\: \"${shortTag}\",/g" package.json
  sed -i '' -e "s/\"insight-api\"\: .*$/\"insight-api\"\: \"${shortTag}\",/g" package.json
  sed -i '' -e "s/\"insight-ui\"\: .*$/\"insight-ui\"\: \"bitpay\/insight\#${tag}\"/g" package.json
}

tag="${1}"
shortTag=`echo "${tag}" | cut -c 2-`

if [ -z "${tag}" ]; then
  echo ""
  echo "No tag given, exiting."
  exit 1
fi


#############################################
# vertcore-node
#############################################
function vertcoreNode() {
  echo ""
  echo "Starting with vertcore-node..."
  sleep 2
  pushd "${vertcoreNodeDir}"

  sudo rm -fr node_modules
  bump_version
  npm install

  git add .
  git diff --staged
  echo ""
  echo -n 'Resume?: (Y/n): '

  read ans

  if [ "${ans}" == 'n' ]; then
    echo "Exiting as requested."
    exit 0
  fi

  echo ""
  echo "Committing changes for vertcore-node..."
  sleep 2
  git commit -S

  echo ""
  echo "Pushing changes to Github..."
  git push origin master && git push upstream master

  echo ""
  echo "Signing a tag"
  git tag -s "${tag}" -m"${tag}"


  echo ""
  echo "Pushing the tag to upstream..."
  git push upstream "${tag}"

  echo ""
  echo "Publishing to npm..."
  npm publish --tag beta

  popd
}

#############################################
# insight-api
#############################################
function insightApi() {
  echo ""
  echo "Releasing insight-api..."
  sleep 2
  pushd "${insightApiDir}"

  sudo rm -fr node_modules
  bump_version
  npm install

  git add .
  git diff --staged
  echo ""
  echo -n 'Resume?: (Y/n): '

  read ans

  if [ "${ans}" == 'n' ]; then
    echo "Exiting as requested."
    exit 0
  fi

  echo ""
  echo "Committing changes for insight-api..."
  sleep 2
  git commit -S

  echo ""
  echo "Pushing changes to Github..."
  git push origin master && git push upstream master

  echo ""
  echo "Signing a tag"
  git tag -s "${tag}" -m"${tag}"


  echo ""
  echo "Pushing the tag to upstream..."
  git push upstream "${tag}"

  echo ""
  echo "Publishing to npm..."
  npm publish --tag beta

  popd
}

#############################################
# insight-ui
#############################################
function insightUi() {
  echo ""
  echo "Releasing insight-ui..."
  sleep 2
  pushd "${insightUIDir}"

  sudo rm -fr node_modules
  bump_version
  npm install

  git add .
  git diff --staged
  echo ""
  echo -n 'Resume?: (Y/n): '

  read ans

  if [ "${ans}" == 'n' ]; then
    echo "Exiting as requested."
    exit 0
  fi

  echo ""
  echo "Committing changes for insight-ui..."
  sleep 2
  git commit -S

  echo ""
  echo "Pushing changes to Github..."
  git push origin master && git push upstream master

  echo ""
  echo "Signing a tag"
  git tag -s "${tag}" -m"${tag}"


  echo ""
  echo "Pushing the tag to upstream..."
  git push upstream "${tag}"

  echo ""
  echo "Publishing to npm..."
  npm publish --tag beta

  popd
}

#############################################
# vertcore
#############################################
function vertcore() {
  echo ""
  echo "Releasing vertcore..."
  sleep 2
  pushd "${vertcoreDir}"

  sudo rm -fr node_modules
  bump_version
  set_deps

  npm install

  git add .
  git diff --staged
  echo ""
  echo -n 'Resume?: (Y/n): '

  read ans

  if [ "${ans}" == 'n' ]; then
    echo "Exiting as requested."
    exit 0
  fi

  echo ""
  echo "Committing changes for vertcore..."
  sleep 2
  git commit -S

  echo ""
  echo "Pushing changes to Github..."
  git push origin master && git push upstream master

  echo ""
  echo "Signing a tag"
  git tag -s "${tag}" -m"${tag}"


  echo ""
  echo "Pushing the tag to upstream..."
  git push upstream "${tag}"

  echo ""
  echo "Publishing to npm..."
  npm publish --tag beta

  popd

  echo "Completed releasing tag: ${tag}"
}

echo ""
echo "Tagging with ${tag}..."

echo "Assuming projects at ${HOME}/source..."

releases="${2}"
if [ -z "${releases}" ]; then
  vertcoreNode
  insightApi
  insightUi
  vertcore
else
  eval "${releases}"
fi

