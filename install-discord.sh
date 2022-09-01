# Discord-specific installation steps
sudo apt-get update
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg\nsudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg\necho "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null\nsudo apt update\nsudo apt install gh
sudo apt-get install tree
sudo apt-get install fzf
sudo apt-get update && sudo apt-get --only-upgrade install google-cloud-sdk-cbt google-cloud-sdk-app-engine-grpc google-cloud-sdk-datalab google-cloud-sdk-kpt google-cloud-sdk-datastore-emulator google-cloud-sdk-app-engine-go google-cloud-sdk-app-engine-python-extras google-cloud-sdk-cloud-build-local google-cloud-sdk-firestore-emulator google-cloud-sdk-app-engine-python google-cloud-sdk-local-extract google-cloud-sdk-terraform-validator google-cloud-sdk-gke-gcloud-auth-plugin google-cloud-sdk-skaffold google-cloud-sdk-spanner-emulator google-cloud-sdk google-cloud-sdk-config-connector google-cloud-sdk-pubsub-emulator google-cloud-sdk-anthos-auth kubectl google-cloud-sdk-app-engine-java google-cloud-sdk-bigtable-emulator google-cloud-sdk-kubectl-oidc google-cloud-sdk-minikube
sudo apt-get install pipx
sudo apt-get install python3-pip
sudo apt-get install python3-venv
sudo apt-get install autojump
sudo apt-get install ruby
sudo apt-get install direnv