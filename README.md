# Ansible dev docker

## Build

```bash
docker build --tag ansible-docker .
```

## Usage

By default, this control machine will assume the execution of an Ansible playbook.  To specify which playbook
to run, simply map the playbook into the container like so:

```bash
docker run -it --rm -v <absolute path to playbook>:/tmp/playbook:Z ansible-bdaas <playbook arguments>
```
