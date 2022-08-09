# Create VM
az vm create \
  --resource-group learn-a88011a3-24d8-4fe6-bc62-3b86b131b653 \
  --name my-vm \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys

# Install Nginx from script on github
az vm extension set \
  --resource-group learn-a88011a3-24d8-4fe6-bc62-3b86b131b653 \
  --vm-name my-vm \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --version 2.1 \
  --settings '{"fileUris":["https://raw.githubusercontent.com/MicrosoftDocs/mslearn-welcome-to-azure/master/configure-nginx.sh"]}' \
  --protected-settings '{"commandToExecute": "./configure-nginx.sh"}'

# Access web server

# List IP of VM and store as Bash variable
IPADDRESS="$(az vm list-ip-addresses \
  --resource-group learn-a88011a3-24d8-4fe6-bc62-3b86b131b653 \
  --name my-vm \
  --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
  --output tsv)"

# Attempt to download homepage of website hosted on VM
curl --connect-timeout 5 http://$IPADDRESS

# List current network security group
az network nsg list \
  --resource-group learn-a88011a3-24d8-4fe6-bc62-3b86b131b653 \
  --query '[].name' \
  --output tsv
# output was "my-vmNSG"

# List rules associated with network security group "my-vmNSG"
# JSON format (default)
az network nsg rule list \
  --resource-group learn-a88011a3-24d8-4fe6-bc62-3b86b131b653 \
  --nsg-name my-vmNSG

# Table format
#only the name, priority, affected ports, and access (Allow or Deny) for each rule.
az network nsg rule list \
  --resource-group learn-a88011a3-24d8-4fe6-bc62-3b86b131b653 \
  --nsg-name my-vmNSG \
  --query '[].{Name:name, Priority:priority, Port:destinationPortRange, Access:access}' \
  --output table

# Create network rule to allow inbound access on port 80
az network nsg rule create \
  --resource-group learn-a88011a3-24d8-4fe6-bc62-3b86b131b653 \
  --nsg-name my-vmNSG \
  --name allow-http \
  --protocol tcp \
  --priority 100 \
  --destination-port-ranges 80 \
  --access Allow

# Try to access website hosted by VM again
curl --connect-timeout 5 http://$IPADDRESS