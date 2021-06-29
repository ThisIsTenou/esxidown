ESXi Auto Shutdown Script v1.0b
Tested on ESXi 5.1 through 5.5 (free)
-------------------------

This script can be used to help shut down virtual machines, for example, in the case of a power outage.
All virtual machines will be shutdown in parallel, this way the time needed for the full shutdown process is way faster.

Deploy the two scripts on an ESXi 5.1 (or greater) attached datastore.  The scripts are known to work up to ESXi 7.0.1.  Make sure they are executable (chmod +x) by the user who will be running the script.

By default, the script tries to shut down all guest VMs automatically, and waits 20 times for a duration of 10 seconds each time for each VM to shut down.  These settings are customizable in the script.

If a guest VM doesn't shut down cleanly, it is forcefully powered off.  You could change this, for example, and make it suspend instead of a forceful shutdown (vmsvc/power.suspend) - it's up to you.

The script can be run via SSH, and the virtual machines you specify (as well as the virtual host) will be shutdown using best effort.

You may consider running the script asynchronously using the async.sh script.  This will start an unstoppable shutdown and return control back to the shell.

This is useful if, for example, you are triggering the shutdown from another server using an SSH connection, and you do not want to rely on the connection staying open while the shutdown process completes.

For example, if you have a Windows box that can detect the UPS shutdown signal from your UPS, and want your ESXi host to shut down using these scripts:

You can use Putty's plink command on Windows to remotely call the script.  The script will execute asynchronously - once it starts, it cannot be stopped, and will succeed even if the SSH connection is closed - and ALL guests and the ESXi host will do their best to shut down, or power off.

If you don't want to use the password in the plink command, you can also use an SSH key.  Generate one using Putty's puttygen tool in Windows (no passphrase, DSA), and install a copy of your public key in the ESXi host's authorized keys file.  The key file can be found in /etc/ssh/keys-root/authorized_keys.

Then you can use a command like this with the private key on the Windows box (with SSH access enabled on ESXi):

C:\plink.exe -i "c:\<private key file>.ppk" root@<your ESXi hostname/IP> "sh /vmfs/volumes/<your datastore>/async.sh /vmfs/volumes/<your datastore>/esxidown.sh"
