# Cloud Torrent

An Ansible playbook to install a media centerin the cloud

Playbook includes the following

[https://plex.tv](https://plex.tv)

[https://github.com/Tautulli/Tautulli](https://github.com/Tautulli/Tautulli) 
A web interface for Plex providing additional info like stats

[https://github.com/jpillora/cloud-torrent](https://github.com/jpillora/cloud-torrent) 
DIY cloud torrent

## runs on ubuntu 18

### Things to do

- [ ] write task role installs deluge seedbox
- [ ] install plex drive - [https://github.com/plexdrive/plexdrive] (https://github.com/plexdrive/plexdrive)
- [ ] create nginx reverse proxy
- [ ] create Ansible task to issue Letsecrypt cert as well as revoke the cert if possible
- [ ] use Ansible to automate Cloudflare and point domain to server


### Ansible Usage

Ansisble gather facts

```
ansible -m setup all -i ../../../Ansible-Inventory/localhosts 
```
Ansible Ping

```
ansible all -m ping -i ../../../Ansible-Inventory/localhosts 
```

run complete Ansible playbook with vault encryption and path to password file set path accordingly

```
ansible-playbook provision.yml --vault-password-file=/home/$USER/ansible-PASSWORDS/MYPASSWORD.txt -i hosts -u root 
```

run ansible playbook with tags

```
ansible-playbook provision.yml --vault-password-file=/home/$USER/ansible-PASSWORDS/MYPASSWORD.txt --tags "tag1,tag2,etc" -i hosts -u root 

ansible-playbook provision.yml --vault-password-file=/home/$USER/ansible-PASSWORDS/MYPASSWORD.txt --tags "tag1,tag2,etc" -i ../../../Ansible-Inventory/hosts
```

run ansible start at a certain task
```
ansible-playbook provision.yml --vault-password-file=/home/$USER/ansible-PASSWORDS/MYPASSWORD.txt --start-at-task="This is the task name" -i hosts -u root

ansible-playbook provision.yml --vault-password-file=/home/$USER/ansible-PASSWORDS/MYPASSWORD.txt --start-at-task="This is the task name" 
```