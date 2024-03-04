import { Octokit } from "@octokit/rest";

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

const username = "django";
await octokit.rest.packages
    .listPackagesForUser({ package_type: "container", username })
    .then(
        async ({ data }) =>
            await Promise.all(
                data.map(
                    async (container) =>
                        await octokit.rest.packages
                            .getAllPackageVersionsForPackageOwnedByUser({
                                package_type: container.package_type,
                                username,
                                package_name: container.name,
                            })
                            .then(({ data }) =>
                                data.map((image) => {
                                    return {
                                        container: container.name,
                                        name: image.name,
                                        tags:
                                            image?.metadata?.container?.tags ??
                                            [],
                                    };
                                })
                            )
                )
            )
    )
    .then((result) => console.log(result.flat()));
