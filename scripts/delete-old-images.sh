#!/usr/bin/env bash

# We need to figure out how many images to keep. First we count how
# many PHP versions we support in the Dockerfile. The we multiple that
# number by 3, because there will be a tagged multiarch image for each
# version and then an additional one for linux/amd64 and one for
# linux/arm64.
php_versions_count=$(grep --count 'AS php[0-9\.]' Dockerfile)
image_count=$((php_versions_count * 3))

versions=$(curl \
	--silent \
	--fail \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer ${GITHUB_TOKEN}" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	https://api.github.com/orgs/reload/packages/container/php-fpm/versions)

mapfile -t version_ids < <(echo "${versions}" | jq -r ".[${image_count}:][].id")

for version_id in "${version_ids[@]}"; do
	echo "Deleting package version id ${version_id}"
	curl \
		--silent \
		--fail \
		-X DELETE \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer ${GITHUB_TOKEN}" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		"https://api.github.com/orgs/reload/packages/container/php-fpm/versions/${version_id}"
done
