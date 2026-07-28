# The InsightFinder Agents for Kubernetes

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

`helm repo add insightfinder https://insightfinder.github.io/charts`

If you had already added this repo earlier, run `helm repo update` to retrieve the latest versions of the packages.

You can then run `helm search repo insightfinder` to see the charts.

To install a chart:

`helm install [NAME] insightfinder/[CHART]`

To uninstall the chart:

`helm uninstall [NAME]`

## Gitleaks setup

To help prevent secrets from being committed, developers can install Gitleaks locally and enable the repository hooks:

* Install Gitleaks. On macOS, Homebrew is a common option: `brew install gitleaks`. On Linux, users can install it using the package manager or download a release binary from the official project page at [https://github.com/gitleaks/gitleaks/releases](https://github.com/gitleaks/gitleaks/releases).
* If needed, install pre-commit. The official installation guide is available at [https://pre-commit.com/](https://pre-commit.com/). Common options include `pipx install pre-commit`, `brew install pre-commit`, or the package manager approach described there.
* Enable the hooks in this repository: `pre-commit install`
* To keep the hook definitions current, you can also run `pre-commit autoupdate` periodically.

This will run the Gitleaks checks automatically before each commit.
