#!/bin/bash
sleep 1m
# Log stdout to file
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/home/ec2-user/terraform.log 2>&1
# Update AL2
sudo yum update -y
# Uninstall AWSCLI v1
aws --version
sudo yum remove -y awscli || echo "aws not installed using yum"
# Install/update awscli2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo ln -s  /usr/local/aws-cli/v2/current/bin/aws /usr/bin/aws
aws --version
# Mount /anaconda3
sudo mkfs.xfs /dev/sdb -f
sudo mkdir /anaconda3
sudo mount /dev/sdb /anaconda3
sudo chown -R ec2-user:ec2-user /anaconda3
sudo echo "UUID=$(lsblk -nr -o UUID,MOUNTPOINT | grep "/anaconda3" | cut -d ' ' -f 1) /anaconda3 xfs defaults,nofail 1 2" | sudo tee -a /etc/fstab
# Install Anaconda
wget https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh -O /home/ec2-user/anaconda.sh &&
    bash /home/ec2-user/anaconda.sh -u -b -p /anaconda3 &&
    echo 'export PATH="/anaconda3/bin:$PATH"' >> /home/ec2-user/.bashrc &&
    rm -rf /home/ec2-user/anaconda.sh &&
## Update Conda
conda update -n base -c defaults conda &&
## Make sure the anaconda environment is writeable
sudo chown -R ec2-user:ec2-user /anaconda3 &&
# Configure Jupyter for AWS HTTP
runuser -l ec2-user -c 'jupyter notebook --generate-config' &&
    sed -i -e "s/# c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '"$(curl http://169.254.169.254/latest/meta-data/public-hostname)"'/g" /home/ec2-user/.jupyter/jupyter_notebook_config.py &&
    sed -i -e "s/# c.NotebookApp.allow_origin = ''/c.NotebookApp.allow_origin = '*'/g" /home/ec2-user/.jupyter/jupyter_notebook_config.py &&
    sed -i -e "s/# c.NotebookApp.open_browser = True/c.NotebookApp.open_browser = False/g" /home/ec2-user/.jupyter/jupyter_notebook_config.py
