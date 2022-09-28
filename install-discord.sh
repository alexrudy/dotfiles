#!/usr/bin/env bash

# Discord-specific installation steps
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update -y
sudo apt-get install --no-install-recommends -y gh tree python3-pip python3-venv autojump ruby direnv
sudo apt-get --only-upgrade --no-install-recommends install -y google-cloud-sdk-cbt google-cloud-sdk-app-engine-grpc google-cloud-sdk-datalab google-cloud-sdk-kpt google-cloud-sdk-datastore-emulator google-cloud-sdk-app-engine-go google-cloud-sdk-app-engine-python-extras google-cloud-sdk-cloud-build-local google-cloud-sdk-firestore-emulator google-cloud-sdk-app-engine-python google-cloud-sdk-local-extract google-cloud-sdk-terraform-validator google-cloud-sdk-gke-gcloud-auth-plugin google-cloud-sdk-skaffold google-cloud-sdk-spanner-emulator google-cloud-sdk google-cloud-sdk-config-connector google-cloud-sdk-pubsub-emulator google-cloud-sdk-anthos-auth kubectl google-cloud-sdk-app-engine-java google-cloud-sdk-bigtable-emulator google-cloud-sdk-kubectl-oidc google-cloud-sdk-minikube
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin --no-update-rc
python3 -m pip install pipx
