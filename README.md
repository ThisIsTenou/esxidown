ESXi Auto Shutdown Script
-------------------------
Tested on ESXi 7.0.1 (Enterprise Plus).

Based on the work of [Jon Saltzman](https://github.com/sixdimensionalarray/esxidown), [Andriy Babak](https://github.com/ababak/esxidown) and [Sophware](https://github.com/sophware/esxidown).


**How does this script differ from the numerous, [other forks](https://github.com/sixdimensionalarray/esxidown/network/members)?**
-------------------------
* VM shutdown commands are run in parallel, greatly reducing the total time needed until the host can shut down.
* Command outputs are written to a log file
* Script- and log-locations are hardcoded, so they work best with my own environment. You need to change them manually.

**What are the different files for?**
-------------------------
The only interesting files are the two scripts, "esxidown.sh" and "async.sh".

**esxidown.sh** is the script doing all the magic. When called, it will put your ESXi-Host into maintenance mode, send a shutdown command to all running VMs, wait for them to shutdown and then proceed to shutdown the phyiscal host, leaving maintenance mode again in the meantime.
The "leaving maintenance mode"-part can technically fail, but at least in my experience, it's always been working fine and allows the VMs to autostart after the host has been brought up again.

**async.sh** is a tiny oneliner, which can call the esxidown.sh-script, executing it in the background instead of the current shell. This means that you can leave the (ssh-)session, without having to wait for the script to finish first. Using this is highly recommended, especially since there's nothing to see when running esxidown.sh manually anyways, all output is being sent to the logfile, not the console.

**How do I use it?**
-------------------------
1. Copy both "esxidown.sh" and "async.sh" onto the **datastore** of your ESXi hosts. You can either do this through vCenter's WebUI or via SFTP/SSH.
2. Make note of the full path of where you stored them and replace the paths in both scripts with the correct ones for your setup:
   * **async.sh line 4**: Replace "/vmfs/volumes/yourdatastore/esxidown.sh" with the full path to your esxidown.sh-script location.
   * **esxidown.sh line 5**: Replace "/vmfs/volumes/yourdatastore/esxidown.log" with the full path to where you want your logfile to be written to.
3. Make both scripts executable: `chmod +x esxidown.sh async.sh`
4. Congrats! You can now safely shutdown your ESXi host just by calling the async.sh-script.

**Important notes:**
* Make sure that both paths are the full paths, starting at root level. Also make sure that all subsequent directories for the log location exist, otherwise it'll fail to be created. You do not have to create the esxidown.log-file itself, though - just the path to it.
* **STORE THE FILES ON A DATASTORE**. Like, honestly. They gotta be on a datastore. If you just throw them into the root-directory, they will **NOT** survive a reboot. This applies to both the scripts and the logfile. A log doesn't help you if it's gone seconds after ;)


**I want to automate this to run when a power loss occurs. Is that possible?**
-------------------------
Certainly! In my setup, my monitoring software is calling these scripts via ssh on all hosts. Here are some command snippets you can base your automation on:

**Interactive oneliner:**
```
ssh root@esxi.lab.local '/bin/sh /vmfs/volumes/yourdatastore/async.sh'
```

**Non-interactive oneliner using authentication keys:**
```
ssh -i ./.ssh/my-key.pem root@esxi.lab.local '/bin/sh /vmfs/volumes/yourdatastore/async.sh'
```

**Non-Interactive expect-script using passwords:**
```
#!/usr/bin/expect
set host [lindex $argv 0]
set password [lindex $argv 1]

spawn ssh root@$host
expect {
  "Are you sure you want to continue connecting" {send "yes\r";exp_continue}
  "Password:" {send "$password\r";exp_continue}
}
expect ":~]"
send "/bin/sh /vmfs/volumes/yourdatastore/async.sh"
send "\r"
expect ":~]"
send "exit\r"
expect eof
```

