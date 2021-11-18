# Create a python telegram bot as a service in Ubuntu

## Steps

### Create the bot

```python
#!/usr/bin/env python3
#env variables
import os
TOKEN = os.getenv('TOKEN')

# Enable logging
import logging
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)
logger = logging.getLogger(__name__)


from telegram import Update, chat
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, CallbackContext

def start(update: Update, context: CallbackContext) -> None:
    update.message.reply_text('hi')

def main():
    updater = Updater(TOKEN, use_context=True)
    dispatcher = updater.dispatcher
    dispatcher.add_handler(CommandHandler("start", start))

    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()
```

### add requirements

```bash
pip freeze > requirements.txt
```

### Add service file for systemd

```text
[Unit]
Description=Sample Python System Service

[Service]
WorkingDirectory=/usr/local/lib/bot/
Environment=PYTHONUNBUFFERED=1
EnvironmentFile=/usr/local/etc/bot/bot.env
ExecStart=/usr/local/lib/bot/venv/bin/python3 /usr/local/lib/bot/bot.py

Restart=on-failure

[Install]
WantedBy=default.target
```

### Create MakeFile

```makefile
all: bot bot.service
.PHONY: all bot install uninstall
lib_dir=/usr/local/lib/bot
conf_dir=/usr/local/etc/bot
service_dir=/etc/systemd/system
venv=${lib_dir}/venv

install: $(service_dir) bot.service
	@echo Installing the service files...
	cp bot.service $(service_dir)
	chown root:root $(service_dir)/bot.service
	chmod 644 $(service_dir)/bot.service

	@echo Installing library files...
	mkdir -p $(lib_dir)
	cp bot.py $(lib_dir)
	chown root:root $(lib_dir)/*
	chmod 644 $(lib_dir)

	@echo Installing configuration files...
	mkdir -p $(conf_dir)
	cp bot.env $(conf_dir)
	chown root:root $(conf_dir)/*
	chmod 644 $(conf_dir)

	@echo Creating python virtual environment and installing packages...
	python3 -m venv $(venv)
	$(venv)/bin/pip3 install -r requirements.txt

	@echo Installation complete...
	@echo run 'systemctl start bot' to start service
	@echo run 'systemctl status bot' to view status

uninstall:
	-systemctl stop bot
	-systemctl disable bot
	-rm -r $(lib_dir)
	-rm -r $(conf_dir)
	-rm -r $(service_dir)/bot.service
```

### Install the package

```bash
sudo make install
```

## Enable and start the service

```bash
sudo systemctl enable bot.service
sudo systemctl start bot.service
sudo systemctl status bot.service

```

## Logs

```bash
journalctl -r -u bot
```

## Cleanup

```bash
sudo make uninstall
```
