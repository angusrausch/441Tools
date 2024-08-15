# 441Tools
Tools for cab441 to make everyones life easier

## Starting

### Clone this repositry

Clone this repositry to your host VM with

```git clone git@github.com:angusrausch/441Tools.git```

### Copy config file
Copy the config file to .ssh directory to create aliases to make ssh easier to use 

```cp config ~/.ssh/```

You can now ssh into machines with 

```ssh extrouter```

Instead of using 

```ssh student@172.0.99.1``` 

Autofill will also work by typing the first couple letters and pressing TAB
> Introuter has multiple so you need to put the number you want to use at the end `introuter1`

### Generate SSH Key
```ssh-keygen -t rsa```

This will generate a private/public key pair to your machine in `.ssh`

This means once these are loaded onto machines you don't have to put your password in at all when connecting 
> `sudo` commands still require password

|Don't do this| These can be manually uploaded to each VM with `ssh-copy-id <hostname>`

Or use below tool

## SSH-Key-Sender

This is a tool to send ssh keys to all hosts in the config file automatically

This allows you to make one command and then can ssh into any VM without password authentication

### Installing dependencies

This requires `sshpass` to allow the password to be automatically inserted

```sudo apt install sshpass```

### Using tool

After installing dependencies to use the tool use

```bash ssh-key-sender.sh```

This will start the command and then it will ask for the config file path, we will use the default so press enter. It will then ask for the key file, again we are using the default so press enter (If you used something other than rsa you will have to input it here and I haven't tested it for that)

It will the ask if you have `sshpass` installed, type `y` then press enter. When prompted for password type `Student441` and press enter again.

It will then begin copying keys. Once this is done try using `ssh bastion` and you should connect straight to it without requiring your password

