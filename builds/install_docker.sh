IMAGE_ARCH=$config_image_arch

echo "Installing docker"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --batch --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

 echo \
 "deb [arch=$IMAGE_ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt install -y docker-ce docker-ce-cli containerd.io

if [ "$config_software_docker_compose" = true ] ; then
    echo "Installing docker-compose"
    sudo apt install -y libffi-dev libssl-dev
    sudo apt install -y python3-dev
    sudo apt install -y python3 python3-pip
    sudo pip3 install docker-compose
fi