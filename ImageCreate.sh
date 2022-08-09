# Create gallery resource group & gallery resource to keep VM images. "sig"="shared image gallery"
# What is the best place to keep a gallery? It's oewn resource group?
az group create --name myGalleryRG --location eastus
az sig create --resource-group Colin.Gallery.RG --gallery-name myGallery 

# List availble VMs to make image of. Make sure to use "--output table" or it prints JSON-like output.
az vm list --output table

# Get ID of VM you want to make an image of. Needs resource group (-g) and name (-n) of VM
az vm get-instance-view -g COLIN_TEST_RESOURCEGROUP -n Colin.VM1 --query id

# Create Image definition. Logical grouping for iamges
az sig image-definition create \
   --resource-group Colin.Gallery.RG \
   --gallery-name myGallery \
   --gallery-image-definition FirstImageDefinition \
   --publisher Colin.Naughton \
   --offer offer.placeholder \
   --sku sku.placeholder \
   --os-type Linux \
   --hyper-v-generation V2 \
   --os-state specialized # as opposed to "generalized" -> removes machine and user specific information from the VM.
# speicalized state is up and running quicker. Login accounts remain.
# Type can be Linux or Windows
# I ended up needing to specify "--hyper-v-generation V2" because V1 is default and causes error later on.


# Create image version
# Format: MajorVersion.MinorVersion.Patch
az sig image-version create \
   --resource-group Colin.Gallery.RG \
   --gallery-name myGallery \
   --gallery-image-definition FirstImageDefinition \
   --gallery-image-version 1.0.0 \
   --target-regions "eastus=1" \
   --replica-count 2 \
   --managed-image "/subscriptions/06a2bb1f-2482-4f82-90c7-7bcc095ee91c/resourceGroups/COLIN_TEST_RESOURCEGROUP/providers/Microsoft.Compute/virtualMachines/Colin.VM1"
   #What is the point of replicas?

# Create VM from image.
# Required params: --specialized or --generalized
# Can specify version in --image
#az group create --name myResourceGroup --location eastus
az vm create --resource-group COLIN_TEST_RESOURCEGROUP \
    --name Colin.VM1.2.ImageDuplicate \
    --image "/subscriptions/06a2bb1f-2482-4f82-90c7-7bcc095ee91c/resourceGroups/Colin.Gallery.RG/providers/Microsoft.Compute/galleries/myGallery/images/FirstImageDefinition/versions/1.0.0" \
    --specialized \
    --generate-ssh-keys
# Required to specify specialized or generalized
# Ended up needing to specify "--generate-ssh-keys"


# Share the gallery

# Get gallery ID
az sig show \
   --resource-group Colin.Gallery.RG \
   --gallery-name myGallery \
   --query id

# Share via RBAC with gallery ID as scope
az role assignment create \
   --role "Reader" \
   --assignee <email address> \
   --scope <gallery ID>