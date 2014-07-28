These are the configuration files I have created to allow me to use my system-installed kerberos and ssh for accessing the DoD's HPC network instead of the binaries from the HPCMP office.  To use them:

* krb5.conf
  1. Copy the file into your home directory as ~/.krb5
  2. Edit your ~/.bash_profile to export the appropriate variable:
    * ```export KRB5_CONFIG=$HOME/.krb5```
* ssh_config
  1. Merge the contents with your local ~/.ssh/config
  2. The first entry just shows how to exclude any global option you have from applying to the DoD HPC systems.
  3. The rest of the options should go at the end of your existing config.
    * Be sure to change the ```User`` option to specify your correct username
  4. Add or remove host shortcut entries as necessary / desired to specify the machines you have access to and accounts on.

After logging out and back in, you should now be able to log in:

```
[user@host ~]$ kinit mydodhpcusername@HPCMP.HPC.MIL
Password for mydodhpcusername@HPCMP.HPC.MIL: 
SAM Authentication
Challenge from authentication server
YubiKey Passcode: 
Warning: Your password will expire in 13 days on Mon 11 Aug 2014 10:05:41 AM EDT
[user@host ~]$ 
[user@host ~]$ 
[user@host ~]$ ssh spirit
...
[mydodhpcusername@spirit04 ~ ]$ 
```
