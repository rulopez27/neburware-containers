#!/bin/bash
# setup_nas.sh
# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root (sudo)."
  exit 1
fi

# Updates and upgrades the system
echo "Updating and upgrading the system..."
apt-get update && apt-get upgrade -y
echo "Update and upgrade completed."

# Split results
mountpoint="/mntsda/sda1"

echo "Largest mounted drive:"
echo "  Mount point: $mountpoint"

# Creating a backup of /etc/fstab
FSTAB="/etc/fstab"
FSTAB_BAK="/etc/fstab.bak.$(date +%F_%H-%M-%S)"
echo "Creating a backup of $FSTAB..."
cp "$FSTAB" "$FSTAB_BAK"
echo "Backup created at $FSTAB_BAK"

# Adds mount entry to /etc/fstab safely
LINE="$device $mountpoint ext4 defaults,noatime 0 1"
if grep -Fxq "$LINE" "$FSTAB"; then
  echo "The device is already set up to be mounted on every reboot. Skipping append."
else
  echo "Appending mount entry to $FSTAB..."
  printf "\n%s\n" "$LINE" >> "$FSTAB"
  echo "Done. The new entry was added to $FSTAB"
fi

# Install Samba
echo "Installing Samba..."
apt-get install samba samba-common-bin -y
echo "Samba installation completed."

# Configure Samba
SMB_CONF="/etc/samba/smb.conf"
SMB_CONF_BAK="/etc/samba/smb.conf.bak.$(date +%F_%H-%M-%S)"
echo "Backing up $SMB_CONF to $SMB_CONF_BAK..."
cp "$SMB_CONF" "$SMB_CONF_BAK"

# Create shared directory with appropriate permissions

DIR="$mountpoint/shared"

# Check if the directory exists
if [ ! -d "$DIR" ]; then
  echo "Directory $DIR does not exist. Creating..."
  mkdir -p "$DIR"
  echo "Directory created successfully."
else
  echo "Directory $DIR already exists."
fi

# Set permissions to allow read/write access for all users
chmod 0777 "$DIR"

SHARE_PATH="$mountpoint/shared"
mkdir -p "$SHARE_PATH"
chmod 0777 "$SHARE_PATH"

BLOCK=$(cat <<EOF
[shared]
path=$SHARE_PATH
writeable=Yes
create mask=0777
directory mask=0777
public=no
EOF
)

# Check if the [shared] section already exists
if grep -Fxq "[shared]" "$SMB_CONF"; then
  echo "The [shared] section already exists in smb.conf. Skipping append."
else
  echo "Appending [shared] section to smb.conf..."
  printf "\n%s\n" "$BLOCK" >> "$SMB_CONF"
  echo "Done. The new section was added."
fi

# Test Samba configuration
echo "Testing Samba configuration..."
if ! testparm -s; then
  echo "Samba configuration test failed. Please check $SMB_CONF."
  exit 1
fi

# Restart Samba service to apply changes
echo "Restarting Samba service..."  
systemctl restart smbd
echo "Samba service restarted."

# Add Samba user if not exists
SMB_USER="neburware-smb"
if id -u "$SMB_USER" >/dev/null 2>&1; then
  echo "User $SMB_USER already exists. Skipping user creation."
else
  echo "Adding Samba user $SMB_USER..." 
  adduser --no-create-home --disabled-password --gecos "" "$SMB_USER"
  echo "Set Samba password for $SMB_USER:"
  smbpasswd -a "$SMB_USER"
fi
echo "Setup complete."