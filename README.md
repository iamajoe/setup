# Setup

Ansible machine setup.

## Requirements

- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [jq](https://jqlang.org/download/)

## Configuration

- `cp .env.dist .env`
- Change `.env` vars

### Custom projects

You can run a custom project by creating a `custom/project_name.yml` and add it to `PLAYBOOKS` environment variable inside the `.env` file.
You can follow [custom/project_example.yml](./custom/project_example.yml) as an example.

## Run

### With .env file

```sh
sh ./run.sh

# or

ENV_FILE=.env sh ./run.sh
```

## TODO

- [ ] [Setup i3](https://github.com/i3/i3)
- [ ] [Setup rofi](https://github.com/adi1090x/rofi)
- [ ] Chromium task and install on devvm
- [ ] Firefox task and install on devvm

## References

- [Mitchell nixos-config](https://github.com/mitchellh/nixos-config)
- [i3 ansible example](https://github.com/Mokkujin/i3-config-ansible)
- [i3 ansible example b](https://github.com/hypebeast/ansible-i3)
- [i3 config mouseless post](https://thevaluable.dev/i3-config-mouseless/)
